package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.util.Log
import com.lagradost.cloudstream3.MainAPI
import com.lagradost.cloudstream3.utils.ExtractorApi
import com.lagradost.cloudstream3.utils.extractorApis
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import java.io.File

/**
 * CloudStreamPluginRegistry manages the lifecycle of CloudStream plugins.
 * 
 * This class is responsible for:
 * - Maintaining a registry of loaded MainAPI instances keyed by sourceId
 * - Auto-loading plugins on initialization
 * - Providing access to MainAPI instances for method routing
 * - Managing extractor registration with the global extractorApis list
 */
class CloudStreamPluginRegistry(private val context: Context) {

    companion object {
        private const val TAG = "CloudStreamPluginRegistry"
        
        @Volatile
        private var instance: CloudStreamPluginRegistry? = null

        fun getInstance(context: Context): CloudStreamPluginRegistry {
            return instance ?: synchronized(this) {
                instance ?: CloudStreamPluginRegistry(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }

    private val pluginLoader = CloudStreamPluginLoader(context)
    private val pluginStore = CloudStreamPluginStore(context)
    private val mutex = Mutex()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    // Registry of MainAPI instances keyed by sourceId (internalName)
    private val apiRegistry = mutableMapOf<String, MainAPI>()
    private val pluginApis = mutableMapOf<String, List<MainAPI>>()

    // Track which extractors we've added to the global list
    private val registeredExtractors = mutableSetOf<ExtractorApi>()

    // Initialization state
    @Volatile
    private var isInitialized = false

    /**
     * Initialize the registry by loading all installed plugins.
     * This should be called once when the bridge is attached.
     */
    suspend fun initialize() = mutex.withLock {
        if (isInitialized) {
            Log.d(TAG, "Registry already initialized")
            return@withLock
        }

        withContext(Dispatchers.IO) {
            try {
                Log.i(TAG, "Initializing CloudStream plugin registry...")

                val plugins = pluginStore.listPlugins()
                var loadedCount = 0

                for (plugin in plugins) {
                    if (plugin.status != CloudStreamPluginStatus.INSTALLED) continue

                    val localPath = plugin.localPath
                    if (localPath.isNullOrBlank()) {
                        Log.w(TAG, "Plugin ${plugin.internalName} has no local path, skipping")
                        continue
                    }

                    val pluginDir = File(localPath)
                    if (!pluginDir.exists()) {
                        Log.w(TAG, "Plugin directory does not exist for ${plugin.internalName}, skipping")
                        continue
                    }

                    val loaded = pluginLoader.loadPlugin(pluginDir, plugin.internalName)
                    if (loaded != null) {
                        registerPlugin(loaded)
                        loadedCount++
                    }
                }

                isInitialized = true
                Log.i(TAG, "Registry initialized with $loadedCount plugins")
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing registry: ${e.message}", e)
            }
        }
    }

    /**
     * Register a loaded plugin in the registry.
     */
    private fun registerPlugin(loadedPlugin: LoadedPlugin) {
        val internalName = loadedPlugin.internalName
        val mainApis = loadedPlugin.mainApis

        if (mainApis.isEmpty()) {
            Log.w(TAG, "Plugin $internalName registered without MainAPIs; skipping")
        }

        pluginApis[internalName] = mainApis
        for (api in mainApis) {
            apiRegistry[api.name] = api
            Log.d(TAG, "Registered MainAPI: ${api.name} (${internalName})")
        }

        // Register extractors with the global list
        for (extractor in loadedPlugin.extractors) {
            if (!registeredExtractors.contains(extractor)) {
                extractorApis.add(extractor)
                registeredExtractors.add(extractor)
                Log.d(TAG, "Registered extractor: ${extractor.name} from plugin $internalName")
            }
        }
    }

    /**
     * Unregister a plugin from the registry.
     */
    private fun unregisterPlugin(internalName: String) {
        val apisForPlugin = pluginApis.remove(internalName) ?: emptyList()
        for (api in apisForPlugin) {
            apiRegistry.entries.removeIf { it.value == api }
        }

        // Remove extractors from global list
        val extractorsToRemove = registeredExtractors.filter { it.sourcePlugin == internalName }
        for (extractor in extractorsToRemove) {
            extractorApis.remove(extractor)
            registeredExtractors.remove(extractor)
        }

        Log.d(TAG, "Unregistered plugin: $internalName")
    }

    /**
     * Load and register a new plugin.
     * 
     * @param pluginDir The directory containing the extracted plugin
     * @param internalName The unique identifier for this plugin
     * @return true if the plugin was loaded successfully
     */
    suspend fun loadAndRegisterPlugin(pluginDir: File, internalName: String): Boolean = mutex.withLock {
        try {
            val loaded = pluginLoader.loadPlugin(pluginDir, internalName)
            if (loaded != null) {
                registerPlugin(loaded)
                return@withLock true
            }
            false
        } catch (e: Exception) {
            Log.e(TAG, "Error loading plugin $internalName: ${e.message}", e)
            false
        }
    }

    /**
     * Unload and unregister a plugin.
     * 
     * @param internalName The unique identifier of the plugin to unload
     * @return true if the plugin was unloaded successfully
     */
    suspend fun unloadAndUnregisterPlugin(internalName: String): Boolean = mutex.withLock {
        try {
            unregisterPlugin(internalName)
            pluginLoader.unloadPlugin(internalName)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error unloading plugin $internalName: ${e.message}", e)
            false
        }
    }

    /**
     * Get a MainAPI instance by sourceId (internalName).
     */
    fun getMainApi(sourceId: String): MainAPI? {
        return apiRegistry[sourceId]
            ?: apiRegistry.values.firstOrNull { it.name.equals(sourceId, ignoreCase = true) }
    }

    /**
     * Get all registered MainAPI instances.
     */
    fun getAllMainApis(): Map<String, MainAPI> {
        return apiRegistry.toMap()
    }

    /**
     * Get all registered MainAPI instances as a list.
     */
    fun getAllMainApisList(): List<MainAPI> {
        return apiRegistry.values.toList()
    }

    /**
     * Check if a plugin is registered.
     */
    fun isPluginRegistered(sourceId: String): Boolean {
        return apiRegistry.containsKey(sourceId)
    }

    /**
     * Get the count of registered plugins.
     */
    fun getRegisteredPluginCount(): Int {
        return apiRegistry.size
    }

    /**
     * Get all extractors from registered plugins.
     */
    fun getPluginExtractors(): List<ExtractorApi> {
        return registeredExtractors.toList()
    }

    /**
     * Reload all plugins from the store.
     */
    suspend fun reloadAllPlugins(): Int = mutex.withLock {
        withContext(Dispatchers.IO) {
            try {
                // Clear existing registrations
                for (internalName in apiRegistry.keys.toList()) {
                    unregisterPlugin(internalName)
                }
                apiRegistry.clear()

                // Reload from store
                val loadedPlugins = pluginLoader.reloadAllPlugins(pluginStore)
                for (loaded in loadedPlugins) {
                    registerPlugin(loaded)
                }

                Log.i(TAG, "Reloaded ${loadedPlugins.size} plugins")
                loadedPlugins.size
            } catch (e: Exception) {
                Log.e(TAG, "Error reloading plugins: ${e.message}", e)
                0
            }
        }
    }

    /**
     * Clear all registered plugins.
     */
    suspend fun clearAll() = mutex.withLock {
        withContext(Dispatchers.IO) {
            // Remove all extractors from global list
            for (extractor in registeredExtractors) {
                extractorApis.remove(extractor)
            }
            registeredExtractors.clear()
            apiRegistry.clear()
            pluginLoader.clearAll()
            isInitialized = false
            Log.i(TAG, "Cleared all registered plugins")
        }
    }

    /**
     * Get plugin metadata for a registered plugin.
     */
    suspend fun getPluginMetadata(sourceId: String): CloudStreamPluginMetadata? {
        return pluginStore.getPlugin(sourceId)
    }

    /**
     * List all plugin metadata from the store.
     */
    suspend fun listAllPluginMetadata(): List<CloudStreamPluginMetadata> {
        return pluginStore.listPlugins()
    }

    /**
     * Get the plugin store instance.
     */
    fun getPluginStore(): CloudStreamPluginStore {
        return pluginStore
    }

    /**
     * Get the plugin loader instance.
     */
    fun getPluginLoader(): CloudStreamPluginLoader {
        return pluginLoader
    }

    /**
     * Check if the registry is initialized.
     */
    fun isInitialized(): Boolean {
        return isInitialized
    }
}

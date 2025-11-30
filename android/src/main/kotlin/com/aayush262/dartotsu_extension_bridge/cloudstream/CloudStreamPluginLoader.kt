package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.util.Log
import com.lagradost.cloudstream3.APIHolder
import com.lagradost.cloudstream3.MainAPI
import com.lagradost.cloudstream3.plugins.BasePlugin
import com.lagradost.cloudstream3.plugins.Plugin
import com.lagradost.cloudstream3.utils.ExtractorApi
import com.lagradost.cloudstream3.utils.extractorApis
import dalvik.system.DexClassLoader
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.io.File

/**
 * CloudStreamPluginLoader handles loading plugin DEX files using DexClassLoader.
 * 
 * This class is responsible for:
 * - Loading classes.dex from installed plugin bundles
 * - Parsing manifest.json to find the plugin class name
 * - Instantiating MainAPI implementations
 * - Registering extractors from plugins
 */
class CloudStreamPluginLoader(private val context: Context) {

    companion object {
        private const val TAG = "CloudStreamPluginLoader"
        private const val DEX_FILE_NAME = "classes.dex"
        private const val MANIFEST_FILE_NAME = "manifest.json"
    }

    private val json = Json { ignoreUnknownKeys = true }
    private val mutex = Mutex()

    // Cache of loaded DexClassLoaders keyed by plugin internalName
    private val classLoaderCache = mutableMapOf<String, DexClassLoader>()

    // Cache of loaded MainAPI instances keyed by plugin internalName
    private val mainApiCache = mutableMapOf<String, List<MainAPI>>()

    // Cache of loaded ExtractorApi instances from plugins
    private val extractorCache = mutableMapOf<String, MutableList<ExtractorApi>>()

    /**
     * Load a plugin from its extracted directory.
     * 
     * @param pluginDir The directory containing the extracted plugin files
     * @param internalName The unique identifier for this plugin
     * @return LoadedPlugin containing the MainAPI instance and any extractors, or null if loading fails
     */
    suspend fun loadPlugin(pluginDir: File, internalName: String): LoadedPlugin? = mutex.withLock {
        withContext(Dispatchers.IO) {
            try {
                // Check if already loaded
                mainApiCache[internalName]?.let { mainApis ->
                    Log.d(TAG, "Plugin $internalName already loaded, returning cached instance")
                    return@withContext LoadedPlugin(
                        mainApis = mainApis,
                        extractors = extractorCache[internalName] ?: emptyList(),
                        internalName = internalName
                    )
                }

                // Validate plugin directory
                if (!pluginDir.exists() || !pluginDir.isDirectory) {
                    Log.e(TAG, "Plugin directory does not exist: ${pluginDir.absolutePath}")
                    return@withContext null
                }

                // Read manifest
                val manifest = readManifest(pluginDir)
                if (manifest == null) {
                    Log.e(TAG, "Failed to read manifest for plugin $internalName")
                    return@withContext null
                }

                // Find DEX file
                val dexFile = findDexFile(pluginDir)
                if (dexFile == null) {
                    Log.e(TAG, "No DEX file found for plugin $internalName")
                    return@withContext null
                }

                // Create optimized DEX output directory
                val optimizedDir = File(context.codeCacheDir, "cloudstream_dex/$internalName")
                if (!optimizedDir.exists()) {
                    optimizedDir.mkdirs()
                }

                // Create DexClassLoader
                val classLoader = DexClassLoader(
                    dexFile.absolutePath,
                    optimizedDir.absolutePath,
                    null,
                    context.classLoader
                )
                classLoaderCache[internalName] = classLoader

                val pluginClassName = manifest.pluginClassName
                if (pluginClassName.isNullOrBlank()) {
                    Log.e(TAG, "Plugin class name not specified in manifest for $internalName")
                    return@withContext null
                }

                val basePlugin = instantiatePlugin(classLoader, pluginClassName, internalName) ?: run {
                    Log.e(TAG, "Failed to instantiate plugin class $pluginClassName for $internalName")
                    return@withContext null
                }

                // Ensure we can capture what the plugin registers
                val beforeProviders = snapshotRegisteredApis()
                val beforeExtractors = snapshotRegisteredExtractors()

                basePlugin.filename = pluginDir.absolutePath

                if (basePlugin is Plugin) {
                    basePlugin.load(context)
                } else {
                    basePlugin.load()
                }

                val newlyRegisteredApis = snapshotRegisteredApis().subtract(beforeProviders)
                if (newlyRegisteredApis.isEmpty()) {
                    Log.w(TAG, "Plugin $internalName registered no MainAPI providers")
                }

                val newlyRegisteredExtractors = snapshotRegisteredExtractors().subtract(beforeExtractors)
                if (newlyRegisteredExtractors.isNotEmpty()) {
                    extractorCache[internalName] = newlyRegisteredExtractors.toMutableList()
                }

                mainApiCache[internalName] = newlyRegisteredApis.toList()

                Log.i(
                    TAG,
                    "Successfully loaded plugin $internalName with ${newlyRegisteredApis.size} providers and ${newlyRegisteredExtractors.size} extractors"
                )

                LoadedPlugin(
                    mainApis = newlyRegisteredApis.toList(),
                    extractors = newlyRegisteredExtractors.toList(),
                    internalName = internalName
                )
            } catch (t: Throwable) {
                Log.e(TAG, "Error loading plugin $internalName: ${t.message}", t)
                null
            }
        }
    }

    /**
     * Unload a plugin and clean up resources.
     */
    suspend fun unloadPlugin(internalName: String): Boolean = mutex.withLock {
        withContext(Dispatchers.IO) {
            try {
                mainApiCache.remove(internalName)
                classLoaderCache.remove(internalName)
                extractorCache.remove(internalName)

                // Clean up optimized DEX directory
                val optimizedDir = File(context.codeCacheDir, "cloudstream_dex/$internalName")
                if (optimizedDir.exists()) {
                    optimizedDir.deleteRecursively()
                }

                Log.i(TAG, "Unloaded plugin $internalName")
                true
            } catch (e: Exception) {
                Log.e(TAG, "Error unloading plugin $internalName: ${e.message}", e)
                false
            }
        }
    }

    /**
     * Get a loaded MainAPI instance by internal name.
     */
    fun getMainApi(internalName: String): MainAPI? {
        return mainApiCache[internalName]?.firstOrNull()
    }

    /**
     * Get all loaded MainAPI instances.
     */
    fun getAllMainApis(): Map<String, MainAPI> {
        return mainApiCache.mapNotNull { (key, apis) ->
            apis.firstOrNull()?.let { key to it }
        }.toMap()
    }

    /**
     * Get extractors from a specific plugin.
     */
    fun getExtractors(internalName: String): List<ExtractorApi> {
        return extractorCache[internalName] ?: emptyList()
    }

    /**
     * Get all extractors from all loaded plugins.
     */
    fun getAllExtractors(): List<ExtractorApi> {
        return extractorCache.values.flatten()
    }

    /**
     * Check if a plugin is loaded.
     */
    fun isPluginLoaded(internalName: String): Boolean {
        return mainApiCache.containsKey(internalName)
    }

    /**
     * Get the count of loaded plugins.
     */
    fun getLoadedPluginCount(): Int {
        return mainApiCache.size
    }

    private fun readManifest(pluginDir: File): PluginManifest? {
        val manifestFile = File(pluginDir, MANIFEST_FILE_NAME)
        if (!manifestFile.exists()) {
            // Try to find manifest in subdirectories
            pluginDir.walkTopDown().maxDepth(2).forEach { file ->
                if (file.name == MANIFEST_FILE_NAME && file.isFile) {
                    return parseManifest(file)
                }
            }
            return null
        }
        return parseManifest(manifestFile)
    }

    private fun parseManifest(manifestFile: File): PluginManifest? {
        return try {
            json.decodeFromString(PluginManifest.serializer(), manifestFile.readText())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to parse manifest: ${e.message}", e)
            null
        }
    }

    private fun findDexFile(pluginDir: File): File? {
        // First check root directory
        val rootDex = File(pluginDir, DEX_FILE_NAME)
        if (rootDex.exists()) {
            return rootDex
        }

        // Search in subdirectories
        pluginDir.walkTopDown().maxDepth(3).forEach { file ->
            if (file.name.endsWith(".dex", ignoreCase = true) && file.isFile) {
                return file
            }
        }

        return null
    }

    private fun instantiatePlugin(
        classLoader: DexClassLoader,
        className: String,
        internalName: String
    ): BasePlugin? {
        return try {
            val clazz = classLoader.loadClass(className)
            val instance = clazz.getDeclaredConstructor().newInstance()
            if (instance is BasePlugin) {
                instance
            } else {
                Log.e(TAG, "Class $className is not a BasePlugin for $internalName")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error instantiating plugin class $className for $internalName: ${e.message}", e)
            null
        }
    }

    private fun snapshotRegisteredApis(): Set<MainAPI> {
        return synchronized(APIHolder.allProviders) {
            APIHolder.allProviders.toSet()
        }
    }

    private fun snapshotRegisteredExtractors(): Set<ExtractorApi> {
        return extractorApis.toSet()
    }

    /**
     * Reload all plugins from the plugin store.
     */
    suspend fun reloadAllPlugins(pluginStore: CloudStreamPluginStore): List<LoadedPlugin> {
        val loadedPlugins = mutableListOf<LoadedPlugin>()

        val plugins = pluginStore.listPlugins()
        for (plugin in plugins) {
            if (plugin.status != CloudStreamPluginStatus.INSTALLED) continue
            
            val localPath = plugin.localPath ?: continue
            val pluginDir = File(localPath)
            
            val loaded = loadPlugin(pluginDir, plugin.internalName)
            if (loaded != null) {
                loadedPlugins.add(loaded)
            }
        }

        Log.i(TAG, "Reloaded ${loadedPlugins.size} plugins")
        return loadedPlugins
    }

    /**
     * Clear all cached plugins.
     */
    suspend fun clearAll() = mutex.withLock {
        withContext(Dispatchers.IO) {
            mainApiCache.clear()
            classLoaderCache.clear()
            extractorCache.clear()

            // Clean up all optimized DEX directories
            val dexCacheDir = File(context.codeCacheDir, "cloudstream_dex")
            if (dexCacheDir.exists()) {
                dexCacheDir.deleteRecursively()
            }

            Log.i(TAG, "Cleared all cached plugins")
        }
    }
}

/**
 * Represents a successfully loaded plugin.
 */
data class LoadedPlugin(
    val mainApis: List<MainAPI>,
    val extractors: List<ExtractorApi>,
    val internalName: String
)

/**
 * Plugin manifest structure.
 */
@Serializable
data class PluginManifest(
    val name: String? = null,
    val pluginClassName: String? = null,
    val version: Int? = null,
    val requiresResources: Boolean? = null,
    val extractorClasses: List<String>? = null,
    val repositoryUrl: String? = null,
    val authors: List<String>? = null,
    val description: String? = null,
    val tvTypes: List<String>? = null,
    val language: String? = null,
    val iconUrl: String? = null,
    val status: Int? = null
)

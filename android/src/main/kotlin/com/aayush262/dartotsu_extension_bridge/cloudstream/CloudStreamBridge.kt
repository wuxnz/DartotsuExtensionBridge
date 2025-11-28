package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.zip.ZipInputStream

/**
 * CloudStreamBridge is the main MethodChannel handler for CloudStream plugin operations.
 * 
 * This class integrates:
 * - CloudStreamPluginStore: Persistent storage for plugin metadata
 * - CloudStreamPluginLoader: DexClassLoader-based plugin loading
 * - CloudStreamPluginRegistry: MainAPI instance registry
 * - CloudStreamApiRouter: Method routing to loaded plugins
 * - CloudStreamExtractorService: Video extractor invocations
 */
class CloudStreamBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "CloudStreamBridge"
        private const val CLOUDSTREAM_PACKAGE_PREFIX = "com.lagradost"
    }

    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val pluginStore = CloudStreamPluginStore(context)
    private val pluginRegistry = CloudStreamPluginRegistry.getInstance(context)
    private val apiRouter = CloudStreamApiRouter(context)
    private val extractorService = CloudStreamExtractorService.getInstance(context)
    private val httpClient by lazy { OkHttpClient() }
    private val json = Json { ignoreUnknownKeys = true }

    @Volatile
    private var isInitialized = false

    init {
        // Initialize the plugin registry asynchronously
        ioScope.launch {
            try {
                pluginRegistry.initialize()
                apiRouter.initialize()
                isInitialized = true
                Log.i(TAG, "CloudStreamBridge initialized with ${pluginRegistry.getRegisteredPluginCount()} plugins")
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing CloudStreamBridge: ${e.message}", e)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "Method called: ${call.method} with args: ${call.arguments}")
        
        // First, try to route to the API router for cloudstream:* methods
        if (apiRouter.handleMethodCall(call, result)) {
            return
        }
        
        // Handle other methods
        when (call.method) {
            "getInstalledAnimeExtensions" -> getInstalledExtensions(1, result)
            "getInstalledMangaExtensions" -> getInstalledExtensions(0, result)
            "getInstalledNovelExtensions" -> getInstalledExtensions(2, result)
            "getInstalledMovieExtensions" -> getInstalledExtensions(3, result)
            "getInstalledTvShowExtensions" -> getInstalledExtensions(4, result)
            "getInstalledCartoonExtensions" -> getInstalledExtensions(5, result)
            "getInstalledDocumentaryExtensions" -> getInstalledExtensions(6, result)
            "getInstalledLivestreamExtensions" -> getInstalledExtensions(7, result)
            "getInstalledNsfwExtensions" -> getInstalledExtensions(8, result)
            "fetchAnimeExtensions" -> fetchExtensions(1, call, result)
            "fetchMangaExtensions" -> fetchExtensions(0, call, result)
            "fetchNovelExtensions" -> fetchExtensions(2, call, result)
            "fetchMovieExtensions" -> fetchExtensions(3, call, result)
            "fetchTvShowExtensions" -> fetchExtensions(4, call, result)
            "fetchCartoonExtensions" -> fetchExtensions(5, call, result)
            "fetchDocumentaryExtensions" -> fetchExtensions(6, call, result)
            "fetchLivestreamExtensions" -> fetchExtensions(7, call, result)
            "fetchNsfwExtensions" -> fetchExtensions(8, call, result)
            "installCloudStreamPlugin" -> installCloudStreamPlugin(call, result)
            "uninstallCloudStreamPlugin" -> uninstallCloudStreamPlugin(call, result)
            "listInstalledCloudStreamPlugins" -> listInstalledCloudStreamPlugins(result)
            "initializePlugins" -> initializePlugins(result)
            "getPluginStatus" -> getPluginStatus(result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * Initialize or reinitialize all plugins.
     */
    private fun initializePlugins(result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val count = pluginRegistry.reloadAllPlugins()
                isInitialized = true
                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "success" to true,
                        "loadedCount" to count,
                        "extractorCount" to extractorService.getExtractorCount()
                    ))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing plugins: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("INIT_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }
    
    /**
     * Get the current plugin status.
     */
    private fun getPluginStatus(result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val status = mapOf(
                    "isInitialized" to isInitialized,
                    "registeredPluginCount" to pluginRegistry.getRegisteredPluginCount(),
                    "extractorCount" to extractorService.getExtractorCount(),
                    "loadedPlugins" to pluginRegistry.getAllMainApis().map { (id, api) ->
                        mapOf(
                            "id" to id,
                            "name" to api.name,
                            "mainUrl" to api.mainUrl,
                            "lang" to api.lang
                        )
                    }
                )
                withContext(Dispatchers.Main) {
                    result.success(status)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error getting plugin status: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("STATUS_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun installCloudStreamPlugin(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
            ?: return result.error("INVALID_ARGS", "Expected metadata map", null)

        val metadataPayload = (args["metadata"] as? Map<*, *>) ?: args
        val repoKey = args["repoKey"]?.toString()

        val metadataMap = metadataPayload.entries.associate { it.key.toString() to it.value }
        val metadata = try {
            metadataMap.toCloudStreamPluginMetadata()
        } catch (t: Throwable) {
            result.error("INVALID_METADATA", t.message, null)
            return
        }

        val downloadUrl = metadata.downloadUrl
            ?: return result.error("MISSING_URL", "Plugin downloadUrl is required", null)

        val extension = when {
            downloadUrl.endsWith(".zip", true) -> "zip"
            downloadUrl.endsWith(".cs3", true) -> "cs3"
            downloadUrl.endsWith(".apk", true) -> "apk"
            else -> "cs3"
        }

        if (extension == "apk") {
            result.error("UNSUPPORTED", "APK plugins must be installed via PackageManager", null)
            return
        }

        ioScope.launch {
            try {
                val bundlePath = pluginStore.resolveBundlePath(repoKey, metadata.internalName, extension)
                downloadTo(bundlePath, downloadUrl)

                val extractedDir = extractBundle(bundlePath, metadata.internalName, repoKey)
                val manifest = readManifest(extractedDir)
                prepareDexFiles(extractedDir, metadata.internalName)

                val saved = pluginStore.upsertPlugin(
                    metadata.copy(
                        version = manifest?.version?.toString() ?: metadata.version,
                        localPath = extractedDir.absolutePath,
                    ),
                )

                // Load the plugin into the registry after installation
                val loadSuccess = pluginRegistry.loadAndRegisterPlugin(extractedDir, metadata.internalName)
                Log.i(TAG, "Plugin ${metadata.internalName} loaded: $loadSuccess")

                withContext(Dispatchers.Main) {
                    result.success(saved.toMetadataPayload().plus(
                        "loaded" to loadSuccess
                    ))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed installing plugin ${metadata.internalName}: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("INSTALL_FAILED", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun uninstallCloudStreamPlugin(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
            ?: return result.error("INVALID_ARGS", "Expected map with internalName", null)

        val internalName = (args["internalName"] ?: args["sourceId"])?.toString()
            ?: return result.error("MISSING_ID", "internalName/sourceId is required", null)

        ioScope.launch {
            try {
                // Unload the plugin from the registry first
                pluginRegistry.unloadAndUnregisterPlugin(internalName)
                
                // Then remove from storage
                val removed = pluginStore.removePlugin(internalName)
                Log.i(TAG, "Plugin $internalName uninstalled: $removed")

                withContext(Dispatchers.Main) {
                    result.success(removed)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed removing plugin $internalName: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("UNINSTALL_FAILED", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun listInstalledCloudStreamPlugins(result: MethodChannel.Result) {
        ioScope.launch {
            val plugins = runCatching { pluginStore.listPlugins() }
                .onFailure { Log.e(TAG, "Failed listing plugins", it) }
                .getOrDefault(emptyList())
                .map { it.toMetadataPayload() }

            withContext(Dispatchers.Main) {
                result.success(plugins)
            }
        }
    }

    private fun getInstalledExtensions(itemType: Int, result: MethodChannel.Result) {
        ioScope.launch {
            val pluginBacked = runCatching {
                pluginStore.listPlugins()
                    .filter { it.matchesItemType(itemType) }
                    .map { it.toInstalledSourcePayload(itemType) }
            }.onFailure {
                Log.e(TAG, "Error pulling plugin metadata: ${it.message}", it)
            }.getOrNull()

            if (!pluginBacked.isNullOrEmpty()) {
                withContext(Dispatchers.Main) {
                    result.success(pluginBacked)
                    Log.d(TAG, "Returned ${pluginBacked.size} plugin-backed extensions for itemType $itemType")
                }
                return@launch
            }

            // Legacy fallback: scan installed packages
            try {
                val packageManager = context.packageManager
                val installedPackages = packageManager.getInstalledPackages(PackageManager.GET_META_DATA)

                val cloudStreamExtensions = installedPackages
                    .filter { pkg ->
                        pkg.packageName.startsWith(CLOUDSTREAM_PACKAGE_PREFIX) &&
                            pkg.packageName != "com.lagradost.cloudstream3"
                    }
                    .mapNotNull { pkg ->
                        try {
                            parseExtensionMetadata(pkg, itemType, packageManager)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing extension ${pkg.packageName}: ${e.message}", e)
                            null
                        }
                    }

                withContext(Dispatchers.Main) {
                    result.success(cloudStreamExtensions)
                    Log.d(TAG, "Returned ${cloudStreamExtensions.size} legacy extensions for itemType $itemType")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error getting installed extensions: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.success(emptyList<Map<String, Any?>>())
                }
            }
        }
    }

    private fun fetchExtensions(itemType: Int, call: MethodCall, result: MethodChannel.Result) {
        // CloudStream extensions are fetched via HTTP in the Dart layer
        // This method is here for interface compatibility but returns empty list
        // as the native layer doesn't handle repository fetching for CloudStream
        CoroutineScope(Dispatchers.IO).launch {
            try {
                withContext(Dispatchers.Main) {
                    result.success(emptyList<Map<String, Any?>>())
                    Log.d(TAG, "fetchExtensions called but handled in Dart layer")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in fetchExtensions: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.success(emptyList<Map<String, Any?>>())
                }
            }
        }
    }

    private fun parseExtensionMetadata(
        pkg: PackageInfo,
        itemType: Int,
        packageManager: PackageManager
    ): Map<String, Any?> {
        val appInfo = pkg.applicationInfo ?: return emptyMap()
        val name = packageManager.getApplicationLabel(appInfo).toString()
        val version = pkg.versionName ?: "Unknown"
        val packageName = pkg.packageName
        
        // Extract icon as base64 or URL if available
        val iconUrl = try {
            // For now, we'll use a placeholder or extract from metadata if available
            val icon = packageManager.getApplicationIcon(appInfo)
            // In a real implementation, you might convert the drawable to base64
            // For now, return null and let the Dart layer handle default icons
            null
        } catch (e: Exception) {
            Log.e(TAG, "Error getting icon for $packageName: ${e.message}")
            null
        }

        // Extract language from package name or metadata
        // CloudStream extensions typically have language in their package name
        val lang = extractLanguageFromPackage(packageName)
        
        // Check if NSFW from metadata or package name
        val isNsfw = appInfo.metaData?.getBoolean("nsfw", false) ?: false

        return mapOf(
            "id" to packageName,
            "name" to name,
            "lang" to lang,
            "isNsfw" to isNsfw,
            "iconUrl" to iconUrl,
            "version" to version,
            "itemType" to itemType,
            "hasUpdate" to false,
            "isObsolete" to false
        )
    }

    private fun extractLanguageFromPackage(packageName: String): String {
        // Try to extract language code from package name
        // CloudStream extensions often follow pattern: com.lagradost.{provider}{lang}
        // Examples: com.lagradost.gogoanime -> "en", com.lagradost.animeflven -> "es"
        
        // Common language patterns in CloudStream extensions
        val langPatterns = mapOf(
            "en" to listOf("en", "english"),
            "es" to listOf("es", "spanish", "latino"),
            "fr" to listOf("fr", "french"),
            "de" to listOf("de", "german"),
            "it" to listOf("it", "italian"),
            "pt" to listOf("pt", "portuguese", "br"),
            "ru" to listOf("ru", "russian"),
            "ja" to listOf("ja", "japanese"),
            "ko" to listOf("ko", "korean"),
            "zh" to listOf("zh", "chinese"),
            "ar" to listOf("ar", "arabic"),
            "hi" to listOf("hi", "hindi"),
            "id" to listOf("id", "indonesian"),
            "tr" to listOf("tr", "turkish"),
            "vi" to listOf("vi", "vietnamese")
        )

        val lowerPackage = packageName.lowercase()
        
        for ((code, patterns) in langPatterns) {
            if (patterns.any { lowerPackage.contains(it) }) {
                return code
            }
        }
        
        // Default to English if no language detected
        return "en"
    }

    private fun downloadTo(destination: File, url: String) {
        if (!destination.parentFile.exists()) destination.parentFile.mkdirs()

        val request = Request.Builder().url(url).build()
        httpClient.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException("HTTP ${response.code} while downloading plugin")
            }

            val body = response.body ?: throw IOException("Empty response body")
            destination.outputStream().use { output ->
                body.byteStream().use { input ->
                    input.copyTo(output)
                }
            }
            Log.d(TAG, "Downloaded plugin bundle to ${destination.absolutePath}")
        }
    }

    private fun extractBundle(bundle: File, internalName: String, repoKey: String?): File {
        val pluginDir = pluginStore.resolvePluginDirectory(repoKey, internalName)
        if (pluginDir.exists()) {
            pluginDir.deleteRecursively()
        }
        pluginDir.mkdirs()

        ZipInputStream(BufferedInputStream(FileInputStream(bundle))).use { zipStream ->
            var entry = zipStream.nextEntry
            while (entry != null) {
                val outFile = File(pluginDir, entry.name)
                if (entry.isDirectory) {
                    outFile.mkdirs()
                } else {
                    outFile.parentFile?.mkdirs()
                    FileOutputStream(outFile).use { output ->
                        zipStream.copyTo(output)
                    }
                }
                zipStream.closeEntry()
                entry = zipStream.nextEntry
            }
        }

        return pluginDir
    }

    private fun readManifest(pluginDir: File): PluginManifest? {
        val manifestFile = File(pluginDir, "manifest.json")
        if (!manifestFile.exists()) return null

        return runCatching {
            json.decodeFromString(PluginManifest.serializer(), manifestFile.readText())
        }.onFailure {
            Log.e(TAG, "Failed to parse manifest for ${pluginDir.name}: ${it.message}", it)
        }.getOrNull()
    }

    private fun prepareDexFiles(pluginDir: File, internalName: String) {
        val dexDir = File(context.codeCacheDir, "cloudstream/$internalName")
        if (dexDir.exists()) {
            dexDir.deleteRecursively()
        }
        dexDir.mkdirs()

        pluginDir.walkTopDown()
            .filter { it.isFile && it.extension.equals("dex", ignoreCase = true) }
            .forEach { dexFile ->
                val target = File(dexDir, dexFile.name)
                dexFile.copyTo(target, overwrite = true)
                target.setReadOnly()
            }
    }

    @Serializable
    data class PluginManifest(
        val name: String? = null,
        val pluginClassName: String? = null,
        val version: Int? = null,
        val requiresResources: Boolean? = null,
    )
}

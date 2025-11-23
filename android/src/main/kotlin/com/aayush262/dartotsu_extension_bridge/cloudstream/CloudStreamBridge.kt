package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class CloudStreamBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "CloudStreamBridge"
        private const val CLOUDSTREAM_PACKAGE_PREFIX = "com.lagradost"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "Method called: ${call.method} with args: ${call.arguments}")
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
            else -> result.notImplemented()
        }
    }

    private fun getInstalledExtensions(itemType: Int, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val packageManager = context.packageManager
                val installedPackages = packageManager.getInstalledPackages(PackageManager.GET_META_DATA)
                
                val cloudStreamExtensions = installedPackages
                    .filter { pkg ->
                        // Filter for CloudStream extensions
                        pkg.packageName.startsWith(CLOUDSTREAM_PACKAGE_PREFIX) &&
                        pkg.packageName != "com.lagradost.cloudstream3" // Exclude main app
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
                    Log.d(TAG, "Returned ${cloudStreamExtensions.size} installed extensions for itemType $itemType")
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
}

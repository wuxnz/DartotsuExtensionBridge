package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.util.Log
import com.lagradost.cloudstream3.*
import com.lagradost.cloudstream3.utils.ExtractorLink
import android.util.Base64
import kotlin.text.Charsets
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File

/**
 * CloudStreamApiRouter handles routing of MethodChannel calls to the appropriate
 * MainAPI methods on loaded CloudStream plugins.
 * 
 * This class implements handlers for:
 * - cloudstream:getPopular
 * - cloudstream:getLatestUpdates
 * - cloudstream:search
 * - cloudstream:getDetail (load)
 * - cloudstream:getVideoList (loadLinks)
 * - cloudstream:getPageList
 * - cloudstream:getNovelContent
 * - cloudstream:getPreference
 * - cloudstream:setPreference
 * - cloudstream:extract (extractor service)
 * - cloudstream:listExtractors
 */
class CloudStreamApiRouter(private val context: Context) {

    companion object {
        private const val TAG = "CloudStreamApiRouter"
    }

private fun decodeCloudStreamUrl(value: String?): String? {
    if (value.isNullOrBlank()) return value
    val prefix = "csjson://"
    return if (value.startsWith(prefix)) {
        val payload = value.substring(prefix.length)
        try {
            val decoded = Base64.decode(payload, Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
            String(decoded, Charsets.UTF_8)
        } catch (e: Exception) {
            Log.w("CloudStreamApiRouter", "Failed to decode CloudStream JSON url: ${e.message}")
            value
        }
    } else {
        value
    }
}

    private val registry = CloudStreamPluginRegistry.getInstance(context)
    private val extractorService = CloudStreamExtractorService.getInstance(context)
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val json = Json { 
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    /**
     * Route a method call to the appropriate handler.
     * Returns true if the method was handled.
     */
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            "cloudstream:getPopular" -> {
                handleGetPopular(call, result)
                true
            }
            "cloudstream:getLatestUpdates" -> {
                handleGetLatestUpdates(call, result)
                true
            }
            "cloudstream:search" -> {
                handleSearch(call, result)
                true
            }
            "cloudstream:getDetail" -> {
                handleGetDetail(call, result)
                true
            }
            "cloudstream:getVideoList" -> {
                handleGetVideoList(call, result)
                true
            }
            "cloudstream:getPageList" -> {
                handleGetPageList(call, result)
                true
            }
            "cloudstream:getNovelContent" -> {
                handleGetNovelContent(call, result)
                true
            }
            "cloudstream:getPreference" -> {
                handleGetPreference(call, result)
                true
            }
            "cloudstream:setPreference" -> {
                handleSetPreference(call, result)
                true
            }
            "cloudstream:extract" -> {
                handleExtract(call, result)
                true
            }
            "cloudstream:extractWithExtractor" -> {
                handleExtractWithExtractor(call, result)
                true
            }
            "cloudstream:listExtractors" -> {
                handleListExtractors(result)
                true
            }
            "cloudstream:loadPlugin" -> {
                handleLoadPlugin(call, result)
                true
            }
            "cloudstream:unloadPlugin" -> {
                handleUnloadPlugin(call, result)
                true
            }
            "cloudstream:reloadPlugins" -> {
                handleReloadPlugins(result)
                true
            }
            "cloudstream:getLoadedPlugins" -> {
                handleGetLoadedPlugins(result)
                true
            }
            // Legacy method names (without cloudstream: prefix)
            "getPopular" -> {
                handleGetPopular(call, result)
                true
            }
            "getLatestUpdates" -> {
                handleGetLatestUpdates(call, result)
                true
            }
            "search" -> {
                handleSearch(call, result)
                true
            }
            "getDetail" -> {
                handleGetDetail(call, result)
                true
            }
            "getVideoList" -> {
                handleGetVideoList(call, result)
                true
            }
            "getPageList" -> {
                handleGetPageList(call, result)
                true
            }
            "getNovelContent" -> {
                handleGetNovelContent(call, result)
                true
            }
            "getPreference" -> {
                handleGetPreference(call, result)
                true
            }
            "setPreference" -> {
                handleSetPreference(call, result)
                true
            }
            else -> false
        }
    }

    private fun handleGetPopular(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val page = call.argument<Int>("page") ?: 1

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        ioScope.launch {
            try {
                val mainApi = getOrLoadMainApi(sourceId)
                if (mainApi == null) {
                    result.error("NOT_FOUND", "Plugin not found: $sourceId", null)
                    return@launch
                }

                if (!mainApi.hasMainPage) {
                    withContext(Dispatchers.Main) {
                        result.success(mapOf(
                            "hasNextPage" to false,
                            "list" to emptyList<Map<String, Any?>>()
                        ))
                    }
                    return@launch
                }

                // Get the first main page request
                val request = mainApi.mainPage.firstOrNull()
                if (request == null) {
                    withContext(Dispatchers.Main) {
                        result.success(mapOf(
                            "hasNextPage" to false,
                            "list" to emptyList<Map<String, Any?>>()
                        ))
                    }
                    return@launch
                }

                val mainPageRequest = MainPageRequest(
                    name = request.name,
                    data = request.data,
                    horizontalImages = request.horizontalImages
                )

                val response = mainApi.getMainPage(page, mainPageRequest)
                val payload = response?.toPayload() ?: mapOf(
                    "hasNextPage" to false,
                    "list" to emptyList<Map<String, Any?>>()
                )

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in getPopular for $sourceId: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleGetLatestUpdates(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val page = call.argument<Int>("page") ?: 1

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        ioScope.launch {
            try {
                val mainApi = getOrLoadMainApi(sourceId)
                if (mainApi == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Plugin not found: $sourceId", null)
                    }
                    return@launch
                }

                // Try to get "Latest" or second main page
                val request = mainApi.mainPage.find { 
                    it.name.contains("latest", ignoreCase = true) ||
                    it.name.contains("recent", ignoreCase = true) ||
                    it.name.contains("new", ignoreCase = true)
                } ?: mainApi.mainPage.getOrNull(1) ?: mainApi.mainPage.firstOrNull()

                if (request == null) {
                    withContext(Dispatchers.Main) {
                        result.success(mapOf(
                            "hasNextPage" to false,
                            "list" to emptyList<Map<String, Any?>>()
                        ))
                    }
                    return@launch
                }

                val mainPageRequest = MainPageRequest(
                    name = request.name,
                    data = request.data,
                    horizontalImages = request.horizontalImages
                )

                val response = mainApi.getMainPage(page, mainPageRequest)
                val payload = response?.toPayload() ?: mapOf(
                    "hasNextPage" to false,
                    "list" to emptyList<Map<String, Any?>>()
                )

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in getLatestUpdates for $sourceId: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleSearch(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val query = call.argument<String>("query")
        val page = call.argument<Int>("page") ?: 1

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        if (query.isNullOrBlank()) {
            result.error("INVALID_ARGS", "query is required", null)
            return
        }

        ioScope.launch {
            try {
                val mainApi = getOrLoadMainApi(sourceId)
                if (mainApi == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Plugin not found: $sourceId", null)
                    }
                    return@launch
                }

                val searchResult = mainApi.search(query, page)
                val payload = mapOf(
                    "hasNextPage" to (searchResult?.hasNext ?: false),
                    "list" to (searchResult?.items?.map { it.toPayload() } ?: emptyList<Map<String, Any?>>())
                )

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in search for $sourceId: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleGetDetail(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val mediaMap = call.argument<Map<String, Any?>>("media")

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        val rawUrl = mediaMap?.get("url")?.toString()
        val url = decodeCloudStreamUrl(rawUrl)
        if (url.isNullOrBlank()) {
            result.error("INVALID_ARGS", "media.url is required", null)
            return
        }

        ioScope.launch {
            try {
                val mainApi = getOrLoadMainApi(sourceId)
                if (mainApi == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Plugin not found: $sourceId", null)
                    }
                    return@launch
                }

                val loadResponse = mainApi.load(url)
                if (loadResponse == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Content not found at $url", null)
                    }
                    return@launch
                }

                val payload = loadResponse.toDetailPayload()

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in getDetail for $sourceId: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleGetVideoList(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val episodeMap = call.argument<Map<String, Any?>>("episode")

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        val rawEpisodeUrl = episodeMap?.get("url")?.toString()
        val episodeUrl = decodeCloudStreamUrl(rawEpisodeUrl)
        if (episodeUrl.isNullOrBlank()) {
            result.error("INVALID_ARGS", "episode.url is required", null)
            return
        }

        ioScope.launch {
            try {
                val mainApi = registry.getMainApi(sourceId)
                if (mainApi == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Plugin not found: $sourceId", null)
                    }
                    return@launch
                }

                val links = mutableListOf<Map<String, Any?>>()
                val subtitles = mutableListOf<Map<String, Any?>>()

                mainApi.loadLinks(
                    data = episodeUrl,
                    isCasting = false,
                    subtitleCallback = { subtitle ->
                        subtitles.add(mapOf(
                            "lang" to subtitle.lang,
                            "url" to subtitle.url
                        ))
                    },
                    callback = { link ->
                        links.add(link.toVideoPayload())
                    }
                )

                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "videos" to links,
                        "subtitles" to subtitles
                    ))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in getVideoList for $sourceId: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleGetPageList(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val episodeMap = call.argument<Map<String, Any?>>("episode")

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        // For manga/novel page lists, we need to handle this differently
        // CloudStream doesn't have a direct getPageList, so we return empty for now
        // This would need custom implementation per provider type

        ioScope.launch {
            withContext(Dispatchers.Main) {
                result.success(emptyList<Map<String, Any?>>())
            }
        }
    }

    private fun handleGetNovelContent(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val chapterId = call.argument<String>("chapterId")

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        if (chapterId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "chapterId is required", null)
            return
        }

        ioScope.launch {
            try {
                val mainApi = registry.getMainApi(sourceId)
                if (mainApi == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Plugin not found: $sourceId", null)
                    }
                    return@launch
                }

                // Load the chapter content
                val loadResponse = mainApi.load(chapterId)
                
                // Extract text content if available
                val content = when (loadResponse) {
                    is TvSeriesLoadResponse -> loadResponse.plot
                    is MovieLoadResponse -> loadResponse.plot
                    is AnimeLoadResponse -> loadResponse.plot
                    else -> null
                }

                withContext(Dispatchers.Main) {
                    result.success(content)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in getNovelContent for $sourceId: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleGetPreference(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        // CloudStream plugins don't have a standard preference API like Aniyomi
        // Return empty list for now
        ioScope.launch {
            withContext(Dispatchers.Main) {
                result.success(emptyList<Map<String, Any?>>())
            }
        }
    }

    private fun handleSetPreference(call: MethodCall, result: MethodChannel.Result) {
        val sourceId = call.argument<String>("sourceId")
        val key = call.argument<String>("key")
        val value = call.argument<Any>("value")

        if (sourceId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "sourceId is required", null)
            return
        }

        // CloudStream plugins don't have a standard preference API
        ioScope.launch {
            withContext(Dispatchers.Main) {
                result.success(false)
            }
        }
    }

    private fun handleExtract(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        val referer = call.argument<String>("referer")

        if (url.isNullOrBlank()) {
            result.error("INVALID_ARGS", "url is required", null)
            return
        }

        ioScope.launch {
            try {
                val extractResult = extractorService.extract(url, referer)
                val payload = extractorService.resultToMap(extractResult)

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in extract: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("EXTRACT_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleExtractWithExtractor(call: MethodCall, result: MethodChannel.Result) {
        val extractorName = call.argument<String>("extractorName")
        val url = call.argument<String>("url")
        val referer = call.argument<String>("referer")

        if (extractorName.isNullOrBlank()) {
            result.error("INVALID_ARGS", "extractorName is required", null)
            return
        }

        if (url.isNullOrBlank()) {
            result.error("INVALID_ARGS", "url is required", null)
            return
        }

        ioScope.launch {
            try {
                val extractResult = extractorService.extractWithExtractor(extractorName, url, referer)
                val payload = extractorService.resultToMap(extractResult)

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in extractWithExtractor: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("EXTRACT_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleListExtractors(result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val extractors = extractorService.listExtractors()
                val payload = extractors.map { it.toMap() }

                withContext(Dispatchers.Main) {
                    result.success(payload)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in listExtractors: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleLoadPlugin(call: MethodCall, result: MethodChannel.Result) {
        val pluginPath = call.argument<String>("pluginPath")
        val internalName = call.argument<String>("internalName")

        if (pluginPath.isNullOrBlank() || internalName.isNullOrBlank()) {
            result.error("INVALID_ARGS", "pluginPath and internalName are required", null)
            return
        }

        ioScope.launch {
            try {
                val pluginDir = java.io.File(pluginPath)
                val success = registry.loadAndRegisterPlugin(pluginDir, internalName)

                withContext(Dispatchers.Main) {
                    result.success(success)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in loadPlugin: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("LOAD_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleUnloadPlugin(call: MethodCall, result: MethodChannel.Result) {
        val internalName = call.argument<String>("internalName")

        if (internalName.isNullOrBlank()) {
            result.error("INVALID_ARGS", "internalName is required", null)
            return
        }

        ioScope.launch {
            try {
                val success = registry.unloadAndUnregisterPlugin(internalName)

                withContext(Dispatchers.Main) {
                    result.success(success)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in unloadPlugin: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("UNLOAD_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleReloadPlugins(result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val count = registry.reloadAllPlugins()

                withContext(Dispatchers.Main) {
                    result.success(count)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in reloadPlugins: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("RELOAD_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    private fun handleGetLoadedPlugins(result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val plugins = registry.getAllMainApis().map { (id, api) ->
                    mapOf(
                        "id" to id,
                        "name" to api.name,
                        "mainUrl" to api.mainUrl,
                        "lang" to api.lang,
                        "hasMainPage" to api.hasMainPage,
                        "hasQuickSearch" to api.hasQuickSearch,
                        "supportedTypes" to api.supportedTypes.map { it.name }
                    )
                }

                withContext(Dispatchers.Main) {
                    result.success(plugins)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in getLoadedPlugins: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("API_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    /**
     * Initialize the router (load all plugins).
     */
    suspend fun initialize() {
        registry.initialize()
    }

    // Extension functions for payload conversion
    private fun HomePageResponse.toPayload(): Map<String, Any?> {
        return mapOf(
            "hasNextPage" to hasNext,
            "list" to items.flatMap { it.list }.map { it.toPayload() }
        )
    }

    private fun SearchResponse.toPayload(): Map<String, Any?> {
        return mapOf(
            "title" to name,
            "url" to url,
            "thumbnail_url" to posterUrl,
            "type" to type?.name
        )
    }

    private fun LoadResponse.toDetailPayload(): Map<String, Any?> {
        val basePayload = mutableMapOf<String, Any?>(
            "title" to name,
            "url" to url,
            "thumbnail_url" to posterUrl,
            "description" to plot,
            "type" to type?.name,
            "year" to year,
            "score" to score?.toFloat(10), // Score out of 10
            "tags" to tags,
            "duration" to duration,
            "backgroundPosterUrl" to backgroundPosterUrl,
            "actors" to actors?.map { 
                mapOf(
                    "name" to it.actor.name,
                    "image" to it.actor.image,
                    "role" to it.role
                )
            }
        )

        // Add episodes based on type
        when (this) {
            is TvSeriesLoadResponse -> {
                basePayload["episodes"] = episodes.map { episode ->
                    mapOf(
                        "name" to episode.name,
                        "url" to episode.data,
                        "episode_number" to episode.episode,
                        "season" to episode.season,
                        "date_upload" to episode.date,
                        "description" to episode.description,
                        "thumbnail_url" to episode.posterUrl
                    )
                }
            }
            is AnimeLoadResponse -> {
                val allEpisodes = mutableListOf<Map<String, Any?>>()
                episodes.forEach { (dubStatus, episodeList) ->
                    episodeList.forEach { episode ->
                        allEpisodes.add(mapOf(
                            "name" to episode.name,
                            "url" to episode.data,
                            "episode_number" to episode.episode,
                            "season" to episode.season,
                            "date_upload" to episode.date,
                            "description" to episode.description,
                            "thumbnail_url" to episode.posterUrl,
                            "dubStatus" to dubStatus.name
                        ))
                    }
                }
                basePayload["episodes"] = allEpisodes
            }
            is MovieLoadResponse -> {
                basePayload["episodes"] = listOf(mapOf(
                    "name" to name,
                    "url" to dataUrl,
                    "episode_number" to 1
                ))
            }
            is LiveStreamLoadResponse -> {
                basePayload["episodes"] = listOf(mapOf(
                    "name" to name,
                    "url" to dataUrl,
                    "episode_number" to 1
                ))
            }
            is TorrentLoadResponse -> {
                basePayload["episodes"] = listOf(mapOf(
                    "name" to name,
                    "url" to torrent,
                    "episode_number" to 1,
                    "magnet" to magnet
                ))
            }
        }

        return basePayload
    }

    private fun ExtractorLink.toVideoPayload(): Map<String, Any?> {
        return mapOf(
            "url" to url,
            "quality" to quality,
            "name" to name,
            "source" to source,
            "referer" to referer,
            "headers" to headers,
            "isM3u8" to isM3u8,
            "isDash" to isDash,
            "type" to type.name
        )
    }

    private suspend fun getOrLoadMainApi(sourceId: String): MainAPI? {
        registry.getMainApi(sourceId)?.let { return it }

        return withContext(Dispatchers.IO) {
            val metadata = registry.getPluginMetadata(sourceId)
            if (metadata == null) {
                Log.w(TAG, "No metadata found for plugin $sourceId")
                return@withContext null
            }

            val localPath = metadata.localPath
            if (localPath.isNullOrBlank()) {
                Log.w(TAG, "Plugin $sourceId has no localPath; cannot load")
                return@withContext null
            }

            val pluginDir = File(localPath)
            val loaded = registry.loadAndRegisterPlugin(pluginDir, metadata.internalName)
            if (!loaded) {
                Log.w(TAG, "Failed to load plugin $sourceId from $localPath")
                return@withContext null
            }

            registry.getMainApi(sourceId)
        }
    }
}

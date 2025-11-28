package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.util.Log
import com.lagradost.cloudstream3.SubtitleFile
import com.lagradost.cloudstream3.utils.ExtractorApi
import com.lagradost.cloudstream3.utils.ExtractorLink
import com.lagradost.cloudstream3.utils.extractorApis
import com.lagradost.cloudstream3.utils.loadExtractor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/**
 * CloudStreamExtractorService provides a clean API for invoking video extractors.
 * 
 * This service:
 * - Exposes extractor invocations as a clean API
 * - Registers all extractor implementations when plugins load
 * - Provides a way for other extension bridges (Aniyomi/Lnreader) to call extractors
 * - Supports both MethodChannel calls and direct Kotlin service interface
 */
class CloudStreamExtractorService(private val context: Context) {

    companion object {
        private const val TAG = "CloudStreamExtractorService"

        @Volatile
        private var instance: CloudStreamExtractorService? = null

        fun getInstance(context: Context): CloudStreamExtractorService {
            return instance ?: synchronized(this) {
                instance ?: CloudStreamExtractorService(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }

    private val json = Json { 
        ignoreUnknownKeys = true
        encodeDefaults = true
    }
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    /**
     * Extract video links from a URL using the appropriate extractor.
     * 
     * @param url The URL to extract from
     * @param referer Optional referer URL
     * @return ExtractorResult containing extracted links and subtitles
     */
    suspend fun extract(url: String, referer: String? = null): ExtractorResult = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "Extracting from URL: $url with referer: $referer")

            val extractedLinks = mutableListOf<ExtractedLink>()
            val extractedSubtitles = mutableListOf<ExtractedSubtitle>()

            val success = loadExtractor(
                url = url,
                referer = referer,
                subtitleCallback = { subtitle ->
                    extractedSubtitles.add(subtitle.toExtractedSubtitle())
                },
                callback = { link ->
                    extractedLinks.add(link.toExtractedLink())
                }
            )

            if (success) {
                Log.d(TAG, "Extraction successful: ${extractedLinks.size} links, ${extractedSubtitles.size} subtitles")
            } else {
                Log.w(TAG, "No extractor found for URL: $url")
            }

            ExtractorResult(
                success = success,
                links = extractedLinks,
                subtitles = extractedSubtitles,
                error = null
            )
        } catch (e: Exception) {
            Log.e(TAG, "Extraction failed for URL $url: ${e.message}", e)
            ExtractorResult(
                success = false,
                links = emptyList(),
                subtitles = emptyList(),
                error = e.message ?: "Unknown extraction error"
            )
        }
    }

    /**
     * Extract using a specific extractor by name.
     * 
     * @param extractorName The name of the extractor to use
     * @param url The URL to extract from
     * @param referer Optional referer URL
     * @return ExtractorResult containing extracted links and subtitles
     */
    suspend fun extractWithExtractor(
        extractorName: String,
        url: String,
        referer: String? = null
    ): ExtractorResult = withContext(Dispatchers.IO) {
        try {
            val extractor = findExtractorByName(extractorName)
            if (extractor == null) {
                Log.w(TAG, "Extractor not found: $extractorName")
                return@withContext ExtractorResult(
                    success = false,
                    links = emptyList(),
                    subtitles = emptyList(),
                    error = "Extractor not found: $extractorName"
                )
            }

            Log.d(TAG, "Using extractor ${extractor.name} for URL: $url")

            val extractedLinks = mutableListOf<ExtractedLink>()
            val extractedSubtitles = mutableListOf<ExtractedSubtitle>()

            extractor.getSafeUrl(
                url = url,
                referer = referer,
                subtitleCallback = { subtitle ->
                    extractedSubtitles.add(subtitle.toExtractedSubtitle())
                },
                callback = { link ->
                    extractedLinks.add(link.toExtractedLink())
                }
            )

            Log.d(TAG, "Extraction with ${extractor.name}: ${extractedLinks.size} links")

            ExtractorResult(
                success = extractedLinks.isNotEmpty(),
                links = extractedLinks,
                subtitles = extractedSubtitles,
                error = null
            )
        } catch (e: Exception) {
            Log.e(TAG, "Extraction with $extractorName failed: ${e.message}", e)
            ExtractorResult(
                success = false,
                links = emptyList(),
                subtitles = emptyList(),
                error = e.message ?: "Unknown extraction error"
            )
        }
    }

    /**
     * Get a list of all available extractors.
     */
    fun listExtractors(): List<ExtractorInfo> {
        return extractorApis.map { extractor ->
            ExtractorInfo(
                name = extractor.name,
                mainUrl = extractor.mainUrl,
                requiresReferer = extractor.requiresReferer,
                sourcePlugin = extractor.sourcePlugin
            )
        }
    }

    /**
     * Find an extractor by name.
     */
    fun findExtractorByName(name: String): ExtractorApi? {
        return extractorApis.find { it.name.equals(name, ignoreCase = true) }
    }

    /**
     * Find extractors that can handle a given URL.
     */
    fun findExtractorsForUrl(url: String): List<ExtractorApi> {
        val lowerUrl = url.lowercase()
        return extractorApis.filter { extractor ->
            lowerUrl.contains(extractor.mainUrl.replace("https://", "").replace("http://", ""))
        }
    }

    /**
     * Check if an extractor exists for a given URL.
     */
    fun hasExtractorForUrl(url: String): Boolean {
        return findExtractorsForUrl(url).isNotEmpty()
    }

    /**
     * Get the count of available extractors.
     */
    fun getExtractorCount(): Int {
        return extractorApis.size
    }

    /**
     * Convert ExtractorResult to a Map for MethodChannel response.
     */
    fun resultToMap(result: ExtractorResult): Map<String, Any?> {
        return mapOf(
            "success" to result.success,
            "links" to result.links.map { it.toMap() },
            "subtitles" to result.subtitles.map { it.toMap() },
            "error" to result.error
        )
    }

    /**
     * Convert ExtractorResult to JSON string.
     */
    fun resultToJson(result: ExtractorResult): String {
        return json.encodeToString(result)
    }

    // Extension functions for conversion
    private fun ExtractorLink.toExtractedLink(): ExtractedLink {
        return ExtractedLink(
            source = source,
            name = name,
            url = url,
            referer = referer,
            quality = quality,
            headers = headers,
            extractorData = extractorData,
            type = type.name,
            isM3u8 = isM3u8,
            isDash = isDash
        )
    }

    private fun SubtitleFile.toExtractedSubtitle(): ExtractedSubtitle {
        return ExtractedSubtitle(
            lang = lang,
            url = url
        )
    }
}

/**
 * Result of an extraction operation.
 */
@Serializable
data class ExtractorResult(
    val success: Boolean,
    val links: List<ExtractedLink>,
    val subtitles: List<ExtractedSubtitle>,
    val error: String?
)

/**
 * Extracted video link information.
 */
@Serializable
data class ExtractedLink(
    val source: String,
    val name: String,
    val url: String,
    val referer: String,
    val quality: Int,
    val headers: Map<String, String> = emptyMap(),
    val extractorData: String? = null,
    val type: String,
    val isM3u8: Boolean,
    val isDash: Boolean
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "source" to source,
            "name" to name,
            "url" to url,
            "referer" to referer,
            "quality" to quality,
            "headers" to headers,
            "extractorData" to extractorData,
            "type" to type,
            "isM3u8" to isM3u8,
            "isDash" to isDash
        )
    }
}

/**
 * Extracted subtitle information.
 */
@Serializable
data class ExtractedSubtitle(
    val lang: String,
    val url: String
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "lang" to lang,
            "url" to url
        )
    }
}

/**
 * Information about an available extractor.
 */
@Serializable
data class ExtractorInfo(
    val name: String,
    val mainUrl: String,
    val requiresReferer: Boolean,
    val sourcePlugin: String?
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "name" to name,
            "mainUrl" to mainUrl,
            "requiresReferer" to requiresReferer,
            "sourcePlugin" to sourcePlugin
        )
    }
}

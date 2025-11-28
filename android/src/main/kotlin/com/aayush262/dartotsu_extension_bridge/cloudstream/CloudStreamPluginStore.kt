package com.aayush262.dartotsu_extension_bridge.cloudstream

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import java.util.Locale

private const val METADATA_FILE_NAME = "plugins.json"
private const val STORE_TAG = "CloudStreamPluginStore"

class CloudStreamPluginStore(private val context: Context) {

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    private val mutex = Mutex()

    private val rootDir: File
        get() = context.getDir("cloudstream_plugins", Context.MODE_PRIVATE)

    private val metadataFile: File
        get() = File(rootDir, METADATA_FILE_NAME)

    suspend fun listPlugins(): List<CloudStreamPluginMetadata> = performIo {
        if (!metadataFile.exists()) return@performIo emptyList()

        return@performIo runCatching {
            json.decodeFromString<List<CloudStreamPluginMetadata>>(metadataFile.readText())
        }.getOrElse { error ->
            Log.e(STORE_TAG, "Failed to parse plugin metadata: ${error.message}", error)
            emptyList()
        }
    }

    suspend fun upsertPlugin(metadata: CloudStreamPluginMetadata): CloudStreamPluginMetadata = performIo {
        val current = listPlugins().associateBy { it.internalName }.toMutableMap()
        val updated = metadata.copy(
            lastUpdated = metadata.lastUpdated ?: System.currentTimeMillis()
        )
        current[updated.internalName] = updated
        writeMetadata(current.values.toList())
        updated
    }

    suspend fun removePlugin(internalName: String): Boolean = performIo {
        val current = listPlugins()
        if (current.isEmpty()) return@performIo false

        val remaining = current.filterNot { it.internalName == internalName }
        val removed = remaining.size != current.size
        if (removed) {
            writeMetadata(remaining)
            deletePluginDirectory(internalName)
        }
        removed
    }

    suspend fun getPlugin(internalName: String): CloudStreamPluginMetadata? = performIo {
        listPlugins().firstOrNull { it.internalName == internalName }
    }

    fun resolvePluginDirectory(repoKey: String?, internalName: String): File {
        val repoSegment = repoKey?.let(::sanitizeDirectoryName) ?: "manual"
        val pluginDir = File(File(rootDir, repoSegment), sanitizeDirectoryName(internalName))
        if (!pluginDir.exists()) {
            pluginDir.mkdirs()
        }
        return pluginDir
    }

    fun resolveBundlePath(repoKey: String?, internalName: String, extension: String = "cs3"): File {
        val dir = resolvePluginDirectory(repoKey, internalName)
        return File(dir, "${sanitizeFileName(internalName)}.$extension")
    }

    private fun deletePluginDirectory(internalName: String) {
        rootDir.listFiles()?.forEach { repoDir ->
            val target = File(repoDir, sanitizeDirectoryName(internalName))
            if (target.exists()) {
                val deleted = target.deleteRecursively()
                Log.d(STORE_TAG, "Deleted plugin directory ${target.absolutePath}: $deleted")
            }
        }
    }

    private suspend fun writeMetadata(entries: List<CloudStreamPluginMetadata>) {
        if (!rootDir.exists()) rootDir.mkdirs()
        metadataFile.writeText(json.encodeToString(entries))
    }

    private suspend fun <T> performIo(block: suspend () -> T): T = mutex.withLock {
        withContext(Dispatchers.IO) { block() }
    }

    private fun sanitizeDirectoryName(raw: String): String {
        return raw.lowercase(Locale.ROOT)
            .replace(Regex("[^a-z0-9._-]"), "-")
            .trim('-')
            .ifEmpty { "plugin" }
    }

    private fun sanitizeFileName(raw: String): String {
        return raw.replace(Regex("[^A-Za-z0-9._-]"), "_")
    }
}

@Serializable
data class CloudStreamPluginMetadata(
    val internalName: String,
    val repoUrl: String? = null,
    val pluginListUrl: String? = null,
    val downloadUrl: String? = null,
    val version: String? = null,
    val tvTypes: List<String> = emptyList(),
    val lang: String? = null,
    val isNsfw: Boolean = false,
    val itemTypes: List<Int> = emptyList(),
    val localPath: String? = null,
    val lastUpdated: Long? = null,
    val status: CloudStreamPluginStatus = CloudStreamPluginStatus.INSTALLED,
)

@Serializable
enum class CloudStreamPluginStatus {
    @SerialName("installed")
    INSTALLED,

    @SerialName("disabled")
    DISABLED,
}

fun CloudStreamPluginMetadata.matchesItemType(itemType: Int): Boolean {
    return itemTypes.isEmpty() || itemTypes.contains(itemType)
}

fun CloudStreamPluginMetadata.toInstalledSourcePayload(itemType: Int): Map<String, Any?> {
    return mapOf(
        "id" to internalName,
        "name" to internalName,
        "lang" to lang,
        "isNsfw" to isNsfw,
        "iconUrl" to null,
        "version" to version,
        "itemType" to itemType,
        "repo" to repoUrl,
        "hasUpdate" to false,
        "isObsolete" to (status == CloudStreamPluginStatus.DISABLED),
        "extensionType" to 2, // ExtensionType.cloudstream index
        "localPath" to localPath,
    )
}

fun CloudStreamPluginMetadata.toMetadataPayload(): Map<String, Any?> {
    return mapOf(
        "internalName" to internalName,
        "repoUrl" to repoUrl,
        "pluginListUrl" to pluginListUrl,
        "downloadUrl" to downloadUrl,
        "version" to version,
        "tvTypes" to tvTypes,
        "lang" to lang,
        "isNsfw" to isNsfw,
        "itemTypes" to itemTypes,
        "localPath" to localPath,
        "lastUpdated" to lastUpdated,
        "status" to status.name.lowercase(Locale.ROOT),
    )
}

fun Map<String, Any?>.toCloudStreamPluginMetadata(): CloudStreamPluginMetadata {
    return CloudStreamPluginMetadata(
        internalName = this["internalName"]?.toString()
            ?: throw IllegalArgumentException("internalName is required"),
        repoUrl = this["repoUrl"]?.toString(),
        pluginListUrl = this["pluginListUrl"]?.toString(),
        downloadUrl = this["downloadUrl"]?.toString(),
        version = this["version"]?.toString(),
        tvTypes = (this["tvTypes"] as? List<*>)
            ?.mapNotNull { it?.toString() }
            ?: emptyList(),
        lang = this["lang"]?.toString(),
        isNsfw = this["isNsfw"] as? Boolean ?: false,
        itemTypes = (this["itemTypes"] as? List<*>)
            ?.mapNotNull { (it as? Number)?.toInt() }
            ?: emptyList(),
        localPath = this["localPath"]?.toString(),
        lastUpdated = when (val value = this["lastUpdated"]) {
            is Number -> value.toLong()
            is String -> value.toLongOrNull()
            else -> null
        },
        status = when (this["status"]?.toString()?.lowercase(Locale.ROOT)) {
            "disabled" -> CloudStreamPluginStatus.DISABLED
            else -> CloudStreamPluginStatus.INSTALLED
        }
    )
}

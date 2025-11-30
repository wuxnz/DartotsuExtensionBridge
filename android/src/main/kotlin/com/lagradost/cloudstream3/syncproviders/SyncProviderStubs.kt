package com.lagradost.cloudstream3.syncproviders

import androidx.annotation.WorkerThread
import com.lagradost.cloudstream3.ActorData
import com.lagradost.cloudstream3.NextAiring
import com.lagradost.cloudstream3.Score
import com.lagradost.cloudstream3.SearchQuality
import com.lagradost.cloudstream3.SearchResponse
import com.lagradost.cloudstream3.ShowStatus
import com.lagradost.cloudstream3.TvType
import com.lagradost.cloudstream3.syncproviders.providers.AniListApi
import com.lagradost.cloudstream3.syncproviders.providers.LocalList
import com.lagradost.cloudstream3.syncproviders.providers.MALApi
import com.lagradost.cloudstream3.syncproviders.providers.SimklApi
import java.util.Date
import java.util.concurrent.TimeUnit

/** Lightweight stand-ins for the upstream sync-provider APIs so plugins referencing them can load. */

enum class SyncWatchType { Watching, Completed, OnHold, Dropped, PlanToWatch }

enum class ListSorting { Query, RatingHigh, RatingLow, AlphabeticalA, AlphabeticalZ, UpdatedNew, UpdatedOld, ReleaseDateNew, ReleaseDateOld }

class UiText(private val raw: String) {
    override fun toString(): String = raw
}

data class AuthLoginPage(val url: String, val payload: String? = null)

data class AuthToken(
    val accessToken: String? = null,
    val refreshToken: String? = null,
    val accessTokenLifetime: Long? = null,
    val refreshTokenLifetime: Long? = null,
    val payload: String? = null,
) {
    fun isAccessTokenExpired(marginSec: Long = 10L): Boolean {
        val expiry = accessTokenLifetime ?: return false
        return (System.currentTimeMillis() / 1000L) + marginSec >= expiry
    }

    fun isRefreshTokenExpired(marginSec: Long = 10L): Boolean {
        val expiry = refreshTokenLifetime ?: return false
        return (System.currentTimeMillis() / 1000L) + marginSec >= expiry
    }
}

data class AuthUser(
    val name: String?,
    val id: Int,
    val profilePicture: String? = null,
    val profilePictureHeaders: Map<String, String>? = null,
)

data class AuthData(val user: AuthUser, val token: AuthToken)

data class AuthPinData(
    val deviceCode: String,
    val userCode: String,
    val verificationUrl: String,
    val expiresIn: Int,
    val interval: Int,
)

data class AuthLoginRequirement(
    val password: Boolean = false,
    val username: Boolean = false,
    val email: Boolean = false,
    val server: Boolean = false,
)

data class AuthLoginResponse(
    val password: String?,
    val username: String?,
    val email: String?,
    val server: String?,
)

abstract class AuthAPI {
    open val name: String = "NONE"
    open val idPrefix: String = "NONE"
    open val icon: Int? = null
    open val requiresLogin: Boolean = true
    open val createAccountUrl: String? = null
    open val redirectUrlIdentifier: String? = null
    open val hasOAuth2: Boolean = false
    open val hasPin: Boolean = false
    open val hasInApp: Boolean = false
    open val inAppLoginRequirement: AuthLoginRequirement? = null

    companion object {
        val unixTime: Long get() = System.currentTimeMillis() / 1000L
        val unixTimeMs: Long get() = System.currentTimeMillis()
        fun splitRedirectUrl(@Suppress("UNUSED_PARAMETER") redirectUrl: String): Map<String, String> = emptyMap()
        fun generateCodeVerifier(): String = System.currentTimeMillis().toString(16)
    }

    @Throws
    open fun isValidRedirectUrl(url: String): Boolean {
        val identifier = redirectUrlIdentifier ?: return false
        return url.contains("/$identifier")
    }

    @Throws open suspend fun login(redirectUrl: String, payload: String?): AuthToken? = null
    @Throws open fun loginRequest(): AuthLoginPage? = null
    @Throws open suspend fun pinRequest(): AuthPinData? = null
    @Throws open suspend fun refreshToken(token: AuthToken): AuthToken? = token
    @Throws open suspend fun login(payload: AuthPinData): AuthToken? = null
    @Throws open suspend fun login(form: AuthLoginResponse): AuthToken? = null
    @Throws open suspend fun user(token: AuthToken?): AuthUser? = null
    @Throws open suspend fun invalidateToken(token: AuthToken): Nothing = throw NotImplementedError()

    @Deprecated("AuthAPI repo helpers are not supported", level = DeprecationLevel.WARNING)
    open fun toRepo(): AuthRepo = object : AuthRepo(this@AuthAPI) {}

    @Deprecated("AuthAPI repo helpers are not supported", level = DeprecationLevel.WARNING)
    fun loginInfo(): AuthAPI.LoginInfo? = null

    @Deprecated("AuthAPI repo helpers are not supported", level = DeprecationLevel.WARNING)
    open suspend fun getPersonalLibrary(): SyncAPI.LibraryMetadata? = null

    @Deprecated("AuthAPI repo helpers are not supported", level = DeprecationLevel.WARNING)
    class LoginInfo(val profilePicture: String? = null, val name: String?, val accountIndex: Int)
}

abstract class AuthRepo(open val api: AuthAPI) {
    fun isValidRedirectUrl(url: String) = api.isValidRedirectUrl(url)
    val idPrefix get() = api.idPrefix
    val name get() = api.name
    val icon get() = api.icon
    val requiresLogin get() = api.requiresLogin
    val createAccountUrl get() = api.createAccountUrl
    val hasOAuth2 get() = api.hasOAuth2
    val hasPin get() = api.hasPin
    val hasInApp get() = api.hasInApp
    val inAppLoginRequirement get() = api.inAppLoginRequirement
    val isAvailable get() = !api.requiresLogin || authUser() != null

    companion object {
        private val oauthPayload: MutableMap<String, String?> = mutableMapOf()
        fun storePayload(prefix: String, payload: String?) {
            synchronized(oauthPayload) { oauthPayload[prefix] = payload }
        }
        fun takePayload(prefix: String): String? = synchronized(oauthPayload) { oauthPayload[prefix] }
    }

    @Throws
    protected open suspend fun freshAuth(): AuthData? {
        val data = authData() ?: return null
        val token = data.token
        if (token.isAccessTokenExpired()) {
            val refreshed = api.refreshToken(token) ?: return null
            val refreshedData = data.copy(token = refreshed)
            refreshUser(refreshedData)
            return refreshedData
        }
        return data
    }

    @Throws
    open fun openOAuth2Page(): Boolean {
        val page = api.loginRequest() ?: return false
        storePayload(idPrefix, page.payload)
        return true
    }

    fun openOAuth2PageWithToast() {
        openOAuth2Page()
    }

    open suspend fun logout(from: AuthUser) {
        val current = AccountManager.accounts(idPrefix)
        val remaining = current.filter { it.user.id != from.id }.toTypedArray()
        AccountManager.updateAccounts(idPrefix, remaining)
        if ((AccountManager.cachedAccountIds[idPrefix] ?: AccountManager.NONE_ID) == from.id) {
            AccountManager.updateAccountsId(idPrefix, AccountManager.NONE_ID)
        }
    }

    open fun refreshUser(newAuth: AuthData) {
        val updated = AccountManager.accounts(idPrefix).map {
            if (it.user.id == newAuth.user.id) newAuth else it
        }.toTypedArray()
        if (updated.isEmpty()) {
            AccountManager.updateAccounts(idPrefix, arrayOf(newAuth))
        } else {
            AccountManager.updateAccounts(idPrefix, updated)
        }
    }

    open fun authData(): AuthData? {
        val id = AccountManager.cachedAccountIds[idPrefix] ?: return null
        return AccountManager.cachedAccounts[idPrefix]?.firstOrNull { it.user.id == id }
    }

    fun authToken(): AuthToken? = authData()?.token
    fun authUser(): AuthUser? = authData()?.user

    val accounts: Array<AuthData>
        get() = AccountManager.cachedAccounts[idPrefix] ?: emptyArray()

    var accountId: Int
        get() = AccountManager.cachedAccountIds[idPrefix] ?: AccountManager.NONE_ID
        set(value) {
            AccountManager.updateAccountsId(idPrefix, value)
        }

    @Throws open suspend fun pinRequest(): AuthPinData? = api.pinRequest()

    @Throws
    private suspend fun setupLogin(token: AuthToken): Boolean {
        val user = api.user(token) ?: return false
        val newAccount = AuthData(user = user, token = token)
        val existing = AccountManager.accounts(idPrefix).filterNot { it.user.id == user.id }
        val combined = (existing + newAccount).toTypedArray()
        AccountManager.updateAccounts(idPrefix, combined)
        AccountManager.updateAccountsId(idPrefix, user.id)
        if (this is SyncRepo) {
            requireLibraryRefresh = true
        }
        return true
    }

    @Throws
    open suspend fun login(form: AuthLoginResponse): Boolean {
        val token = api.login(form) ?: return false
        return setupLogin(token)
    }

    @Throws
    open suspend fun login(payload: AuthPinData): Boolean {
        val token = api.login(payload) ?: return false
        return setupLogin(token)
    }

    @Throws
    open suspend fun login(redirectUrl: String): Boolean {
        val token = api.login(redirectUrl, takePayload(idPrefix)) ?: return false
        return setupLogin(token)
    }
}

abstract class AccountManager {
    companion object {
        const val NONE_ID: Int = -1

        val cachedAccounts: MutableMap<String, Array<AuthData>> = mutableMapOf()
        val cachedAccountIds: MutableMap<String, Int> = mutableMapOf()

        private val malApi = MALApi()
        private val aniListApi = AniListApi()
        private val simklApi = SimklApi()
        private val localListApi = LocalList()

        val syncApis: Array<SyncRepo> = arrayOf(
            SyncRepo(malApi),
            SyncRepo(aniListApi),
            SyncRepo(simklApi),
            SyncRepo(localListApi),
        )

        @JvmStatic
        fun getSimklApi(): SimklApi = simklApi

        @JvmStatic
        fun getMalApi(): MALApi = malApi

        @JvmStatic
        fun getAniListApi(): AniListApi = aniListApi

        @JvmStatic
        fun getLocalListApi(): LocalList = localListApi

        fun accounts(prefix: String): Array<AuthData> = cachedAccounts[prefix] ?: emptyArray()

        fun updateAccounts(prefix: String, array: Array<AuthData>) {
            cachedAccounts[prefix] = array
        }

        fun updateAccountsId(prefix: String, id: Int) {
            cachedAccountIds[prefix] = id
        }

        fun initMainAPI() {}

        fun secondsToReadable(seconds: Int, completedValue: String = "0m"): String {
            var secondsLong = seconds.toLong()
            val days = TimeUnit.SECONDS.toDays(secondsLong)
            secondsLong -= TimeUnit.DAYS.toSeconds(days)
            val hours = TimeUnit.SECONDS.toHours(secondsLong)
            secondsLong -= TimeUnit.HOURS.toSeconds(hours)
            val minutes = TimeUnit.SECONDS.toMinutes(secondsLong)
            return if (minutes < 0) completedValue else buildString {
                if (days != 0L) append(days).append('d').append(' ')
                if (hours != 0L) append(hours).append('h').append(' ')
                append(minutes).append('m')
            }
        }
    }
}

abstract class SyncAPI : AuthAPI() {
    open var requireLibraryRefresh: Boolean = true
    open val mainUrl: String = "NONE"
    open val supportedWatchTypes: Set<SyncWatchType> = SyncWatchType.entries.toSet()
    open val syncIdName: SyncIdName? = null

    @Throws
    @WorkerThread
    open suspend fun updateStatus(auth: AuthData?, id: String, newStatus: AbstractSyncStatus): Boolean = false

    @Throws
    @WorkerThread
    open suspend fun status(auth: AuthData?, id: String): AbstractSyncStatus? = null

    @Throws
    @WorkerThread
    open suspend fun load(auth: AuthData?, id: String): SyncResult? = null

    @Throws
    @WorkerThread
    open suspend fun search(auth: AuthData?, query: String): List<SyncSearchResult>? = null

    @Throws
    @WorkerThread
    open suspend fun library(auth: AuthData?): LibraryMetadata? = null

    @Throws
    open fun urlToId(url: String): String? = null

    data class SyncSearchResult(
        override val name: String,
        override val apiName: String,
        var syncId: String,
        override val url: String,
        override var posterUrl: String?,
        override var type: TvType? = null,
        override var quality: SearchQuality? = null,
        override var posterHeaders: Map<String, String>? = null,
        override var id: Int? = null,
        override var score: Score? = null,
    ) : SearchResponse

    abstract class AbstractSyncStatus {
        abstract var status: SyncWatchType
        abstract var score: Score?
        abstract var watchedEpisodes: Int?
        abstract var isFavorite: Boolean?
        abstract var maxEpisodes: Int?
    }

    data class SyncStatus(
        override var status: SyncWatchType,
        override var score: Score?,
        override var watchedEpisodes: Int?,
        override var isFavorite: Boolean? = null,
        override var maxEpisodes: Int? = null,
    ) : AbstractSyncStatus()

    data class SyncResult(
        var id: String,
        var totalEpisodes: Int? = null,
        var title: String? = null,
        var publicScore: Score? = null,
        var duration: Int? = null,
        var synopsis: String? = null,
        var airStatus: ShowStatus? = null,
        var nextAiring: NextAiring? = null,
        var studio: List<String>? = null,
        var genres: List<String>? = null,
        var synonyms: List<String>? = null,
        var trailers: List<String>? = null,
        var isAdult: Boolean? = null,
        var posterUrl: String? = null,
        var backgroundPosterUrl: String? = null,
        var startDate: Long? = null,
        var endDate: Long? = null,
        var recommendations: List<SyncSearchResult>? = null,
        var nextSeason: SyncSearchResult? = null,
        var prevSeason: SyncSearchResult? = null,
        var actors: List<ActorData>? = null,
    )

    data class Page(val title: UiText, var items: List<LibraryItem>) {
        fun sort(method: ListSorting?, query: String? = null) {
            items = when (method) {
                ListSorting.Query -> if (query != null) {
                    items.sortedBy { -query.lowercase().compareTo(it.name.lowercase()) }
                } else items
                ListSorting.RatingHigh -> items.sortedBy { -(it.personalRating?.toInt(100) ?: 0) }
                ListSorting.RatingLow -> items.sortedBy { it.personalRating?.toInt(100) ?: 0 }
                ListSorting.AlphabeticalA -> items.sortedBy { it.name }
                ListSorting.AlphabeticalZ -> items.sortedBy { it.name }.reversed()
                ListSorting.UpdatedNew -> items.sortedBy { it.lastUpdatedUnixTime?.times(-1) }
                ListSorting.UpdatedOld -> items.sortedBy { it.lastUpdatedUnixTime }
                ListSorting.ReleaseDateNew -> items.sortedByDescending { it.releaseDate }
                ListSorting.ReleaseDateOld -> items.sortedBy { it.releaseDate }
                else -> items
            }
        }
    }

    data class LibraryMetadata(val allLibraryLists: List<LibraryList>, val supportedListSorting: Set<ListSorting>)

    data class LibraryList(val name: UiText, val items: List<LibraryItem>)

    data class LibraryItem(
        override val name: String,
        override val url: String,
        val syncId: String,
        val episodesCompleted: Int?,
        val episodesTotal: Int?,
        val personalRating: Score?,
        val lastUpdatedUnixTime: Long?,
        override val apiName: String,
        override var type: TvType?,
        override var posterUrl: String?,
        override var posterHeaders: Map<String, String>?,
        override var quality: SearchQuality?,
        val releaseDate: Date?,
        override var id: Int? = null,
        val plot: String? = null,
        override var score: Score? = null,
        val tags: List<String>? = null,
    ) : SearchResponse
}

class SyncRepo(override val api: SyncAPI) : AuthRepo(api) {
    val syncIdName = api.syncIdName
    var requireLibraryRefresh: Boolean
        get() = api.requireLibraryRefresh
        set(value) {
            api.requireLibraryRefresh = value
        }

    suspend fun updateStatus(id: String, newStatus: SyncAPI.AbstractSyncStatus): Result<Boolean> = runCatching {
        api.updateStatus(freshAuth(), id, newStatus)
    }

    suspend fun status(id: String): Result<SyncAPI.AbstractSyncStatus?> = runCatching {
        api.status(freshAuth(), id)
    }

    suspend fun load(id: String): Result<SyncAPI.SyncResult?> = runCatching {
        api.load(freshAuth(), id)
    }

    suspend fun library(): Result<SyncAPI.LibraryMetadata?> = runCatching {
        api.library(freshAuth())
    }
}

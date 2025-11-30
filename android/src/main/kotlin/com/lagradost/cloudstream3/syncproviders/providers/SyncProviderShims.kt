package com.lagradost.cloudstream3.syncproviders.providers

import com.lagradost.cloudstream3.syncproviders.SyncAPI

open class BaseSyncApiShim(
    override val idPrefix: String,
    override val name: String,
) : SyncAPI()

class MALApi : BaseSyncApiShim("mal", "MyAnimeList")
class AniListApi : BaseSyncApiShim("anilist", "AniList")
class SimklApi : BaseSyncApiShim("simkl", "Simkl")
class LocalList : BaseSyncApiShim("local", "LocalList")

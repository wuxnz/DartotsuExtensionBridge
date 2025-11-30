package com.lagradost.cloudstream3.plugins

import android.content.Context
import android.content.res.Resources
import android.util.Log

abstract class Plugin : BasePlugin() {
    @Throws(Throwable::class)
    open fun load(context: Context) {
        load()
    }

    fun registerVideoClickAction(element: VideoClickAction) {
        Log.i(PLUGIN_TAG, "Adding ${element.name} VideoClickAction")
        element.sourcePlugin = this.filename
        synchronized(VideoClickActionHolder.allVideoClickActions) {
            VideoClickActionHolder.allVideoClickActions.add(element)
        }
    }

    var resources: Resources? = null
    var openSettings: ((context: Context) -> Unit)? = null

    open class VideoClickAction(
        open val name: String = "Action",
        open var sourcePlugin: String? = null,
    )

    object VideoClickActionHolder {
        val allVideoClickActions = mutableListOf<VideoClickAction>()
    }
}

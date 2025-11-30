package com.lagradost.cloudstream3

import android.content.Context
import java.lang.ref.WeakReference

/**
 * Minimal stub of the legacy AcraApplication class so older CloudStream plugins keep working.
 * This implementation only stores context/keys in-memory and does not persist anything.
 */
class AcraApplication {
    companion object {
        private var _context: WeakReference<Context>? = null
        @PublishedApi
        internal val memoryStore = mutableMapOf<String, Any?>()

        var context: Context?
            get() = _context?.get()
            set(value) {
                _context = WeakReference(value)
            }

        fun <T> setKey(path: String, value: T) {
            memoryStore[path] = value
        }

        fun <T> setKey(folder: String, path: String, value: T) {
            memoryStore["$folder/$path"] = value
        }

        inline fun <reified T : Any> getKey(path: String, defVal: T?): T? {
            return memoryStore[path] as? T ?: defVal
        }

        inline fun <reified T : Any> getKey(path: String): T? {
            return memoryStore[path] as? T
        }

        inline fun <reified T : Any> getKey(folder: String, path: String): T? {
            return memoryStore["$folder/$path"] as? T
        }

        inline fun <reified T : Any> getKey(folder: String, path: String, defVal: T?): T? {
            return memoryStore["$folder/$path"] as? T ?: defVal
        }
    }
}

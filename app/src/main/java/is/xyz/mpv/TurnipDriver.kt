package `is`.xyz.mpv

import android.content.Context
import android.util.Log
import java.io.File

object TurnipDriver {
    private const val TAG = "TurnipDriver"
    private const val DRIVER_SUBDIR = "turnip"
    private const val DRIVER_NAME = "libvulkan_freedreno.so"

    @Volatile var ready: Boolean = false
        private set

    fun ensureInstalled(context: Context): Boolean {
        try {
            val dir = File(context.filesDir, DRIVER_SUBDIR)
            if (!dir.exists()) dir.mkdirs()
            val dst = File(dir, DRIVER_NAME)
            if (dst.exists() && dst.length() > 1_000_000L) {
                ready = true
                return true
            }
            context.assets.open("turnip/$DRIVER_NAME").use { input ->
                dst.outputStream().use { output -> input.copyTo(output) }
            }
            // tmp dir for adrenotools (api < 29 path, harmless on newer)
            val tmp = File(dir, "tmp")
            if (!tmp.exists()) tmp.mkdirs()
            ready = dst.exists() && dst.length() > 1_000_000L
            Log.i(TAG, "turnip driver installed=${ready} size=${dst.length()}")
            return ready
        } catch (e: Exception) {
            Log.e(TAG, "turnip install failed", e)
            ready = false
            return false
        }
    }

    fun driverDir(context: Context): String =
        File(context.filesDir, DRIVER_SUBDIR).absolutePath + "/"

    fun tmpDir(context: Context): String =
        File(File(context.filesDir, DRIVER_SUBDIR), "tmp").absolutePath
}

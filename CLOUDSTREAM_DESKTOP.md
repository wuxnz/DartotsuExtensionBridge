# CloudStream Desktop Support

This document describes the CloudStream extension support for desktop platforms (Linux and Windows).

## Overview

CloudStream plugins are now supported on desktop platforms with the following capabilities:

- **Plugin Discovery**: Browse and discover plugins from CloudStream repositories
- **Plugin Installation**: Download and install plugin bundles (.cs3/.zip files)
- **Plugin Management**: List, update, and uninstall installed plugins
- **Metadata Storage**: Persistent storage of plugin metadata
- **JS Plugin Execution**: Execute JavaScript-based plugins via QuickJS runtime

## Architecture

### Android vs Desktop

On Android, CloudStream plugins are compiled as DEX (Dalvik Executable) files that can be loaded and executed using Android's `DexClassLoader`. This allows full plugin functionality including:

- Content searching
- Media loading
- Video extraction
- Custom extractors

On desktop platforms (Linux/Windows), the implementation provides:

1. **Plugin Management**: Full support for installing, listing, and uninstalling plugins
2. **Metadata Storage**: Plugin information is stored in a JSON file
3. **Bundle Extraction**: Plugin bundles are downloaded and extracted for inspection
4. **JS Plugin Execution**: JavaScript-based plugins can be executed via QuickJS
5. **DEX Limitation**: DEX-based plugins cannot be executed (no Dalvik runtime)

### Implementation Details

The desktop implementation uses a pure Dart approach with QuickJS for JS execution:

```
lib/CloudStream/desktop/
├── desktop.dart                           # Barrel export file
├── cloudstream_desktop_bridge.dart        # Main bridge handling method calls
├── cloudstream_desktop_bundle_parser.dart # ZIP extraction and manifest parsing
├── cloudstream_desktop_channel_handler.dart # Platform channel setup
├── cloudstream_desktop_config.dart        # Feature flags and configuration
├── cloudstream_desktop_diagnostics.dart   # Runtime health checks
├── cloudstream_desktop_plugin_store.dart  # Metadata persistence
├── cloudstream_desktop_telemetry.dart     # Instrumentation and metrics
├── dex/
│   ├── dex.dart                          # DEX module barrel export
│   ├── dex_runtime_interface.dart        # Abstract DEX runtime interface
│   ├── dex2jar_converter.dart            # DEX to JAR conversion
│   ├── jre_dex_runtime.dart              # JRE-based DEX execution
│   ├── dex_plugin_service.dart           # DEX plugin execution service
│   └── host_api_shims.dart               # Android API shims for DEX
└── js/
    ├── js.dart                           # JS module barrel export
    ├── cloudstream_js_runtime.dart       # QuickJS runtime with CloudStream APIs
    └── cloudstream_js_plugin_service.dart # JS plugin execution service
```

#### CloudStreamDesktopPluginStore

Manages plugin metadata storage:

- Stores metadata in `~/Documents/Aniya/{linux|windows}/cloudstream_plugins/plugins.json`
- Handles plugin directory structure
- Provides CRUD operations for plugin metadata

#### CloudStreamDesktopBundleParser

Handles plugin bundle processing:

- Downloads plugin bundles from URLs
- Extracts .cs3/.zip archives using the `archive` package
- Parses manifest.json files
- Identifies plugin content (DEX files, JS files, assets)

#### CloudStreamDesktopBridge

Implements the platform channel methods:

- `initializePlugins`: Initialize the plugin store
- `getPluginStatus`: Get current plugin status
- `installCloudStreamPlugin`: Download and install a plugin
- `uninstallCloudStreamPlugin`: Remove a plugin
- `listInstalledCloudStreamPlugins`: List all installed plugins
- `getInstalled*Extensions`: Get installed extensions by type

## Capabilities & Limitations

### What Works

- ✅ Plugin discovery from repositories
- ✅ Plugin installation (metadata and bundle storage)
- ✅ Plugin listing and management
- ✅ Plugin uninstallation
- ✅ Repository management
- ✅ UI for browsing available plugins
- ✅ **JS Plugin Execution** (search, load, loadLinks)

### JS Plugin Support

JavaScript-based CloudStream plugins can now be executed on desktop via QuickJS:

- **Search**: Query plugins for content
- **Load**: Get media details and episode lists
- **LoadLinks**: Extract video/stream URLs

The JS runtime provides CloudStream-compatible APIs:

- HTTP client (via Dart bridge)
- Storage API (persistent preferences)
- Crypto utilities (atob/btoa)
- URL/URLSearchParams polyfills
- CloudStream type enums (TvType, ShowStatus, etc.)

### Limitations

- ⚠️ **DEX plugins**: Experimental support via dex2jar + JRE
- ❌ **Custom extractors**: DEX-based extractors not yet supported
- ❌ **Some JS plugins**: May require APIs not yet implemented

### Plugin Compatibility

| Plugin Type     | Desktop Support                     |
| --------------- | ----------------------------------- |
| Pure JS         | ✅ Full support                     |
| Hybrid (JS+DEX) | ⚠️ JS parts only (DEX experimental) |
| Pure DEX        | ⚠️ Experimental (requires JRE)      |

## DEX Plugin Support (Experimental)

DEX plugin execution is now available as an experimental feature using dex2jar + JRE.

### Requirements

- **Java Runtime Environment (JRE)** 11 or later
- **dex2jar** tool for DEX to JAR conversion

### Installation

#### Linux

```bash
# Install JRE (Ubuntu/Debian)
sudo apt install openjdk-17-jre

# Install dex2jar
# Download from: https://github.com/pxb1988/dex2jar/releases
# Extract to ~/.local/share/dex-tools/
# Add to PATH: export PATH="$PATH:$HOME/.local/share/dex-tools"
```

#### Windows

```powershell
# Install JRE via Chocolatey
choco install openjdk17

# Install dex2jar
choco install dex2jar
# Or download manually from GitHub and add to PATH
```

### Enabling DEX Execution

DEX execution is disabled by default. To enable:

```dart
import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';

// Get the bridge instance
final bridge = getDesktopBridge();

// Enable DEX execution (experimental)
await bridge.setDexExecutionEnabled(true);

// Check if DEX runtime is available
if (bridge.isDexRuntimeAvailable) {
  print('DEX execution available');
}
```

### How It Works

1. **DEX to JAR Conversion**: When a plugin is loaded, dex2jar converts the `classes.dex` file to a JAR file
2. **JVM Execution**: The JAR is executed on the JVM with CloudStream bridge classes
3. **Host API Shims**: Dart provides HTTP, storage, crypto, and logging APIs to the JVM process
4. **Result Marshaling**: Results are serialized as JSON and passed back to Dart

### Limitations

- **Performance**: JVM startup adds latency to first plugin call
- **Memory**: Each plugin runs in a separate JVM process
- **Compatibility**: Some Android-specific APIs may not be available
- **Security**: DEX execution is sandboxed but runs native code

### Future Improvements

- GraalVM native image for faster startup
- Embedded Dalvik interpreter for better compatibility
- Process pooling to reduce JVM startup overhead
- Enhanced sandboxing with seccomp/AppArmor

## Usage

### Initialization

Desktop CloudStream support is automatically initialized when `DartotsuExtensionBridge.init()` is called on Linux or Windows:

```dart
// In your app's main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the extension bridge
  await DartotsuExtensionBridge().init(null, 'Aniya');

  // CloudStream desktop support is now active
  runApp(MyApp());
}
```

### Manual Initialization

If you need to initialize desktop CloudStream support separately:

```dart
import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';

// Initialize desktop CloudStream
await initializeDesktopCloudStream();

// Check if available
if (isDesktopCloudStreamAvailable) {
  print('Desktop CloudStream support is active');
}
```

### Checking Capabilities

```dart
import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';

final handler = CloudStreamDesktopChannelHandler.instance;
final capabilities = handler.bridge.getCapabilities();

print('Platform: ${capabilities['platform']}');
print('Is Initialized: ${capabilities['isInitialized']}');
print('Can execute JS plugins: ${capabilities['canExecuteJs']}');
print('Can execute DEX plugins: ${capabilities['canExecuteDex']}');
print('JS Plugin Count: ${capabilities['jsPluginCount']}');
print('Total Plugin Count: ${capabilities['totalPluginCount']}');
```

### Capability Flags in ExtensionsController

The `ExtensionsController` exposes capability flags for UI integration:

```dart
final controller = Get.find<ExtensionsController>();

// Check if CloudStream can execute plugins
if (controller.isCloudStreamFunctional) {
  // CloudStream is fully functional (Android or desktop with JS/DEX)
}

// Check specific capabilities
if (controller.canExecuteJsPlugins) {
  // JS plugins can be executed
}

if (controller.canExecuteDexPlugins) {
  // DEX plugins can be executed (experimental)
}

// Get raw capabilities map
final caps = controller.cloudStreamCapabilities.value;
```

## Configuration

### Feature Flags

Plugin execution is controlled via feature flags that can be set through environment variables or programmatically:

#### Environment Variables

```bash
# Enable JS plugin execution (default: false)
export CLOUDSTREAM_ENABLE_JS_PLUGINS=true

# Enable DEX plugin execution (default: false, experimental)
export CLOUDSTREAM_ENABLE_DEX_PLUGINS=true

# Enable telemetry/instrumentation (default: true)
export CLOUDSTREAM_ENABLE_TELEMETRY=true

# Enable verbose logging (default: false)
export CLOUDSTREAM_VERBOSE_LOGGING=true

# Timeout settings (in seconds)
export CLOUDSTREAM_JS_TIMEOUT=30
export CLOUDSTREAM_DEX_TIMEOUT=60

# Memory limit (in MB)
export CLOUDSTREAM_MAX_MEMORY_MB=256
```

#### Programmatic Configuration

```dart
import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';

// Access the config singleton
final config = cloudstreamConfig;

// Enable JS plugins
config.enableDesktopJsPlugins = true;

// Enable DEX plugins (experimental)
config.enableDesktopDexPlugins = true;

// Configure timeouts
config.jsTimeoutSeconds = 30;
config.dexTimeoutSeconds = 60;

// Export/import configuration
final json = config.toJson();
config.fromJson(json);
```

## Diagnostics

### Running Diagnostics

```dart
import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';

final bridge = getDesktopBridge();
final diagnostics = CloudStreamDesktopDiagnostics(bridge);

// Run all checks
final report = await diagnostics.runDiagnostics();

// Print to console
print(report);

// Check specific results
if (!report.allPassed) {
  for (final check in report.checks.where((c) => !c.passed)) {
    print('Failed: ${check.name}');
    print('  ${check.message}');
    print('  Suggestion: ${check.suggestion}');
  }
}
```

### Diagnostic Checks

The diagnostics system checks:

- **Platform**: Verify running on Linux or Windows
- **JS Execution Enabled**: Check if JS plugins are enabled
- **QuickJS Runtime**: Verify QuickJS is available (bundled)
- **DEX Execution Enabled**: Check if DEX plugins are enabled
- **Java Runtime**: Check if JRE 11+ is installed
- **dex2jar Tool**: Check if dex2jar is available
- **DEX Runtime Available**: Overall DEX capability check
- **Plugin Store**: Verify plugin store is accessible
- **Configuration**: Validate timeout and memory settings

## Telemetry

### Accessing Telemetry

```dart
import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';

// Get telemetry singleton
final telemetry = cloudstreamTelemetry;

// Get summary
final summary = telemetry.getSummary();
print('Total calls: ${summary['totalCalls']}');
print('Total errors: ${summary['totalErrors']}');

// Get plugin-specific stats
final stats = telemetry.getPluginStats('my-plugin');
if (stats != null) {
  print('Success rate: ${stats.successRate}');
  print('Average duration: ${stats.averageDuration.inMilliseconds}ms');
}

// Get recent events
final events = telemetry.getRecentEvents(limit: 50);
for (final event in events) {
  print(event);
}

// Export to file
final filePath = await telemetry.exportToFile();
print('Exported to: $filePath');
```

### Telemetry Events

Events are recorded for:

- Runtime initialization/shutdown
- Plugin load/unload
- Method calls (search, load, loadLinks, etc.)
- Errors and warnings

## File Locations

### Linux

```
~/.local/share/Aniya/linux/cloudstream_plugins/
├── plugins.json                    # Plugin metadata
├── bundles/                        # Downloaded plugin bundles
│   └── {repo}/
│       └── {plugin}.cs3
└── {repo}/                         # Extracted plugins
    └── {plugin}/
        ├── manifest.json
        ├── classes.dex
        └── ...
```

### Windows

```
%USERPROFILE%\Documents\Aniya\windows\cloudstream_plugins\
├── plugins.json
├── bundles\
│   └── {repo}\
│       └── {plugin}.cs3
└── {repo}\
    └── {plugin}\
        ├── manifest.json
        ├── classes.dex
        └── ...
```

## Troubleshooting

### Plugin Installation Fails

1. Check network connectivity
2. Verify the plugin URL is accessible
3. Check disk space
4. Review logs for specific error messages

### Plugins Not Appearing

1. Ensure the repository URL is correct
2. Check that the manifest.json is valid
3. Verify itemTypes/tvTypes are set correctly

### Desktop CloudStream Not Initializing

1. Check that you're running on Linux or Windows
2. Verify DartotsuExtensionBridge.init() was called
3. Check logs for initialization errors

### "Plugin has no JS code" Error

This error occurs when trying to use a DEX-only plugin on desktop:

1. **Why it happens**: Most CloudStream plugins are compiled as DEX (Android bytecode), not JavaScript. Desktop platforms cannot execute DEX code without a JVM.

2. **Solutions**:

   - Look for JS-based plugins from community repositories
   - Wait for DEX runtime support (requires JRE + dex2jar)
   - Use the app on Android for DEX-only plugins

3. **How to identify DEX-only plugins**:
   - Plugins marked with "DEX" badge in the UI
   - `isExecutableOnDesktop == false` in the extension entity
   - Plugin bundle contains `classes.dex` but no `.js` files

### Desktop Readiness Checklist

Before using CloudStream on desktop, verify:

- [ ] Running on Linux or Windows
- [ ] `CLOUDSTREAM_ENABLE_JS_PLUGINS=true` (if using env vars)
- [ ] JS plugins installed (not DEX-only)
- [ ] Plugin storage directory is writable

For DEX runtime (experimental):

- [ ] JRE 11+ installed and in PATH
- [ ] dex2jar installed and in PATH
- [ ] `CLOUDSTREAM_ENABLE_DEX_PLUGINS=true`

## API Reference

### CloudStreamDesktopPluginMetadata

```dart
class CloudStreamDesktopPluginMetadata {
  final String internalName;      // Unique plugin identifier
  final String? displayName;      // Human-readable name
  final String? repoUrl;          // Source repository URL
  final String? downloadUrl;      // Plugin bundle URL
  final String? version;          // Plugin version
  final List<String> tvTypes;     // Content types (Anime, Movie, etc.)
  final String? lang;             // Language code
  final bool isNsfw;              // NSFW flag
  final List<int> itemTypes;      // ItemType indices
  final String? localPath;        // Local extraction path
  final String? iconUrl;          // Plugin icon URL
  final bool hasJsCode;           // Whether plugin has JS code
  final bool hasDexCode;          // Whether plugin has DEX code
}
```

### Source Model Extensions

The `Source` model includes desktop-specific fields:

```dart
class Source {
  // ... existing fields ...

  /// Whether this source can be executed on desktop platforms.
  /// For CloudStream: true if plugin has JS code, false if DEX-only.
  bool? isExecutableOnDesktop;
}
```

### ExtensionEntity Extensions

The `ExtensionEntity` includes desktop capability flags:

```dart
class ExtensionEntity {
  // ... existing fields ...

  /// Whether this extension can be executed on desktop platforms.
  /// Null means unknown (not yet checked or not applicable).
  final bool? isExecutableOnDesktop;
}
```

### Platform Channel Methods

| Method                            | Description             | Desktop Support    |
| --------------------------------- | ----------------------- | ------------------ |
| `initializePlugins`               | Initialize plugin store | ✅ Full            |
| `getPluginStatus`                 | Get plugin status       | ✅ Full            |
| `installCloudStreamPlugin`        | Install a plugin        | ✅ Full            |
| `uninstallCloudStreamPlugin`      | Uninstall a plugin      | ✅ Full            |
| `listInstalledCloudStreamPlugins` | List plugins            | ✅ Full            |
| `getInstalled*Extensions`         | Get by type             | ✅ Full            |
| `cloudstream:search`              | Search content          | ✅ JS plugins only |
| `cloudstream:getPopular`          | Get popular content     | ✅ JS plugins only |
| `cloudstream:getDetail`           | Load details            | ✅ JS plugins only |
| `cloudstream:getVideoList`        | Get video links         | ✅ JS plugins only |
| `cloudstream:loadLinks`           | Get video links         | ✅ JS plugins only |
| `cloudstream:extract`             | Extract videos          | ❌ DEX required    |
| `cloudstream:listExtractors`      | List extractors         | ❌ DEX required    |

## JS Runtime API Reference

### CloudStreamJsRuntime

The QuickJS runtime provides these CloudStream-compatible globals:

```javascript
// Logging
console.log(), console.warn(), console.error(), console.debug()

// Storage (persistent across app restarts)
await storage.get(key)       // Get stored value
await storage.set(key, value) // Store value
await storage.remove(key)    // Remove a value
await storage.clear()        // Clear all plugin storage

// Type enums
TvType.Movie, TvType.Anime, TvType.TvSeries, ...
ShowStatus.Completed, ShowStatus.Ongoing, ShowStatus.Unknown
DubStatus.Dubbed, DubStatus.Subbed
Qualities.P360, Qualities.P480, Qualities.P720, Qualities.P1080, ...

// Helper functions
newSearchResponse(name, url, type, posterUrl)
newEpisode(data, name, season, episode, posterUrl, rating, description, date)
newExtractorLink(source, name, url, referer, quality, isM3u8, headers, extractorData, type)
newSubtitleFile(lang, url)

// HTTP Client (via Dart bridge)
const client = new Client();
await client.get(url, headers)
await client.post(url, headers, body)
```

### CloudStreamJsPluginService

```dart
class CloudStreamJsPluginService {
  // Check if a plugin has executable JS code
  Future<bool> canExecutePlugin(String pluginId);

  // Execute plugin methods
  Future<CloudStreamSearchResult> search(String pluginId, String query, int page);
  Future<CloudStreamSearchResult> getPopular(String pluginId, int page);
  Future<CloudStreamDetailResult> load(String pluginId, String url);
  Future<CloudStreamVideoResult> loadLinks(String pluginId, String episodeUrl);

  // Get list of JS-executable plugins
  Future<List<String>> getExecutablePlugins();

  // Cleanup
  void disposePlugin(String pluginId);
  void disposeAll();
}
```

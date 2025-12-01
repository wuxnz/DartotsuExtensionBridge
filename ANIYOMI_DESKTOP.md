# Aniyomi Desktop Support

This document describes the Aniyomi extension support for desktop platforms (Linux and Windows).

## Overview

Aniyomi plugins are now supported on desktop platforms with the following capabilities:

- **Plugin Discovery**: Browse and discover plugins from Aniyomi repositories
- **Plugin Installation**: Download and install APK bundles
- **Plugin Management**: List, update, and uninstall installed plugins
- **Metadata Storage**: Persistent storage of plugin metadata
- **DEX Plugin Execution**: Execute Aniyomi plugins via dex2jar + JRE runtime

## Phase 0: API Inventory & Requirements

### Aniyomi Plugin API Surface

Based on analysis of the Android `AniyomiBridge.kt` and `AniyomiExtensionManager.kt`:

#### Core Methods (Required for MVP)

| Method                        | Description                           | Android Dependencies                |
| ----------------------------- | ------------------------------------- | ----------------------------------- |
| `getInstalledAnimeExtensions` | List installed anime extensions       | `ExtensionLoader`, `PackageManager` |
| `getInstalledMangaExtensions` | List installed manga extensions       | `ExtensionLoader`, `PackageManager` |
| `fetchAnimeExtensions`        | Fetch available extensions from repos | `OkHttpClient`, JSON parsing        |
| `fetchMangaExtensions`        | Fetch available extensions from repos | `OkHttpClient`, JSON parsing        |
| `search`                      | Search for content                    | Source API, coroutines              |
| `getPopular`                  | Get popular content                   | Source API, coroutines              |
| `getLatestUpdates`            | Get latest updates                    | Source API, coroutines              |
| `getDetail`                   | Get media details                     | Source API, coroutines              |
| `getVideoList`                | Get video streams                     | Source API, coroutines, OkHttp      |
| `getPageList`                 | Get manga pages                       | Source API, coroutines, OkHttp      |

#### Preference Methods (Phase 2)

| Method                 | Description            | Android Dependencies                     |
| ---------------------- | ---------------------- | ---------------------------------------- |
| `getPreference`        | Get source preferences | `PreferenceManager`, `SharedPreferences` |
| `saveSourcePreference` | Save preference value  | `SharedPreferences`                      |

### Android API Dependencies

#### Critical Dependencies (Must Emulate)

1. **Kotlin Coroutines**

   - `CoroutineScope`, `Dispatchers.IO`, `launch`, `withContext`
   - Desktop: Use Dart isolates or async/await patterns

2. **OkHttp Network Stack**

   - HTTP client with interceptors, cookies, headers
   - Desktop: Use Dart `http` package with custom client

3. **SharedPreferences**

   - Key-value storage for plugin settings
   - Desktop: JSON file or SQLite

4. **PreferenceScreen/PreferenceManager**

   - UI preference system
   - Desktop: Custom preference storage

5. **Context/Application**
   - Android application context
   - Desktop: Provide stub with essential methods

#### Secondary Dependencies (Can Stub)

1. **PackageManager** - For extension discovery (replaced by file-based discovery)
2. **DexClassLoader** - For loading extensions (replaced by dex2jar + JRE)
3. **Injekt** - Dependency injection (replaced by direct instantiation)

### Extension Package Structure

Aniyomi extensions are distributed as APK files containing:

```
extension.apk
├── AndroidManifest.xml       # Package info, version, permissions
├── classes.dex               # Compiled Kotlin/Java code
├── res/
│   └── mipmap-*/
│       └── ic_launcher.png   # Extension icon
└── META-INF/
    └── MANIFEST.MF           # JAR manifest
```

### Repository Index Format

Extensions are discovered via `index.min.json`:

```json
[
  {
    "name": "Extension Name",
    "pkg": "eu.kanade.tachiyomi.animeextension.en.example",
    "apk": "tachiyomi-en.example-v1.0.0.apk",
    "lang": "en",
    "code": 1,
    "version": "1.0.0",
    "nsfw": 0,
    "hasReadme": 0,
    "hasChangelog": 0,
    "sources": [
      {
        "name": "Example",
        "lang": "en",
        "id": 1234567890,
        "baseUrl": "https://example.com"
      }
    ]
  }
]
```

## Architecture

### Desktop vs Android

| Feature          | Android                            | Desktop                               |
| ---------------- | ---------------------------------- | ------------------------------------- |
| Extension Format | APK (installed via PackageManager) | APK (extracted, DEX converted to JAR) |
| Code Execution   | DexClassLoader                     | dex2jar + JRE                         |
| Network          | OkHttp                             | Dart http + custom interceptors       |
| Storage          | SharedPreferences                  | JSON files                            |
| Preferences      | PreferenceScreen                   | Custom UI                             |
| Coroutines       | Native Kotlin                      | JVM coroutines via bridge             |

### Implementation Details

```
lib/Aniyomi/desktop/
├── aniyomi_desktop.dart                    # Barrel export
├── aniyomi_desktop_bridge.dart             # Main bridge handling method calls
├── aniyomi_desktop_plugin_store.dart       # Metadata persistence
├── aniyomi_apk_extractor.dart              # APK extraction and parsing
├── aniyomi_desktop_config.dart             # Feature flags and configuration
├── aniyomi_host_shims.dart                 # Android API shims for Aniyomi
└── aniyomi_preference_store.dart           # SharedPreferences emulation
```

## Configuration

### Feature Flags

```bash
# Enable Aniyomi desktop support (default: false)
export ANIYOMI_ENABLE_DESKTOP=true

# Enable verbose logging
export ANIYOMI_VERBOSE_LOGGING=true

# Timeout settings (in seconds)
export ANIYOMI_DEX_TIMEOUT=60

# Memory limit (in MB)
export ANIYOMI_MAX_MEMORY_MB=512
```

### Programmatic Configuration

```dart
import 'package:dartotsu_extension_bridge/Aniyomi/desktop/aniyomi_desktop.dart';

// Access the config singleton
final config = aniyomiDesktopConfig;

// Enable Aniyomi desktop
config.enableDesktopAniyomi = true;

// Configure timeouts
config.dexTimeoutSeconds = 60;
```

## Requirements

### Runtime Requirements

1. **Java Runtime Environment (JRE) 11+**

   - Required for executing converted DEX code
   - Download: https://adoptium.net/

2. **dex2jar Tool**
   - Required for converting DEX to JAR
   - Download: https://github.com/pxb1988/dex2jar/releases

### Installation

#### Linux

```bash
# Install JRE
sudo apt install openjdk-11-jre

# Install dex2jar
wget https://github.com/pxb1988/dex2jar/releases/download/v2.4/dex2jar-2.4.zip
unzip dex2jar-2.4.zip -d ~/.local/share/dex2jar
export PATH="$PATH:$HOME/.local/share/dex2jar"
```

#### Windows

1. Install JRE from https://adoptium.net/
2. Download dex2jar and add to PATH

## Usage

### Initialization

Desktop Aniyomi support is automatically initialized when `DartotsuExtensionBridge.init()` is called on Linux or Windows:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the extension bridge
  await DartotsuExtensionBridge().init(null, 'Aniya');

  // Aniyomi desktop support is now active (if enabled)
  runApp(MyApp());
}
```

### Checking Capabilities

```dart
import 'package:dartotsu_extension_bridge/Aniyomi/desktop/aniyomi_desktop.dart';

final bridge = getAniyomiDesktopBridge();
final capabilities = bridge.getCapabilities();

print('Platform: ${capabilities['platform']}');
print('DEX Runtime Available: ${capabilities['dexRuntimeAvailable']}');
print('Can Execute Plugins: ${capabilities['canExecutePlugins']}');
```

## Limitations

### Current Limitations

1. **DEX Execution Required**: Unlike CloudStream which supports JS plugins, Aniyomi plugins are DEX-only
2. **JRE Dependency**: Requires Java Runtime Environment installed
3. **Performance**: JVM startup overhead for each plugin call
4. **Compatibility**: Some Android-specific APIs may not be fully emulated

### Not Supported (Mobile-Only)

- Plugin settings UI (preferences work but no native UI)
- WebView-based authentication
- Android-specific permissions

## Troubleshooting

### Common Issues

#### "Java not found"

Ensure JRE 11+ is installed and in PATH:

```bash
java -version
```

#### "dex2jar not found"

Ensure dex2jar is installed and in PATH:

```bash
d2j-dex2jar.sh --version  # Linux
d2j-dex2jar.bat --version  # Windows
```

#### "Plugin execution failed"

Check the logs for specific errors. Common causes:

- Missing Android API shim
- Network timeout
- Coroutine execution failure

### Diagnostics

```dart
import 'package:dartotsu_extension_bridge/Aniyomi/desktop/aniyomi_desktop.dart';

final diagnostics = AniyomiDesktopDiagnostics();
final report = await diagnostics.runDiagnostics();

print(report);
```

## Roadmap

### Phase 1 - Core Infrastructure (Current)

- [x] Plugin store and metadata schema
- [x] APK extraction pipeline
- [x] DEX runtime extensions for Aniyomi
- [x] Platform channel handlers

### Phase 2 - Emulator Services

- [ ] Android service emulation stubs
- [ ] SharedPreferences mapping
- [ ] Network stack with interceptors
- [ ] Preference UI integration

### Phase 3 - Observability & QA

- [ ] Diagnostics and telemetry
- [ ] Integration tests
- [ ] Security sandboxing
- [ ] Documentation updates

### Future Improvements

- GraalVM native image for faster startup
- Process pooling to reduce JVM overhead
- Enhanced Android API coverage
- WebView authentication support

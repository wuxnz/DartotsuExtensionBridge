# CloudStream Library Setup

This document describes how to set up the CloudStream library dependency for the DartotsuExtensionBridge.

## Prerequisites

The CloudStream library is required for loading and executing CloudStream plugins (.cs3/.zip files). Without it, you'll see errors like:

```
com.lagradost.cloudstream3.plugins.Plugin not found
```

## Setup Steps

### 1. Clone the CloudStream Repository

The CloudStream library must be cloned into `deps/cloudstream`:

```bash
cd ref/DartotsuExtensionBridge
git clone https://github.com/recloudstream/cloudstream.git deps/cloudstream
```

### 2. Verify Directory Structure

After cloning, verify the following structure exists:

```
deps/cloudstream/
├── library/
│   ├── build.gradle.kts
│   └── src/
├── gradle/
│   └── libs.versions.toml
├── settings.gradle.kts
└── ...
```

### 3. Build the CloudStream Library

From the `android` directory, run:

```bash
cd android
./gradlew :cloudstream-library:assemble
```

This should compile successfully if:

- Gradle version is compatible (check `gradle/wrapper/gradle-wrapper.properties`)
- Kotlin version matches (currently using 2.2.21)
- All dependencies resolve correctly

### 4. Verify Integration

The `settings.gradle` includes the cloudstream-library module:

```gradle
include ':cloudstream-library'
project(':cloudstream-library').projectDir = new File(rootDir, '../deps/cloudstream/library')
```

The `build.gradle` depends on it:

```gradle
implementation project(':cloudstream-library')
```

## Troubleshooting

### Gradle Version Mismatch

If you see Gradle compatibility errors, ensure the Gradle wrapper version in `deps/cloudstream/gradle/wrapper/gradle-wrapper.properties` is compatible with the bridge's Gradle version.

### Kotlin Version Mismatch

The bridge uses Kotlin 2.2.21. If CloudStream requires a different version, you may need to:

1. Update the bridge's Kotlin version, or
2. Use a compatible CloudStream branch/tag

### Missing libs.versions.toml

The `settings.gradle` references `deps/cloudstream/gradle/libs.versions.toml` for version catalogs. Ensure this file exists after cloning.

## CI/CD Integration

Add the following to your CI pipeline before building the Flutter app:

```yaml
- name: Clone CloudStream library
  run: |
    cd ref/DartotsuExtensionBridge
    if [ ! -d "deps/cloudstream" ]; then
      git clone --depth 1 https://github.com/recloudstream/cloudstream.git deps/cloudstream
    fi

- name: Build CloudStream library
  run: |
    cd ref/DartotsuExtensionBridge/android
    ./gradlew :cloudstream-library:assemble
```

## Plugin Loading Flow

1. User installs a CloudStream plugin (.cs3/.zip)
2. `CloudStreamBridge.installCloudStreamPlugin` downloads and extracts the bundle
3. `CloudStreamPluginLoader.loadPlugin` uses `DexClassLoader` to load `classes.dex`
4. The plugin's `MainAPI` class is instantiated (requires CloudStream library classes)
5. Plugin is registered in `CloudStreamPluginStore` with metadata

## Related Files

- `android/settings.gradle` - Module inclusion
- `android/build.gradle` - Dependency declaration
- `CloudStreamPluginLoader.kt` - DEX loading logic
- `CloudStreamPluginStore.kt` - Plugin metadata persistence
- `CloudStreamBridge.kt` - Flutter method channel handler

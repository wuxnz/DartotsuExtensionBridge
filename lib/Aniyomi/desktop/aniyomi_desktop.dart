/// Desktop support for Aniyomi extensions on Linux and Windows.
///
/// This library provides a pure Dart implementation of Aniyomi plugin
/// management and execution for desktop platforms. It uses dex2jar + JRE
/// to execute Aniyomi's DEX-based plugins.
///
/// ## Features
///
/// - **Plugin Discovery**: Browse and discover plugins from Aniyomi repositories
/// - **Plugin Installation**: Download and install APK bundles
/// - **Plugin Management**: List, update, and uninstall installed plugins
/// - **DEX Execution**: Execute plugins via dex2jar + JRE runtime
///
/// ## Requirements
///
/// - Java Runtime Environment (JRE) 11+
/// - dex2jar tool
///
/// ## Usage
///
/// ```dart
/// import 'package:dartotsu_extension_bridge/Aniyomi/desktop/aniyomi_desktop.dart';
///
/// // Initialize desktop Aniyomi support
/// await initializeDesktopAniyomi();
///
/// // Check if available
/// if (isDesktopAniyomiAvailable) {
///   print('Desktop Aniyomi support is active');
/// }
/// ```
///
/// ## Configuration
///
/// Set environment variables to configure:
///
/// ```bash
/// export ANIYOMI_ENABLE_DESKTOP=true
/// export ANIYOMI_DEX_TIMEOUT=60
/// export ANIYOMI_MAX_MEMORY_MB=512
/// ```
///
/// See ANIYOMI_DESKTOP.md for full documentation.
library;

export 'aniyomi_apk_extractor.dart';
export 'aniyomi_desktop_bridge.dart';
export 'aniyomi_desktop_channel_handler.dart';
export 'aniyomi_desktop_config.dart';
export 'aniyomi_desktop_plugin_store.dart';
export 'aniyomi_host_shims.dart';

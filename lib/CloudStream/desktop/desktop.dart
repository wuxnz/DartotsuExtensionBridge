/// Desktop CloudStream extension support.
///
/// This module provides CloudStream plugin management for Linux and Windows platforms.
///
/// ## Limitations
///
/// Desktop platforms have the following limitations compared to Android:
///
/// 1. **DEX Plugin Execution**: CloudStream plugins are typically compiled as Android
///    DEX files, which cannot be executed on desktop without a JVM/Dalvik runtime.
///
/// 2. **JS Plugin Support**: Some plugins may include JavaScript code that could
///    potentially be executed via QuickJS, but this requires additional integration.
///
/// 3. **Plugin Management Only**: This implementation focuses on plugin discovery,
///    installation, and metadata management. Actual content fetching from plugins
///    is not supported.
///
/// ## Usage
///
/// ```dart
/// import 'package:dartotsu_extension_bridge/CloudStream/desktop/desktop.dart';
///
/// // Set up the desktop channel handler (call once at app startup)
/// setupDesktopCloudStreamChannel();
///
/// // The CloudStreamExtensions class will automatically use the desktop bridge
/// // when running on Linux or Windows.
/// ```
library;

export 'cloudstream_desktop_bridge.dart';
export 'cloudstream_desktop_bundle_parser.dart';
export 'cloudstream_desktop_channel_handler.dart';
export 'cloudstream_desktop_config.dart';
export 'cloudstream_desktop_diagnostics.dart';
export 'cloudstream_desktop_plugin_store.dart';
export 'cloudstream_desktop_telemetry.dart';
export 'dex/dex.dart';
export 'js/js.dart';

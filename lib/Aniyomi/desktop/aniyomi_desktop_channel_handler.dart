import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'aniyomi_desktop_bridge.dart';
import 'aniyomi_desktop_config.dart';

/// Platform channel handler for Aniyomi desktop support.
///
/// Sets up the method channel to intercept calls on desktop platforms
/// and route them to the desktop bridge implementation.
class AniyomiDesktopChannelHandler {
  static AniyomiDesktopChannelHandler? _instance;
  static AniyomiDesktopChannelHandler get instance =>
      _instance ??= AniyomiDesktopChannelHandler._();

  AniyomiDesktopChannelHandler._();

  static const String _channelName = 'aniyomiExtensionBridge';

  MethodChannel? _channel;
  AniyomiDesktopBridge? _bridge;
  bool _isInitialized = false;

  /// Check if the handler is initialized.
  bool get isInitialized => _isInitialized;

  /// Get the bridge instance.
  AniyomiDesktopBridge? get bridge => _bridge;

  /// Initialize the desktop channel handler.
  ///
  /// This sets up the method channel to intercept calls and route them
  /// to the desktop bridge implementation.
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!Platform.isLinux && !Platform.isWindows) {
      debugPrint('AniyomiDesktopChannelHandler: Not a desktop platform');
      return;
    }

    if (!aniyomiDesktopConfig.enableDesktopAniyomi) {
      debugPrint('AniyomiDesktopChannelHandler: Desktop Aniyomi is disabled');
      return;
    }

    try {
      _bridge = getAniyomiDesktopBridge();
      await _bridge!.initialize();

      _channel = const MethodChannel(_channelName);
      _channel!.setMethodCallHandler(_handleMethodCall);

      _isInitialized = true;
      debugPrint('AniyomiDesktopChannelHandler initialized');
    } catch (e) {
      debugPrint('Failed to initialize AniyomiDesktopChannelHandler: $e');
      rethrow;
    }
  }

  /// Handle method calls from the platform channel.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (_bridge == null) {
      throw PlatformException(
        code: 'NOT_INITIALIZED',
        message: 'Aniyomi desktop bridge not initialized',
      );
    }

    return _bridge!.handleMethodCall(call);
  }

  /// Get capabilities of the desktop implementation.
  Map<String, dynamic> getCapabilities() {
    if (_bridge == null) {
      return {
        'platform': Platform.operatingSystem,
        'isInitialized': false,
        'isEnabled': aniyomiDesktopConfig.enableDesktopAniyomi,
        'dexRuntimeAvailable': false,
        'canExecutePlugins': false,
        'supportsPluginManagement': false,
      };
    }
    return _bridge!.getCapabilities();
  }

  /// Dispose the handler.
  Future<void> dispose() async {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _bridge = null;
    _isInitialized = false;
  }
}

/// Initialize Aniyomi desktop support.
///
/// Call this during app initialization on desktop platforms.
Future<void> initializeDesktopAniyomi() async {
  if (!Platform.isLinux && !Platform.isWindows) return;

  await AniyomiDesktopChannelHandler.instance.initialize();
}

/// Check if Aniyomi desktop support is available.
bool get isDesktopAniyomiAvailable =>
    AniyomiDesktopChannelHandler.instance.isInitialized;

/// Get the Aniyomi desktop bridge.
AniyomiDesktopBridge? getAniyomiDesktopBridgeIfAvailable() =>
    AniyomiDesktopChannelHandler.instance.bridge;

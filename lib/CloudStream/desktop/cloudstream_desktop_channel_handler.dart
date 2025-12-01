import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cloudstream_desktop_bridge.dart';

/// Desktop platform channel handler for CloudStream.
///
/// This class sets up a method channel handler on desktop platforms (Linux/Windows)
/// that routes CloudStream method calls to the Dart-based desktop bridge implementation.
///
/// On Android, the native Kotlin implementation handles these calls.
/// On desktop, we use a pure Dart implementation since DEX execution isn't possible.
class CloudStreamDesktopChannelHandler {
  static const String _channelName = 'cloudstreamExtensionBridge';
  static CloudStreamDesktopChannelHandler? _instance;
  static bool _isSetup = false;

  final CloudStreamDesktopBridge _bridge;
  MethodChannel? _channel;
  Future<ByteData?> Function(ByteData?)? _binaryHandler;

  CloudStreamDesktopChannelHandler._() : _bridge = CloudStreamDesktopBridge();

  /// Get the singleton instance.
  static CloudStreamDesktopChannelHandler get instance {
    _instance ??= CloudStreamDesktopChannelHandler._();
    return _instance!;
  }

  /// Check if we're running on a desktop platform.
  static bool get isDesktopPlatform {
    return Platform.isLinux || Platform.isWindows;
  }

  /// Set up the desktop channel handler.
  ///
  /// This should be called early in app initialization, before any
  /// CloudStreamExtensions methods are called.
  ///
  /// On non-desktop platforms, this is a no-op.
  Future<void> setup() async {
    if (!isDesktopPlatform) {
      debugPrint(
        'CloudStreamDesktopChannelHandler: Not a desktop platform, skipping setup',
      );
      return;
    }

    if (_isSetup) {
      debugPrint('CloudStreamDesktopChannelHandler: Already set up');
      return;
    }

    try {
      // Initialize the bridge first
      await _bridge.initialize();

      // Create the method channel and intercept outgoing calls so they are handled
      // by the desktop bridge rather than the missing native implementation.
      _channel = const MethodChannel(_channelName);

      final messenger = ServicesBinding.instance.defaultBinaryMessenger;
      if (_binaryHandler != null) {
        messenger.setMessageHandler(_channelName, null);
        _binaryHandler = null;
      }

      _binaryHandler = (ByteData? message) async {
        final codec = _channel!.codec;
        final methodCall = codec.decodeMethodCall(message);
        try {
          final result = await _handleMethodCall(methodCall);
          return codec.encodeSuccessEnvelope(result);
        } on PlatformException catch (e) {
          return codec.encodeErrorEnvelope(
            code: e.code,
            message: e.message,
            details: e.details,
          );
        } catch (e, stackTrace) {
          return codec.encodeErrorEnvelope(
            code: 'DESKTOP_BRIDGE_ERROR',
            message: e.toString(),
            details: stackTrace.toString(),
          );
        }
      };
      messenger.setMessageHandler(_channelName, _binaryHandler);

      _isSetup = true;
      debugPrint('CloudStreamDesktopChannelHandler: Setup complete');
    } catch (e) {
      debugPrint('CloudStreamDesktopChannelHandler: Setup failed: $e');
      rethrow;
    }
  }

  /// Handle intercepted method calls destined for the native platform.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('CloudStreamDesktopChannelHandler: ${call.method}');

    try {
      return await _bridge.handleMethodCall(call);
    } on PlatformException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('CloudStreamDesktopChannelHandler error: $e\n$stackTrace');
      throw PlatformException(
        code: 'DESKTOP_BRIDGE_ERROR',
        message: e.toString(),
        stacktrace: stackTrace.toString(),
      );
    }
  }

  /// Check if the handler is set up.
  bool get isSetup => _isSetup;

  /// Get the underlying bridge for direct access if needed.
  CloudStreamDesktopBridge get bridge => _bridge;

  /// Get desktop-specific capabilities.
  Map<String, dynamic> getCapabilities() {
    return {
      'platform': Platform.operatingSystem,
      'isDesktop': true,
      'canExecuteDexPlugins': false,
      'canExecuteJsPlugins':
          false, // TODO: Enable when QuickJS integration is complete
      'supportsPluginManagement': true,
      'supportsPluginDiscovery': true,
      'supportsPluginInstallation': true,
      'supportsPluginUninstallation': true,
    };
  }
}

/// Initialize the desktop CloudStream channel handler.
///
/// Call this early in your app's initialization, typically in main() or
/// before initializing DartotsuExtensionBridge.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeDesktopCloudStream();
///   // ... rest of initialization
/// }
/// ```
Future<void> initializeDesktopCloudStream() async {
  if (!CloudStreamDesktopChannelHandler.isDesktopPlatform) {
    return;
  }

  try {
    await CloudStreamDesktopChannelHandler.instance.setup();
  } catch (e) {
    debugPrint('Failed to initialize desktop CloudStream: $e');
    // Don't rethrow - allow app to continue without CloudStream support
  }
}

/// Check if desktop CloudStream support is available.
bool get isDesktopCloudStreamAvailable {
  return CloudStreamDesktopChannelHandler.isDesktopPlatform &&
      CloudStreamDesktopChannelHandler.instance.isSetup;
}

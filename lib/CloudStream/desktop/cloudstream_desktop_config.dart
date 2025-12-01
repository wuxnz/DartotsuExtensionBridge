import 'dart:io';

import 'package:flutter/foundation.dart';

/// Configuration for CloudStream desktop plugin execution.
///
/// This class manages feature flags and settings for JS and DEX plugin
/// execution on desktop platforms.
class CloudStreamDesktopConfig {
  static CloudStreamDesktopConfig? _instance;

  /// Get the singleton instance.
  static CloudStreamDesktopConfig get instance {
    _instance ??= CloudStreamDesktopConfig._();
    return _instance!;
  }

  CloudStreamDesktopConfig._() {
    _loadFromEnvironment();
  }

  // Feature flags
  bool _enableDesktopJsPlugins = false;
  bool _enableDesktopDexPlugins = false;
  bool _enableTelemetry = true;
  bool _enableVerboseLogging = false;

  // Runtime configuration
  int _jsTimeoutSeconds = 30;
  int _dexTimeoutSeconds = 60;
  int _maxMemoryMb = 256;

  /// Whether JS plugin execution is enabled on desktop.
  bool get enableDesktopJsPlugins => _enableDesktopJsPlugins;
  set enableDesktopJsPlugins(bool value) {
    _enableDesktopJsPlugins = value;
    debugPrint('CloudStream: JS plugins ${value ? 'enabled' : 'disabled'}');
  }

  /// Whether DEX plugin execution is enabled on desktop (experimental).
  bool get enableDesktopDexPlugins => _enableDesktopDexPlugins;
  set enableDesktopDexPlugins(bool value) {
    _enableDesktopDexPlugins = value;
    debugPrint('CloudStream: DEX plugins ${value ? 'enabled' : 'disabled'}');
  }

  /// Whether telemetry/instrumentation is enabled.
  bool get enableTelemetry => _enableTelemetry;
  set enableTelemetry(bool value) => _enableTelemetry = value;

  /// Whether verbose logging is enabled.
  bool get enableVerboseLogging => _enableVerboseLogging;
  set enableVerboseLogging(bool value) => _enableVerboseLogging = value;

  /// Timeout for JS plugin operations in seconds.
  int get jsTimeoutSeconds => _jsTimeoutSeconds;
  set jsTimeoutSeconds(int value) => _jsTimeoutSeconds = value.clamp(5, 120);

  /// Timeout for DEX plugin operations in seconds.
  int get dexTimeoutSeconds => _dexTimeoutSeconds;
  set dexTimeoutSeconds(int value) => _dexTimeoutSeconds = value.clamp(10, 300);

  /// Maximum memory allocation for plugin runtimes in MB.
  int get maxMemoryMb => _maxMemoryMb;
  set maxMemoryMb(int value) => _maxMemoryMb = value.clamp(64, 1024);

  /// Load configuration from environment variables.
  void _loadFromEnvironment() {
    final env = Platform.environment;

    // Feature flags from environment
    if (env.containsKey('CLOUDSTREAM_ENABLE_JS_PLUGINS')) {
      _enableDesktopJsPlugins =
          env['CLOUDSTREAM_ENABLE_JS_PLUGINS']?.toLowerCase() == 'true';
    }

    if (env.containsKey('CLOUDSTREAM_ENABLE_DEX_PLUGINS')) {
      _enableDesktopDexPlugins =
          env['CLOUDSTREAM_ENABLE_DEX_PLUGINS']?.toLowerCase() == 'true';
    }

    if (env.containsKey('CLOUDSTREAM_ENABLE_TELEMETRY')) {
      _enableTelemetry =
          env['CLOUDSTREAM_ENABLE_TELEMETRY']?.toLowerCase() != 'false';
    }

    if (env.containsKey('CLOUDSTREAM_VERBOSE_LOGGING')) {
      _enableVerboseLogging =
          env['CLOUDSTREAM_VERBOSE_LOGGING']?.toLowerCase() == 'true';
    }

    // Timeouts from environment
    if (env.containsKey('CLOUDSTREAM_JS_TIMEOUT')) {
      _jsTimeoutSeconds =
          int.tryParse(env['CLOUDSTREAM_JS_TIMEOUT'] ?? '') ??
          _jsTimeoutSeconds;
    }

    if (env.containsKey('CLOUDSTREAM_DEX_TIMEOUT')) {
      _dexTimeoutSeconds =
          int.tryParse(env['CLOUDSTREAM_DEX_TIMEOUT'] ?? '') ??
          _dexTimeoutSeconds;
    }

    if (env.containsKey('CLOUDSTREAM_MAX_MEMORY_MB')) {
      _maxMemoryMb =
          int.tryParse(env['CLOUDSTREAM_MAX_MEMORY_MB'] ?? '') ?? _maxMemoryMb;
    }

    debugPrint(
      'CloudStream config loaded: '
      'JS=$_enableDesktopJsPlugins, '
      'DEX=$_enableDesktopDexPlugins, '
      'telemetry=$_enableTelemetry',
    );
  }

  /// Export current configuration as a map.
  Map<String, dynamic> toJson() => {
    'enableDesktopJsPlugins': _enableDesktopJsPlugins,
    'enableDesktopDexPlugins': _enableDesktopDexPlugins,
    'enableTelemetry': _enableTelemetry,
    'enableVerboseLogging': _enableVerboseLogging,
    'jsTimeoutSeconds': _jsTimeoutSeconds,
    'dexTimeoutSeconds': _dexTimeoutSeconds,
    'maxMemoryMb': _maxMemoryMb,
  };

  /// Apply configuration from a map.
  void fromJson(Map<String, dynamic> json) {
    if (json.containsKey('enableDesktopJsPlugins')) {
      _enableDesktopJsPlugins =
          json['enableDesktopJsPlugins'] as bool? ?? false;
    }
    if (json.containsKey('enableDesktopDexPlugins')) {
      _enableDesktopDexPlugins =
          json['enableDesktopDexPlugins'] as bool? ?? false;
    }
    if (json.containsKey('enableTelemetry')) {
      _enableTelemetry = json['enableTelemetry'] as bool? ?? true;
    }
    if (json.containsKey('enableVerboseLogging')) {
      _enableVerboseLogging = json['enableVerboseLogging'] as bool? ?? false;
    }
    if (json.containsKey('jsTimeoutSeconds')) {
      jsTimeoutSeconds = json['jsTimeoutSeconds'] as int? ?? 30;
    }
    if (json.containsKey('dexTimeoutSeconds')) {
      dexTimeoutSeconds = json['dexTimeoutSeconds'] as int? ?? 60;
    }
    if (json.containsKey('maxMemoryMb')) {
      maxMemoryMb = json['maxMemoryMb'] as int? ?? 256;
    }
  }

  /// Reset to default values.
  void reset() {
    _enableDesktopJsPlugins = false;
    _enableDesktopDexPlugins = false;
    _enableTelemetry = true;
    _enableVerboseLogging = false;
    _jsTimeoutSeconds = 30;
    _dexTimeoutSeconds = 60;
    _maxMemoryMb = 256;
  }
}

/// Shorthand accessor for the config singleton.
CloudStreamDesktopConfig get cloudstreamConfig =>
    CloudStreamDesktopConfig.instance;

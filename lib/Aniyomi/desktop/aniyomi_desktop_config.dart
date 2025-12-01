import 'dart:io';

/// Configuration for Aniyomi desktop plugin execution.
///
/// This singleton manages feature flags and settings for Aniyomi plugin
/// execution on desktop platforms (Linux/Windows).
class AniyomiDesktopConfig {
  static AniyomiDesktopConfig? _instance;
  static AniyomiDesktopConfig get instance =>
      _instance ??= AniyomiDesktopConfig._();

  AniyomiDesktopConfig._() {
    _loadFromEnvironment();
  }

  // Feature flags
  bool _enableDesktopAniyomi = false;
  bool _enableTelemetry = true;
  bool _verboseLogging = false;

  // Timeout settings
  int _dexTimeoutSeconds = 60;
  int _networkTimeoutSeconds = 30;

  // Memory settings
  int _maxMemoryMb = 512;

  // Paths
  String? _javaPath;
  String? _dex2jarPath;

  /// Enable/disable Aniyomi desktop support.
  bool get enableDesktopAniyomi => _enableDesktopAniyomi;
  set enableDesktopAniyomi(bool value) => _enableDesktopAniyomi = value;

  /// Enable/disable telemetry collection.
  bool get enableTelemetry => _enableTelemetry;
  set enableTelemetry(bool value) => _enableTelemetry = value;

  /// Enable/disable verbose logging.
  bool get verboseLogging => _verboseLogging;
  set verboseLogging(bool value) => _verboseLogging = value;

  /// DEX execution timeout in seconds.
  int get dexTimeoutSeconds => _dexTimeoutSeconds;
  set dexTimeoutSeconds(int value) => _dexTimeoutSeconds = value;

  /// Network request timeout in seconds.
  int get networkTimeoutSeconds => _networkTimeoutSeconds;
  set networkTimeoutSeconds(int value) => _networkTimeoutSeconds = value;

  /// Maximum memory for JVM in MB.
  int get maxMemoryMb => _maxMemoryMb;
  set maxMemoryMb(int value) => _maxMemoryMb = value;

  /// Custom Java path (null = auto-detect).
  String? get javaPath => _javaPath;
  set javaPath(String? value) => _javaPath = value;

  /// Custom dex2jar path (null = auto-detect).
  String? get dex2jarPath => _dex2jarPath;
  set dex2jarPath(String? value) => _dex2jarPath = value;

  /// DEX execution timeout as Duration.
  Duration get dexTimeout => Duration(seconds: _dexTimeoutSeconds);

  /// Network timeout as Duration.
  Duration get networkTimeout => Duration(seconds: _networkTimeoutSeconds);

  /// Load configuration from environment variables.
  void _loadFromEnvironment() {
    final env = Platform.environment;

    // Feature flags
    if (env['ANIYOMI_ENABLE_DESKTOP']?.toLowerCase() == 'true') {
      _enableDesktopAniyomi = true;
    }
    if (env['ANIYOMI_ENABLE_TELEMETRY']?.toLowerCase() == 'false') {
      _enableTelemetry = false;
    }
    if (env['ANIYOMI_VERBOSE_LOGGING']?.toLowerCase() == 'true') {
      _verboseLogging = true;
    }

    // Timeouts
    if (env['ANIYOMI_DEX_TIMEOUT'] != null) {
      _dexTimeoutSeconds =
          int.tryParse(env['ANIYOMI_DEX_TIMEOUT']!) ?? _dexTimeoutSeconds;
    }
    if (env['ANIYOMI_NETWORK_TIMEOUT'] != null) {
      _networkTimeoutSeconds =
          int.tryParse(env['ANIYOMI_NETWORK_TIMEOUT']!) ??
          _networkTimeoutSeconds;
    }

    // Memory
    if (env['ANIYOMI_MAX_MEMORY_MB'] != null) {
      _maxMemoryMb =
          int.tryParse(env['ANIYOMI_MAX_MEMORY_MB']!) ?? _maxMemoryMb;
    }

    // Paths
    _javaPath = env['ANIYOMI_JAVA_PATH'];
    _dex2jarPath = env['ANIYOMI_DEX2JAR_PATH'];
  }

  /// Reload configuration from environment.
  void reload() => _loadFromEnvironment();

  /// Export configuration to JSON.
  Map<String, dynamic> toJson() => {
    'enableDesktopAniyomi': _enableDesktopAniyomi,
    'enableTelemetry': _enableTelemetry,
    'verboseLogging': _verboseLogging,
    'dexTimeoutSeconds': _dexTimeoutSeconds,
    'networkTimeoutSeconds': _networkTimeoutSeconds,
    'maxMemoryMb': _maxMemoryMb,
    'javaPath': _javaPath,
    'dex2jarPath': _dex2jarPath,
  };

  /// Import configuration from JSON.
  void fromJson(Map<String, dynamic> json) {
    _enableDesktopAniyomi =
        json['enableDesktopAniyomi'] ?? _enableDesktopAniyomi;
    _enableTelemetry = json['enableTelemetry'] ?? _enableTelemetry;
    _verboseLogging = json['verboseLogging'] ?? _verboseLogging;
    _dexTimeoutSeconds = json['dexTimeoutSeconds'] ?? _dexTimeoutSeconds;
    _networkTimeoutSeconds =
        json['networkTimeoutSeconds'] ?? _networkTimeoutSeconds;
    _maxMemoryMb = json['maxMemoryMb'] ?? _maxMemoryMb;
    _javaPath = json['javaPath'];
    _dex2jarPath = json['dex2jarPath'];
  }

  @override
  String toString() => 'AniyomiDesktopConfig(${toJson()})';
}

/// Global config instance.
AniyomiDesktopConfig get aniyomiDesktopConfig => AniyomiDesktopConfig.instance;

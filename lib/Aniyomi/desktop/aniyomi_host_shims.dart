import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Android API shims for Aniyomi plugin execution on desktop.
///
/// Provides emulation of Android APIs that Aniyomi plugins depend on:
/// - SharedPreferences
/// - Context/Application
/// - Network (OkHttp-compatible)
/// - Coroutines (via JVM)
class AniyomiHostShims {
  final String pluginId;
  final String pluginDir;

  late final AniyomiSharedPreferences sharedPreferences;
  late final AniyomiContextShim context;
  late final AniyomiNetworkShim network;

  AniyomiHostShims({required this.pluginId, required this.pluginDir}) {
    sharedPreferences = AniyomiSharedPreferences(
      path.join(pluginDir, 'preferences.json'),
    );
    context = AniyomiContextShim(pluginId: pluginId, pluginDir: pluginDir);
    network = AniyomiNetworkShim();
  }

  /// Initialize all shims.
  Future<void> initialize() async {
    await sharedPreferences.load();
  }

  /// Dispose all shims.
  Future<void> dispose() async {
    await sharedPreferences.save();
  }

  /// Export shim configuration for JVM bridge.
  Map<String, dynamic> toJvmConfig() => {
    'pluginId': pluginId,
    'pluginDir': pluginDir,
    'preferencesPath': sharedPreferences.filePath,
    'userAgent': network.userAgent,
    'locale': context.locale,
  };
}

/// SharedPreferences emulation using JSON file storage.
class AniyomiSharedPreferences {
  final String filePath;
  final Map<String, dynamic> _data = {};
  bool _isDirty = false;

  AniyomiSharedPreferences(this.filePath);

  /// Load preferences from disk.
  Future<void> load() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _data.clear();
        _data.addAll(json);
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Save preferences to disk.
  Future<void> save() async {
    if (!_isDirty) return;

    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(_data),
      );
      _isDirty = false;
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  // String operations
  String? getString(String key, {String? defaultValue}) =>
      _data[key] as String? ?? defaultValue;

  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    _isDirty = true;
    return true;
  }

  // Int operations
  int getInt(String key, {int defaultValue = 0}) =>
      (_data[key] as num?)?.toInt() ?? defaultValue;

  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    _isDirty = true;
    return true;
  }

  // Bool operations
  bool getBool(String key, {bool defaultValue = false}) =>
      _data[key] as bool? ?? defaultValue;

  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    _isDirty = true;
    return true;
  }

  // Float operations
  double getFloat(String key, {double defaultValue = 0.0}) =>
      (_data[key] as num?)?.toDouble() ?? defaultValue;

  Future<bool> setFloat(String key, double value) async {
    _data[key] = value;
    _isDirty = true;
    return true;
  }

  // Long operations (stored as int in Dart)
  int getLong(String key, {int defaultValue = 0}) =>
      (_data[key] as num?)?.toInt() ?? defaultValue;

  Future<bool> setLong(String key, int value) async {
    _data[key] = value;
    _isDirty = true;
    return true;
  }

  // StringSet operations
  Set<String> getStringSet(String key, {Set<String>? defaultValue}) {
    final list = _data[key] as List<dynamic>?;
    if (list == null) return defaultValue ?? {};
    return list.map((e) => e.toString()).toSet();
  }

  Future<bool> setStringSet(String key, Set<String> value) async {
    _data[key] = value.toList();
    _isDirty = true;
    return true;
  }

  // Remove and contains
  Future<bool> remove(String key) async {
    _data.remove(key);
    _isDirty = true;
    return true;
  }

  bool contains(String key) => _data.containsKey(key);

  // Get all keys
  Set<String> getKeys() => _data.keys.toSet();

  // Get all data
  Map<String, dynamic> getAll() => Map.unmodifiable(_data);

  // Clear all
  Future<bool> clear() async {
    _data.clear();
    _isDirty = true;
    return true;
  }

  /// Export for JVM bridge.
  Map<String, dynamic> toJson() => Map.from(_data);

  /// Import from JVM bridge.
  void fromJson(Map<String, dynamic> json) {
    _data.clear();
    _data.addAll(json);
    _isDirty = true;
  }
}

/// Android Context emulation.
class AniyomiContextShim {
  final String pluginId;
  final String pluginDir;

  AniyomiContextShim({required this.pluginId, required this.pluginDir});

  /// Get the package name.
  String get packageName => pluginId;

  /// Get the files directory.
  String get filesDir => path.join(pluginDir, 'files');

  /// Get the cache directory.
  String get cacheDir => path.join(pluginDir, 'cache');

  /// Get the current locale.
  String get locale => Platform.localeName.split('_').first;

  /// Get the full locale with country.
  String get localeWithCountry => Platform.localeName;

  /// Check if network is available.
  Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Get string resource (stub - returns key).
  String getString(String key) => key;

  /// Get string resource with format args (stub).
  String getStringFormatted(String key, List<dynamic> args) {
    var result = key;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('%${i + 1}\$s', args[i].toString());
      result = result.replaceAll('%s', args[i].toString());
    }
    return result;
  }

  /// Export for JVM bridge.
  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'filesDir': filesDir,
    'cacheDir': cacheDir,
    'locale': locale,
    'localeWithCountry': localeWithCountry,
  };
}

/// Network shim for OkHttp-compatible operations.
class AniyomiNetworkShim {
  String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  final Map<String, String> _defaultHeaders = {};
  final Map<String, String> _cookies = {};

  String get userAgent => _userAgent;
  set userAgent(String value) => _userAgent = value;

  Map<String, String> get defaultHeaders => Map.unmodifiable(_defaultHeaders);

  /// Set a default header.
  void setDefaultHeader(String key, String value) {
    _defaultHeaders[key] = value;
  }

  /// Remove a default header.
  void removeDefaultHeader(String key) {
    _defaultHeaders.remove(key);
  }

  /// Get cookies for a domain.
  Map<String, String> getCookies(String domain) {
    return Map.fromEntries(
      _cookies.entries.where((e) => e.key.startsWith('$domain:')),
    );
  }

  /// Set a cookie.
  void setCookie(String domain, String name, String value) {
    _cookies['$domain:$name'] = value;
  }

  /// Clear cookies for a domain.
  void clearCookies(String domain) {
    _cookies.removeWhere((key, _) => key.startsWith('$domain:'));
  }

  /// Clear all cookies.
  void clearAllCookies() {
    _cookies.clear();
  }

  /// Build headers for a request.
  Map<String, String> buildHeaders({
    String? referer,
    Map<String, String>? extra,
  }) {
    return {
      'User-Agent': _userAgent,
      ..._defaultHeaders,
      if (referer != null) 'Referer': referer,
      ...?extra,
    };
  }

  /// Export for JVM bridge.
  Map<String, dynamic> toJson() => {
    'userAgent': _userAgent,
    'defaultHeaders': _defaultHeaders,
    'cookies': _cookies,
  };

  /// Import from JVM bridge.
  void fromJson(Map<String, dynamic> json) {
    _userAgent = json['userAgent'] as String? ?? _userAgent;
    if (json['defaultHeaders'] != null) {
      _defaultHeaders.clear();
      _defaultHeaders.addAll(
        Map<String, String>.from(json['defaultHeaders'] as Map),
      );
    }
    if (json['cookies'] != null) {
      _cookies.clear();
      _cookies.addAll(Map<String, String>.from(json['cookies'] as Map));
    }
  }
}

/// Logging shim for Aniyomi plugins.
class AniyomiLogShim {
  final String tag;
  final bool verbose;

  AniyomiLogShim({required this.tag, this.verbose = false});

  void d(String message) {
    if (verbose) debugPrint('[$tag] D: $message');
  }

  void i(String message) {
    debugPrint('[$tag] I: $message');
  }

  void w(String message) {
    debugPrint('[$tag] W: $message');
  }

  void e(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[$tag] E: $message');
    if (error != null) debugPrint('[$tag] E: $error');
    if (stackTrace != null) debugPrint('[$tag] E: $stackTrace');
  }
}

/// Crypto shim for common operations.
class AniyomiCryptoShim {
  /// Base64 encode.
  String base64Encode(List<int> bytes) => base64.encode(bytes);

  /// Base64 decode.
  List<int> base64Decode(String encoded) => base64.decode(encoded);

  /// URL encode.
  String urlEncode(String value) => Uri.encodeComponent(value);

  /// URL decode.
  String urlDecode(String value) => Uri.decodeComponent(value);
}

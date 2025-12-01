import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Host API shims that mirror Android services for DEX plugin execution.
///
/// These shims provide the same API surface that CloudStream plugins expect
/// on Android, but implemented in Dart for desktop platforms.
class HostApiShims {
  final HttpShim _httpShim;
  final StorageShim _storageShim;
  final CryptoShim _cryptoShim;
  final LoggingShim _loggingShim;

  HostApiShims(String pluginId)
    : _httpShim = HttpShim(),
      _storageShim = StorageShim(pluginId),
      _cryptoShim = CryptoShim(),
      _loggingShim = LoggingShim(pluginId);

  /// Initialize all shims.
  Future<void> initialize() async {
    await _storageShim.initialize();
  }

  /// Get the HTTP shim.
  HttpShim get http => _httpShim;

  /// Get the storage shim.
  StorageShim get storage => _storageShim;

  /// Get the crypto shim.
  CryptoShim get crypto => _cryptoShim;

  /// Get the logging shim.
  LoggingShim get logging => _loggingShim;

  /// Handle a host API call from the plugin.
  Future<Map<String, dynamic>> handleCall(
    String api,
    String method,
    Map<String, dynamic> args,
  ) async {
    try {
      switch (api) {
        case 'http':
          return await _httpShim.handleCall(method, args);
        case 'storage':
          return await _storageShim.handleCall(method, args);
        case 'crypto':
          return _cryptoShim.handleCall(method, args);
        case 'log':
          return _loggingShim.handleCall(method, args);
        default:
          return {'error': 'Unknown API: $api'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Dispose of resources.
  Future<void> dispose() async {
    await _storageShim.dispose();
  }
}

/// HTTP client shim for network requests.
class HttpShim {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> handleCall(
    String method,
    Map<String, dynamic> args,
  ) async {
    switch (method) {
      case 'get':
        return _get(args);
      case 'post':
        return _post(args);
      case 'head':
        return _head(args);
      default:
        return {'error': 'Unknown HTTP method: $method'};
    }
  }

  Future<Map<String, dynamic>> _get(Map<String, dynamic> args) async {
    final url = args['url'] as String;
    final headers = _parseHeaders(args['headers']);

    try {
      final response = await _client.get(Uri.parse(url), headers: headers);
      return _responseToMap(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _post(Map<String, dynamic> args) async {
    final url = args['url'] as String;
    final headers = _parseHeaders(args['headers']);
    final body = args['body'];

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: body is String ? body : jsonEncode(body),
      );
      return _responseToMap(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _head(Map<String, dynamic> args) async {
    final url = args['url'] as String;
    final headers = _parseHeaders(args['headers']);

    try {
      final response = await _client.head(Uri.parse(url), headers: headers);
      return _responseToMap(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Map<String, String>? _parseHeaders(dynamic headers) {
    if (headers == null) return null;
    if (headers is Map) {
      return headers.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return null;
  }

  Map<String, dynamic> _responseToMap(http.Response response) {
    return {
      'statusCode': response.statusCode,
      'body': response.body,
      'headers': response.headers,
      'isRedirect': response.isRedirect,
      'contentLength': response.contentLength,
    };
  }

  void dispose() {
    _client.close();
  }
}

/// Storage shim for plugin preferences and data.
class StorageShim {
  final String _pluginId;
  late Directory _storageDir;
  late File _prefsFile;
  Map<String, dynamic> _prefs = {};
  bool _initialized = false;

  StorageShim(this._pluginId);

  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _storageDir = Directory(
      path.join(appDir.path, 'cloudstream_plugins', _pluginId, 'storage'),
    );

    if (!await _storageDir.exists()) {
      await _storageDir.create(recursive: true);
    }

    _prefsFile = File(path.join(_storageDir.path, 'preferences.json'));
    await _loadPrefs();

    _initialized = true;
  }

  Future<void> _loadPrefs() async {
    try {
      if (await _prefsFile.exists()) {
        final content = await _prefsFile.readAsString();
        _prefs = jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading preferences for $_pluginId: $e');
      _prefs = {};
    }
  }

  Future<void> _savePrefs() async {
    try {
      await _prefsFile.writeAsString(jsonEncode(_prefs));
    } catch (e) {
      debugPrint('Error saving preferences for $_pluginId: $e');
    }
  }

  Future<Map<String, dynamic>> handleCall(
    String method,
    Map<String, dynamic> args,
  ) async {
    if (!_initialized) {
      await initialize();
    }

    switch (method) {
      case 'get':
        final key = args['key'] as String;
        return {'value': _prefs[key]};

      case 'set':
        final key = args['key'] as String;
        final value = args['value'];
        _prefs[key] = value;
        await _savePrefs();
        return {'success': true};

      case 'remove':
        final key = args['key'] as String;
        _prefs.remove(key);
        await _savePrefs();
        return {'success': true};

      case 'clear':
        _prefs.clear();
        await _savePrefs();
        return {'success': true};

      case 'keys':
        return {'keys': _prefs.keys.toList()};

      case 'getAll':
        return {'data': _prefs};

      case 'writeFile':
        return _writeFile(args);

      case 'readFile':
        return _readFile(args);

      case 'deleteFile':
        return _deleteFile(args);

      case 'fileExists':
        return _fileExists(args);

      default:
        return {'error': 'Unknown storage method: $method'};
    }
  }

  Future<Map<String, dynamic>> _writeFile(Map<String, dynamic> args) async {
    final filename = args['filename'] as String;
    final content = args['content'];
    final file = File(path.join(_storageDir.path, filename));

    try {
      if (content is String) {
        await file.writeAsString(content);
      } else if (content is List<int>) {
        await file.writeAsBytes(content);
      } else {
        await file.writeAsString(jsonEncode(content));
      }
      return {'success': true, 'path': file.path};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _readFile(Map<String, dynamic> args) async {
    final filename = args['filename'] as String;
    final asBytes = args['asBytes'] as bool? ?? false;
    final file = File(path.join(_storageDir.path, filename));

    try {
      if (!await file.exists()) {
        return {'error': 'File not found'};
      }

      if (asBytes) {
        final bytes = await file.readAsBytes();
        return {'content': bytes};
      } else {
        final content = await file.readAsString();
        return {'content': content};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _deleteFile(Map<String, dynamic> args) async {
    final filename = args['filename'] as String;
    final file = File(path.join(_storageDir.path, filename));

    try {
      if (await file.exists()) {
        await file.delete();
      }
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _fileExists(Map<String, dynamic> args) async {
    final filename = args['filename'] as String;
    final file = File(path.join(_storageDir.path, filename));
    return {'exists': await file.exists()};
  }

  Future<void> dispose() async {
    // Save any pending changes
    await _savePrefs();
  }
}

/// Crypto shim for hashing and encoding.
class CryptoShim {
  Map<String, dynamic> handleCall(String method, Map<String, dynamic> args) {
    switch (method) {
      case 'md5':
        return _hash(md5, args);
      case 'sha1':
        return _hash(sha1, args);
      case 'sha256':
        return _hash(sha256, args);
      case 'sha512':
        return _hash(sha512, args);
      case 'base64Encode':
        return _base64Encode(args);
      case 'base64Decode':
        return _base64Decode(args);
      case 'urlEncode':
        return _urlEncode(args);
      case 'urlDecode':
        return _urlDecode(args);
      default:
        return {'error': 'Unknown crypto method: $method'};
    }
  }

  Map<String, dynamic> _hash(Hash algorithm, Map<String, dynamic> args) {
    final input = args['input'] as String;
    final digest = algorithm.convert(utf8.encode(input));
    return {'hash': digest.toString()};
  }

  Map<String, dynamic> _base64Encode(Map<String, dynamic> args) {
    final input = args['input'];
    if (input is String) {
      return {'result': base64Encode(utf8.encode(input))};
    } else if (input is List<int>) {
      return {'result': base64Encode(input)};
    }
    return {'error': 'Invalid input type'};
  }

  Map<String, dynamic> _base64Decode(Map<String, dynamic> args) {
    final input = args['input'] as String;
    try {
      final bytes = base64Decode(input);
      final asString = args['asString'] as bool? ?? true;
      if (asString) {
        return {'result': utf8.decode(bytes)};
      } else {
        return {'result': bytes};
      }
    } catch (e) {
      return {'error': 'Invalid base64: $e'};
    }
  }

  Map<String, dynamic> _urlEncode(Map<String, dynamic> args) {
    final input = args['input'] as String;
    return {'result': Uri.encodeComponent(input)};
  }

  Map<String, dynamic> _urlDecode(Map<String, dynamic> args) {
    final input = args['input'] as String;
    try {
      return {'result': Uri.decodeComponent(input)};
    } catch (e) {
      return {'error': 'Invalid URL encoding: $e'};
    }
  }
}

/// Logging shim for plugin debug output.
class LoggingShim {
  final String _pluginId;
  final List<LogEntry> _logs = [];
  static const int _maxLogs = 1000;

  LoggingShim(this._pluginId);

  Map<String, dynamic> handleCall(String method, Map<String, dynamic> args) {
    switch (method) {
      case 'debug':
        return _log(LogLevel.debug, args);
      case 'info':
        return _log(LogLevel.info, args);
      case 'warn':
        return _log(LogLevel.warn, args);
      case 'error':
        return _log(LogLevel.error, args);
      case 'getLogs':
        return _getLogs(args);
      case 'clearLogs':
        _logs.clear();
        return {'success': true};
      default:
        return {'error': 'Unknown log method: $method'};
    }
  }

  Map<String, dynamic> _log(LogLevel level, Map<String, dynamic> args) {
    final message = args['message'] as String;
    final tag = args['tag'] as String?;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      pluginId: _pluginId,
      tag: tag,
      message: message,
    );

    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Also print to debug console
    debugPrint(
      '[$_pluginId][${level.name}]${tag != null ? '[$tag]' : ''} $message',
    );

    return {'success': true};
  }

  Map<String, dynamic> _getLogs(Map<String, dynamic> args) {
    final level = args['level'] as String?;
    final limit = args['limit'] as int? ?? 100;

    var logs = _logs;
    if (level != null) {
      final filterLevel = LogLevel.values.firstWhere(
        (l) => l.name == level,
        orElse: () => LogLevel.debug,
      );
      logs = logs.where((l) => l.level.index >= filterLevel.index).toList();
    }

    final result = logs.reversed.take(limit).map((l) => l.toJson()).toList();
    return {'logs': result};
  }
}

/// Log level enum.
enum LogLevel { debug, info, warn, error }

/// A log entry.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String pluginId;
  final String? tag;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.pluginId,
    this.tag,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': level.name,
    'pluginId': pluginId,
    'tag': tag,
    'message': message,
  };
}

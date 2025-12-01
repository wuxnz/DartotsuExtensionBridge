import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Persistent storage service for CloudStream JS plugins.
///
/// Provides a simple key-value storage mechanism that persists across
/// app restarts. Each plugin has its own isolated storage namespace.
class CloudStreamJsStorage {
  static CloudStreamJsStorage? _instance;

  /// Get the singleton instance.
  static CloudStreamJsStorage get instance {
    _instance ??= CloudStreamJsStorage._();
    return _instance!;
  }

  CloudStreamJsStorage._();

  /// In-memory cache of plugin storage.
  final Map<String, Map<String, dynamic>> _cache = {};

  /// Whether the storage has been initialized.
  bool _isInitialized = false;

  /// The base directory for storage files.
  Directory? _storageDir;

  /// Initialize the storage service.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final platformDir = Platform.isWindows ? 'windows' : 'linux';
      _storageDir = Directory(
        path.join(appDir.path, 'Aniya', platformDir, 'cloudstream_storage'),
      );

      if (!await _storageDir!.exists()) {
        await _storageDir!.create(recursive: true);
      }

      _isInitialized = true;
      debugPrint('CloudStreamJsStorage initialized at ${_storageDir!.path}');
    } catch (e) {
      debugPrint('Failed to initialize CloudStreamJsStorage: $e');
      rethrow;
    }
  }

  /// Get the storage file path for a plugin.
  File _getStorageFile(String pluginId) {
    final sanitizedId = pluginId.replaceAll(RegExp(r'[^\w\-.]'), '_');
    return File(path.join(_storageDir!.path, '$sanitizedId.json'));
  }

  /// Load storage for a plugin from disk.
  Future<Map<String, dynamic>> _loadPluginStorage(String pluginId) async {
    if (_cache.containsKey(pluginId)) {
      return _cache[pluginId]!;
    }

    final file = _getStorageFile(pluginId);
    if (!await file.exists()) {
      _cache[pluginId] = {};
      return _cache[pluginId]!;
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      _cache[pluginId] = data;
      return data;
    } catch (e) {
      debugPrint('Failed to load storage for $pluginId: $e');
      _cache[pluginId] = {};
      return _cache[pluginId]!;
    }
  }

  /// Save storage for a plugin to disk.
  Future<void> _savePluginStorage(String pluginId) async {
    final data = _cache[pluginId];
    if (data == null) return;

    final file = _getStorageFile(pluginId);
    try {
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to save storage for $pluginId: $e');
    }
  }

  /// Get a value from plugin storage.
  Future<dynamic> get(String pluginId, String key) async {
    await initialize();
    final storage = await _loadPluginStorage(pluginId);
    return storage[key];
  }

  /// Set a value in plugin storage.
  Future<bool> set(String pluginId, String key, dynamic value) async {
    await initialize();
    final storage = await _loadPluginStorage(pluginId);
    storage[key] = value;
    await _savePluginStorage(pluginId);
    return true;
  }

  /// Remove a value from plugin storage.
  Future<bool> remove(String pluginId, String key) async {
    await initialize();
    final storage = await _loadPluginStorage(pluginId);
    storage.remove(key);
    await _savePluginStorage(pluginId);
    return true;
  }

  /// Clear all storage for a plugin.
  Future<bool> clear(String pluginId) async {
    await initialize();
    _cache[pluginId] = {};
    final file = _getStorageFile(pluginId);
    if (await file.exists()) {
      await file.delete();
    }
    return true;
  }

  /// Get all keys for a plugin.
  Future<List<String>> getKeys(String pluginId) async {
    await initialize();
    final storage = await _loadPluginStorage(pluginId);
    return storage.keys.toList();
  }

  /// Get all values for a plugin.
  Future<Map<String, dynamic>> getAll(String pluginId) async {
    await initialize();
    return Map<String, dynamic>.from(await _loadPluginStorage(pluginId));
  }
}

/// Shorthand accessor for the storage singleton.
CloudStreamJsStorage get cloudstreamJsStorage => CloudStreamJsStorage.instance;

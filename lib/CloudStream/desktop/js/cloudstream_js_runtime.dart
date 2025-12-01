import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_qjs/flutter_qjs.dart';

import '../../../Mangayomi/Eval/javascript/http.dart';
import 'cloudstream_js_storage.dart';

/// CloudStream-compatible JavaScript runtime for desktop plugin execution.
///
/// This class provides a QuickJS-based runtime that implements the CloudStream
/// plugin API surface, allowing JS-based plugins to execute on desktop platforms.
class CloudStreamJsRuntime {
  late JavascriptRuntime _runtime;
  bool _isInitialized = false;
  final String _pluginId;
  final String? _pluginCode;
  final Map<String, dynamic> _pluginConfig;

  CloudStreamJsRuntime({
    required String pluginId,
    String? pluginCode,
    Map<String, dynamic> pluginConfig = const {},
  }) : _pluginId = pluginId,
       _pluginCode = pluginCode,
       _pluginConfig = pluginConfig;

  /// Initialize the runtime with CloudStream-compatible APIs.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _runtime = _createRuntime();

      // Initialize HTTP client bridge
      JsHttpClient(_runtime).init();

      // Initialize CloudStream-specific APIs
      _initCloudStreamApis();

      // Initialize polyfills
      _initPolyfills();

      // Load plugin code if provided
      if (_pluginCode != null && _pluginCode.isNotEmpty) {
        _runtime.evaluate(_pluginCode);
      }

      _isInitialized = true;
      debugPrint('CloudStreamJsRuntime initialized for plugin: $_pluginId');
    } catch (e) {
      debugPrint('Failed to initialize CloudStreamJsRuntime: $e');
      rethrow;
    }
  }

  /// Create the QuickJS runtime with appropriate settings.
  JavascriptRuntime _createRuntime() {
    final runtime = QuickJsRuntime2(stackSize: 1024 * 1024 * 4);
    runtime.enableHandlePromises();
    return runtime;
  }

  /// Initialize CloudStream-compatible global APIs.
  void _initCloudStreamApis() {
    // Register message handlers for Dart-JS bridge
    _runtime.onMessage('cs_log', (dynamic args) async {
      final level = args[0] as String? ?? 'info';
      final message = args[1]?.toString() ?? '';
      debugPrint('[$_pluginId][$level] $message');
      return null;
    });

    _runtime.onMessage('cs_storage_get', (dynamic args) async {
      final key = args[0] as String?;
      if (key == null) return null;
      try {
        final value = await cloudstreamJsStorage.get(_pluginId, key);
        return value;
      } catch (e) {
        debugPrint('[$_pluginId] Storage get error: $e');
        return null;
      }
    });

    _runtime.onMessage('cs_storage_set', (dynamic args) async {
      final key = args[0] as String?;
      final value = args[1];
      if (key == null) return false;
      try {
        await cloudstreamJsStorage.set(_pluginId, key, value);
        return true;
      } catch (e) {
        debugPrint('[$_pluginId] Storage set error: $e');
        return false;
      }
    });

    _runtime.onMessage('cs_storage_remove', (dynamic args) async {
      final key = args[0] as String?;
      if (key == null) return false;
      try {
        await cloudstreamJsStorage.remove(_pluginId, key);
        return true;
      } catch (e) {
        debugPrint('[$_pluginId] Storage remove error: $e');
        return false;
      }
    });

    _runtime.onMessage('cs_storage_clear', (dynamic args) async {
      try {
        await cloudstreamJsStorage.clear(_pluginId);
        return true;
      } catch (e) {
        debugPrint('[$_pluginId] Storage clear error: $e');
        return false;
      }
    });

    // Inject CloudStream-compatible JavaScript APIs
    _runtime.evaluate('''
// CloudStream Plugin API Compatibility Layer

// Logging
const console = {
  log: (...args) => sendMessage('cs_log', JSON.stringify(['info', args.join(' ')])),
  warn: (...args) => sendMessage('cs_log', JSON.stringify(['warn', args.join(' ')])),
  error: (...args) => sendMessage('cs_log', JSON.stringify(['error', args.join(' ')])),
  debug: (...args) => sendMessage('cs_log', JSON.stringify(['debug', args.join(' ')])),
  info: (...args) => sendMessage('cs_log', JSON.stringify(['info', args.join(' ')])),
};

// Storage API - persistent key-value storage for plugin preferences
const storage = {
  get: async (key) => {
    const result = await sendMessage('cs_storage_get', JSON.stringify([key]));
    if (result === null || result === undefined) return null;
    try {
      return typeof result === 'string' ? JSON.parse(result) : result;
    } catch (e) {
      return result;
    }
  },
  set: async (key, value) => {
    return await sendMessage('cs_storage_set', JSON.stringify([key, value]));
  },
  remove: async (key) => {
    return await sendMessage('cs_storage_remove', JSON.stringify([key]));
  },
  clear: async () => {
    return await sendMessage('cs_storage_clear', JSON.stringify([]));
  },
};

// Plugin configuration
const pluginConfig = ${jsonEncode(_pluginConfig)};
const pluginId = "$_pluginId";

// Helper to stringify async results
async function jsonStringify(fn) {
  try {
    const result = await fn();
    return JSON.stringify(result);
  } catch (e) {
    return JSON.stringify({ error: e.message || String(e) });
  }
}

// CloudStream TvType enum
const TvType = {
  Movie: 'Movie',
  AnimeMovie: 'AnimeMovie',
  TvSeries: 'TvSeries',
  Cartoon: 'Cartoon',
  Anime: 'Anime',
  OVA: 'OVA',
  Documentary: 'Documentary',
  AsianDrama: 'AsianDrama',
  Live: 'Live',
  NSFW: 'NSFW',
  Others: 'Others',
  Music: 'Music',
  AudioBook: 'AudioBook',
  Torrent: 'Torrent',
};

// CloudStream ShowStatus enum
const ShowStatus = {
  Completed: 'Completed',
  Ongoing: 'Ongoing',
  Unknown: 'Unknown',
};

// CloudStream DubStatus enum
const DubStatus = {
  Dubbed: 'Dubbed',
  Subbed: 'Subbed',
};

// CloudStream Quality constants
const Qualities = {
  Unknown: -1,
  P360: 360,
  P480: 480,
  P720: 720,
  P1080: 1080,
  P1440: 1440,
  P2160: 2160,
};

// SearchResponse helper
function newSearchResponse(name, url, type, posterUrl) {
  return {
    name: name,
    url: url,
    type: type || TvType.Movie,
    posterUrl: posterUrl,
  };
}

// Episode helper
function newEpisode(data, name, season, episode, posterUrl, rating, description, date) {
  return {
    data: data,
    name: name,
    season: season,
    episode: episode,
    posterUrl: posterUrl,
    rating: rating,
    description: description,
    date: date,
  };
}

// ExtractorLink helper
function newExtractorLink(source, name, url, referer, quality, isM3u8, headers, extractorData, type) {
  return {
    source: source,
    name: name,
    url: url,
    referer: referer || '',
    quality: quality || Qualities.Unknown,
    isM3u8: isM3u8 || false,
    isDash: false,
    headers: headers || {},
    extractorData: extractorData,
    type: type || 'VIDEO',
  };
}

// SubtitleFile helper
function newSubtitleFile(lang, url) {
  return {
    lang: lang,
    url: url,
  };
}
''');
  }

  /// Initialize JavaScript polyfills for missing browser APIs.
  void _initPolyfills() {
    _runtime.evaluate('''
// URL polyfill
class URL {
  constructor(url, base) {
    if (base) {
      // Simple base URL handling
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (url.startsWith('/')) {
          const baseUrl = new URL(base);
          url = baseUrl.origin + url;
        } else {
          url = base.replace(/\\/[^\\/]*\$/, '/') + url;
        }
      }
    }
    
    const match = url.match(/^(https?:\\/\\/)?([^\\/]+)(.*)\$/);
    this.protocol = match[1] ? match[1].replace('://', ':') : 'https:';
    this.host = match[2] || '';
    this.hostname = this.host.split(':')[0];
    this.port = this.host.split(':')[1] || '';
    this.pathname = match[3] ? match[3].split('?')[0].split('#')[0] : '/';
    this.search = url.includes('?') ? '?' + url.split('?')[1].split('#')[0] : '';
    this.hash = url.includes('#') ? '#' + url.split('#')[1] : '';
    this.origin = this.protocol + '//' + this.host;
    this.href = this.origin + this.pathname + this.search + this.hash;
  }
  
  toString() {
    return this.href;
  }
}

// URLSearchParams polyfill
class URLSearchParams {
  constructor(init) {
    this._params = {};
    if (typeof init === 'string') {
      init = init.replace(/^\\?/, '');
      init.split('&').forEach(pair => {
        const [key, value] = pair.split('=');
        if (key) {
          this._params[decodeURIComponent(key)] = decodeURIComponent(value || '');
        }
      });
    } else if (init && typeof init === 'object') {
      Object.keys(init).forEach(key => {
        this._params[key] = init[key];
      });
    }
  }
  
  get(key) { return this._params[key] || null; }
  set(key, value) { this._params[key] = value; }
  has(key) { return key in this._params; }
  delete(key) { delete this._params[key]; }
  
  toString() {
    return Object.keys(this._params)
      .map(key => encodeURIComponent(key) + '=' + encodeURIComponent(this._params[key]))
      .join('&');
  }
}

// atob/btoa polyfills
function atob(str) {
  // Base64 decode
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  let output = '';
  str = str.replace(/=+\$/, '');
  
  for (let bc = 0, bs = 0, buffer, i = 0; buffer = str.charAt(i++);) {
    buffer = chars.indexOf(buffer);
    if (buffer === -1) continue;
    bs = bc % 4 ? bs * 64 + buffer : buffer;
    if (bc++ % 4) {
      output += String.fromCharCode(255 & bs >> (-2 * bc & 6));
    }
  }
  return output;
}

function btoa(str) {
  // Base64 encode
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  let output = '';
  
  for (let block = 0, charCode, i = 0, map = chars;
       str.charAt(i | 0) || (map = '=', i % 1);
       output += map.charAt(63 & block >> 8 - i % 1 * 8)) {
    charCode = str.charCodeAt(i += 3/4);
    block = block << 8 | charCode;
  }
  return output;
}

// TextEncoder/TextDecoder polyfills
class TextEncoder {
  encode(str) {
    const utf8 = [];
    for (let i = 0; i < str.length; i++) {
      let charcode = str.charCodeAt(i);
      if (charcode < 0x80) utf8.push(charcode);
      else if (charcode < 0x800) {
        utf8.push(0xc0 | (charcode >> 6), 0x80 | (charcode & 0x3f));
      } else if (charcode < 0xd800 || charcode >= 0xe000) {
        utf8.push(0xe0 | (charcode >> 12), 0x80 | ((charcode >> 6) & 0x3f), 0x80 | (charcode & 0x3f));
      } else {
        i++;
        charcode = 0x10000 + (((charcode & 0x3ff) << 10) | (str.charCodeAt(i) & 0x3ff));
        utf8.push(0xf0 | (charcode >> 18), 0x80 | ((charcode >> 12) & 0x3f), 0x80 | ((charcode >> 6) & 0x3f), 0x80 | (charcode & 0x3f));
      }
    }
    return new Uint8Array(utf8);
  }
}

class TextDecoder {
  decode(bytes) {
    let str = '';
    for (let i = 0; i < bytes.length; i++) {
      str += String.fromCharCode(bytes[i]);
    }
    return str;
  }
}
''');
  }

  /// Evaluate JavaScript code synchronously.
  dynamic evaluate(String code) {
    if (!_isInitialized) {
      throw StateError('Runtime not initialized');
    }

    try {
      final result = _runtime.evaluate(code);
      return result.rawResult;
    } catch (e) {
      debugPrint('JS evaluation error: $e');
      rethrow;
    }
  }

  /// Evaluate JavaScript code asynchronously.
  Future<dynamic> evaluateAsync(String code) async {
    if (!_isInitialized) {
      throw StateError('Runtime not initialized');
    }

    try {
      final jsResult = await _runtime.evaluateAsync(code);
      final result = await _runtime.handlePromise(jsResult);
      return result.rawResult;
    } catch (e) {
      debugPrint('JS async evaluation error: $e');
      rethrow;
    }
  }

  /// Call a plugin method and return the result as JSON.
  Future<Map<String, dynamic>> callPluginMethod(
    String methodName,
    List<dynamic> args,
  ) async {
    if (!_isInitialized) {
      throw StateError('Runtime not initialized');
    }

    try {
      final argsJson = jsonEncode(args);
      final code =
          '''
        jsonStringify(async () => {
          const args = $argsJson;
          return await plugin.$methodName(...args);
        })
      ''';

      final resultStr = await evaluateAsync(code);
      if (resultStr is String) {
        return jsonDecode(resultStr) as Map<String, dynamic>;
      }
      return {'error': 'Unexpected result type: ${resultStr.runtimeType}'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Dispose of the runtime resources.
  void dispose() {
    if (_isInitialized) {
      try {
        _runtime.dispose();
      } catch (e) {
        debugPrint('Error disposing runtime: $e');
      }
      _isInitialized = false;
    }
  }

  /// Check if the runtime is initialized.
  bool get isInitialized => _isInitialized;
}

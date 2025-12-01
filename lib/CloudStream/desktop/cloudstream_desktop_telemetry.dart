import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'cloudstream_desktop_config.dart';

/// Telemetry event types.
enum TelemetryEventType {
  runtimeInit,
  runtimeShutdown,
  pluginLoad,
  pluginUnload,
  methodCall,
  methodSuccess,
  methodFailure,
  error,
  warning,
}

/// A telemetry event.
class TelemetryEvent {
  final DateTime timestamp;
  final TelemetryEventType type;
  final String? pluginId;
  final String? method;
  final Duration? duration;
  final bool? success;
  final String? error;
  final Map<String, dynamic>? metadata;

  TelemetryEvent({
    required this.type,
    this.pluginId,
    this.method,
    this.duration,
    this.success,
    this.error,
    this.metadata,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    if (pluginId != null) 'pluginId': pluginId,
    if (method != null) 'method': method,
    if (duration != null) 'durationMs': duration!.inMilliseconds,
    if (success != null) 'success': success,
    if (error != null) 'error': error,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  String toString() {
    final parts = <String>[
      '[${timestamp.toIso8601String()}]',
      type.name.toUpperCase(),
    ];
    if (pluginId != null) parts.add('plugin=$pluginId');
    if (method != null) parts.add('method=$method');
    if (duration != null) parts.add('duration=${duration!.inMilliseconds}ms');
    if (success != null) parts.add('success=$success');
    if (error != null) parts.add('error=$error');
    return parts.join(' ');
  }
}

/// Aggregated statistics for a plugin.
class PluginStats {
  final String pluginId;
  int totalCalls = 0;
  int successfulCalls = 0;
  int failedCalls = 0;
  Duration totalDuration = Duration.zero;
  Duration? minDuration;
  Duration? maxDuration;
  final Map<String, int> methodCounts = {};
  final Map<String, int> errorCounts = {};
  DateTime? lastCallTime;
  DateTime? lastErrorTime;

  PluginStats(this.pluginId);

  double get successRate => totalCalls > 0 ? successfulCalls / totalCalls : 0.0;

  Duration get averageDuration => totalCalls > 0
      ? Duration(microseconds: totalDuration.inMicroseconds ~/ totalCalls)
      : Duration.zero;

  void recordCall(
    String method,
    Duration duration,
    bool success,
    String? error,
  ) {
    totalCalls++;
    totalDuration += duration;
    lastCallTime = DateTime.now();

    if (success) {
      successfulCalls++;
    } else {
      failedCalls++;
      lastErrorTime = DateTime.now();
      if (error != null) {
        errorCounts[error] = (errorCounts[error] ?? 0) + 1;
      }
    }

    methodCounts[method] = (methodCounts[method] ?? 0) + 1;

    if (minDuration == null || duration < minDuration!) {
      minDuration = duration;
    }
    if (maxDuration == null || duration > maxDuration!) {
      maxDuration = duration;
    }
  }

  Map<String, dynamic> toJson() => {
    'pluginId': pluginId,
    'totalCalls': totalCalls,
    'successfulCalls': successfulCalls,
    'failedCalls': failedCalls,
    'successRate': successRate,
    'totalDurationMs': totalDuration.inMilliseconds,
    'averageDurationMs': averageDuration.inMilliseconds,
    'minDurationMs': minDuration?.inMilliseconds,
    'maxDurationMs': maxDuration?.inMilliseconds,
    'methodCounts': methodCounts,
    'errorCounts': errorCounts,
    'lastCallTime': lastCallTime?.toIso8601String(),
    'lastErrorTime': lastErrorTime?.toIso8601String(),
  };
}

/// Telemetry service for CloudStream desktop plugin execution.
///
/// Collects and reports metrics about plugin runtime performance,
/// errors, and usage patterns.
class CloudStreamDesktopTelemetry {
  static CloudStreamDesktopTelemetry? _instance;

  static CloudStreamDesktopTelemetry get instance {
    _instance ??= CloudStreamDesktopTelemetry._();
    return _instance!;
  }

  CloudStreamDesktopTelemetry._();

  final Queue<TelemetryEvent> _events = Queue();
  final Map<String, PluginStats> _pluginStats = {};
  static const int _maxEvents = 1000;

  // Runtime stats
  DateTime? _runtimeInitTime;
  int _jsRuntimeInitCount = 0;
  int _dexRuntimeInitCount = 0;

  /// Record a runtime initialization event.
  void recordRuntimeInit(String runtimeType, {Map<String, dynamic>? metadata}) {
    if (!cloudstreamConfig.enableTelemetry) return;

    _runtimeInitTime = DateTime.now();
    if (runtimeType == 'js') {
      _jsRuntimeInitCount++;
    } else if (runtimeType == 'dex') {
      _dexRuntimeInitCount++;
    }

    _addEvent(
      TelemetryEvent(
        type: TelemetryEventType.runtimeInit,
        metadata: {'runtimeType': runtimeType, ...?metadata},
      ),
    );
  }

  /// Record a runtime shutdown event.
  void recordRuntimeShutdown(String runtimeType) {
    if (!cloudstreamConfig.enableTelemetry) return;

    _addEvent(
      TelemetryEvent(
        type: TelemetryEventType.runtimeShutdown,
        metadata: {'runtimeType': runtimeType},
      ),
    );
  }

  /// Record a plugin load event.
  void recordPluginLoad(
    String pluginId,
    Duration duration,
    bool success, {
    String? error,
  }) {
    if (!cloudstreamConfig.enableTelemetry) return;

    _addEvent(
      TelemetryEvent(
        type: TelemetryEventType.pluginLoad,
        pluginId: pluginId,
        duration: duration,
        success: success,
        error: error,
      ),
    );
  }

  /// Record a method call start.
  Stopwatch startMethodCall(String pluginId, String method) {
    if (cloudstreamConfig.enableVerboseLogging) {
      debugPrint('CloudStream: $pluginId.$method() started');
    }
    return Stopwatch()..start();
  }

  /// Record a method call completion.
  void recordMethodCall(
    String pluginId,
    String method,
    Stopwatch stopwatch,
    bool success, {
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    stopwatch.stop();
    final duration = stopwatch.elapsed;

    if (cloudstreamConfig.enableVerboseLogging) {
      debugPrint(
        'CloudStream: $pluginId.$method() '
        '${success ? 'succeeded' : 'failed'} '
        'in ${duration.inMilliseconds}ms'
        '${error != null ? ' - $error' : ''}',
      );
    }

    if (!cloudstreamConfig.enableTelemetry) return;

    // Update plugin stats
    final stats = _pluginStats.putIfAbsent(
      pluginId,
      () => PluginStats(pluginId),
    );
    stats.recordCall(method, duration, success, error);

    // Add event
    _addEvent(
      TelemetryEvent(
        type: success
            ? TelemetryEventType.methodSuccess
            : TelemetryEventType.methodFailure,
        pluginId: pluginId,
        method: method,
        duration: duration,
        success: success,
        error: error,
        metadata: metadata,
      ),
    );
  }

  /// Record an error event.
  void recordError(
    String message, {
    String? pluginId,
    String? method,
    StackTrace? stackTrace,
  }) {
    debugPrint('CloudStream ERROR: $message');
    if (stackTrace != null && cloudstreamConfig.enableVerboseLogging) {
      debugPrint('Stack trace: $stackTrace');
    }

    if (!cloudstreamConfig.enableTelemetry) return;

    _addEvent(
      TelemetryEvent(
        type: TelemetryEventType.error,
        pluginId: pluginId,
        method: method,
        error: message,
        metadata: stackTrace != null
            ? {'stackTrace': stackTrace.toString()}
            : null,
      ),
    );
  }

  /// Record a warning event.
  void recordWarning(String message, {String? pluginId}) {
    debugPrint('CloudStream WARNING: $message');

    if (!cloudstreamConfig.enableTelemetry) return;

    _addEvent(
      TelemetryEvent(
        type: TelemetryEventType.warning,
        pluginId: pluginId,
        error: message,
      ),
    );
  }

  void _addEvent(TelemetryEvent event) {
    _events.addLast(event);
    while (_events.length > _maxEvents) {
      _events.removeFirst();
    }
  }

  /// Get recent events.
  List<TelemetryEvent> getRecentEvents({int limit = 100}) {
    return _events.toList().reversed.take(limit).toList();
  }

  /// Get events for a specific plugin.
  List<TelemetryEvent> getPluginEvents(String pluginId, {int limit = 100}) {
    return _events
        .where((e) => e.pluginId == pluginId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Get statistics for a plugin.
  PluginStats? getPluginStats(String pluginId) {
    return _pluginStats[pluginId];
  }

  /// Get statistics for all plugins.
  Map<String, PluginStats> getAllPluginStats() {
    return Map.unmodifiable(_pluginStats);
  }

  /// Get a summary of telemetry data.
  Map<String, dynamic> getSummary() {
    final totalCalls = _pluginStats.values.fold<int>(
      0,
      (sum, stats) => sum + stats.totalCalls,
    );
    final totalErrors = _pluginStats.values.fold<int>(
      0,
      (sum, stats) => sum + stats.failedCalls,
    );

    return {
      'runtimeInitTime': _runtimeInitTime?.toIso8601String(),
      'jsRuntimeInitCount': _jsRuntimeInitCount,
      'dexRuntimeInitCount': _dexRuntimeInitCount,
      'totalPlugins': _pluginStats.length,
      'totalCalls': totalCalls,
      'totalErrors': totalErrors,
      'overallSuccessRate': totalCalls > 0
          ? (totalCalls - totalErrors) / totalCalls
          : 0.0,
      'eventCount': _events.length,
    };
  }

  /// Export telemetry data to a file.
  Future<String> exportToFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final telemetryDir = Directory(
      path.join(appDir.path, 'cloudstream_telemetry'),
    );

    if (!await telemetryDir.exists()) {
      await telemetryDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(
      path.join(telemetryDir.path, 'telemetry_$timestamp.json'),
    );

    final data = {
      'exportTime': DateTime.now().toIso8601String(),
      'summary': getSummary(),
      'pluginStats': _pluginStats.map((k, v) => MapEntry(k, v.toJson())),
      'recentEvents': getRecentEvents(
        limit: 500,
      ).map((e) => e.toJson()).toList(),
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('Telemetry exported to: ${file.path}');

    return file.path;
  }

  /// Clear all telemetry data.
  void clear() {
    _events.clear();
    _pluginStats.clear();
  }
}

/// Shorthand accessor for the telemetry singleton.
CloudStreamDesktopTelemetry get cloudstreamTelemetry =>
    CloudStreamDesktopTelemetry.instance;

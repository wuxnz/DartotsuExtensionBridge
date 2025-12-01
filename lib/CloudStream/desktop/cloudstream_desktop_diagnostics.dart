import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'cloudstream_desktop_bridge.dart';
import 'cloudstream_desktop_config.dart';
import 'cloudstream_desktop_telemetry.dart';

/// Diagnostic check result.
class DiagnosticCheck {
  final String name;
  final String description;
  final bool passed;
  final String? message;
  final String? suggestion;

  DiagnosticCheck({
    required this.name,
    required this.description,
    required this.passed,
    this.message,
    this.suggestion,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'passed': passed,
    if (message != null) 'message': message,
    if (suggestion != null) 'suggestion': suggestion,
  };

  @override
  String toString() {
    final status = passed ? '✓' : '✗';
    final buffer = StringBuffer('$status $name: $description');
    if (message != null) buffer.write(' - $message');
    if (!passed && suggestion != null) buffer.write('\n  → $suggestion');
    return buffer.toString();
  }
}

/// Diagnostic report for CloudStream desktop runtime.
class DiagnosticReport {
  final DateTime timestamp;
  final String platform;
  final List<DiagnosticCheck> checks;
  final Map<String, dynamic> runtimeInfo;
  final Map<String, dynamic> configInfo;
  final Map<String, dynamic>? telemetrySummary;

  DiagnosticReport({
    required this.timestamp,
    required this.platform,
    required this.checks,
    required this.runtimeInfo,
    required this.configInfo,
    this.telemetrySummary,
  });

  bool get allPassed => checks.every((c) => c.passed);
  int get passedCount => checks.where((c) => c.passed).length;
  int get failedCount => checks.where((c) => !c.passed).length;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'platform': platform,
    'allPassed': allPassed,
    'passedCount': passedCount,
    'failedCount': failedCount,
    'checks': checks.map((c) => c.toJson()).toList(),
    'runtimeInfo': runtimeInfo,
    'configInfo': configInfo,
    if (telemetrySummary != null) 'telemetrySummary': telemetrySummary,
  };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(
      '═══════════════════════════════════════════════════════════',
    );
    buffer.writeln('CloudStream Desktop Diagnostics');
    buffer.writeln(
      '═══════════════════════════════════════════════════════════',
    );
    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');
    buffer.writeln('Platform: $platform');
    buffer.writeln(
      'Status: ${allPassed ? 'All checks passed' : '$failedCount check(s) failed'}',
    );
    buffer.writeln(
      '───────────────────────────────────────────────────────────',
    );
    buffer.writeln('Checks:');
    for (final check in checks) {
      buffer.writeln('  $check');
    }
    buffer.writeln(
      '───────────────────────────────────────────────────────────',
    );
    buffer.writeln('Runtime Info:');
    runtimeInfo.forEach((k, v) => buffer.writeln('  $k: $v'));
    buffer.writeln(
      '───────────────────────────────────────────────────────────',
    );
    buffer.writeln('Configuration:');
    configInfo.forEach((k, v) => buffer.writeln('  $k: $v'));
    buffer.writeln(
      '═══════════════════════════════════════════════════════════',
    );
    return buffer.toString();
  }
}

/// Diagnostics service for CloudStream desktop runtime.
///
/// Provides health checks and diagnostic information about the
/// JS and DEX plugin execution environments.
class CloudStreamDesktopDiagnostics {
  final CloudStreamDesktopBridge _bridge;

  CloudStreamDesktopDiagnostics(this._bridge);

  /// Run all diagnostic checks and generate a report.
  Future<DiagnosticReport> runDiagnostics() async {
    final checks = <DiagnosticCheck>[];

    // Platform check
    checks.add(_checkPlatform());

    // JS runtime checks
    checks.addAll(await _checkJsRuntime());

    // DEX runtime checks
    checks.addAll(await _checkDexRuntime());

    // Plugin store check
    checks.add(await _checkPluginStore());

    // Configuration check
    checks.add(_checkConfiguration());

    return DiagnosticReport(
      timestamp: DateTime.now(),
      platform: Platform.operatingSystem,
      checks: checks,
      runtimeInfo: await _getRuntimeInfo(),
      configInfo: cloudstreamConfig.toJson(),
      telemetrySummary: cloudstreamTelemetry.getSummary(),
    );
  }

  DiagnosticCheck _checkPlatform() {
    final isSupported = Platform.isLinux || Platform.isWindows;
    return DiagnosticCheck(
      name: 'Platform',
      description: 'Check if platform is supported',
      passed: isSupported,
      message: Platform.operatingSystem,
      suggestion: isSupported
          ? null
          : 'Desktop plugins only work on Linux and Windows',
    );
  }

  Future<List<DiagnosticCheck>> _checkJsRuntime() async {
    final checks = <DiagnosticCheck>[];

    // Check if JS execution is enabled
    checks.add(
      DiagnosticCheck(
        name: 'JS Execution Enabled',
        description: 'Check if JS plugin execution is enabled',
        passed: cloudstreamConfig.enableDesktopJsPlugins,
        message: cloudstreamConfig.enableDesktopJsPlugins
            ? 'Enabled'
            : 'Disabled',
        suggestion: cloudstreamConfig.enableDesktopJsPlugins
            ? null
            : 'Set CLOUDSTREAM_ENABLE_JS_PLUGINS=true or enable in settings',
      ),
    );

    // Check QuickJS availability (it's bundled, so should always be available)
    checks.add(
      DiagnosticCheck(
        name: 'QuickJS Runtime',
        description: 'Check if QuickJS is available',
        passed: true, // QuickJS is bundled with flutter_qjs
        message: 'Bundled with flutter_qjs',
      ),
    );

    return checks;
  }

  Future<List<DiagnosticCheck>> _checkDexRuntime() async {
    final checks = <DiagnosticCheck>[];

    // Check if DEX execution is enabled
    checks.add(
      DiagnosticCheck(
        name: 'DEX Execution Enabled',
        description: 'Check if DEX plugin execution is enabled',
        passed: cloudstreamConfig.enableDesktopDexPlugins,
        message: cloudstreamConfig.enableDesktopDexPlugins
            ? 'Enabled'
            : 'Disabled',
        suggestion: cloudstreamConfig.enableDesktopDexPlugins
            ? null
            : 'Set CLOUDSTREAM_ENABLE_DEX_PLUGINS=true (experimental)',
      ),
    );

    // Check Java availability
    final javaCheck = await _checkJava();
    checks.add(javaCheck);

    // Check dex2jar availability
    final dex2jarCheck = await _checkDex2Jar();
    checks.add(dex2jarCheck);

    // Overall DEX runtime availability
    final dexAvailable = javaCheck.passed && dex2jarCheck.passed;
    checks.add(
      DiagnosticCheck(
        name: 'DEX Runtime Available',
        description: 'Check if DEX runtime can be used',
        passed: dexAvailable,
        message: dexAvailable ? 'All requirements met' : 'Missing requirements',
        suggestion: dexAvailable
            ? null
            : 'Install Java 11+ and dex2jar to enable DEX plugin execution',
      ),
    );

    return checks;
  }

  Future<DiagnosticCheck> _checkJava() async {
    try {
      // Check JAVA_HOME
      final javaHome = Platform.environment['JAVA_HOME'];
      if (javaHome != null && javaHome.isNotEmpty) {
        final javaBin = Platform.isWindows
            ? path.join(javaHome, 'bin', 'java.exe')
            : path.join(javaHome, 'bin', 'java');
        if (await File(javaBin).exists()) {
          final version = await _getJavaVersion(javaBin);
          return DiagnosticCheck(
            name: 'Java Runtime',
            description: 'Check if Java is available',
            passed: true,
            message: 'Found at JAVA_HOME: $version',
          );
        }
      }

      // Check PATH
      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        'java',
      ]);

      if (result.exitCode == 0) {
        final javaPath = result.stdout.toString().trim().split('\n').first;
        final version = await _getJavaVersion(javaPath);
        return DiagnosticCheck(
          name: 'Java Runtime',
          description: 'Check if Java is available',
          passed: true,
          message: 'Found in PATH: $version',
        );
      }

      return DiagnosticCheck(
        name: 'Java Runtime',
        description: 'Check if Java is available',
        passed: false,
        message: 'Not found',
        suggestion: Platform.isLinux
            ? 'Install with: sudo apt install openjdk-17-jre'
            : 'Install from https://adoptium.net/',
      );
    } catch (e) {
      return DiagnosticCheck(
        name: 'Java Runtime',
        description: 'Check if Java is available',
        passed: false,
        message: 'Error checking: $e',
        suggestion: 'Ensure Java 11+ is installed and in PATH',
      );
    }
  }

  Future<String> _getJavaVersion(String javaPath) async {
    try {
      final result = await Process.run(javaPath, ['-version']);
      final output = result.stderr.toString();
      final match = RegExp(r'version "([^"]+)"').firstMatch(output);
      return match?.group(1) ?? 'unknown version';
    } catch (e) {
      return 'unknown version';
    }
  }

  Future<DiagnosticCheck> _checkDex2Jar() async {
    try {
      final toolName = Platform.isWindows ? 'd2j-dex2jar.bat' : 'd2j-dex2jar';

      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        toolName,
      ]);

      if (result.exitCode == 0) {
        final toolPath = result.stdout.toString().trim().split('\n').first;
        return DiagnosticCheck(
          name: 'dex2jar Tool',
          description: 'Check if dex2jar is available',
          passed: true,
          message: 'Found at: $toolPath',
        );
      }

      return DiagnosticCheck(
        name: 'dex2jar Tool',
        description: 'Check if dex2jar is available',
        passed: false,
        message: 'Not found in PATH',
        suggestion: 'Download from https://github.com/pxb1988/dex2jar/releases',
      );
    } catch (e) {
      return DiagnosticCheck(
        name: 'dex2jar Tool',
        description: 'Check if dex2jar is available',
        passed: false,
        message: 'Error checking: $e',
        suggestion: 'Download from https://github.com/pxb1988/dex2jar/releases',
      );
    }
  }

  Future<DiagnosticCheck> _checkPluginStore() async {
    try {
      final status = await _bridge.handleMethodCall(
        const MethodCall('getPluginStatus'),
      );

      final pluginCount = (status as Map)['registeredPluginCount'] ?? 0;
      return DiagnosticCheck(
        name: 'Plugin Store',
        description: 'Check plugin store status',
        passed: true,
        message: '$pluginCount plugin(s) registered',
      );
    } catch (e) {
      return DiagnosticCheck(
        name: 'Plugin Store',
        description: 'Check plugin store status',
        passed: false,
        message: 'Error: $e',
        suggestion: 'Try reinitializing the plugin store',
      );
    }
  }

  DiagnosticCheck _checkConfiguration() {
    final config = cloudstreamConfig;
    final issues = <String>[];

    if (config.jsTimeoutSeconds < 10) {
      issues.add('JS timeout too low');
    }
    if (config.dexTimeoutSeconds < 20) {
      issues.add('DEX timeout too low');
    }
    if (config.maxMemoryMb < 128) {
      issues.add('Memory limit too low');
    }

    return DiagnosticCheck(
      name: 'Configuration',
      description: 'Check configuration validity',
      passed: issues.isEmpty,
      message: issues.isEmpty ? 'Valid' : issues.join(', '),
      suggestion: issues.isEmpty ? null : 'Review timeout and memory settings',
    );
  }

  Future<Map<String, dynamic>> _getRuntimeInfo() async {
    try {
      final status = await _bridge.handleMethodCall(
        const MethodCall('getPluginStatus'),
      );

      return {
        'isInitialized': status['isInitialized'] ?? false,
        'registeredPluginCount': status['registeredPluginCount'] ?? 0,
        'jsExecutableCount': status['jsExecutableCount'] ?? 0,
        'jsExecutionEnabled': _bridge.isJsExecutionEnabled,
        'dexExecutionEnabled': _bridge.isDexExecutionEnabled,
        'dexRuntimeAvailable': _bridge.isDexRuntimeAvailable,
        'platform': status['platform'] ?? Platform.operatingSystem,
      };
    } catch (e) {
      return {'error': e.toString(), 'platform': Platform.operatingSystem};
    }
  }

  /// Print diagnostic report to console.
  Future<void> printDiagnostics() async {
    final report = await runDiagnostics();
    debugPrint(report.toString());
  }
}

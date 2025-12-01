import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'dex2jar_converter.dart';
import 'dex_runtime_interface.dart';
import 'process_sandbox.dart';

/// DEX runtime implementation using dex2jar + JRE.
///
/// This runtime converts DEX files to JAR format and executes them
/// on a standard JVM. It provides the best compatibility with existing
/// CloudStream plugins while requiring a JRE installation.
class JreDexRuntime implements DexRuntime {
  final Dex2JarConverter _converter = Dex2JarConverter();
  late final ProcessSandbox _sandbox;

  String? _javaPath;
  String? _runtimeDir;
  DexRuntimeConfig _config = const DexRuntimeConfig();
  bool _isInitialized = false;
  bool _sandboxAvailable = false;

  final Map<String, _LoadedPlugin> _loadedPlugins = {};
  final Map<String, Process> _runningProcesses = {};

  @override
  DexRuntimeType get type => DexRuntimeType.dex2jarJre;

  @override
  Future<DexRuntimeStatus> getStatus() async {
    final javaVersion = await _getJavaVersion();
    final dex2jarAvailable = _converter.isAvailable;

    return DexRuntimeStatus(
      isAvailable: _javaPath != null && dex2jarAvailable,
      type: type,
      version: javaVersion,
      runtimePath: _javaPath,
      capabilities: [
        if (_javaPath != null) 'jre',
        if (dex2jarAvailable) 'dex2jar',
      ],
      diagnostics: {
        'javaPath': _javaPath,
        'javaVersion': javaVersion,
        'dex2jarPath': _converter.dex2jarPath,
        'dex2jarAvailable': dex2jarAvailable,
        'runtimeDir': _runtimeDir,
        'loadedPlugins': _loadedPlugins.keys.toList(),
      },
    );
  }

  @override
  Future<DexRuntimeResult<void>> initialize(DexRuntimeConfig config) async {
    if (_isInitialized) {
      return DexRuntimeResult.success(null);
    }

    _config = config;

    try {
      // Find Java
      _javaPath = await _findJava();
      if (_javaPath == null) {
        return DexRuntimeResult.failure(
          'Java not found. Please install JRE 11 or later.',
        );
      }

      // Initialize dex2jar converter
      final dex2jarOk = await _converter.initialize();
      if (!dex2jarOk) {
        return DexRuntimeResult.failure(
          'dex2jar not found. ${_converter.getInstallInstructions()}',
        );
      }

      // Create runtime directory
      _runtimeDir = await _createRuntimeDir();

      // Initialize sandbox if enabled
      if (config.sandboxed) {
        _sandbox = ProcessSandbox(
          config: SandboxConfig(
            enabled: true,
            maxCpuSeconds: config.timeout.inSeconds,
            maxMemoryMb: config.maxMemoryMb,
            allowNetwork: true,
            readWritePaths: [_runtimeDir!],
          ),
        );
        _sandboxAvailable = await _sandbox.isAvailable();
        debugPrint('Sandbox available: $_sandboxAvailable');
      } else {
        _sandbox = ProcessSandbox(config: SandboxConfig.permissive);
        _sandboxAvailable = false;
      }

      _isInitialized = true;
      debugPrint(
        'JreDexRuntime initialized: java=$_javaPath, sandbox=$_sandboxAvailable',
      );

      return DexRuntimeResult.success(null);
    } catch (e) {
      return DexRuntimeResult.failure('Initialization failed: $e');
    }
  }

  @override
  Future<DexRuntimeResult<String>> loadPlugin({
    required String dexPath,
    required String pluginClassName,
    required String pluginId,
  }) async {
    if (!_isInitialized) {
      return DexRuntimeResult.failure('Runtime not initialized');
    }

    if (_loadedPlugins.containsKey(pluginId)) {
      return DexRuntimeResult.success(pluginId);
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Convert DEX to JAR
      final pluginDir = path.join(_runtimeDir!, 'plugins', pluginId);
      final conversionResult = await _converter.convert(
        dexPath: dexPath,
        outputDir: pluginDir,
        jarName: pluginId,
      );

      if (!conversionResult.success) {
        return DexRuntimeResult.failure(
          conversionResult.error ?? 'DEX conversion failed',
        );
      }

      // Store plugin info
      _loadedPlugins[pluginId] = _LoadedPlugin(
        id: pluginId,
        dexPath: dexPath,
        jarPath: conversionResult.jarPath!,
        className: pluginClassName,
        loadedAt: DateTime.now(),
      );

      stopwatch.stop();
      debugPrint('Plugin loaded: $pluginId (${stopwatch.elapsed})');

      return DexRuntimeResult.success(
        pluginId,
        executionTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return DexRuntimeResult.failure('Failed to load plugin: $e');
    }
  }

  @override
  Future<DexRuntimeResult<void>> unloadPlugin(String pluginId) async {
    final plugin = _loadedPlugins.remove(pluginId);
    if (plugin == null) {
      return DexRuntimeResult.failure('Plugin not loaded: $pluginId');
    }

    // Cancel any running processes
    await cancelOperations(pluginId);

    // Clean up JAR file
    try {
      final jarFile = File(plugin.jarPath);
      if (await jarFile.exists()) {
        await jarFile.delete();
      }

      final pluginDir = Directory(path.dirname(plugin.jarPath));
      if (await pluginDir.exists()) {
        await pluginDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error cleaning up plugin $pluginId: $e');
    }

    debugPrint('Plugin unloaded: $pluginId');
    return DexRuntimeResult.success(null);
  }

  @override
  Future<DexRuntimeResult<Map<String, dynamic>>> callMethod({
    required String pluginId,
    required String methodName,
    required List<dynamic> args,
  }) async {
    if (!_isInitialized) {
      return DexRuntimeResult.failure('Runtime not initialized');
    }

    final plugin = _loadedPlugins[pluginId];
    if (plugin == null) {
      return DexRuntimeResult.failure('Plugin not loaded: $pluginId');
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Build classpath
      final classpath = _buildClasspath(plugin);

      // Serialize arguments
      final argsJson = jsonEncode(args);
      final argsBase64 = base64Encode(utf8.encode(argsJson));

      // Build Java command
      final javaArgs = [
        ..._config.toJvmArgs(),
        '-cp', classpath,
        'com.cloudstream.bridge.PluginRunner', // Bridge class
        plugin.className,
        methodName,
        argsBase64,
      ];

      // Get sandbox wrapper if available
      final workingDir = path.dirname(plugin.jarPath);
      final sandboxWrapper = _sandboxAvailable
          ? await _sandbox.getSandboxWrapper(workingDir)
          : null;

      // Run Java process (sandboxed if available)
      final Process process;
      if (sandboxWrapper != null) {
        debugPrint(
          'Running $pluginId.$methodName in sandbox (${sandboxWrapper.type.name})',
        );
        process = await Process.start(
          sandboxWrapper.processExecutable,
          sandboxWrapper.getProcessArgs(_javaPath!, javaArgs),
          workingDirectory: workingDir,
        );
      } else {
        process = await Process.start(
          _javaPath!,
          javaArgs,
          workingDirectory: workingDir,
        );
      }

      _runningProcesses[pluginId] = process;

      // Collect output with timeout
      final stdout = StringBuffer();
      final stderr = StringBuffer();

      final stdoutSub = process.stdout
          .transform(utf8.decoder)
          .listen((data) => stdout.write(data));
      final stderrSub = process.stderr
          .transform(utf8.decoder)
          .listen((data) => stderr.write(data));

      final exitCode = await process.exitCode.timeout(
        _config.timeout,
        onTimeout: () {
          process.kill();
          throw TimeoutException('Method call timed out', _config.timeout);
        },
      );

      await stdoutSub.cancel();
      await stderrSub.cancel();
      _runningProcesses.remove(pluginId);

      stopwatch.stop();

      if (exitCode != 0) {
        return DexRuntimeResult.failure(
          'Method call failed (exit $exitCode): ${stderr.toString()}',
        );
      }

      // Parse result
      final resultStr = stdout.toString().trim();
      if (resultStr.isEmpty) {
        return DexRuntimeResult.success(
          <String, dynamic>{},
          executionTime: stopwatch.elapsed,
        );
      }

      try {
        final result = jsonDecode(resultStr) as Map<String, dynamic>;
        return DexRuntimeResult.success(
          result,
          executionTime: stopwatch.elapsed,
        );
      } catch (e) {
        return DexRuntimeResult.failure('Failed to parse result: $e');
      }
    } on TimeoutException catch (e) {
      stopwatch.stop();
      return DexRuntimeResult.failure('Timeout: ${e.message}');
    } catch (e) {
      stopwatch.stop();
      return DexRuntimeResult.failure('Method call error: $e');
    }
  }

  @override
  bool isPluginLoaded(String pluginId) {
    return _loadedPlugins.containsKey(pluginId);
  }

  @override
  List<String> getLoadedPlugins() {
    return _loadedPlugins.keys.toList();
  }

  @override
  Future<void> shutdown() async {
    // Cancel all running processes
    for (final pluginId in _runningProcesses.keys.toList()) {
      await cancelOperations(pluginId);
    }

    // Unload all plugins
    for (final pluginId in _loadedPlugins.keys.toList()) {
      await unloadPlugin(pluginId);
    }

    _isInitialized = false;
    debugPrint('JreDexRuntime shutdown complete');
  }

  @override
  Future<void> cancelOperations(String pluginId) async {
    final process = _runningProcesses.remove(pluginId);
    if (process != null) {
      process.kill();
      debugPrint('Cancelled operations for plugin: $pluginId');
    }
  }

  /// Find Java executable.
  Future<String?> _findJava() async {
    // Check JAVA_HOME first
    final javaHome = Platform.environment['JAVA_HOME'];
    if (javaHome != null && javaHome.isNotEmpty) {
      final javaBin = Platform.isWindows
          ? path.join(javaHome, 'bin', 'java.exe')
          : path.join(javaHome, 'bin', 'java');
      if (await File(javaBin).exists()) {
        return javaBin;
      }
    }

    // Check PATH
    try {
      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        'java',
      ]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          return output.split('\n').first.trim();
        }
      }
    } catch (e) {
      debugPrint('Error finding java: $e');
    }

    // Check common locations
    final commonPaths = Platform.isWindows
        ? [
            r'C:\Program Files\Java\jdk-17\bin\java.exe',
            r'C:\Program Files\Java\jdk-11\bin\java.exe',
            r'C:\Program Files\Eclipse Adoptium\jdk-17\bin\java.exe',
            r'C:\Program Files\Eclipse Adoptium\jdk-11\bin\java.exe',
          ]
        : [
            '/usr/bin/java',
            '/usr/lib/jvm/java-17-openjdk/bin/java',
            '/usr/lib/jvm/java-11-openjdk/bin/java',
            '/opt/java/openjdk/bin/java',
          ];

    for (final javaPath in commonPaths) {
      if (await File(javaPath).exists()) {
        return javaPath;
      }
    }

    return null;
  }

  /// Get Java version string.
  Future<String?> _getJavaVersion() async {
    _javaPath ??= await _findJava();
    if (_javaPath == null) return null;

    try {
      final result = await Process.run(_javaPath!, ['-version']);
      // Java outputs version to stderr
      final output = result.stderr.toString();
      final match = RegExp(r'version "([^"]+)"').firstMatch(output);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }

  /// Create runtime directory for JAR files and temp data.
  Future<String> _createRuntimeDir() async {
    final tempDir = Directory.systemTemp;
    final runtimeDir = Directory(
      path.join(tempDir.path, 'cloudstream_dex_runtime'),
    );

    if (!await runtimeDir.exists()) {
      await runtimeDir.create(recursive: true);
    }

    return runtimeDir.path;
  }

  /// Build classpath for running a plugin.
  String _buildClasspath(_LoadedPlugin plugin) {
    final separator = Platform.isWindows ? ';' : ':';
    final classpathEntries = <String>[
      plugin.jarPath,
      // Add bridge JAR (would be bundled with app)
      path.join(_runtimeDir!, 'lib', 'cloudstream-bridge.jar'),
      // Add CloudStream library dependencies
      path.join(_runtimeDir!, 'lib', '*'),
    ];

    return classpathEntries.join(separator);
  }
}

/// Information about a loaded plugin.
class _LoadedPlugin {
  final String id;
  final String dexPath;
  final String jarPath;
  final String className;
  final DateTime loadedAt;

  _LoadedPlugin({
    required this.id,
    required this.dexPath,
    required this.jarPath,
    required this.className,
    required this.loadedAt,
  });
}

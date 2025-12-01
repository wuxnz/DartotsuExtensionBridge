import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Result of a DEX to JAR conversion.
class Dex2JarResult {
  final bool success;
  final String? jarPath;
  final String? error;
  final Duration conversionTime;

  Dex2JarResult({
    required this.success,
    this.jarPath,
    this.error,
    required this.conversionTime,
  });
}

/// Converts Android DEX files to JAR format for JVM execution.
///
/// This class wraps the dex2jar tool to convert CloudStream plugin DEX files
/// into JAR files that can be executed on a standard JVM.
class Dex2JarConverter {
  static const String _dex2jarToolName = 'd2j-dex2jar';
  static const String _dex2jarToolNameWindows = 'd2j-dex2jar.bat';

  String? _dex2jarPath;
  bool _isInitialized = false;

  /// Initialize the converter by locating dex2jar.
  Future<bool> initialize() async {
    if (_isInitialized) return _dex2jarPath != null;

    _dex2jarPath = await _findDex2Jar();
    _isInitialized = true;

    if (_dex2jarPath != null) {
      debugPrint('dex2jar found at: $_dex2jarPath');
    } else {
      debugPrint('dex2jar not found in PATH or bundled locations');
    }

    return _dex2jarPath != null;
  }

  /// Check if dex2jar is available.
  bool get isAvailable => _dex2jarPath != null;

  /// Get the path to dex2jar.
  String? get dex2jarPath => _dex2jarPath;

  /// Convert a DEX file to JAR format.
  ///
  /// [dexPath] is the path to the input DEX file.
  /// [outputDir] is the directory where the JAR will be created.
  /// [jarName] is the name for the output JAR file (without extension).
  Future<Dex2JarResult> convert({
    required String dexPath,
    required String outputDir,
    String? jarName,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (!_isInitialized) {
      await initialize();
    }

    if (_dex2jarPath == null) {
      return Dex2JarResult(
        success: false,
        error: 'dex2jar not available. Please install dex-tools.',
        conversionTime: stopwatch.elapsed,
      );
    }

    // Validate input
    final dexFile = File(dexPath);
    if (!await dexFile.exists()) {
      return Dex2JarResult(
        success: false,
        error: 'DEX file not found: $dexPath',
        conversionTime: stopwatch.elapsed,
      );
    }

    // Create output directory
    final outDir = Directory(outputDir);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    // Determine output JAR path
    final baseName = jarName ?? path.basenameWithoutExtension(dexPath);
    final jarPath = path.join(outputDir, '$baseName.jar');

    try {
      // Run dex2jar
      final result = await Process.run(_dex2jarPath!, [
        '-f', // Force overwrite
        '-o', jarPath, // Output path
        dexPath, // Input DEX
      ], workingDirectory: outputDir);

      stopwatch.stop();

      if (result.exitCode != 0) {
        final stderr = result.stderr.toString();
        debugPrint('dex2jar failed: $stderr');
        return Dex2JarResult(
          success: false,
          error: 'dex2jar conversion failed: $stderr',
          conversionTime: stopwatch.elapsed,
        );
      }

      // Verify output exists
      if (!await File(jarPath).exists()) {
        return Dex2JarResult(
          success: false,
          error: 'JAR file was not created',
          conversionTime: stopwatch.elapsed,
        );
      }

      debugPrint('DEX converted to JAR: $jarPath (${stopwatch.elapsed})');
      return Dex2JarResult(
        success: true,
        jarPath: jarPath,
        conversionTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint('dex2jar error: $e');
      return Dex2JarResult(
        success: false,
        error: 'Conversion error: $e',
        conversionTime: stopwatch.elapsed,
      );
    }
  }

  /// Find dex2jar in PATH or bundled locations.
  Future<String?> _findDex2Jar() async {
    final toolName = Platform.isWindows
        ? _dex2jarToolNameWindows
        : _dex2jarToolName;

    // Check PATH first
    final pathResult = await _findInPath(toolName);
    if (pathResult != null) return pathResult;

    // Check bundled locations
    final bundledPaths = _getBundledPaths(toolName);
    for (final bundledPath in bundledPaths) {
      if (await File(bundledPath).exists()) {
        return bundledPath;
      }
    }

    return null;
  }

  /// Search for a tool in the system PATH.
  Future<String?> _findInPath(String toolName) async {
    try {
      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        toolName,
      ]);

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          return output.split('\n').first.trim();
        }
      }
    } catch (e) {
      debugPrint('Error searching PATH for $toolName: $e');
    }
    return null;
  }

  /// Get potential bundled paths for dex2jar.
  List<String> _getBundledPaths(String toolName) {
    final appDir = Platform.resolvedExecutable;
    final appDirPath = path.dirname(appDir);

    return [
      // Bundled with app
      path.join(appDirPath, 'data', 'dex-tools', toolName),
      path.join(appDirPath, 'dex-tools', toolName),
      path.join(appDirPath, 'tools', 'dex-tools', toolName),
      // Linux standard locations
      if (Platform.isLinux) ...[
        '/usr/bin/$toolName',
        '/usr/local/bin/$toolName',
        path.join(
          Platform.environment['HOME'] ?? '',
          '.local',
          'bin',
          toolName,
        ),
      ],
      // Windows standard locations
      if (Platform.isWindows) ...[
        path.join(
          Platform.environment['LOCALAPPDATA'] ?? '',
          'dex-tools',
          toolName,
        ),
        path.join(
          Platform.environment['PROGRAMFILES'] ?? '',
          'dex-tools',
          toolName,
        ),
      ],
    ];
  }

  /// Get installation instructions for dex2jar.
  String getInstallInstructions() {
    if (Platform.isLinux) {
      return '''
To install dex2jar on Linux:

1. Download from: https://github.com/pxb1988/dex2jar/releases
2. Extract to ~/.local/share/dex-tools/
3. Add to PATH: export PATH="\$PATH:\$HOME/.local/share/dex-tools"
4. Make executable: chmod +x ~/.local/share/dex-tools/d2j-*

Or use a package manager if available:
  - Arch Linux: yay -S dex2jar
  - Ubuntu/Debian: May need to build from source
''';
    } else if (Platform.isWindows) {
      return '''
To install dex2jar on Windows:

1. Download from: https://github.com/pxb1988/dex2jar/releases
2. Extract to %LOCALAPPDATA%\\dex-tools\\
3. Add to PATH via System Properties > Environment Variables
4. Restart your terminal/IDE

Or use Chocolatey: choco install dex2jar
''';
    }
    return 'Please download dex2jar from: https://github.com/pxb1988/dex2jar/releases';
  }
}

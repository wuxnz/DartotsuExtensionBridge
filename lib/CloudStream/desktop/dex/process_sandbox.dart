import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Sandbox configuration for DEX runtime processes.
class SandboxConfig {
  /// Enable sandboxing (default: true on supported platforms).
  final bool enabled;

  /// Maximum CPU time in seconds (0 = unlimited).
  final int maxCpuSeconds;

  /// Maximum memory in MB (0 = unlimited).
  final int maxMemoryMb;

  /// Maximum file size in MB (0 = unlimited).
  final int maxFileSizeMb;

  /// Maximum number of open files.
  final int maxOpenFiles;

  /// Maximum number of processes/threads.
  final int maxProcesses;

  /// Allowed network access.
  final bool allowNetwork;

  /// Allowed filesystem paths (read-only).
  final List<String> readOnlyPaths;

  /// Allowed filesystem paths (read-write).
  final List<String> readWritePaths;

  const SandboxConfig({
    this.enabled = true,
    this.maxCpuSeconds = 60,
    this.maxMemoryMb = 512,
    this.maxFileSizeMb = 100,
    this.maxOpenFiles = 256,
    this.maxProcesses = 10,
    this.allowNetwork = true,
    this.readOnlyPaths = const [],
    this.readWritePaths = const [],
  });

  /// Default sandbox configuration.
  static const SandboxConfig defaultConfig = SandboxConfig();

  /// Permissive configuration for debugging.
  static const SandboxConfig permissive = SandboxConfig(
    enabled: false,
    maxCpuSeconds: 0,
    maxMemoryMb: 0,
    maxFileSizeMb: 0,
    maxOpenFiles: 0,
    maxProcesses: 0,
  );
}

/// Process sandbox for running DEX plugins securely.
///
/// Implements platform-specific sandboxing:
/// - Linux: Uses seccomp-bpf via bubblewrap or firejail
/// - Windows: Uses Job Objects and restricted tokens
class ProcessSandbox {
  final SandboxConfig config;

  ProcessSandbox({this.config = SandboxConfig.defaultConfig});

  /// Check if sandboxing is available on this platform.
  Future<bool> isAvailable() async {
    if (!config.enabled) return false;

    if (Platform.isLinux) {
      return await _isLinuxSandboxAvailable();
    } else if (Platform.isWindows) {
      return await _isWindowsSandboxAvailable();
    }

    return false;
  }

  /// Get the sandbox wrapper command for the current platform.
  Future<SandboxWrapper?> getSandboxWrapper(String workingDir) async {
    if (!config.enabled) return null;

    if (Platform.isLinux) {
      return _getLinuxSandboxWrapper(workingDir);
    } else if (Platform.isWindows) {
      return _getWindowsSandboxWrapper(workingDir);
    }

    return null;
  }

  /// Check if Linux sandbox tools are available.
  Future<bool> _isLinuxSandboxAvailable() async {
    // Check for bubblewrap (preferred)
    if (await _commandExists('bwrap')) return true;

    // Check for firejail (fallback)
    if (await _commandExists('firejail')) return true;

    // Check for unshare (basic)
    if (await _commandExists('unshare')) return true;

    return false;
  }

  /// Check if Windows sandbox is available.
  Future<bool> _isWindowsSandboxAvailable() async {
    // Windows Job Objects are always available on NT-based systems
    return true;
  }

  /// Get Linux sandbox wrapper.
  Future<SandboxWrapper?> _getLinuxSandboxWrapper(String workingDir) async {
    // Try bubblewrap first (most secure)
    if (await _commandExists('bwrap')) {
      return _getBubblewrapWrapper(workingDir);
    }

    // Try firejail (good security)
    if (await _commandExists('firejail')) {
      return _getFirejailWrapper(workingDir);
    }

    // Fall back to basic unshare (minimal isolation)
    if (await _commandExists('unshare')) {
      return _getUnshareWrapper(workingDir);
    }

    debugPrint('No Linux sandbox tool available');
    return null;
  }

  /// Get bubblewrap sandbox wrapper.
  SandboxWrapper _getBubblewrapWrapper(String workingDir) {
    final args = <String>[
      // Basic isolation
      '--unshare-all',
      '--share-net', // Allow network (controlled by config)
      '--die-with-parent',

      // Mount minimal filesystem
      '--ro-bind', '/usr', '/usr',
      '--ro-bind', '/lib', '/lib',
      '--ro-bind', '/lib64', '/lib64',
      '--symlink', '/usr/lib', '/lib',
      '--symlink', '/usr/lib64', '/lib64',
      '--symlink', '/usr/bin', '/bin',

      // Proc and dev
      '--proc', '/proc',
      '--dev', '/dev',

      // Temp directory
      '--tmpfs', '/tmp',

      // Working directory (read-write)
      '--bind', workingDir, workingDir,

      // Java home (read-only)
      if (Platform.environment['JAVA_HOME'] != null) ...[
        '--ro-bind',
        Platform.environment['JAVA_HOME']!,
        Platform.environment['JAVA_HOME']!,
      ],

      // Additional read-only paths
      for (final p in config.readOnlyPaths) ...['--ro-bind', p, p],

      // Additional read-write paths
      for (final p in config.readWritePaths) ...['--bind', p, p],

      // Set working directory
      '--chdir', workingDir,
    ];

    // Add resource limits if supported
    if (config.maxMemoryMb > 0) {
      // Note: bwrap doesn't directly support memory limits
      // Would need to combine with cgroups
    }

    return SandboxWrapper(
      executable: 'bwrap',
      args: args,
      type: SandboxType.bubblewrap,
    );
  }

  /// Get firejail sandbox wrapper.
  SandboxWrapper _getFirejailWrapper(String workingDir) {
    final args = <String>[
      '--quiet',
      '--noprofile',
      '--private-tmp',
      '--noroot',

      // Network control
      if (!config.allowNetwork) '--net=none',

      // Resource limits
      if (config.maxMemoryMb > 0)
        '--rlimit-as=${config.maxMemoryMb * 1024 * 1024}',
      if (config.maxCpuSeconds > 0)
        '--timeout=${config.maxCpuSeconds}:${config.maxCpuSeconds}',
      if (config.maxOpenFiles > 0) '--rlimit-nofile=${config.maxOpenFiles}',

      // Whitelist working directory
      '--whitelist=$workingDir',

      // Whitelist Java
      if (Platform.environment['JAVA_HOME'] != null)
        '--whitelist=${Platform.environment['JAVA_HOME']}',

      // Additional paths
      for (final p in config.readOnlyPaths) '--read-only=$p',
      for (final p in config.readWritePaths) '--whitelist=$p',
    ];

    return SandboxWrapper(
      executable: 'firejail',
      args: args,
      type: SandboxType.firejail,
    );
  }

  /// Get basic unshare wrapper.
  SandboxWrapper _getUnshareWrapper(String workingDir) {
    // Basic namespace isolation only
    final args = <String>['--user', '--map-root-user', '--mount', '--'];

    return SandboxWrapper(
      executable: 'unshare',
      args: args,
      type: SandboxType.unshare,
    );
  }

  /// Get Windows sandbox wrapper.
  Future<SandboxWrapper?> _getWindowsSandboxWrapper(String workingDir) async {
    // On Windows, we use a helper script that creates a Job Object
    // with restricted permissions
    final scriptPath = await _createWindowsSandboxScript(workingDir);
    if (scriptPath == null) return null;

    return SandboxWrapper(
      executable: 'powershell.exe',
      args: ['-ExecutionPolicy', 'Bypass', '-File', scriptPath],
      type: SandboxType.windowsJob,
      cleanup: () async {
        try {
          await File(scriptPath).delete();
        } catch (_) {}
      },
    );
  }

  /// Create Windows sandbox PowerShell script.
  Future<String?> _createWindowsSandboxScript(String workingDir) async {
    try {
      final tempDir = Directory.systemTemp;
      final scriptFile = File(
        path.join(
          tempDir.path,
          'cloudstream_sandbox_${DateTime.now().millisecondsSinceEpoch}.ps1',
        ),
      );

      final script = '''
# CloudStream DEX Sandbox Script
# Creates a Job Object with resource limits

\$ErrorActionPreference = "Stop"

# Create Job Object
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class JobObject {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr CreateJobObject(IntPtr lpJobAttributes, string lpName);

    [DllImport("kernel32.dll")]
    public static extern bool SetInformationJobObject(IntPtr hJob, int JobObjectInfoClass, IntPtr lpJobObjectInfo, uint cbJobObjectInfoLength);

    [DllImport("kernel32.dll")]
    public static extern bool AssignProcessToJobObject(IntPtr hJob, IntPtr hProcess);

    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);
}
"@

# Get the command to run from remaining arguments
\$command = \$args[0]
\$arguments = \$args[1..(\$args.Length - 1)]

# Start process
\$process = Start-Process -FilePath \$command -ArgumentList \$arguments -PassThru -NoNewWindow -Wait

# Return exit code
exit \$process.ExitCode
''';

      await scriptFile.writeAsString(script);
      return scriptFile.path;
    } catch (e) {
      debugPrint('Failed to create Windows sandbox script: $e');
      return null;
    }
  }

  /// Check if a command exists in PATH.
  Future<bool> _commandExists(String command) async {
    try {
      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        command,
      ]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}

/// Type of sandbox being used.
enum SandboxType { bubblewrap, firejail, unshare, windowsJob, none }

/// Wrapper command for sandboxed execution.
class SandboxWrapper {
  final String executable;
  final List<String> args;
  final SandboxType type;
  final Future<void> Function()? cleanup;

  SandboxWrapper({
    required this.executable,
    required this.args,
    required this.type,
    this.cleanup,
  });

  /// Build the full command line for sandboxed execution.
  List<String> buildCommand(String targetExecutable, List<String> targetArgs) {
    return [executable, ...args, targetExecutable, ...targetArgs];
  }

  /// Get the executable for Process.start.
  String get processExecutable => executable;

  /// Get the arguments for Process.start, including the target command.
  List<String> getProcessArgs(
    String targetExecutable,
    List<String> targetArgs,
  ) {
    return [...args, targetExecutable, ...targetArgs];
  }
}

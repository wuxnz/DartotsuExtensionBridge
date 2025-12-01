/// DEX Runtime abstraction for CloudStream plugin execution on desktop.
///
/// This module defines the interface for executing Android DEX-based plugins
/// on desktop platforms using various runtime strategies.
library;

/// Supported DEX runtime implementations.
enum DexRuntimeType {
  /// Convert DEX to JAR using dex2jar, execute on bundled JRE.
  dex2jarJre,

  /// Use GraalVM native image for Kotlin/JVM bytecode execution.
  graalvm,

  /// Embedded Dalvik/ART interpreter (experimental).
  embeddedDalvik,

  /// No DEX runtime available.
  none,
}

/// Result of a DEX runtime operation.
class DexRuntimeResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final Duration? executionTime;

  DexRuntimeResult({
    required this.success,
    this.data,
    this.error,
    this.executionTime,
  });

  factory DexRuntimeResult.success(T data, {Duration? executionTime}) {
    return DexRuntimeResult(
      success: true,
      data: data,
      executionTime: executionTime,
    );
  }

  factory DexRuntimeResult.failure(String error) {
    return DexRuntimeResult(success: false, error: error);
  }
}

/// Status of the DEX runtime.
class DexRuntimeStatus {
  final bool isAvailable;
  final DexRuntimeType type;
  final String? version;
  final String? runtimePath;
  final List<String> capabilities;
  final Map<String, dynamic> diagnostics;

  DexRuntimeStatus({
    required this.isAvailable,
    required this.type,
    this.version,
    this.runtimePath,
    this.capabilities = const [],
    this.diagnostics = const {},
  });

  Map<String, dynamic> toJson() => {
    'isAvailable': isAvailable,
    'type': type.name,
    'version': version,
    'runtimePath': runtimePath,
    'capabilities': capabilities,
    'diagnostics': diagnostics,
  };
}

/// Configuration for DEX runtime execution.
class DexRuntimeConfig {
  /// Maximum execution time for a single operation.
  final Duration timeout;

  /// Maximum memory allocation (in MB).
  final int maxMemoryMb;

  /// Whether to enable JIT compilation (if supported).
  final bool enableJit;

  /// Whether to run in a sandboxed process.
  final bool sandboxed;

  /// Additional JVM arguments.
  final List<String> jvmArgs;

  /// Environment variables to pass to the runtime.
  final Map<String, String> environment;

  const DexRuntimeConfig({
    this.timeout = const Duration(seconds: 30),
    this.maxMemoryMb = 256,
    this.enableJit = true,
    this.sandboxed = true,
    this.jvmArgs = const [],
    this.environment = const {},
  });

  List<String> toJvmArgs() {
    return ['-Xmx${maxMemoryMb}m', if (!enableJit) '-Xint', ...jvmArgs];
  }
}

/// Abstract interface for DEX runtime implementations.
///
/// Each runtime strategy (dex2jar+JRE, GraalVM, embedded Dalvik) implements
/// this interface to provide a consistent API for plugin execution.
abstract class DexRuntime {
  /// Get the runtime type.
  DexRuntimeType get type;

  /// Get the current runtime status.
  Future<DexRuntimeStatus> getStatus();

  /// Initialize the runtime.
  ///
  /// This may involve:
  /// - Checking for required binaries (java, dex2jar, etc.)
  /// - Setting up the runtime environment
  /// - Warming up the JIT compiler
  Future<DexRuntimeResult<void>> initialize(DexRuntimeConfig config);

  /// Load a plugin from a DEX file.
  ///
  /// [dexPath] is the path to the classes.dex file.
  /// [pluginClassName] is the fully-qualified class name of the plugin.
  /// [pluginId] is a unique identifier for this plugin instance.
  Future<DexRuntimeResult<String>> loadPlugin({
    required String dexPath,
    required String pluginClassName,
    required String pluginId,
  });

  /// Unload a previously loaded plugin.
  Future<DexRuntimeResult<void>> unloadPlugin(String pluginId);

  /// Call a method on a loaded plugin.
  ///
  /// [pluginId] identifies the plugin instance.
  /// [methodName] is the method to call.
  /// [args] are the method arguments (JSON-serializable).
  Future<DexRuntimeResult<Map<String, dynamic>>> callMethod({
    required String pluginId,
    required String methodName,
    required List<dynamic> args,
  });

  /// Check if a plugin is loaded.
  bool isPluginLoaded(String pluginId);

  /// Get list of loaded plugin IDs.
  List<String> getLoadedPlugins();

  /// Shutdown the runtime and release resources.
  Future<void> shutdown();

  /// Cancel any running operations for a plugin.
  Future<void> cancelOperations(String pluginId);
}

/// Factory for creating DEX runtime instances.
class DexRuntimeFactory {
  /// Detect the best available DEX runtime on the current system.
  static Future<DexRuntimeType> detectAvailableRuntime() async {
    // Check for JRE first (most common)
    if (await _isJreAvailable()) {
      return DexRuntimeType.dex2jarJre;
    }

    // Check for GraalVM
    if (await _isGraalVmAvailable()) {
      return DexRuntimeType.graalvm;
    }

    return DexRuntimeType.none;
  }

  static Future<bool> _isJreAvailable() async {
    // Will be implemented to check for java binary
    return false;
  }

  static Future<bool> _isGraalVmAvailable() async {
    // Will be implemented to check for GraalVM
    return false;
  }
}

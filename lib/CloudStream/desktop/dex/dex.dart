/// CloudStream DEX plugin execution support for desktop.
///
/// This module provides DEX-based plugin execution on Linux and Windows
/// platforms using dex2jar + JRE or alternative runtimes.
///
/// **Note**: DEX execution is experimental and requires:
/// - Java Runtime Environment (JRE) 11 or later
/// - dex2jar tool for DEX to JAR conversion
///
/// See CLOUDSTREAM_DESKTOP.md for setup instructions.
library;

export 'dex2jar_converter.dart';
export 'dex_plugin_service.dart';
export 'dex_runtime_interface.dart';
export 'host_api_shims.dart';
export 'jre_dex_runtime.dart';
export 'process_sandbox.dart';

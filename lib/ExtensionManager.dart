import 'dart:io';

import 'package:dartotsu_extension_bridge/Settings/Settings.dart';
import 'package:get/get.dart';

import 'Aniyomi/AniyomiExtensions.dart';
import 'Aniyomi/AniyomiSourceMethods.dart';
import 'Aniyomi/desktop/aniyomi_desktop_channel_handler.dart';
import 'Aniyomi/desktop/aniyomi_desktop_config.dart';
import 'CloudStream/CloudStreamExtensions.dart';
import 'CloudStream/CloudStreamSourceMethods.dart';
import 'CloudStream/desktop/cloudstream_desktop_channel_handler.dart';
import 'Extensions/Extensions.dart';
import 'Extensions/SourceMethods.dart';
import 'Lnreader/LnReaderExtensions.dart';
import 'Lnreader/LnReaderSourceMethods.dart';
import 'Mangayomi/MangayomiExtensions.dart';
import 'Mangayomi/MangayomiSourceMethods.dart';
import 'Models/Source.dart';
import 'extension_bridge.dart';

class ExtensionManager extends GetxController {
  ExtensionManager() {
    initialize();
  }

  late final Rx<Extension> _currentManager;

  Extension get currentManager => _currentManager.value;

  void initialize() {
    final settings = isar.bridgeSettings.getSync(26)!;
    final savedType = ExtensionType.fromString(settings.currentManager);
    _currentManager = savedType.getManager().obs;
  }

  void setCurrentManager(ExtensionType type) {
    _currentManager.value = type.getManager();
    final settings = isar.bridgeSettings.getSync(26)!;
    isar.writeTxnSync(() {
      isar.bridgeSettings.putSync(settings..currentManager = type.toString());
    });
  }
}

abstract class HasSourceMethods {
  SourceMethods get methods;
}

extension SourceMethodsExtension on Source {
  SourceMethods get methods => currentSourceMethods(this);
}

SourceMethods currentSourceMethods(Source source) {
  if (source is HasSourceMethods) {
    return (source as HasSourceMethods).methods;
  }

  final type = source.extensionType;
  switch (type) {
    case ExtensionType.mangayomi:
      return MangayomiSourceMethods(source);
    case ExtensionType.aniyomi:
      return AniyomiSourceMethods(source);
    case ExtensionType.cloudstream:
      return CloudStreamSourceMethods(source);
    case ExtensionType.lnreader:
      return LnReaderSourceMethods(source);
    case null:
      // Default to Mangayomi for sources without explicit type
      return MangayomiSourceMethods(source);
  }
}

/// Get the list of supported extension types for the current platform.
///
/// On Android: All extension types are supported.
/// On Desktop (Linux/Windows): Mangayomi, LnReader, and CloudStream are supported.
/// Aniyomi is conditionally supported on desktop if the DEX runtime is available.
List<ExtensionType> get getSupportedExtensions {
  if (Platform.isAndroid) {
    return ExtensionType.values;
  }

  // Desktop platforms
  final supported = <ExtensionType>[
    ExtensionType.mangayomi,
    ExtensionType.lnreader,
  ];

  // CloudStream is supported on desktop with JS runtime when handler is set up
  if (Platform.isLinux || Platform.isWindows) {
    final handler = CloudStreamDesktopChannelHandler.instance;
    if (handler.isSetup) {
      supported.add(ExtensionType.cloudstream);
    }
  }

  // Aniyomi is conditionally supported on desktop with DEX runtime
  if ((Platform.isLinux || Platform.isWindows) &&
      aniyomiDesktopConfig.enableDesktopAniyomi &&
      isDesktopAniyomiAvailable) {
    supported.add(ExtensionType.aniyomi);
  }

  return supported;
}

enum ExtensionType {
  mangayomi,
  aniyomi,
  cloudstream,
  lnreader;

  Extension getManager() {
    switch (this) {
      case ExtensionType.aniyomi:
        return Get.find<AniyomiExtensions>(tag: 'AniyomiExtensions');
      case ExtensionType.mangayomi:
        return Get.find<MangayomiExtensions>(tag: 'MangayomiExtensions');
      case ExtensionType.cloudstream:
        return Get.find<CloudStreamExtensions>(tag: 'CloudStreamExtensions');
      case ExtensionType.lnreader:
        return Get.find<LnReaderExtensions>(tag: 'LnReaderExtensions');
    }
  }

  @override
  String toString() {
    switch (this) {
      case ExtensionType.aniyomi:
        return 'Aniyomi';
      case ExtensionType.mangayomi:
        return 'Mangayomi';
      case ExtensionType.cloudstream:
        return 'CloudStream';
      case ExtensionType.lnreader:
        return 'LnReader';
    }
  }

  static ExtensionType fromString(String? name) {
    return ExtensionType.values.firstWhere(
      (e) => e.toString() == name,
      orElse: () => getSupportedExtensions.first,
    );
  }

  static ExtensionType fromManager(Extension manager) {
    if (manager is AniyomiExtensions) {
      return ExtensionType.aniyomi;
    } else if (manager is MangayomiExtensions) {
      return ExtensionType.mangayomi;
    } else if (manager is CloudStreamExtensions) {
      return ExtensionType.cloudstream;
    } else if (manager is LnReaderExtensions) {
      return ExtensionType.lnreader;
    }
    throw Exception('Unknown extension manager type');
  }
}

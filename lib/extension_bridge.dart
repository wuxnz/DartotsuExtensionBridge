import 'dart:io';

import 'package:dartotsu_extension_bridge/Settings/Settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'Aniyomi/AniyomiExtensions.dart';
import 'Aniyomi/desktop/aniyomi_desktop_channel_handler.dart';
import 'Aniyomi/desktop/aniyomi_desktop_config.dart';
import 'CloudStream/CloudStreamExtensions.dart';
import 'CloudStream/desktop/cloudstream_desktop_channel_handler.dart';
import 'ExtensionManager.dart';
import 'Lnreader/LnReaderExtensions.dart';
import 'Mangayomi/Eval/dart/model/source_preference.dart';
import 'Mangayomi/MangayomiExtensions.dart';
import 'Mangayomi/Models/Source.dart';
import 'package:aniya/eval_extensions/aniya_eval_extensions.dart';
import 'package:aniya/eval_extensions/storage/aniya_eval_plugin_store.dart';

late Isar isar;
WebViewEnvironment? webViewEnvironment;

class DartotsuExtensionBridge {
  Future<void> init(Isar? isarInstance, String dirName) async {
    var document = await getDatabaseDirectory(dirName);
    if (isarInstance == null) {
      isar = Isar.openSync([
        MSourceSchema,
        SourcePreferenceSchema,
        SourcePreferenceStringValueSchema,
        BridgeSettingsSchema,
      ], directory: p.join(document.path, 'isar'));
    } else {
      isar = isarInstance;
    }
    final settings = await isar.bridgeSettings
        .filter()
        .idEqualTo(26)
        .findFirst();
    if (settings == null) {
      isar.writeTxnSync(
        () => isar.bridgeSettings.putSync(BridgeSettings()..id = 26),
      );
    }

    if (Platform.isAndroid) {
      Get.put(AniyomiExtensions(), tag: 'AniyomiExtensions');
    }

    // Initialize desktop CloudStream support before creating CloudStreamExtensions
    if (Platform.isLinux || Platform.isWindows) {
      try {
        await initializeDesktopCloudStream();
        debugPrint('Desktop CloudStream support initialized');
      } catch (e) {
        debugPrint('Failed to initialize desktop CloudStream: $e');
        // Continue without CloudStream support on desktop
      }

      // Initialize desktop Aniyomi support if enabled
      if (aniyomiDesktopConfig.enableDesktopAniyomi) {
        try {
          await initializeDesktopAniyomi();
          debugPrint('Desktop Aniyomi support initialized');
          // Register AniyomiExtensions for desktop when DEX runtime is available
          if (isDesktopAniyomiAvailable) {
            Get.put(AniyomiExtensions(), tag: 'AniyomiExtensions');
          }
        } catch (e) {
          debugPrint('Failed to initialize desktop Aniyomi: $e');
          // Continue without Aniyomi support on desktop
        }
      }
    }

    if (Platform.isAndroid || Platform.isLinux || Platform.isWindows) {
      Get.put(CloudStreamExtensions(), tag: 'CloudStreamExtensions');
    }
    // Register Aniya eval-based extensions manager
    final aniyaStore = AniyaEvalPluginStore();
    final aniyaManager = AniyaEvalExtensions(store: aniyaStore);
    Get.put(aniyaStore);
    Get.put(aniyaManager, tag: 'AniyaEvalExtensions');
    Get.put(MangayomiExtensions(), tag: 'MangayomiExtensions');
    Get.put(LnReaderExtensions(), tag: 'LnReaderExtensions');
    Get.put(ExtensionManager());
    if (Platform.isWindows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      if (availableVersion != null) {
        webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(
            userDataFolder: p.join(document.path, 'flutter_inappwebview'),
          ),
        );
      }
    }
  }
}

Future<Directory> getDatabaseDirectory(String dirName) async {
  final dir = await getApplicationDocumentsDirectory();
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return dir;
  } else {
    String dbDir = p.join(dir.path, dirName, 'databases');
    await Directory(dbDir).create(recursive: true);
    return Directory(dbDir);
  }
}

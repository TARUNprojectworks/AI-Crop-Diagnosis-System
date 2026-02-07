import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/preferences_service.dart';
import 'services/speech_service.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/submission_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);

  final speechService = SpeechService();
  await speechService.init();

  final storageService = StorageService();
  final syncService = SyncService(storageService: storageService);

  // Start auto-sync service
  syncService.startAutoSync(interval: const Duration(minutes: 5));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(preferencesService)),
        ChangeNotifierProvider(
            create: (_) => LanguageProvider(preferencesService)),
        ChangeNotifierProvider(
            create: (_) => FontSizeProvider(preferencesService)),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProxyProvider<ConnectivityProvider, SubmissionProvider>(
          create: (context) => SubmissionProvider(
            storageService: storageService,
            syncService: syncService,
          ),
          update: (context, connectivity, previous) {
            // Trigger sync when connectivity changes to online
            if (connectivity.isOnline && previous != null) {
              syncService.syncPendingSubmissions();
            }
            return previous ??
                SubmissionProvider(
                  storageService: storageService,
                  syncService: syncService,
                );
          },
        ),
        Provider.value(value: speechService),
        Provider.value(value: storageService),
        Provider.value(value: syncService),
        Provider.value(value: preferencesService),
      ],
      child: const CropDiseaseApp(),
    ),
  );
}

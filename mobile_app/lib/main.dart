import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/theme/app_theme.dart';
import 'core/services/isar_service.dart';
import 'core/app_router.dart';
import 'core/utils/ad_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/services/app_lifecycle_reactor.dart';
import 'core/services/ad_synchronization_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/ui/app_bootstrap.dart';

import 'package:flutter/foundation.dart'; // Add this import

// ... imports

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Initialize Firebase first as it's often needed for other services
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Only enable Crashlytics collection in production
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // 2. Load .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env loading failed: $e');
  }

  // 3. Initialize Ads and Isar
  final isarService = IsarService();

  final isarInit = isarService.init().catchError((e, stack) {
    debugPrint('Isar initialization failed: $e');
    FirebaseCrashlytics.instance
        .recordError(e, stack, reason: 'Isar Init Failed');
  });

  final adsInit = AdHelper.initAds().catchError((e, stack) {
    debugPrint('Ads initialization failed: $e');
    FirebaseCrashlytics.instance
        .recordError(e, stack, reason: 'Ads Init Failed');
  });

  // 4. Set System UI Overlay Style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 5. Preload Theme with a TIMEOUT
  ThemeMode initialTheme = ThemeMode.dark;
  try {
    final container = ProviderContainer();
    initialTheme = await container
        .read(themeInitializationProvider.future)
        .timeout(const Duration(seconds: 2), onTimeout: () => ThemeMode.dark);
    container.dispose();
  } catch (e, stack) {
    debugPrint('Theme loading failed: $e');
    FirebaseCrashlytics.instance
        .recordError(e, stack, reason: 'Theme Loading Failed');
  }

  // Wait for critical services with a safety net
  await Future.wait([
    isarInit,
    adsInit,
  ]).timeout(const Duration(seconds: 5), onTimeout: () => []);

  final appContainer = ProviderContainer(
    overrides: [
      isarServiceProvider.overrideWithValue(isarService),
      themeProvider.overrideWith((ref) => ThemeNotifier(initialTheme)),
    ],
  );

  runApp(UncontrolledProviderScope(
    container: appContainer,
    child: const AppBootstrap(child: AiResumeBuilderApp()),
  ));

  // Explicitly remove splash after rendering starts
  FlutterNativeSplash.remove();
}

class AiResumeBuilderApp extends ConsumerStatefulWidget {
  const AiResumeBuilderApp({super.key});

  @override
  ConsumerState<AiResumeBuilderApp> createState() => _AiResumeBuilderAppState();
}

class _AiResumeBuilderAppState extends ConsumerState<AiResumeBuilderApp> {
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    // Initialize Ad Sync and Lifecycle Reactor
    final adService = ref.read(adSynchronizationProvider);
    _appLifecycleReactor = AppLifecycleReactor(adService);
    _appLifecycleReactor.listenToAppStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'AI Resume Builder & CV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouterProvider,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Generated delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
      ],
    );
  }
}

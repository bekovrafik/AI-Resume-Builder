import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/services/isar_service.dart';
import 'core/app_router.dart';
import 'core/utils/ad_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/app_lifecycle_reactor.dart';
import 'core/services/ad_synchronization_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/ui/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  await AdHelper.initAds();

  final isarService = IsarService();
  await isarService.init();

  // Set System UI Overlay Style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent, // Fix for "black screen"
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness
        .light, // Or dynamic based on theme, but usually best to start with one
  ));
  await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge); // Enforce edge-to-edge checks

  // Preload Theme
  final container = ProviderContainer();
  final initialTheme = await container.read(themeInitializationProvider.future);

  // Re-create container WITH overrides to fix dependency issues
  // We dispose the temporary one used for reading 'themeInitializationProvider' if we want,
  // but it's cleaner to just create a new one with overrides.
  container.dispose();

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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/isar_service.dart';
import 'core/app_router.dart';
import 'core/utils/ad_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/app_lifecycle_reactor.dart';
import 'core/services/ad_synchronization_service.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AdHelper.initAds();

  final isarService = IsarService();
  await isarService.init();

  // Preload Theme
  final container = ProviderContainer();
  final initialTheme = await container.read(themeInitializationProvider.future);

  runApp(UncontrolledProviderScope(
    container: container,
    child: ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
        themeProvider.overrideWith((ref) => ThemeNotifier(initialTheme)),
      ],
      child: const AiResumeBuilderApp(),
    ),
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

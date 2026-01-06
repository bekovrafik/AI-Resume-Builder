import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/core/services/ad_synchronization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manual Mock for Ad Service
class MockAdSynchronizationService extends AdSynchronizationService {
  MockAdSynchronizationService() : super(autoStart: false);
  // Actually, AdSynchronizationService ctor triggers initPreloading which might be bad.
  // But Dart mocking via extends is tricky if ctor has side effects.
  // Ideally, use an interface or a facade.
  // For now, let's assume the side effects (Ad load) will fail silently in test env
  // OR we override logic to do nothing.

  @override
  void loadAppOpenAd() {}
  @override
  void loadRewardedInterstitialAd() {}
  @override
  void showAppOpenAdIfAvailable() {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // 2. Build App with Overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adSynchronizationProvider
              .overrideWithValue(MockAdSynchronizationService()),
        ],
        child: const AiResumeBuilderApp(),
      ),
    );

    // 3. Verify it builds
    // We expect to find the MaterialApp (title check)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

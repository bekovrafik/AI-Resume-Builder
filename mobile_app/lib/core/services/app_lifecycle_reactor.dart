import 'package:flutter/material.dart';
import 'package:mobile_app/core/services/ad_synchronization_service.dart';

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AdSynchronizationService adService;

  AppLifecycleReactor(this.adService);

  void listenToAppStateChanges() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Warm Start: Show App Open Ad
      adService.showAppOpenAdIfAvailable();
    }
  }
}

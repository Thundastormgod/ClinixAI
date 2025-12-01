// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// Platform Detection Utilities
// Provides cross-platform detection for web-safe demo mode

import 'package:flutter/foundation.dart';

/// Platform detection utilities for ClinixAI.
/// 
/// Used to determine which features are available on the current platform.
/// Web and desktop platforms use demo/mock implementations since
/// Cactus SDK and Isar require native binaries.
class PlatformUtils {
  PlatformUtils._();

  /// Returns true if running on web.
  static bool get isWeb => kIsWeb;

  /// Returns true if running on a platform that supports native features.
  /// Currently only Android and iOS support Cactus SDK and Isar.
  static bool get isNativeMobile {
    if (kIsWeb) return false;
    // Use defaultTargetPlatform which is safe on all platforms
    return defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Returns true if running on desktop (Windows, macOS, Linux).
  static bool get isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Returns true if we should use demo mode (mock implementations).
  /// Demo mode is used on web and desktop where native SDKs aren't available.
  static bool get useDemoMode => isWeb || isDesktop;

  /// Returns true if we can use native Cactus SDK for local LLM.
  static bool get canUseCactusSDK => isNativeMobile;

  /// Returns true if we can use native Isar database.
  static bool get canUseIsarDatabase => isNativeMobile;

  /// Returns a human-readable platform name.
  static String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }
}

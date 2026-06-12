import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../data/mock_data.dart';
import '../models/user_profile.dart';

/// Lightweight wrapper that attempts platform social sign-in and returns a
/// partial `UserProfile` using `MockData.demoUser` as a base. If the
/// platform flow fails or is not available, methods return `null` so callers
/// can fall back to mock behaviour.
class SocialAuth {
  static final GoogleSignIn _google = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Attempts interactive Google sign-in. Returns a UserProfile or null.
  static Future<UserProfile?> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) return null;
      final displayName = account.displayName;
      final email = account.email;
      return MockData.demoUser.copyWith(
        name: displayName ?? email.split('@').first,
        email: email,
      );
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Google sign-in failed: $e\n$st');
      }
      return null;
    }
  }

  /// Attempts Sign in with Apple. Returns a UserProfile or null.
  static Future<UserProfile?> signInWithApple() async {
    try {
      // This will present the native Apple sign-in UI on supported platforms.
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final email = credential.email ?? '${credential.userIdentifier}@appleid';
      final name = credential.givenName != null
          ? '${credential.givenName}${credential.familyName != null ? ' ${credential.familyName}' : ''}'
          : email.split('@').first;

      return MockData.demoUser.copyWith(
        name: name,
        email: email,
      );
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Apple sign-in failed: $e\n$st');
      }
      return null;
    }
  }
}

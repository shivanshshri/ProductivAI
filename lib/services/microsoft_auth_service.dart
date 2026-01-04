import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:ai_app/screens/dashboard.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onLoginSuccess() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
}

class MicrosoftAuthService {
  static const String clientId = "5682fa2e-768e-44aa-81ef-44009a9cc82f";
  static const String redirectUrl = "msal5682fa2e-768e-44aa-81ef-44009a9cc82f://auth";

  // ✅ FIXED: Added Calendars.Read to the scope
  static const String scope = "openid profile email offline_access User.Read Calendars.Read";

  StreamSubscription? _sub;

  Future<void> signOut() async {
    try {
      print("🔵 Signing out...");

      // Cancel any active subscriptions
      await _sub?.cancel();

      // Optional: Revoke the refresh token (if you stored it)
      // You would need to store the refresh token somewhere to do this

      print("✅ Signed out successfully");
    } catch (e) {
      print("❌ Sign out error: $e");
    }
  }

  Future<Map<String, dynamic>?> signInWithMicrosoft() async {
    final completer = Completer<Map<String, dynamic>?>();
    final appLinks = AppLinks();

    try {
      // Build authorization URL
      final authUrl = Uri.https(
        'login.microsoftonline.com',
        '/common/oauth2/v2.0/authorize',
        {
          'client_id': clientId,
          'response_type': 'code',
          'redirect_uri': redirectUrl,
          'scope': scope,
          'response_mode': 'query',
          'prompt': 'select_account',
        },
      );

      print("🔵 Authorization URL: $authUrl");

      // Set up app links listener BEFORE launching browser
      _sub = appLinks.uriLinkStream.listen((Uri uri) async {
        print("🔵 Received app link: $uri");

        if (uri.toString().startsWith(redirectUrl)) {
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];

          if (error != null) {
            print("❌ OAuth error: $error");
            print("❌ Error description: ${uri.queryParameters['error_description']}");
            await _sub?.cancel();
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            return;
          }

          if (code != null) {
            print("✅ Got authorization code: ${code.substring(0, 10)}...");
            final tokens = await _exchangeCodeForTokens(code);
            await _sub?.cancel();
            if (!completer.isCompleted) {
              completer.complete(tokens);
            }
          } else {
            print("❌ No code in redirect");
            await _sub?.cancel();
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
        }
      }, onError: (err) {
        print("❌ App link error: $err");
        _sub?.cancel();
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      // Give listener time to set up
      await Future.delayed(Duration(milliseconds: 500));

      // Launch browser
      print("🔵 Launching browser...");
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        print("❌ Failed to launch browser");
        await _sub?.cancel();
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      } else {
        print("✅ Browser launched successfully");
      }

      // Timeout after 5 minutes
      Timer(Duration(minutes: 5), () {
        if (!completer.isCompleted) {
          print("⏱️ Authentication timeout");
          _sub?.cancel();
          completer.complete(null);
        }
      });

    } catch (e, stackTrace) {
      print("❌ Sign in error: $e");
      print("❌ Stack trace: $stackTrace");
      await _sub?.cancel();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }

    return completer.future;


  }

  Future<Map<String, dynamic>?> _exchangeCodeForTokens(String code) async {
    try {
      print("🔵 Exchanging code for tokens...");

      final response = await http.post(
        Uri.parse('https://login.microsoftonline.com/common/oauth2/v2.0/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'code': code,
          'redirect_uri': redirectUrl,
          'grant_type': 'authorization_code',
          'scope': scope,
        },
      );

      print("🔵 Token response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Successfully got tokens!");
        print("✅ Access token length: ${data['access_token']?.length ?? 0}");

        final accessToken = data['access_token'];
        final profile = await _getMicrosoftUserProfile(accessToken);

        return {
          'accessToken': accessToken,
          'idToken': data['id_token'],
          'refreshToken': data['refresh_token'],
          'displayName': profile?['displayName'],
          'email': profile?['email'],
        };
      } else {
        print("❌ Token exchange failed: ${response.statusCode}");
        print("❌ Response: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("❌ Token exchange error: $e");
      print("❌ Stack trace: $stackTrace");
    }
    return null;
  }

  // Fixed: Moved this method outside of _exchangeCodeForTokens
  Future<Map<String, dynamic>?> _getMicrosoftUserProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'displayName': data['displayName'],
          'email': data['mail'] ?? data['userPrincipalName'],
        };
      } else {
        print("❌ Graph error: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("❌ Graph exception: $e");
    }
    return null;
  }

  void dispose() {
    _sub?.cancel();
  }
}


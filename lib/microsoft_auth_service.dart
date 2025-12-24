import 'package:flutter_appauth/flutter_appauth.dart';

class MicrosoftAuthService {
  static const String clientId = "5682fa2e-768e-44aa-81ef-44009a9cc82f";
  static const String tenantId = "common";
  static const String redirectUrl =
      "https://login.live.com/oauth20_desktop.srf";

  static const List<String> scopes = [
    "openid",
    "profile",
    "email",
    "offline_access",
    "User.Read"
  ];

  final FlutterAppAuth _appAuth = FlutterAppAuth();

  Future<Map<String, dynamic>?> signInWithMicrosoft() async {
    try {
      final AuthorizationTokenResponse? result =
      await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          scopes: scopes,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint:
            "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            tokenEndpoint:
            "https://login.microsoftonline.com/common/oauth2/v2.0/token",
          ),
        ),
      );

      if (result != null) {
        return {
          "accessToken": result.accessToken,
          "idToken": result.idToken,
          "refreshToken": result.refreshToken,
        };
      }
    } catch (e) {
      print("Microsoft login error: $e");
    }
    return null;
  }
}

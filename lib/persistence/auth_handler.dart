import 'package:nebx/nebx.dart';
import 'package:nebx_minimal_example/models/token_response_model.dart';
import 'package:nebx_minimal_example/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHandler {
  AuthHandler._();

  static const accessTokenStorageKey = "accessToken";
  static const refreshTokenStorageKey = "refreshToken";
  static const expiringMinutes = 1;

  static final SharedPreferencesAsync _storage =
      getIt<SharedPreferencesAsync>();

  static Future<String> loadAccessToken() async {
    return await _storage.getString(accessTokenStorageKey) ?? "";
  }

  static Future<IVerdict<String>> refreshAccessToken(IDioClient client) async {
    const endpoint = "/auth/refresh";
    final refreshToken = await _storage.getString(refreshTokenStorageKey) ?? "";

    final Map<String, dynamic> body = {
      "refreshToken": refreshToken,
      "expiresInMins": expiringMinutes,
    };

    final encodedBody = CodecHelper.encodeJson(body);
    final result = await client.post(url: endpoint, data: encodedBody);
    if (result.isFailure) return Verdict.failed(result.issue);

    late final TokenResponse loginResponse;

    try {
      final decodedResponse = CodecHelper.decodeJson(result.data);
      loginResponse = TokenResponse.fromJson(decodedResponse);
    } catch (e) {
      return Verdict.failed(Issue.parsing());
    }

    // save the refreshed tokens
    await _storage.setString(accessTokenStorageKey, loginResponse.accessToken);
    await _storage.setString(
        refreshTokenStorageKey, loginResponse.refreshToken);

    // pass access token so the interceptor can grab it
    return Verdict.successful(loginResponse.accessToken);
  }
}

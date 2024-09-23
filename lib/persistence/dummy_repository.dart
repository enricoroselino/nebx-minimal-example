import 'package:nebx/nebx.dart';
import 'package:nebx_minimal_example/models/token_response_model.dart';
import 'package:nebx_minimal_example/persistence/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IDummyRepository {
  Future<IVerdict> loginAccount();

  Future<IVerdict> fetchUserData();
}

class DummyRepository implements IDummyRepository {
  late final IDioClient _client;
  late final SharedPreferencesAsync _sharedPref;

  DummyRepository({
    required IDioClient client,
    required SharedPreferencesAsync sharedPref,
  }) {
    _client = client;
    _sharedPref = sharedPref;
  }

  @override
  Future<IVerdict> loginAccount() async {
    const endpoint = "/auth/login";
    final Map<String, dynamic> body = {
      "username": "emilys",
      "password": "emilyspass",
      "expiresInMins": AuthHandler.expiringMinutes,
    };

    final encodedBody = CodecHelper.encodeJson(body);
    final result = await _client.post(url: endpoint, data: encodedBody);

    if (result.isFailure) return result;
    late final TokenResponse loginResponse;

    try {
      final decodedResponse = CodecHelper.decodeJson(result.data);
      loginResponse = TokenResponse.fromJson(decodedResponse);
    } catch (e) {
      return Verdict.failed(Issue.parsing());
    }

    // save the tokens after login successfully
    await _sharedPref.setString(
        AuthHandler.accessTokenStorageKey, loginResponse.accessToken);
    await _sharedPref.setString(
        AuthHandler.refreshTokenStorageKey, loginResponse.refreshToken);
    return Verdict.successful();
  }

  @override
  Future<IVerdict> fetchUserData() async {
    // this endpoint need a authorization
    // but i don't need to bother about providing and refreshing anymore
    const endpoint = "/auth/me";
    final result = await _client.get(url: endpoint);
    if (result.isFailure) return result;
    return Verdict.successful();
  }
}

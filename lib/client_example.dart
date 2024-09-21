import 'package:flutter/material.dart';
import 'package:nebx/nebx.dart';
import 'package:nebx_verdict/nebx_verdict.dart';

class TokenResponse {
  String accessToken;
  String refreshToken;

  TokenResponse._({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> jsonObject) {
    return TokenResponse._(
      accessToken: jsonObject["accessToken"],
      refreshToken: jsonObject["refreshToken"],
    );
  }
}

var accessToken = "";
var refreshToken = "";
const int expiringMins = 1;

String accessTokenLoader() {
  print("access token loaded: $accessToken");
  return accessToken;
}

Future<IVerdict<String>> accessTokenRefresher(IDioClient client) async {
  const endpoint = "/auth/refresh";
  final Map<String, dynamic> body = {
    "refreshToken": refreshToken,
    "expiresInMins": expiringMins,
  };

  print("Refreshing the token using: $refreshToken");
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

  // save the tokens
  accessToken = loginResponse.accessToken;
  refreshToken = loginResponse.refreshToken;
  print("refreshed access token: ${loginResponse.accessToken}");
  print("refreshed refresh token: ${loginResponse.refreshToken}");

  // pass access token so the interceptor can grab it
  return Verdict.successful(loginResponse.accessToken);
}

Future<IVerdict> loginAccount(IDioClient client) async {
  const endpoint = "/auth/login";
  final Map<String, dynamic> body = {
    "username": "emilys",
    "password": "emilyspass",
    "expiresInMins": expiringMins,
  };

  final encodedBody = CodecHelper.encodeJson(body);
  final result = await client.post(url: endpoint, data: encodedBody);

  if (result.isFailure) return result;
  late final TokenResponse loginResponse;

  try {
    final decodedResponse = CodecHelper.decodeJson(result.data);
    loginResponse = TokenResponse.fromJson(decodedResponse);
  } catch (e) {
    return Verdict.failed(Issue.parsing());
  }

  // save the tokens
  accessToken = loginResponse.accessToken;
  refreshToken = loginResponse.refreshToken;
  print("saved access token: ${loginResponse.accessToken}");
  print("saved refresh token: ${loginResponse.refreshToken}");
  return Verdict.successful();
}

Future<IVerdict> fetchUserData(IDioClient client) async {
  const endpoint = "/auth/me";
  final result = await client.get(url: endpoint);
  if (result.isFailure) return result;

  print(result.data);
  return Verdict.successful();
}

const baseUrl = "https://dummyjson.com/";
final normalClient = DioBuilderFactory.clientBasic(baseUrl: baseUrl)
    .addRequestTimeOut()
    .buildErrorHandling();

final jwtClient = DioBuilderFactory.clientJsonWebToken(
  baseUrl: baseUrl,
  onTokenLoad: accessTokenLoader,
  onTokenRefresh: (fetcher) => accessTokenRefresher(fetcher),
).addRequestTimeOut().buildErrorHandling();

class ClientExample extends StatefulWidget {
  const ClientExample({super.key});

  @override
  State<ClientExample> createState() => _ClientExampleState();
}

class _ClientExampleState extends State<ClientExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              /// try swapping the client between normalClient and jwtClient
              await loginAccount(jwtClient);
            },
            child: const Text("Login Account"),
          ),
          ElevatedButton(
            onPressed: () async {
              /// try swapping the client between normalClient and jwtClient
              /// also try wait the token expired to see auto refresh token functionality when facing unauthorized status code
              await fetchUserData(jwtClient);
            },
            child: const Text("Fetch user data"),
          )
        ],
      )),
    );
  }
}

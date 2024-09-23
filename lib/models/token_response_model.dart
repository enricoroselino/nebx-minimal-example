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
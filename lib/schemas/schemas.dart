class Token {
  final String accessToken;
  final String tokenType;

  Token({required this.accessToken, required this.tokenType});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'], // соответствует полю в Python 
      tokenType: json['token_type'],     // соответствует "bearer" 
    );
  }
}
class User {
  User({required this.email, required this.id, this.authToken});

  final String email;
  final String id;
  final String? authToken;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      authToken: json['authentication_token'],
    );
  }
}

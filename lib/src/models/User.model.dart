class UserChat {
  final String userName;
  String message;

  UserChat({this.userName, this.message});

  factory UserChat.fromJson(Map<String, dynamic> json) {
    return UserChat(
      userName: json['userName'],
      message: json['message'],
    );
  }
}

class UserAgora {
  final int id;
  final String userName;

  UserAgora({this.id, this.userName});

  factory UserAgora.fromJson(Map<String, dynamic> json) {
    return UserAgora(
      id: json['id'],
      userName: json['userName'],
    );
  }
}

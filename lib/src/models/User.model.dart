class UserChat {
  final String userName;
  final String message;

  UserChat({this.userName, this.message});

  factory UserChat.fromJson(Map<String, dynamic> json) {
    return UserChat(
      userName: json['userName'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'message': message,
      };
}

class UserAgora {
  final int id;
  final String userName;

  UserAgora({this.id, this.userName});

  factory UserAgora.fromJson(Map<String, dynamic> json) {
    return UserAgora(
      id: json['id'] as int,
      userName: json['userName'] as String,
    );
  }
}

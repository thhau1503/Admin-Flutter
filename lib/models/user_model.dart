class User {
  final String id;
  final String username;
  final String email;
  final String userRole;
  final String phone;
  final String address;
  final bool isOnline;
  final String avatarUrl;

  User.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        username = json['username'],
        email = json['email'],
        userRole = json['user_role'],
        phone = json['phone'],
        address = json['address'],
        isOnline = json['isOnline'],
        avatarUrl = json['avatar']['url'];

  User.fromJsonCustom(Map<String, dynamic> json)
      : id = json['_id'],
        username = json['username'],
        email = json['email'],
        phone = json['phone'],
        avatarUrl = json['avatar']['url'],
        userRole = "",
        address = '', // Initialize address//+
        isOnline = false; // Initialize isOnline//+
}

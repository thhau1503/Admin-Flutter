import 'package:admin/models/user_model.dart';

class Notification {
  final String id;
  final User id_user;
  final String message;
  final String createdAt;

  Notification({
    required this.id,
    required this.id_user,
    required this.message,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] as String,
      id_user: User.fromJsonCustom(json['id_user']),
      message: json['message'] as String,
      createdAt: json['create_at'] as String,
    );
  }
}

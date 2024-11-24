import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/models/notification_model.dart' as admin_model;

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<admin_model.Notification> notifications = [];
  bool isLoading = true;
  String? error;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MjhkNmU0MDcwODhlZWZhZmI0MDRhNiIsInVzZXJfcm9sZSI6IkFkbWluIiwiaWF0IjoxNzMyMzM3OTQ0LCJleHAiOjE3MzI5NDI3NDR9.oRBtJEMRA-TzdQ7MmjhX-bfLMwWwiUDaWoQPQokFC5k';
  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://be-android-project.onrender.com/api/notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm Bearer token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          notifications = data
              .map((json) => admin_model.Notification.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Thông báo'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final avatarUrl =
                          notification.id_user.avatarUrl ?? ''; // Xử lý null
                      final username =
                          notification.id_user.username ?? 'Người dùng ẩn danh';
                      final message =
                          notification.message ?? 'Không có thông báo';
                      final createdAt =
                          notification.createdAt ?? 'Không xác định';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null, // Đặt null nếu không có URL
                            child: avatarUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày: $createdAt',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }
}

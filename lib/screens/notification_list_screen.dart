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
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? error;
  String selectedUserId = "";
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MjhkNmU0MDcwODhlZWZhZmI0MDRhNiIsInVzZXJfcm9sZSI6IkFkbWluIiwiaWF0IjoxNzMyMzM3OTQ0LCJleHAiOjE3MzI5NDI3NDR9.oRBtJEMRA-TzdQ7MmjhX-bfLMwWwiUDaWoQPQokFC5k';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    fetchUsers();
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
          'Authorization': 'Bearer $token',
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

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://be-android-project.onrender.com/api/auth/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data
              .map((user) => {
                    "id": user["_id"],
                    "username": user["username"],
                  })
              .toList();
        });
      } else {
        setState(() {
          error = 'Error fetching users: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching users: ${e.toString()}';
      });
    }
  }

  Future<void> updateNotification(
      String id, String message, String userId, String createdAt) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://be-android-project.onrender.com/api/notification/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "message": message,
          "id_user": userId,
          "createdAt": createdAt,
        }),
      );

      if (response.statusCode == 200) {
        fetchNotifications(); // Refresh notifications
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update notification: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://be-android-project.onrender.com/api/notification/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchNotifications(); // Refresh notifications
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to delete notification: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> addNotification(
      String message, String userId, String createdAt) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://be-android-project.onrender.com/api/notification/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "message": message,
          "id_user": userId,
          "createdAt": createdAt,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchNotifications(); // Refresh notifications list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add notification: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void showAddNotificationDialog() {
    String message = "";
    String userId = "";
    final now = DateTime.now().toIso8601String();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm Thông báo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  message = value;
                },
                decoration: const InputDecoration(
                  labelText: "Thông báo",
                ),
              ),
              DropdownButtonFormField<String>(
                value: userId.isEmpty ? null : userId,
                items: users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user["id"],
                    child: Text(user["username"]),
                  );
                }).toList(),
                onChanged: (value) {
                  userId = value ?? "";
                },
                decoration: const InputDecoration(labelText: "Người dùng"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                if (message.isNotEmpty && userId.isNotEmpty) {
                  addNotification(message, userId, now);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Điền đầy đủ thông tin')),
                  );
                }
              },
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );
  }

  void showEditNotificationDialog(admin_model.Notification notification) {
    String message = notification.message ?? '';
    String userId = notification.id_user.id ?? '';
    final createdAt =
        notification.createdAt ?? DateTime.now().toIso8601String();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa Thông báo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  message = value;
                },
                decoration: InputDecoration(
                  labelText: "Thông báo",
                  hintText: notification.message,
                ),
              ),
              DropdownButtonFormField<String>(
                value: userId.isEmpty ? null : userId,
                items: users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user["id"],
                    child: Text(user["username"]),
                  );
                }).toList(),
                onChanged: (value) {
                  userId = value ?? '';
                },
                decoration: const InputDecoration(labelText: "Người dùng"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                if (message.isNotEmpty && userId.isNotEmpty) {
                  updateNotification(
                      notification.id!, message, userId, createdAt);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Điền đầy đủ thông tin')),
                  );
                }
              },
              child: const Text("Cập nhật"),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận"),
          content: const Text("Bạn có chắc chắn muốn xóa thông báo này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteNotification(id);
                Navigator.of(context).pop();
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thông báo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: showAddNotificationDialog,
              child: const Text("Thêm Thông báo"),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      notification.id_user.avatarUrl != null &&
                                              notification
                                                  .id_user.avatarUrl!.isNotEmpty
                                          ? NetworkImage(
                                              notification.id_user.avatarUrl!)
                                          : null,
                                  child:
                                      notification.id_user.avatarUrl == null ||
                                              notification
                                                  .id_user.avatarUrl!.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Text(notification.message ??
                                    'Không có nội dung'),
                                subtitle: Text(
                                  'Người nhận: ${notification.id_user.username} - Ngày tạo: ${notification.createdAt}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        showEditNotificationDialog(
                                            notification);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        showDeleteConfirmationDialog(
                                            notification.id!);
                                      },
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

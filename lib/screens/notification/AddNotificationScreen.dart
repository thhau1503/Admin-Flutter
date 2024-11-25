import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({Key? key}) : super(key: key);

  @override
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedUserId;
  String? notificationMessage;
  List<dynamic> users = [];
  bool isLoading = true;
  bool isSubmitting = false;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MjhkNmU0MDcwODhlZWZhZmI0MDRhNiIsInVzZXJfcm9sZSI6IkFkbWluIiwiaWF0IjoxNzMyMzM3OTQ0LCJleHAiOjE3MzI5NDI3NDR9.oRBtJEMRA-TzdQ7MmjhX-bfLMwWwiUDaWoQPQokFC5k';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
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
          users = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: ${e.toString()}')),
      );
    }
  }

  Future<void> addNotification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      isSubmitting = true;
    });

    final DateTime createdAt = (DateTime.now());
    final body = {
      'message': notificationMessage,
      'id_user': selectedUserId,
      'createdAt': createdAt,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://be-android-project.onrender.com/api/notification/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification added successfully')),
        );
        Navigator.pop(context, true); // Quay lại màn hình trước đó
      } else {
        throw Exception('Failed to add notification');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Thông báo'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      decoration:
                          const InputDecoration(labelText: 'Chọn người dùng'),
                      items: users.map<DropdownMenuItem<String>>((user) {
                        return DropdownMenuItem<String>(
                          value: user['_id'],
                          child: Text(user['username']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUserId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn người dùng' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Thông báo'),
                      maxLines: 3,
                      onSaved: (value) {
                        notificationMessage = value;
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập thông báo'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: addNotification,
                            child: const Text('Thêm thông báo'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

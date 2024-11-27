import 'package:admin/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<String?> getAuthToken() async {
  return await storage.read(key: "authToken");
}

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({Key? key}) : super(key: key);

  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<Report> Reports = [];
  bool isLoading = true;
  String? error;

  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MjhkNmU0MDcwODhlZWZhZmI0MDRhNiIsInVzZXJfcm9sZSI6IkFkbWluIiwiaWF0IjoxNzMyMzM3OTQ0LCJleHAiOjE3MzI5NDI3NDR9.oRBtJEMRA-TzdQ7MmjhX-bfLMwWwiUDaWoQPQokFC5k';

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final token = await getAuthToken();

      final response = await http.get(
        Uri.parse('https://be-android-project.onrender.com/api/report/getAll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          Reports = data.map((json) => Report.fromJson(json)).toList();
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

  Future<void> updateReportStatus(String id, String status) async {
    try {
      final token = await getAuthToken();

      final response = await http.patch(
        Uri.parse(
            'https://be-android-project.onrender.com/api/report/$id/status/$status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        fetchReports(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      final token = await getAuthToken();

      final response = await http.delete(
        Uri.parse(
            'https://be-android-project.onrender.com/api/report/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        fetchReports(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete report: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirm'),
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
        title: const Text('Quản lý Report'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: Reports.length,
                  itemBuilder: (context, index) {
                    final report = Reports[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    report.id_user.avatarUrl,
                                  ),
                                  radius: 25,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.id_user.username,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(report.id_user.email),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              'Bài viết: ${report.id_post.title}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Địa chỉ: ${report.id_post.location.address}, '
                                '${report.id_post.location.city}'),
                            const Divider(height: 20),
                            Text('Lý do báo cáo: ${report.report_reason}'),
                            Text('Mô tả: ${report.description}'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Trạng thái: ${report.status}'),
                                Text(
                                  'Ngày tạo: ${report.createdAt}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () => showConfirmationDialog(
                                    title: 'Xác nhận',
                                    content:
                                        'Bạn có chắc muốn chuyển trạng thái sang Processing?',
                                    onConfirm: () => updateReportStatus(
                                        report.id, 'processing'),
                                  ),
                                  icon: const Icon(Icons.timelapse,
                                      color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => showConfirmationDialog(
                                    title: 'Xác nhận',
                                    content:
                                        'Bạn có chắc muốn chuyển trạng thái sang Resolved?',
                                    onConfirm: () => updateReportStatus(
                                        report.id, 'resolved'),
                                  ),
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                ),
                                IconButton(
                                  onPressed: () => showConfirmationDialog(
                                    title: 'Xác nhận',
                                    content:
                                        'Bạn có chắc muốn xóa báo cáo này?',
                                    onConfirm: () => deleteReport(report.id),
                                  ),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

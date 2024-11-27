import 'package:admin/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

final storage = FlutterSecureStorage();
Future<String?> getAuthToken() async {
  return await storage.read(key: "authToken");
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  List<User> visibleUsers = [];
  int itemsPerPage = 5;
  int currentPage = 0;
  bool isLoading = true;
  String? error;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MjhkNmU0MDcwODhlZWZhZmI0MDRhNiIsInVzZXJfcm9sZSI6IkFkbWluIiwiaWF0IjoxNzMyMzM3OTQ0LCJleHAiOjE3MzI5NDI3NDR9.oRBtJEMRA-TzdQ7MmjhX-bfLMwWwiUDaWoQPQokFC5k';
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _roleController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedImagePath;
  String _selectedRole = 'User';
  final List<String> _roles = ['Admin', 'User', 'Renter'];
  void _showAddUserDialog() {
    _usernameController.clear();
    _passwordController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _selectedImagePath = null;
    _selectedRole = 'User';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng mới'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                    if (image != null) {
                      final mimeType = lookupMimeType(image.path);
                      if (mimeType?.startsWith('image/') ?? false) {
                        setState(() {
                          _selectedImagePath = image.path;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Vui lòng chọn file ảnh có định dạng hợp lệ (JPG, JPEG, PNG).'),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _selectedImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.add_photo_alternate, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Không được để trống' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: _roles.map((String role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn role' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await getAuthToken();
              if (_formKey.currentState?.validate() ?? false) {
                var request = http.MultipartRequest(
                  'POST',
                  Uri.parse(
                      'https://be-android-project.onrender.com/api/auth/admin/create-user'),
                );

                request.headers.addAll({
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'multipart/form-data'
                });
                request.fields['username'] = _usernameController.text;
                request.fields['password'] = _passwordController.text;
                request.fields['email'] = _emailController.text;
                request.fields['phone'] = _phoneController.text;
                request.fields['address'] = _addressController.text;
                request.fields['user_role'] = _selectedRole;
                if (_selectedImagePath != null) {
                  final mimeType = lookupMimeType(_selectedImagePath!);
                  if (mimeType != null) {
                    final mimeParts = mimeType.split('/');
                    request.files.add(await http.MultipartFile.fromPath(
                      'avatar',
                      _selectedImagePath!,
                      contentType: MediaType(mimeParts[0], mimeParts[1]),
                    ));
                  }
                }

                try {
                  final response = await request.send();
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tạo người dùng thành công')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Có lỗi xảy ra')),
                    );
                    print('Error response: ${response.statusCode}');
                  }
                } catch (e) {
                  print('Exception occurred: $e');
                  print('Stack trace: ${StackTrace.current}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Có lỗi xảy ra')),
                  );
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(User user) {
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _selectedImagePath = null;
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa thông tin người dùng'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      final mimeType = lookupMimeType(image.path);
                      if (mimeType?.startsWith('image/') ?? false) {
                        setState(() {
                          _selectedImagePath = image.path;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng chọn một tệp ảnh hợp lệ.'),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _selectedImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              user.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    helperText: 'Leave blank to keep current password',
                  ),
                  obscureText: true,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                try {
                  var request = http.MultipartRequest(
                    'PUT',
                    Uri.parse(
                        'https://be-android-project.onrender.com/api/auth/users/${user.id}'),
                  );

                  request.headers
                      .addAll({'Content-Type': 'multipart/form-data'});

                  request.fields['username'] = _usernameController.text;
                  request.fields['email'] = _emailController.text;
                  request.fields['phone'] = _phoneController.text;
                  request.fields['address'] = _addressController.text;

                  if (_passwordController.text.isNotEmpty) {
                    request.fields['password'] = _passwordController.text;
                  }

                  if (_selectedImagePath != null) {
                    final mimeType = lookupMimeType(_selectedImagePath!);
                    if (mimeType != null) {
                      final mimeParts = mimeType.split('/');
                      request.files.add(await http.MultipartFile.fromPath(
                        'avatar',
                        _selectedImagePath!,
                        contentType: MediaType(mimeParts[0], mimeParts[1]),
                      ));
                    }
                  }

                  final response = await request.send();
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Có lỗi xảy ra')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Có lỗi xảy ra')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa người dùng ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await getAuthToken();
              try {
                final response = await http.delete(
                  Uri.parse(
                      'https://be-android-project.onrender.com/api/auth/user/${user.id}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  fetchUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa người dùng thành công')),
                  );
                } else if (response.statusCode == 404) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy người dùng')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Có lỗi xảy ra khi xóa người dùng')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await getAuthToken();
      print(token);
      final response = await http.get(
        Uri.parse('https://be-android-project.onrender.com/api/auth/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm Bearer token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList();
          isLoading = false;
          currentPage = 0;
          updateVisibleUsers();
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

  void updateVisibleUsers() {
    int start = currentPage * itemsPerPage;
    int end = start + itemsPerPage;
    setState(() {
      visibleUsers = users.sublist(
        start,
        end > users.length ? users.length : end,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserDialog,
            tooltip: 'Thêm người dùng mới',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUsers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(error!),
                      ElevatedButton(
                        onPressed: fetchUsers,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: visibleUsers.length,
                        itemBuilder: (context, index) {
                          final user = visibleUsers[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user.avatarUrl),
                              ),
                              title: Text(user.username),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  Text(user.userRole),
                                  Text(user.phone),
                                  Text(user.address),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditUserDialog(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _showDeleteConfirmDialog(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: currentPage > 0
                              ? () {
                                  setState(() {
                                    currentPage--;
                                    updateVisibleUsers();
                                  });
                                }
                              : null,
                          child: const Text('Trước'),
                        ),
                        Text('Trang ${currentPage + 1}'),
                        ElevatedButton(
                          onPressed:
                              (currentPage + 1) * itemsPerPage < users.length
                                  ? () {
                                      setState(() {
                                        currentPage++;
                                        updateVisibleUsers();
                                      });
                                    }
                                  : null,
                          child: const Text('Tiếp'),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}

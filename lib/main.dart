import 'package:admin/screens/notification_list_screen.dart';
<<<<<<< HEAD
=======
import 'package:admin/screens/post_list_screen.dart';
>>>>>>> main
import 'package:admin/screens/report_list_screen.dart';
import 'package:admin/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final FlutterSecureStorage storage = FlutterSecureStorage();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
        '/user': (context) => UserListScreen(),
        '/post': (context) => PostListScreen(),
        '/notification': (context) => NotificationListScreen(),
        '/report': (context) => ReportListScreen(),
      },
    );
  }
}

/// SplashScreen kiểm tra token khi khởi động
class SplashScreen extends StatelessWidget {
  Future<void> checkLoginStatus(BuildContext context) async {
    final token = await storage.read(key: "authToken");
    if (token != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLoginStatus(context);
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    const String apiUrl =
        "https://be-android-project.onrender.com/api/auth/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        String? token;
        if (responseData['token'] != null) {
          token = responseData['token'];
        } else if (responseData['data']?['token'] != null) {
          token = responseData['data']['token'];
        } else if (responseData['accessToken'] != null) {
          token = responseData['accessToken'];
        }


        if (token != null) {
          await storage.write(key: "authToken", value: token);
          
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Đăng nhập thất bại';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kết nối tới server!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    await storage.delete(key: "authToken");
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Quản lý User'),
              onTap: () => Navigator.of(context).pushNamed('/user'),
            ),
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text('Quản lý Post'),
              onTap: () => Navigator.of(context).pushNamed('/post'),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Quản lý Thông báo'),
<<<<<<< HEAD
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationListScreen()),
                );
              },
=======
              onTap: () => Navigator.of(context).pushNamed('/notification'),
>>>>>>> main
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Quản lý Report'),
<<<<<<< HEAD
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportListScreen()),
                );
              },
=======
              onTap: () => Navigator.of(context).pushNamed('/report'),
>>>>>>> main
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Chào mừng bạn đến với Admin Dashboard!'),
      ),
    );
  }
}

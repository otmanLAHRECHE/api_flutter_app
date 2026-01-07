import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'auth_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Flutter_api_app",
      initialRoute: '/login',
      routes: {
        '/login': (context) =>  LoginScreen(),
        '/register': (context) =>  RegisterScreen(),
        '/posts': (context) =>  PostsScreen(),
      },
    );
  }
}

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async{
              Navigator.pushReplacementNamed(context, '/login');
              await AuthService.logout();
            },
          ),
        ],
      ),
      body: Center(child: Text('Posts list will appear here')),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'https://cgo0k8kcw8o08gokckkwcsgo.feeef.dev';
final _secureStorage = FlutterSecureStorage();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String password = '';
  bool loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final payload = {
      'name': name,
      'phone': phone,
      'password': password,
    };

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        // backend may return token or user object; adapt as needed
        final token = body['token'] ?? body['access_token'];
        if (token != null) {
          await _secureStorage.write(key: 'jwt', value: token);
          Navigator.pushReplacementNamed(context, '/posts');
          return;
        }
        // if no token, navigate to login and show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful. Please login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final err = res.body.isNotEmpty ? jsonDecode(res.body)['message'] ?? res.body : 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  String? _validateNotEmpty(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full name'),
                onChanged: (v) => name = v,
                validator: _validateNotEmpty,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                onChanged: (v) => phone = v,
                validator: _validateNotEmpty,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) {
                  if (v == null || v.length < 6) return 'Password must be at least 6 chars';
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : _register,
                child: loading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Register'),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

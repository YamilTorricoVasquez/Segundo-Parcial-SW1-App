import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:sw1segundoparcial/login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //  title: 'Material App',
      home: Login(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await _authService.login(email, password);
    if (response.containsKey('error')) {
      setState(() {
        _errorMessage = response['error'];
      });
    } else {
      setState(() {
        _errorMessage = '';
      });
      // Si es exitoso, puedes navegar o almacenar el usuario
      print('User ID: ${response['uid']}');
      print('User Name: ${response['userName']}');
      print('Roles: ${response['roles']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class AuthService {
  final String baseUrl =
      'http://tu_dominio.com'; // Cambia a la URL de tu servidor

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('http://192.168.0.10:8069/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // Manejar la respuesta de éxito
          return {
            'uid': responseData['uid'],
            'userName': responseData['user_name'],
            'roles': responseData['roles'],
          };
        } else {
          // Manejar errores específicos
          return {'error': responseData['error']};
        }
      } else {
        return {'error': 'Error de conexión al servidor.'};
      }
    } catch (e) {
      return {'error': 'Error: $e'};
    }
  }
}

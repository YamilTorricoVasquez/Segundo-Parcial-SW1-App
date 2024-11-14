import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/profile/scaffold_estudiante.dart';
import 'package:sw1segundoparcial/profile/scaffold_padre.dart';
import 'package:sw1segundoparcial/profile/scaffold_profesor.dart';
import 'package:sw1segundoparcial/widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _valido = "";
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
      // Filtrar para obtener solo el rol 'Estudiante'
      var estudianteRole = response['roles'].firstWhere(
        (role) => role == 'Estudiante',
        orElse: () => null, // Retorna null si no se encuentra
      );
      var padreRole = response['roles'].firstWhere(
        (role) => role == 'Padre',
        orElse: () => null, // Retorna null si no se encuentra
      );
      var profesorRole = response['roles'].firstWhere(
        (role) => role == 'Profesor',
        orElse: () => null, // Retorna null si no se encuentra
      );
      Globals.idUser = response['uid'];
      //  obtenerTokens(response['uid']);
      // Globals.rol = estudianteRole;
      if (estudianteRole != null) {
        setState(() {
          _text = const CircularProgressIndicator();
          Globals.rol = estudianteRole;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScaffoldEstudiante(),
            ));
        print('Rol encontrado: $estudianteRole');
        setState(() {
              _text = Text(
                "Iniciar sesion",
                style: styleSesion,
              );
            });
      } else {
        if (padreRole == 'Padre') {
          setState(() {
            Globals.rol = padreRole;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScaffoldPadre(),
              ));
          print('Rol encontrado: $padreRole');
          setState(() {
              _text = Text(
                "Iniciar sesion",
                style: styleSesion,
              );
            });
        } else {
          if (profesorRole == 'Profesor') {
            setState(() {
              _text = const CircularProgressIndicator();
              Globals.rol = profesorRole;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScaffoldProfesor(),
                ));
            print('Rol encontrado: $profesorRole');
            setState(() {
              _text = Text(
                "Iniciar sesion",
                style: styleSesion,
              );
            });
          }
          //  print('Rol no encontrado');
        }
        print('Rol no encontrado');
      }
      // Si es exitoso, puedes navegar o almacenar el usuario
      print('User ID: ${Globals.idUser}');
      print('User Name: ${response['userName']}');
      print('User Name: ${Globals.email}');
      print('User Name: ${Globals.rol}');

      print('Roles: ${response['roles']}');
    }
  }

  bool _bool = true;
  Icon _icon = const Icon(Icons.visibility_off_outlined);
  Widget _text = Text(
    "Iniciar sesion",
    style: styleSesion,
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<List<String>?> obtenerTokens(String userId) async {
    final url = 'http://${Globals.ip}:8069/api/device_tokens';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<String> tokens = List<String>.from(jsonResponse['tokens']);
        return tokens;
      } else {
        print("Error: ${jsonResponse['message']}");
        return null;
      }
    } else {
      print("Error en la respuesta: ${response.statusCode}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              height: 550,
              // color: Colors.blue[900],
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Container(
            //  decoration: fondoApp,
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    //Image.network('https://st2.depositphotos.com/4207741/9966/v/450/depositphotos_99667454-stock-illustration-baby-boy-and-girl.jpg',height: 180,),
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [shadowstyleBox],
                        color: Colors.white,
                      ),
                      child: Center(child: Text("LOGO")),
                      /*child: Image.asset(
                      'images/logoBaby.png',
                      fit: BoxFit.contain,
                    ),*/
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [shadowstyleBox],
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: "Correo electronico",
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                controller: _emailController,
                                validator: (value) {
                                  // Verificar si el campo está vacío
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa un correo electrónico';
                                  }
                                  // Verificar si el formato del email es correcto usando una expresión regular
                                  final RegExp emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Por favor, ingresa un correo válido';
                                  }
                                  return null; // Si el valor es válido
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          //  border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [shadowstyleBox],
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: "Contraseña",
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _bool = !_bool;
                                            if (_bool) {
                                              _icon = const Icon(Icons
                                                  .visibility_off_outlined);
                                            } else {
                                              _icon = const Icon(
                                                  Icons.visibility_outlined);
                                            }
                                          });
                                        },
                                        icon: _icon)),
                                controller: _passwordController,
                                obscureText: _bool,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su contraseña.';
                                  }
                                  return null;
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 318,
                        height: 50,
                        decoration: BoxDecoration(
                          // border: Border.all(color: Colors.pink.shade200),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [shadowstyleBox],
                        ),
                        child: Center(
                          child: _text,
                        ),
                      ),
                      onTap: () async {
                        //  Globals.email = _emailController.text;
                        if (_formKey.currentState!.validate()) {
                          _login();

                          setState(() {
                            _text = Text("Iniciar sesion", style: styleSesion);
                          });
                        }
                      },
                    ),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthService {
  final String baseUrl =
      'http://${Globals.ip}:8069/api/login'; // Cambia a la URL de tu servidor

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('http://${Globals.ip}:8069/api/login');
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
          Globals.email = email;
          Globals.nombreUsuario = responseData['user_name'];
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

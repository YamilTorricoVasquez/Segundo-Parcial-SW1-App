import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/profile/scaffold_curso.dart';
import 'package:sw1segundoparcial/widget.dart';

class EstudiantesPage extends StatefulWidget {
  final String nombreCurso;
  final String nombreNivel;
  final String nombreParalelo;

  EstudiantesPage(
      {required this.nombreCurso,
      required this.nombreNivel,
      required this.nombreParalelo});

  @override
  State<EstudiantesPage> createState() => _EstudiantesPageState();
}

class _EstudiantesPageState extends State<EstudiantesPage> {
  Future<List<Estudiante>> fetchEstudiantes(
      String nombreCurso, String nombreNivel, String nombreParalelo) async {
    final response = await http.get(Uri.parse(
        'http://${Globals.ip}:8069/api/profesor/estudiantes/$nombreCurso/$nombreNivel/$nombreParalelo'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((estudiante) => Estudiante.fromJson(estudiante))
          .toList();
    } else {
      throw Exception('Error al cargar estudiantes');
    }
  }

  String _mensaje = "";
  Future<void> registrarAsistencia(
      String ciEstudiante, String estadoAsistencia, String ciProfesor) async {
    final url =
        'http://${Globals.ip}:8069/api/estudiante/asistencia'; // Reemplaza <TU_SERVIDOR> con la dirección IP o URL de tu servidor.

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ci': ciEstudiante,
        'estado': estadoAsistencia, // 'Presente' o 'Ausente'
        'ci_profesor': ciProfesor,
      }),
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve un 200 OK, parsea la respuesta
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] != null) {
        print(responseBody['success']);
      } else if (responseBody['error'] != null) {
        setState(() {
          mostrarMensajeTemporal(context,
              "Ya registro la asistencia a este estudiante: ${_mensaje}");
        });

        print('Error: ${responseBody['error']}');
      }
    } else {
      // Si la respuesta no fue OK, lanza un error
      throw Exception('Error al registrar asistencia: ${response.body}');
    }
  }

  void mostrarMensajeTemporal(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration:
          Duration(seconds: 2), // Tiempo que el mensaje se muestra en pantalla
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Estudiante>>(
          future: fetchEstudiantes(
              widget.nombreCurso, widget.nombreNivel, widget.nombreParalelo),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay estudiantes disponibles.'));
            } else {
              final estudiantes = snapshot.data!;
              return Column(
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [shadowstyleBox],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.arrow_back,
                                size: 29,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Aquí colocas los widgets que quieres mostrar encima del ListView
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Lista de Estudiantes',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            'Registra la asistencia de cada estudiante',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),

                  // Usar un Expanded para que el ListView ocupe el espacio restante
                  Expanded(
                    child: ListView.builder(
                      itemCount: estudiantes.length,
                      itemBuilder: (context, index) {
                        final estudiante = estudiantes[index];
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    estudiante.nombre,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _mensaje = "";
                                    });
                                    // Mostrar un alert dialog antes de registrar la asistencia como 'presente'
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmar Asistencia'),
                                          content: Text(
                                              '¿Estás seguro de marcar la asistencia como presente ${estudiante.nombre}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                // Cierra el diálogo sin hacer nada
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _mensaje = estudiante.nombre;
                                                });
                                                // Llama a registrarAsistencia y cierra el diálogo
                                                registrarAsistencia(
                                                    estudiante.ci,
                                                    'presente',
                                                    Globals.ci);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Confirmar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _mensaje = "";
                                    });
                                    // Mostrar un alert dialog antes de registrar la asistencia como 'ausente'
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmar Asistencia'),
                                          content: Text(
                                              '¿Estás seguro de marcar la asistencia como ausente?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                // Cierra el diálogo sin hacer nada
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Llama a registrarAsistencia y cierra el diálogo
                                                registrarAsistencia(
                                                    estudiante.ci,
                                                    'ausente',
                                                    Globals.ci);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Confirmar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class Estudiante {
  final String nombre;
  final String ci;

  Estudiante({required this.nombre, required this.ci});

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      nombre: json['nombre'],
      ci: json['ci'],
    );
  }
}

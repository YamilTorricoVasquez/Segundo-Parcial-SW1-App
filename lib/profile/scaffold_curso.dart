/*import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/profile/scaffold_lista_estudiante.dart';

class CursosScreen extends StatefulWidget {
  final String email;

  CursosScreen({required this.email});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  Future<List<Curso1>> fetchCursos(String email) async {
    final response = await http
        .get(Uri.parse('http://192.168.0.10:8069/api/profesor/cursos/$email'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Asegúrate de que 'cursos_asignados' existe en la respuesta
      if (data['cursos_asignados'] != null) {
        return List<Curso1>.from(
            data['cursos_asignados'].map((curso) => Curso1.fromJson(curso)));
      } else {
        throw Exception('No se encontraron cursos asignados');
      }
    } else {
      throw Exception('Error al cargar los cursos: ${response.reasonPhrase}');
    }
  }

  bool _otroWidget = true;

  Widget _widget = Text("");

  @override
  Widget build(BuildContext context) {
    return _otroWidget
        ? FutureBuilder<List<Curso1>>(
            future: fetchCursos(widget.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay cursos asignados.'));
              } else {
                final cursos = snapshot.data!;
                return ListView.builder(
                  itemCount: cursos.length,
                  itemBuilder: (context, index) {
                    final curso = cursos[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          Globals.nivel = curso.nivel;
                          Globals.curso = curso.curso;
                          Globals.paralelo = curso.paralelo;
                          _otroWidget = false;
                        });
                      },
                      child: ListTile(
                        title: Text(curso.curso),
                        subtitle: Text(
                            'Nivel: ${curso.nivel} - Paralelo: ${curso.paralelo}'),
                      ),
                    );
                  },
                );
              }
            },
          )
        : EstudiantesPage(
            nombreCurso: Globals.curso,
            nombreNivel: Globals.nivel,
            nombreParalelo: Globals.paralelo);
  }
}

class Curso1 {
  final String curso;
  final String nivel;
  final String paralelo;

  Curso1({required this.curso, required this.nivel, required this.paralelo});

  factory Curso1.fromJson(Map<String, dynamic> json) {
    return Curso1(
      curso: json['curso'],
      nivel: json['nivel'],
      paralelo: json['paralelo'],
    );
  }
}
*/
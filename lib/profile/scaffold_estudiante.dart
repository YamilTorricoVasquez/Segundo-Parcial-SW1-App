import 'package:flutter/material.dart';
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/login.dart';
import 'package:sw1segundoparcial/widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScaffoldEstudiante extends StatefulWidget {
  const ScaffoldEstudiante({super.key});

  @override
  State<ScaffoldEstudiante> createState() => _ScaffoldEstudianteState();
}

class _ScaffoldEstudianteState extends State<ScaffoldEstudiante> {
  Future<Estudiante?> obtenerEstudianteInfo(String email) async {
    final url =
        'http://${Globals.ip}:8069/api/estudiante/info/$email'; // Cambia 'tu_dominio' por tu URL real
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      Globals.curso = data['curso'];
      Globals.nivel = data['nivel'];
      Globals.paralelo = data['paralelo'];

      /*print("Curso: $curso");
      print("Nivel: $nivel");
      print("Paralelo: $paralelo");*/
      return Estudiante.fromJson(data);
    } else {
      print('Error: ${response.statusCode}');
      return null; // Manejar el caso de error
    }
  }

  Estudiante? estudiante;
  late Future<List<Horario>> futureHorarios = Future.value([]);
  Future<List<Horario>> fetchHorarios(
      String nombreCurso, String nombreNivel, String nombreParalelo) async {
    final url = Uri.parse(
        'http://${Globals.ip}:8069/api/estudiante/horario/$nombreCurso/$nombreNivel/$nombreParalelo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodificar la respuesta como una lista de mapas
      List<dynamic> data = jsonDecode(response.body);

      // Convertir cada elemento de la lista en un objeto Horario
      return data.map((json) => Horario.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar horarios');
    }
  }

  Color _colors = Colors.white;
  Color _colors2 = Colors.white;
  @override
  void initState() {
    super.initState();

    // Obtener la información del estudiante y luego el horario
    obtenerEstudianteInfo(Globals.email).then((info) {
      setState(() {
        estudiante = info;
        if (estudiante != null) {}
      });
    });
    fetchComunicados(
        curso: Globals.curso, nivel: Globals.nivel, paralelo: Globals.paralelo);
  }

  int noLeidos = 0;
  final ComunicadoService _comunicadoService = ComunicadoService();
  List<Map<String, dynamic>> comunicados = [];
  bool isLoading = true;

  // Función para obtener comunicados y actualizar el estado
  Future<void> fetchComunicados({
    required String curso,
    required String nivel,
    required String paralelo,
  }) async {
    try {
      final data = await _comunicadoService.fetchComunicados(
        rol: Globals.rol,
        usuarioId: Globals.idUser.toString(),
        curso: curso, // Pasar el curso
        nivel: nivel, // Pasar el nivel
        paralelo: paralelo, // Pasar el paralelo
      );

      setState(() {
        isLoading = false;

        // Filtrar los comunicados no leídos y contarlos
        comunicados = data;
      });

      print("Entro por aqui");
    } catch (e) {
      print("Error al obtener comunicados: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _pantalla = Text("");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Stack(
            children: [
              Positioned(
                child: Container(
                  height: 230,
                  width: double.infinity,
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
              // Welcome Box
              Positioned(
                top: 80,
                left: (MediaQuery.of(context).size.width / 2) - 90,
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [shadowstyleBox],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          "Bienvenido",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900]),
                        ),
                        Text(
                          Globals.nombreUsuario,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 175,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _colors = Colors.grey;
                      _colors2 = Colors.white;
                      // Configurar el Future para los horarios solo si el estudiante existe
                      futureHorarios = fetchHorarios(estudiante!.curso,
                          estudiante!.nivel, estudiante!.paralelo);
                      _pantalla = Horarios(futureHorarios: futureHorarios);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _colors,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [shadowstyleBox],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.black),
                        const SizedBox(width: 10),
                        Text(
                          "Horario",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 290,
                top: 40,
                child: IconButton(
                  color: _colors2,
                  icon: Icon(
                    Icons.notifications,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _colors = Colors.white;
                      _colors2 = Colors.grey;
                      _pantalla = Comunicado(comunicados: comunicados);
                    });
                  },
                ),
              ),
              Positioned(
                top: 45,
                left: 320,
                child: Text(
                  "${Globals.noLeidosCount}",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 35,
                left: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: Icon(
                    Icons.output,
                    color: Colors.black,
                    size: 35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Horarios Table Section
          Expanded(
            child: _pantalla,
          ),
        ],
      ),
    );
  }
}

class Horarios extends StatelessWidget {
  const Horarios({
    super.key,
    required this.futureHorarios,
  });

  final Future<List<Horario>> futureHorarios;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Horario>>(
      future: futureHorarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay horarios disponibles."));
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12.0, // Espacio entre columnas
              dataRowHeight: 60.0, // Altura de las filas de datos
              columns: const [
                DataColumn(
                    label: Text('Día',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                DataColumn(
                    label: Text('Materia',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                DataColumn(
                    label: Text('Hora Inicio',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                DataColumn(
                    label: Text('Hora Fin',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
              ],
              rows: snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final horario = entry.value;

                return DataRow(
                  color: index.isEven
                      ? MaterialStateProperty.all(Colors.grey.shade200)
                      : MaterialStateProperty.all(Colors.white),
                  cells: [
                    DataCell(Text(horario.dia)),
                    DataCell(Text(horario.materiaId)),
                    DataCell(Text(horario.horaInicio)),
                    DataCell(Text(horario.horaFin)),
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

class Comunicado extends StatelessWidget {
  const Comunicado({
    super.key,
    required this.comunicados,
  });

  final List<Map<String, dynamic>> comunicados;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comunicados.length,
      itemBuilder: (context, index) {
        final comunicado = comunicados[index];
        return Card(
          // Añadir Card para mejorar la apariencia
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          elevation: 2,
          child: ListTile(
            title: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alineación a la izquierda
              children: [
                Text(
                  comunicado['fecha'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4), // Espacio entre fecha y nombre
                Text(
                  comunicado['name'],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                comunicado['descripcion_comunicado'],
                maxLines: 2, // Limitar líneas
                overflow: TextOverflow.ellipsis, // Mostrar '...' si excede
              ),
            ),
            trailing: Text(
              comunicado['remitente']?['name'] ?? 'Sin remitente',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}

class Estudiante {
  final String nombre;
  final String ci;
  final String curso;
  final String nivel;
  final String paralelo;

  Estudiante({
    required this.nombre,
    required this.ci,
    required this.curso,
    required this.nivel,
    required this.paralelo,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      nombre: json['nombre'],
      ci: json['ci'],
      curso: json['curso'],
      nivel: json['nivel'],
      paralelo: json['paralelo'],
    );
  }
}

class Horario {
  final String dia;
  final String materiaId;
  final String horaInicio;
  final String horaFin;

  Horario(
      {required this.materiaId,
      required this.horaInicio,
      required this.horaFin,
      required this.dia});

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      dia: json['dia'],
      materiaId: json['materia_id'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
    );
  }
}

class ComunicadoService {
  // URL de la API, cambia la IP y puerto si es necesario
  static  String apiUrl = "http://${Globals.ip}:8069/api/comunicados";

  // Función para obtener comunicados, con parámetros opcionales "rol", "usuario_id", "curso", "nivel", "paralelo"
  Future<List<Map<String, dynamic>>> fetchComunicados({
    String? rol,
    String? usuarioId,
    String? curso,
    String? nivel,
    String? paralelo,
  }) async {
    try {
      // Definir los parámetros de la consulta
      final queryParameters = {
        if (rol != null) 'rol': rol,
        if (usuarioId != null) 'usuario_id': usuarioId,
        if (curso != null) 'curso': curso,
        if (nivel != null) 'nivel': nivel,
        if (paralelo != null) 'paralelo': paralelo,
      };

      // Construir la URL con los parámetros opcionales
      final url = Uri.parse(apiUrl).replace(queryParameters: queryParameters);

      // Realizar la solicitud GET
      final response = await http.get(url);

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          // Actualizar el contador de no leídos en `Globals.noLeidosCount`
          Globals.noLeidosCount = jsonResponse['no_leidos'] ?? 0;
          // Retornar la lista de comunicados si el estado es exitoso
          return List<Map<String, dynamic>>.from(jsonResponse['comunicados']);
        } else {
          throw Exception("Error en la respuesta: ${jsonResponse['message']}");
        }
      } else {
        throw Exception("Error en la solicitud: Código ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener comunicados: $e");
      rethrow; // Vuelve a lanzar el error para que lo manejes en el llamador
    }
  }
}

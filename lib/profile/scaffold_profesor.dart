import 'package:flutter/material.dart';
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/login.dart';

import 'package:sw1segundoparcial/profile/scaffold_eleccion.dart';
import 'dart:async';
import 'package:sw1segundoparcial/widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScaffoldProfesor extends StatefulWidget {
  const ScaffoldProfesor({super.key});

  @override
  State<ScaffoldProfesor> createState() => _ScaffoldProfesorState();
}

class _ScaffoldProfesorState extends State<ScaffoldProfesor> {
  late Future<List<Curso>> futureCursos;
  Color _buttonColor1 = Colors.white;
  Color _buttonColor2 = Colors.white;
  Color _buttonColor3 = Colors.white;
  Color _buttonColor4 = Colors.white;
  Future<List<Curso>> fetchCursosHorario(String email) async {
    final response = await http.get(
      Uri.parse('http://${Globals.ip}:8069/api/profesor/cursos/horario/$email'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List cursosJson = data['cursos_asignados'];
      return cursosJson.map((curso) => Curso.fromJson(curso)).toList();
    } else {
      throw Exception('Error al cargar los cursos');
    }
  }

  Future<String?> obtenerInformacionProfesor(String email) async {
    final url = 'http://${Globals.ip}:8069/api/profesor/informacion/$email';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['error'] == null) {
          // Retorna solo el CI del profesor
          return responseBody['ci'];
        } else {
          print('Error: ${responseBody['error']}');
          return null;
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener la información del profesor: $e');
      return null;
    }
  }

  Future<List<Curso1>> fetchCursos(String email) async {
    final response = await http
        .get(Uri.parse('http://${Globals.ip}:8069/api/profesor/cursos/$email'));

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

  Future<List<Curso2>> fetchCursos2(String email) async {
    final response = await http
        .get(Uri.parse('http://${Globals.ip}:8069/api/profesor/cursos/$email'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Asegúrate de que 'cursos_asignados' existe en la respuesta
      if (data['cursos_asignados'] != null) {
        return List<Curso2>.from(
            data['cursos_asignados'].map((curso) => Curso2.fromJson(curso)));
      } else {
        throw Exception('No se encontraron cursos asignados');
      }
    } else {
      throw Exception('Error al cargar los cursos: ${response.reasonPhrase}');
    }
  }

  Timer? _timer; // Declara un Timer
  @override
  void initState() {
    super.initState();
    futureCursos = fetchCursosHorario(Globals.email);
    fetchComunicados();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el Timer
    super.dispose();
  }

  final ComunicadoService _comunicadoService = ComunicadoService();
  List<Map<String, dynamic>> comunicados = [];
  bool isLoading = true;

  // Función para obtener comunicados y actualizar el estado
  Future<void> fetchComunicados() async {
    try {
      final data = await _comunicadoService.fetchComunicados(
          rol: Globals.rol, usuarioId: Globals.idUser.toString());
      setState(() {
        isLoading = false;

        // Filtrar los comunicados no leídos y contarlos
        comunicados = data;

        /* Globals.noLeidosCount = data
            .where((com) => com['no_leidos'])
            .length; // Actualiza el contador de no leídos*/
      });
      print("Entro por aqui");
    } catch (e) {
      print("Error al obtener comunicados: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> crearComunicado({
    required String name,
    required String descripcionComunicado,
    required String destinatarioName,
    required String cursoId,
    required String nivelId,
    required String paraleloId,
    required String fechaEnvio,
    required int remitenteUid, // Cambiado para representar mejor el UID
    bool enviarNotificacion = true,
  }) async {
    final url = 'http://${Globals.ip}:8069/api/comunicados/create';

    // Preparar los datos para enviar
    final data = {
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "name": name,
        "descripcion_comunicado": descripcionComunicado,
        "destinatario_name": destinatarioName,
        "curso_id": cursoId,
        "nivel_id": nivelId,
        "paralelo_id": paraleloId,
        "fecha_envio": fechaEnvio,
        "uid": remitenteUid, // Agregar remitente UID aquí
        "enviar_notificacion": enviarNotificacion,
      },
      "id": 1,
    };

    try {
      // Hacer la solicitud POST
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Aquí podrías agregar más headers si es necesario, por ejemplo: 'Authorization': 'Bearer token'
        },
        body: jsonEncode(data),
      );

      // Manejar la respuesta
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(
            'Respuesta JSON completa: $jsonResponse'); // Imprime la respuesta completa para verificar su estructura

        // Acceder a 'status' dentro de 'result'
        if (jsonResponse.containsKey('result') &&
            jsonResponse['result']['status'] == 'success') {
          print(
              'Comunicado creado exitosamente: ${jsonResponse['result']['comunicado_id']}');
        } else if (jsonResponse['result'] != null &&
            jsonResponse['result'].containsKey('message')) {
          print('Error: ${jsonResponse['result']['message']}');
        } else {
          print('Error inesperado en la respuesta: $jsonResponse');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _nombreCurso = 'Seleccionar curso';
  String _nombreCurso2 = 'Seleccionar curso';
  Widget _pantalla = Text("");
  bool showNotas = true; // Variable para controlar la vista
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
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
                top: 115,
                left: 2,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _buttonColor1 = Colors.grey;
                      _buttonColor2 = Colors.white;
                      _buttonColor3 = Colors.white;
                      _buttonColor4 = Colors.white;
                      _nombreCurso2 = "Seleccionar Curso";
                      _nombreCurso = "Seleccionar Curso";
                      showNotas = true;
                      futureCursos = fetchCursosHorario(Globals.email);
                      _pantalla = Horario_lista(futureCursos: futureCursos);
                    });
                  },
                  child: Container(
                    // height: 30,
                    decoration: BoxDecoration(
                      color: _buttonColor1,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [shadowstyleBox],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.black),
                        //const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Center(
                            child: Text(
                              "Horario",
                              style: styleTexto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 175,
                left: 175,
                child: Seleccionar_Curso(),
              ),
              Positioned(
                left: 290,
                top: 40,
                child: IconButton(
                  color: _buttonColor4,
                  icon: Icon(
                    Icons.notifications,
                    size: 30,
                  ),
                  onPressed: () {
                    fetchComunicados();
                    setState(() {
                      _buttonColor3 = Colors.white;
                      _buttonColor1 = Colors.white;
                      _buttonColor2 = Colors.white;
                      _buttonColor4 = Colors.grey;
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
                      MaterialPageRoute(builder: (context) => Login()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.output,
                    color: Colors.black,
                    size: 35,
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: _pantalla),
        ],
      ),
    );
  }

  /*crearComunicado(
                      name: "Probando nomb3123re312312322233122",
                      descripcionComunicado:
                          "Descripción del comunicado importante.",
                      destinatarioName: "Padre",
                      cursoId: "primero",
                      nivelId: "primaria",
                      paraleloId: "A",
                      fechaEnvio: "2024-11-02 10:00:00",
                      remitenteUid: Globals.idUser,
                      enviarNotificacion: true, // Opcional, por defecto es true
                    );*/
  FutureBuilder<List<Curso1>> Seleccionar_Curso() {
    return FutureBuilder<List<Curso1>>(
      future: fetchCursos(Globals.email), // Llamada a la API
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error al cargar los cursos');
        } else {
          List<Curso1> cursos = snapshot.data!;
          Curso1? cursoSeleccionado;

          return Container(
            // height: 30,
            decoration: BoxDecoration(
                color: _buttonColor2,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [shadowstyleBox]),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Curso1>(
                hint: Row(
                  children: [
                    /*const Icon(Icons.class_rounded,
                                  color: Colors.black),*/
                    const SizedBox(width: 10),
                    Text(
                      _nombreCurso,
                      style: styleTexto,
                    ),
                  ],
                ),
                value: cursoSeleccionado,
                items: cursos.map<DropdownMenuItem<Curso1>>((Curso1 curso) {
                  return DropdownMenuItem<Curso1>(
                    value: curso,
                    child: Text(
                      '${curso.curso} - ${curso.nivel} - ${curso.paralelo}',
                      style: styleTexto,
                    ),
                  );
                }).toList(),
                onChanged: (Curso1? nuevoCurso) async {
                  Globals.ci =
                      (await obtenerInformacionProfesor(Globals.email))!;
                  setState(() {
                    _buttonColor1 = Colors.white;
                    _buttonColor2 = Colors.grey;
                    _buttonColor3 = Colors.white;
                    _buttonColor4 = Colors.white;
                    cursoSeleccionado = nuevoCurso;
                    _nombreCurso = nuevoCurso!.curso +
                        '-' +
                        nuevoCurso!.nivel +
                        '-' +
                        nuevoCurso!.paralelo;
                    // Aquí puedes agregar lógica para mostrar estudiantes o realizar acciones
                    /* _pantalla = EstudiantesPage(
                        nombreCurso: cursoSeleccionado!.curso,
                        nombreNivel: cursoSeleccionado!.nivel,
                        nombreParalelo: cursoSeleccionado!.paralelo);*/
                    _pantalla = ScaffoldEleccion(
                      nombreCurso: cursoSeleccionado!.curso,
                      nombreNivel: cursoSeleccionado!.nivel,
                      nombreParalelo: cursoSeleccionado!.paralelo,
                    );
                  });
                },
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                dropdownColor: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }

  FutureBuilder<List<Curso1>> Seleccionar_Curso2() {
    return FutureBuilder<List<Curso1>>(
      future: fetchCursos(Globals.email), // Llamada a la API
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error al cargar los cursos');
        } else {
          List<Curso1> cursos = snapshot.data!;
          Curso1? cursoSeleccionado2;

          return Container(
            // height: 30,
            decoration: BoxDecoration(
                color: _buttonColor2,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [shadowstyleBox]),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Curso1>(
                hint: Row(
                  children: [
                    /*const Icon(Icons.class_rounded,
                                  color: Colors.black),*/
                    const SizedBox(width: 10),
                    Text(
                      _nombreCurso,
                      style: styleTexto,
                    ),
                  ],
                ),
                value: cursoSeleccionado2,
                items: cursos.map<DropdownMenuItem<Curso1>>((Curso1 curso) {
                  return DropdownMenuItem<Curso1>(
                    value: curso,
                    child: Text(
                      '${curso.curso} - ${curso.nivel} - ${curso.paralelo}',
                      style: styleTexto,
                    ),
                  );
                }).toList(),
                onChanged: (Curso1? nuevoCurso) async {
                  Globals.ci =
                      (await obtenerInformacionProfesor(Globals.email))!;
                  setState(() {
                    _buttonColor1 = Colors.white;
                    _buttonColor2 = Colors.grey;
                    _buttonColor3 = Colors.white;
                    _buttonColor4 = Colors.white;
                    cursoSeleccionado2 = nuevoCurso;
                    _nombreCurso = nuevoCurso!.curso +
                        '-' +
                        nuevoCurso!.nivel +
                        '-' +
                        nuevoCurso!.paralelo;
                  });
                },
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                dropdownColor: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }
}

/*
class Cursos_lista extends StatefulWidget {
  const Cursos_lista({super.key});

  @override
  State<Cursos_lista> createState() => _Cursos_listaState();
}

class _Cursos_listaState extends State<Cursos_lista> {
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
    return FutureBuilder<List<Curso1>>(
      future: fetchCursos(Globals.email),
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
    );
  }
}*/
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
                maxLines: 1000,
                overflow: TextOverflow.ellipsis, // Mostrar '...' si excede
              ),
            ),
            trailing: Column(
              children: [
                Text("Enviado por:"),
                Text(
                  comunicado['remitente']?['name'] ?? 'Sin remitente',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Horario_lista extends StatelessWidget {
  const Horario_lista({
    super.key,
    required this.futureCursos,
  });

  final Future<List<Curso>> futureCursos;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Curso>>(
      future: futureCursos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No hay cursos disponibles"));
        } else {
          final cursos = snapshot.data!;
          return ListView(
            children: cursos.map((curso) {
              return ExpansionTile(
                title: Text(
                    "Curso: ${curso.curso} de ${curso.nivel}  ${curso.paralelo}"),
                children: [
                  DataTable(
                    columns: [
                      DataColumn(label: Text('Día')),
                      DataColumn(label: Text('Materia')),
                      DataColumn(label: Text('Inicio')),
                      DataColumn(label: Text('Fin')),
                    ],
                    rows: curso.horarios.map((horario) {
                      return DataRow(
                        cells: [
                          DataCell(Text(horario.dia)),
                          DataCell(Text(horario.materia)),
                          DataCell(Text(horario.horaInicio)),
                          DataCell(Text(horario.horaFin)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class OtroWidget extends StatelessWidget {
  Future<List<Curso>> fetchCursos(String email) async {
    final response = await http
        .get(Uri.parse('http://${Globals.ip}:8069/api/profesor/cursos/$email'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['cursos_asignados'] != null) {
        return List<Curso>.from(
            data['cursos_asignados'].map((curso) => Curso.fromJson(curso)));
      } else {
        throw Exception('No se encontraron cursos asignados');
      }
    } else {
      throw Exception('Error al cargar los cursos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Curso>>(
        future: fetchCursos(Globals.email),
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
                return ListTile(
                  title: Text(curso.curso),
                  subtitle: Text(
                      'Nivel: ${curso.nivel} - Paralelo: ${curso.paralelo}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Curso {
  final String curso;
  final String nivel;
  final String paralelo;
  final List<Horario> horarios;

  Curso({
    required this.curso,
    required this.nivel,
    required this.paralelo,
    required this.horarios,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    var list = json['horarios'] as List;
    List<Horario> horariosList = list.map((i) => Horario.fromJson(i)).toList();

    return Curso(
      curso: json['curso'],
      nivel: json['nivel'],
      paralelo: json['paralelo'],
      horarios: horariosList,
    );
  }
}

class Horario {
  final String dia;
  final String materia;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.dia,
    required this.materia,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      dia: json['dia'],
      materia: json['materia'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
    );
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

class Curso2 {
  final String curso;
  final String nivel;
  final String paralelo;

  Curso2({required this.curso, required this.nivel, required this.paralelo});

  factory Curso2.fromJson(Map<String, dynamic> json) {
    return Curso2(
      curso: json['curso'],
      nivel: json['nivel'],
      paralelo: json['paralelo'],
    );
  }
}

class ComunicadoService {
  // URL de la API, cambia la IP y puerto si es necesario
  static String apiUrl = "http://${Globals.ip}:8069/api/comunicados";

  // Función para obtener comunicados, con parámetros opcionales "rol" y "usuario_id"
  Future<List<Map<String, dynamic>>> fetchComunicados({
    String? rol,
    String? usuarioId,
  }) async {
    try {
      // Definir los parámetros de la consulta
      final queryParameters = {
        if (rol != null) 'rol': rol,
        if (usuarioId != null) 'usuario_id': usuarioId,
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

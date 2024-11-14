import 'package:flutter/material.dart';
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/login.dart';
import 'package:sw1segundoparcial/widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScaffoldPadre extends StatefulWidget {
  const ScaffoldPadre({super.key});

  @override
  State<ScaffoldPadre> createState() => _ScaffoldPadreState();
}

final ci_estudiante = '';
Color _color1 = Colors.white;
Color _color2 = Colors.white;

class _ScaffoldPadreState extends State<ScaffoldPadre> {
  Future<String?> fetchEstudianteCI(String emailTutor) async {
    final String apiUrl =
        'http://${Globals.ip}:8069/api/estudiante/informacion/$emailTutor';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica si hay un error en la respuesta
        if (data['error'] != null) {
          print('Error: ${data['error']}');
          return null;
        }
        print(data['ci']);
        // Retorna el CI del estudiante
        return data['ci'];
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Widget _pantalla = Text(""); // Variable para controlar la vista
  late Future<Map<String, List<Nota>>> futureNotas = Future.value({});
  late var aux = '';
  @override
  void initState() {
    super.initState();
    fetchComunicados();
  }

  int noLeidos = 0;
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

  TextEditingController _ciController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Positioned(
                child: Container(
                  height: 230,
                  width: 580,
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
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 175,
                left: 20,
                child: Container(
                  // height: 50,
                  // width: 190,
                  decoration: BoxDecoration(
                    color: _color2,
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.white,
                    boxShadow: [shadowstyleBox],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _color2 = Colors.grey;
                            _color1 = Colors.white;
                          });
                          Globals.pantallas = ConsultarBoletin();
                        },
                        icon: Text(
                          "Boletin",
                          style: styleTexto,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 290,
                top: 40,
                child: IconButton(
                  color: _color1,
                  icon: Icon(
                    Icons.notifications,
                    size: 30,
                  ),
                  onPressed: () {
                    fetchComunicados();
                    setState(() {
                      _color2 = Colors.white;
                      _color1 = Colors.grey;
                      Globals.pantallas = Comunicado(comunicados: comunicados);
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
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Globals.pantallas,
          )
        ],
      ),
    );
  }
}

class ConsultarBoletin extends StatefulWidget {
  const ConsultarBoletin({
    super.key,
  });

  @override
  State<ConsultarBoletin> createState() => _ConsultarBoletinState();
}

class _ConsultarBoletinState extends State<ConsultarBoletin> {
  Future<Map<String, List<Nota>>> fetchNotas(String ci) async {
    final response = await http
        .get(Uri.parse('http://${Globals.ip}:8069/api/estudiante/notas/$ci'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Verifica si la clave 'notas' está presente y contiene datos
      if (data.containsKey('notas') && data['notas'] is Map<String, dynamic>) {
        // Mapea la lista JSON a un mapa de trimestre a lista de objetos Nota
        Map<String, List<Nota>> notasPorTrimestre = {};
        data['notas'].forEach((trimestre, notas) {
          notasPorTrimestre[trimestre] =
              (notas as List).map((item) => Nota.fromJson(item)).toList();
        });
        return notasPorTrimestre;
      } else {
        // Devuelve un mapa vacío si no se encuentran notas
        return {};
      }
    } else {
      throw Exception('Error al cargar las notas');
    }
  }

  late Future<Map<String, List<Nota>>> futureNotas = Future.value({});
  TextEditingController _ciController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [shadowstyleBox]),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: TextFormField(
                controller: _ciController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          futureNotas = fetchNotas(_ciController.text);
                          // Globals.pantallas = Boletin(futureNotas: futureNotas);
                        });
                      },
                      icon: Icon(Icons.search)),
                ),
              ),
            ),
          ),
        ),
        Boletin(futureNotas: futureNotas)
      ],
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
                maxLines: 800, // Limitar líneas
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

class Boletin extends StatelessWidget {
  const Boletin({
    super.key,
    required this.futureNotas,
  });

  final Future<Map<String, List<Nota>>> futureNotas;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Nota>>>(
      future: futureNotas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron notas'));
        } else {
          return SingleChildScrollView(
            child: Column(
              children: snapshot.data!.entries.map((entry) {
                String trimestre = entry.key;
                List<Nota> notas = entry.value;

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trimestre,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Table(
                          border: TableBorder.all(),
                          children: [
                            // Cabecera de la tabla
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Materia',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Nota',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            // Filas de notas
                            for (var nota in notas)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(nota.materia),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${nota.nota}'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

// Define tu otro widget aquí
class OtroWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Este es otro widget'));
  }
}

class Nota {
  final String curso;
  final String nivel;
  final String paralelo;
  final String materia;
  final int nota;
  final String trimestre;
  final String fechaEntrega;

  Nota({
    required this.curso,
    required this.nivel,
    required this.paralelo,
    required this.materia,
    required this.nota,
    required this.trimestre,
    required this.fechaEntrega,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      curso: json['curso'] ?? '',
      nivel: json['nivel'] ?? '',
      paralelo: json['paralelo'] ?? '',
      materia: json['materia'] ?? '',
      nota: json['nota'] ?? 0,
      trimestre: json['trimestre'] ?? '',
      fechaEntrega: json['fecha_entrega'] ?? '',
    );
  }
}

class ComunicadoService {
  // URL de la API, cambia la IP y puerto si es necesario
  static  String apiUrl = "http://${Globals.ip}:8069/api/comunicados";

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

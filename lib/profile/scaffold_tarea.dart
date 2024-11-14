import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sw1segundoparcial/globals.dart';
import 'package:sw1segundoparcial/widget.dart';

class ScaffoldTarea extends StatefulWidget {
  String nombreCurso;
  String nombreNivel;
  String nombreParalelo;
  ScaffoldTarea(
      {super.key,
      required this.nombreCurso,
      required this.nombreNivel,
      required this.nombreParalelo});

  @override
  State<ScaffoldTarea> createState() => _ScaffoldTareaState();
}

class _ScaffoldTareaState extends State<ScaffoldTarea> {
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

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
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
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 45),
                          child: Column(
                            children: [
                              Text(
                                "Crear tarea para el curso:",
                                style: styleTexto,
                              ),
                              Text(
                                "${widget.nombreCurso} de ${widget.nombreNivel} ${widget.nombreParalelo}",
                                style: styleTexto,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    controller: _tituloController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      label: Text("Titulo de la tarea"),
                    ),
                  ),
                ),
              ),
            ),
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
                    controller: _descripcionController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1, // Mínimo número de líneas
                    maxLines:
                        null, // Número máximo de líneas, null permite que crezca indefinidamente
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      label: Text("Descripción de la tarea"),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  crearComunicado(
                      name: _tituloController.text,
                      descripcionComunicado: _descripcionController.text,
                      destinatarioName: 'Estudiante',
                      cursoId: widget.nombreCurso,
                      nivelId: widget.nombreNivel,
                      paraleloId: widget.nombreParalelo,
                      fechaEnvio: obtenerFechaActual(),
                      remitenteUid: Globals.idUser);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [shadowstyleBox]),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "Enviar tarea",
                      style: styleTexto,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

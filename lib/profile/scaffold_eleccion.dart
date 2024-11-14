import 'package:flutter/material.dart';
import 'package:sw1segundoparcial/profile/scaffold_lista_estudiante.dart';
import 'package:sw1segundoparcial/profile/scaffold_tarea.dart';
import 'package:sw1segundoparcial/widget.dart';

class ScaffoldEleccion extends StatefulWidget {
  String nombreCurso;
  String nombreNivel;
  String nombreParalelo;
  ScaffoldEleccion(
      {super.key,
      required this.nombreCurso,
      required this.nombreNivel,
      required this.nombreParalelo});

  @override
  State<ScaffoldEleccion> createState() => _ScaffoldEleccionState();
}

class _ScaffoldEleccionState extends State<ScaffoldEleccion> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScaffoldTarea(
                    nombreCurso: widget.nombreCurso,
                    nombreNivel: widget.nombreNivel,
                    nombreParalelo: widget.nombreParalelo,
                  ),
                ));
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
                boxShadow: [shadowstyleBox]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Crear Tarea",
                style: styleTexto,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EstudiantesPage(
                      nombreCurso: widget.nombreCurso,
                      nombreNivel: widget.nombreNivel,
                      nombreParalelo: widget.nombreParalelo),
                ));
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
                boxShadow: [shadowstyleBox]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Lista Estudiante",
                style: styleTexto,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

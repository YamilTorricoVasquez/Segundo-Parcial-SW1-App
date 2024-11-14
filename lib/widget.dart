import 'package:flutter/material.dart';

final styleTitulo = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
final styleTexto = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]);
final shadowstyleBox = BoxShadow(
  color: Colors.black.withOpacity(0.5),
  offset: const Offset(0, 3),
  blurRadius: 6,
);
final styleSesion = TextStyle(
  fontSize: 25, // Tamaño de la fuente
  fontWeight: FontWeight.bold, // Peso de la fuente (negrita)
  //fontStyle: FontStyle., // Fuente en cursiva
  color: Colors.black, // Color del texto
  letterSpacing: 1.0, // Espaciado entre letras
  fontFamily: 'Roboto', // Familia de la fuente, puedes usar la que prefieras
);

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class Globals {
  static String token = '';
  static String nombreUsuario = '';
  static String email = '';
  static String ci = '';
  static String rol = '';
  static String curso = '';
  static String nivel = '';
  static String paralelo = '';
  static Widget pantallas = Text("");
  static int noLeidosCount = 0;
  static int idUser = 0;
  static String ip = "3.19.219.210";
}

String obtenerFechaActual() {
  DateTime now = DateTime.now();
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
}


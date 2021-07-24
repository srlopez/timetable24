import 'dart:convert';

import 'package:flutter/material.dart';

class Actividad {
  //
  int dia = 0;
  int minutos;
  int marcaInicial = 0;
  int nHuecos = 0;
  //
  bool activo = false;
  String titulo = '';
  String subtitulo = '';
  String pie = '';
  Color color = Colors.grey.shade200;

  Actividad({required this.dia, required marca, required this.minutos})
      : marcaInicial = marca,
        nHuecos = 1 {
    resetActividad();
  }

  void resetActividad() {
    activo = false;
    titulo = '';
    subtitulo = '';
    pie = '';
    color = Colors.grey.shade200;
  }

  Actividad clone() => Actividad.fromJson(toJson());

  Actividad.fromJson(Map<String, dynamic> json)
      : dia = int.parse(json['dia'].toString()),
        minutos = int.parse(json['minutos'].toString()),
        marcaInicial = int.parse(json['inicio'].toString()),
        nHuecos = int.parse(json['largo'].toString()),
        //
        color = Color(int.parse(json['color'].toString())),
        activo = int.parse(json['activo'].toString()) == 1 ? true : false,
        titulo = json['titulo'] ?? '',
        subtitulo = json['subtitulo'] ?? '',
        pie = json['pie'] ?? '';

  factory Actividad.fromString(String source) {
    return Actividad.fromJson(jsonDecode(source));
  }

  Map<String, dynamic> toJson() => {
        'dia': dia,
        'minutos': minutos,
        'inicio': marcaInicial,
        'largo': nHuecos,
        //
        'color': color.value,
        'activo': activo ? 1 : 0,
        'titulo': titulo,
        'subtitulo': subtitulo,
        'pie': pie,
      };

  toString() => jsonEncode(toJson());
}

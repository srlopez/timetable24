import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timetable24/global/app_controller.dart';
import 'package:timetable24/models/marca_horaria.dart';

class RelojController extends GetxController {
  AppController app;
  RelojController({required this.app});

  static RelojController get to => Get.find<RelojController>();

  @override
  void onInit() {
    setScales();
    setCurrentTime();
    setTimer();
    setActividad();
    bRead();
    super.onInit();
  }

  // Storage
  final box = GetStorage();
  bWrite() =>
      box.write('reloj', [scale.value, font.value, color.value, texto.value]);
  bRead() {
    var values = box.read('reloj') ?? [0, 0, 0, 0];
    scale.value = values[0];
    font.value = values[1];
    color.value = values[2];
    texto.value = values[3];
  }

  // hora resto
  String _getTime() => DateFormat.Hms().format(DateTime.now());
  String formatResto(int total, int done) => "-${total - done}'";
  var currentTime = '';
  //var currentRest = '';

  var currentHMS = ['', '', ''].obs;
  var milliseconds = 1000;
  var dots = ':';
  var light = true;

  void setCurrentTime() {
    var nextTime = _getTime().split(dots);
    if (nextTime[2] == currentHMS[2]) return;
    currentHMS.value = nextTime;
    currentTime = nextTime[0] + dots + nextTime[1];
    light = !light;
    textos[0] = currentTime;
    textos[1] = currentTime;
  }

  void setTimer() =>
      Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
        setCurrentTime();
        setActividad();
      });

  // Actividad
  var progresoData = ProgresoData.fromNull().obs;

  void setActividad() {
    var now = DateTime.now();

    if (!app.esFechaConActividad(now)) {
      // Dia marcado como sin actividad horaria
      progresoData.value = ProgresoData.fromNull();
      return;
    }
    var act = app.getActividadActual();
    if (act == null) {
      // No hay actividad en este momento
      progresoData.value = ProgresoData.fromNull();
      return;
    }
    var mNow = Marca(DateTime.now().hour, DateTime.now().minute);
    var mIni = app.marcasHorarias[act.marcaInicial];
    var mFin = app.marcasHorarias[act.marcaInicial + act.nHuecos];
    var total = act.minutos;
    var done = mNow.diff(mIni);

    textos[1] = formatResto(total, done);
    progresoData.value = ProgresoData(
        start: mIni, end: mFin, total: total, done: done, color: act.color);
  }

  // FORMATO ======
  // tamaño
  var scale = 0.obs;
  var scales = [];
  void setScales() {
    for (var s = 10.0; s <= 18.0; s += 1.8) scales.add(s);
  }

  void nextScale() {
    scale.value = (scale.value + 1) % scales.length;
    bWrite();
  }

  // tipo
  var font = 0.obs;
  var fonts = [
    GoogleFonts.bebasNeue,
    GoogleFonts.shanti,
    GoogleFonts.lato, //
    GoogleFonts.comfortaa,
    GoogleFonts.coda,
    GoogleFonts.voces,
    GoogleFonts.bellota,
    GoogleFonts.oswald,
    GoogleFonts.poppins,

    //GoogleFonts.flamenco, //
    //GoogleFonts.inconsolata,
    //GoogleFonts.playfairDisplay,
    //GoogleFonts.anton,
    //GoogleFonts.barlowCondensed,
    //GoogleFonts.teko,
    //GoogleFonts.abrilFatface,
    //GoogleFonts.creteRound,
  ];
  void nextFont() {
    font.value = (font.value + 1) % fonts.length;
    bWrite();
  }

  // color
  var color = 0.obs;
  var colores = [
    Colors.white,
    Colors.amber,
    Colors.blue,
    Colors.brown,
    Colors.cyan,
    Colors.green,
    Colors.grey,
    Colors.indigo,
    Colors.lime,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.yellow,
  ];
  void nextColor() {
    color.value = (color.value + 1) % colores.length;
    bWrite();
  }

  // Hora o resto de actividad
  var texto = 0.obs;
  var textos = ['', ''];
  void nextText() {
    texto.value = (texto.value + 1) % 2;
    bWrite();
  }
}

class ProgresoData {
  bool visible = false;
  String start = '';
  String end = '';
  int total = 0;
  int done = 0;
  Color color = Colors.white;

  ProgresoData.fromNull()
      : start = '',
        end = '',
        total = 0,
        done = 0;

  ProgresoData(
      {required start,
      required end,
      required this.total,
      required this.done,
      color})
      : start = start.toString(),
        end = end.toString(),
        color = color ?? Colors.white,
        visible = true;
}

import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timetable24/global/app_controller.dart';
import 'package:timetable24/models/marca_horaria.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class RelojController extends GetxController {
  AppController app;
  RelojController({required this.app});

  static RelojController get to => Get.find<RelojController>();

  @override
  void onInit() {
    loadFonts();
    setScales();
    setCurrentTime();
    setTimer();
    setActividad();
    bRead();
    super.onInit();
  }

  @override
  void onReady() {
    //print('RelojController onReady Wakelock.enable()');
    Wakelock.enable();
    super.onReady();
  }

  @override
  void onClose() {
    //print('RelojController onClose  Wakelock.disable()');
    Wakelock.disable();
    super.onClose();
  }

  // Storage
  final box = GetStorage();
  bWrite() => box.write(
      'reloj', [scale.value, font.value, color.value, mode.value, alarm.value]);
  bRead() {
    var values = box.read('reloj') ?? [0, 0, 0, 0, 0];
    scale.value = values[0]; // tamaño del Font
    font.value = values[1]; // Tipo de Font
    color.value = values[2]; // Color
    mode.value = values[3]; // Hora/CuentaAtras
    alarm.value = values[4]; // On/off
  }

  // hora / resto
  String _getTime() => DateFormat.Hms().format(DateTime.now());
  String formatResto(int total, int done) => "-${total - done}'";
  String formatRestoEnSegundos() => '-${60 - int.parse(currentHMS[2])}"';
  var currentTime = '';
  var currentHMS = ['', '', ''].obs;
  var milliseconds = 1000;
  var colon = ':';
  var tictac = true;

  void setCurrentTime() {
    var nextTime = _getTime().split(colon);
    if (nextTime[2] == currentHMS[2]) return;
    currentHMS.value = nextTime;
    currentTime = nextTime[0] + colon + nextTime[1];
    tictac = !tictac;
    modeTexts[0] = currentTime;
    modeTexts[1] = currentTime;
  }

  void setTimer() =>
      Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
        setCurrentTime();
        setActividad();
      });

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

  // FUENTE =======
  var font = 0.obs;
  var fonts = [
    //1
    GoogleFonts.bebasNeue,
    GoogleFonts.oswald,
    GoogleFonts.poppins,
    GoogleFonts.fjallaOne,
    GoogleFonts.righteous,
    //2
    GoogleFonts.shanti,
    GoogleFonts.lato,
    GoogleFonts.coda,
    GoogleFonts.voces,
    GoogleFonts.raleway,
    GoogleFonts.mako,
    GoogleFonts.encodeSansCondensed,
//4
    GoogleFonts.dmSerifDisplay,
    GoogleFonts.vidaloka,
    GoogleFonts.trirong,
    //5
    GoogleFonts.merriweather,
    GoogleFonts.adamina,
    //6
    GoogleFonts.cinzel,
    GoogleFonts.bellefair,
    //7
    GoogleFonts.nixieOne,
    GoogleFonts.rationale,
    GoogleFonts.emilysCandy,
    GoogleFonts.ralewayDots,
    GoogleFonts.zcoolQingKeHuangYou,
    GoogleFonts.londrinaShadow,
  ];
  void nextFont() {
    font.value = (font.value + 1) % fonts.length;
    bWrite();
    //print('font ${font.value} ${fontIName(font.value)}');
  }

  void loadFonts() {
    // Google Fonts muestra el font por defecto si éste no está cargado
    // El efecto es feo, así que cargamos los fonts antes
    for (var i = 0; i < fonts.length; i++) {
      print('loading font ${i + 1}/${fonts.length} ${fontName(fonts[i])}...');

      font();
    }
    fonts.forEach((font) {});
  }

  //String fontIName(int i) => fontName(fonts[i]);
  String fontName(Function gf) => gf.toString().split(":")[1].split(' ').last;

  // COLOR =======
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
  int siguienteColor() => (color.value + 1) % colores.length;
  void nextColor() {
    color.value = siguienteColor();
    bWrite();
  }

  // MODE ======= Hora o resto de actividad
  var mode = 0.obs;
  var modeTexts = ['', ''];
  void nextMode() {
    mode.value = (mode.value + 1) % 2;
    bWrite();
  }

  // ALARMA ========
  var alarm = 0.obs;
  var playing = false;
  var alarmIcon = [
    Icons.notifications_off,
    Icons.notifications_on,
    Icons.notifications_paused_sharp
  ];
  void setAlarm() {
    alarm.value = (alarm.value + 1) % alarmIcon.length;
    bWrite();
  }

  void playSound() {
    if (!playing) FlutterRingtonePlayer.playAlarm(asAlarm: true);
    playing = true;
  }

  void playBuzz() {
    Vibrate.vibrate();
    playing = true;
  }

  void stopSound() {
    if (!playing) return;
    FlutterRingtonePlayer.stop();
    playing = false;
  }

  // Actividad / ProgressData ================
  var progresoData = ProgresoData.fromNull().obs;

  void setActividad() {
    var now = DateTime.now();

    if (!app.esFechaConActividad(now)) {
      // Dia marcado como sin actividad horaria
      setNoActividad();
      stopSound();
      return;
    }
    var act = app.getActividadActual();
    if (act == null) {
      setNoActividad();
      stopSound();
      return;
    }
    var mNow = Marca(DateTime.now().hour, DateTime.now().minute);
    var mIni = app.marcasHorarias[act.marcaInicial];
    var mFin = app.marcasHorarias[act.marcaInicial + act.nHuecos];
    var total = act.minutos;
    var done = mNow.diff(mIni) - 1; // -1 Para no resentar el minuto Cero

    modeTexts[1] = formatResto(total, done);

    // Verificamos si es el último minuto
    // Alarma y presentación de segundos
    if (done == total - 1) {
      // Ultimo minuto
      modeTexts[1] = formatRestoEnSegundos();
      switch (alarm.value) {
        case 1:
          playSound();
          break;
        case 2:
          playBuzz();
          break;
        default:
      }
    } else {
      // No es el ultimo minuto
      stopSound();
    }

    progresoData.value = ProgresoData(
        start: mIni, end: mFin, total: total, done: done, color: act.color);
  }

  void setNoActividad() {
    progresoData.value = ProgresoData.fromNull();
    mode.value = 0;
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

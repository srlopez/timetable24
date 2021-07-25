import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timetable24/global/app_utils.dart';
import 'package:timetable24/models/marca_horaria.dart';

class RelojPageController extends GetxController {
  @override
  void onInit() {
    setScales();
    setCurrentTime();
    setTimer();
    bRead();
    super.onInit();
  }

  // Storage
  final box = GetStorage();
  bWrite() => box.write('reloj', [scale.value, font.value, color.value]);
  bRead() {
    var values = box.read('reloj') ?? [0, 0, 0];
    scale.value = values[0];
    font.value = values[1];
    color.value = values[2];
  }

  // hora
  var currentHM = [].obs;
  var milliseconds = 1000;
  var dots = ':';
  var light = true;
  String _getTime() => DateFormat.Hms().format(DateTime.now());
  void setCurrentTime() {
    var prevSeconds = currentHM.length > 0 ? currentHM[2] : 'x';
    var currentTime = _getTime();
    currentHM.value = currentTime.split(dots);
    light = prevSeconds == currentHM[2] ? light : !light;
  }

  void setTimer() => Timer.periodic(
      Duration(milliseconds: milliseconds), (timer) => setCurrentTime());

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
    GoogleFonts.shanti,
    GoogleFonts.bebasNeue,
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

  // colr
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
}

class RelojPage extends StatelessWidget {
  const RelojPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = Get.put(RelojPageController());

    var from = Marca(DateTime.now().hour, 0);
    var to = Marca(DateTime.now().hour + 1, 0);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
      ),
      body: Container(
        color: Colors.black,
        child: RotatedBox(
          quarterTurns: 1,
          child: Stack(
            children: [
              // HORA
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: _buildReloj(_, context)),
                  _buildProgressBar(_, context, from, to, Colors.amber),
                ],
              ),
              // BOTONES
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      BText('➕➖', onPressed: _.nextScale),
                      BText('aA', onPressed: _.nextFont),
                      Obx(() => BText('⬤',
                          onPressed: _.nextColor,
                          color: _.colores[
                              (_.color.value + 1) % _.colores.length])),
                      //     BText('Back->', onPressed: () => Get.back()),
                    ],
                  ),
                  Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    RelojPageController _,
    BuildContext context,
    Marca from,
    Marca to,
    Color color,
  ) {
    var font = _.fonts[1];
    var fStyle = Theme.of(context).textTheme.bodyText1!.copyWith(color: color);

    var now = Marca(DateTime.now().hour, DateTime.now().minute);

    var prev = now.diff(from);
    var total = to.diff(from);

    var height = 20.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 10),
        Text(
          from.toString(),
          style: font(textStyle: fStyle),
          textScaleFactor: 2,
        ),
        SizedBox(width: 10),
        Expanded(
            flex: prev,
            child: Container(height: height, color: darken(color, 0))),
        Expanded(
            flex: total - prev,
            child: Container(height: height, color: lighten(color, .3))),
        SizedBox(width: 10),
        Text(
          to.toString(),
          style: font(textStyle: fStyle),
          textScaleFactor: 2,
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _buildReloj(RelojPageController _, BuildContext context) {
    //print('_buildReloj');
    return Center(
      child: Obx(() {
        //print('_buildReloj Obx');

        var hora = _.currentHM[0];
        var mins = _.currentHM[1];
        var puntos = _.dots;
        var sFactor = _.scales[_.scale.value];
        var font = _.fonts[_.font.value];
        var color = _.colores[_.color.value];

        var fStyle =
            Theme.of(context).textTheme.bodyText1!.copyWith(color: color);
        var fStyleDots = fStyle.copyWith(
            color: _.light
                ? color
                : _.color.value == 0
                    ? darken(color, .2)
                    : lighten(color, .2));

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(hora,
                style: font(textStyle: fStyle), textScaleFactor: sFactor),
            Text(puntos,
                style: font(textStyle: fStyleDots), textScaleFactor: sFactor),
            Text(mins,
                style: font(textStyle: fStyle),
                textScaleFactor: sFactor,
                overflow: TextOverflow.clip),
          ],
        );
      }),
    );
  }
}

class BText extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? color;

  const BText(this.text, {this.onPressed, this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed ?? () {},
        child: Text(
          text,
          style: TextStyle(color: color ?? Colors.grey),
        ));
  }
}

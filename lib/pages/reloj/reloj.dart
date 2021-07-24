import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RelojPageController extends GetxController {
  var currentTime = ''.obs;
  var scale = 1.0.obs;
  var font = 0.obs;

  @override
  void onInit() {
    super.onInit();
    currentTime.value = _getTime();
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      currentTime.value = _getTime();
    });
  }

  String _getTime() => DateFormat.Hm().format(DateTime.now());
}

class RelojPage extends StatelessWidget {
  const RelojPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = Get.put(RelojPageController());
    //final app = Get.find<AppController>();

    var fonts = [
      GoogleFonts.bebasNeue,
      GoogleFonts.lato, //
      GoogleFonts.flamenco, //
      GoogleFonts.comfortaa,
      GoogleFonts.coda,
      GoogleFonts.voces,
      GoogleFonts.bellota,
      GoogleFonts.inconsolata,
      GoogleFonts.oswald,
      GoogleFonts.poppins,
      GoogleFonts.playfairDisplay,
      GoogleFonts.anton,
      GoogleFonts.barlowCondensed,
      GoogleFonts.teko,
      GoogleFonts.abrilFatface,
      GoogleFonts.creteRound,
      GoogleFonts.shanti
    ];

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
              Center(
                child: Obx(() => Text(
                      '${_.currentTime.value}',
                      //style: GoogleFonts.flamenco(textStyle: headline),
                      style: fonts[_.font.value](
                          textStyle: Theme.of(context).textTheme.headline1!),
                      textScaleFactor: _.scale.value,
                    )),
              ),
              // BOTONES
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      BText('Back->', onPressed: () => Get.back()),
                    ],
                  ),
                  Spacer(),
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Obx(() => BText(
                              'Scale (${_.scale.value.toString().substring(0, 3)})',
                              onPressed: () {
                            _.scale.value += .1;
                            if (_.scale.value > 2.6) _.scale.value = 1;
                          })),
                      Obx(() => BText('Font (${_.font.value})', onPressed: () {
                            _.font.value++;
                            if (_.font.value == fonts.length) _.font.value = 0;
                          })),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BText extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const BText(this.text, {this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Colors.grey),
        ));
  }
}

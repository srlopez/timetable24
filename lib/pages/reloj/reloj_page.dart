import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../global/app_utils.dart';
import 'reloj_controller.dart';

class RelojPage extends StatelessWidget {
  const RelojPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = RelojController.to;

    final pd = _.pd;

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
                  // TEXTO CENTRAL
                  Expanded(child: _buildReloj(context)),
                  // BARRA DE PROGRESO
                  Obx(() => pd.value.visible
                      ? _buildProgressBar(context, pd.value)
                      : Container()),
                ],
              ),
              // FORMATO
              _buildBotoneraFormato(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotoneraFormato() {
    final _ = RelojController.to;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            BText('◀ ▶', onPressed: _.nextScale),
            BText('aℬαβ', onPressed: _.nextFont),
            Obx(() => BText('⓰', //'⬤'
                onPressed: _.nextColor,
                color: _.colores[(_.color.value + 1) % _.colores.length])),
            //     BText('Back->', onPressed: () => Get.back()),
          ],
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    ProgresoData pd,
  ) {
    final _ = RelojController.to;

    var font = _.fonts[0];
    var fStyle =
        Theme.of(context).textTheme.bodyText1!.copyWith(color: pd.color);

    var height = 30.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 10),
        Text(
          pd.start,
          style: font(textStyle: fStyle),
          textScaleFactor: 2,
        ),
        SizedBox(width: 10),
        Expanded(
            child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                    flex: pd.done,
                    child:
                        Container(height: height, color: darken(pd.color, 0))),
                Expanded(
                    flex: pd.total - pd.done,
                    child: Container(
                        height: height, color: lighten(pd.color, .3))),
              ],
            ),
            Center(
              child: Text(
                "-${pd.total - pd.done}'",
                style: font(textStyle: fStyle.copyWith(color: Colors.black)),
                textScaleFactor: 2,
              ),
            ),
          ],
        )),
        SizedBox(width: 10),
        Text(
          pd.end,
          style: font(textStyle: fStyle),
          textScaleFactor: 2,
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _buildReloj(BuildContext context) {
    final _ = RelojController.to;

    //print('_buildReloj');
    return Center(
      child: Obx(() {
        //print('_buildReloj Obx');

        var hora = _.currentHMS[0];
        var mins = _.currentHMS[1];
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

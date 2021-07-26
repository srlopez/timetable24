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
    final pd = _.progresoData;

    print(_.textos);
    print(_.texto.value);

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
                  Expanded(
                    child: Obx(() {
                      final value = _.textos[_.texto.value];
                      final p = _.texto.value == 0 ? 2 : 0;
                      return _buildReloj(context, value, p);
                    }),
                  ),
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
            //https://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols
            Obx(() => BText(['12:00', _.formatResto(40, 10)][_.texto.value],
                onPressed: _.nextText)),
            BText('▼▲', onPressed: _.nextScale),
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
    var resto = _.formatResto(pd.total, pd.done);

    var decoIni = BoxDecoration(
      color: lighten(pd.color, .3),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(height / 2),
          bottomLeft: Radius.circular(height / 2)),
    );

    var decoFin = BoxDecoration(
        color: darken(pd.color, 0),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(height / 2),
            bottomRight: Radius.circular(height / 2)));

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
                    child: Container(
                        height: height,
                        //color: darken(pd.color, 0),
                        decoration: decoIni)),
                Expanded(
                    flex: pd.total - pd.done,
                    child: Container(
                        height: height,
                        //color: lighten(pd.color, .3),
                        decoration: decoFin)),
              ],
            ),
            Center(
              child: Text(
                resto,
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

  Widget _buildReloj(BuildContext context, String value, int iParpadeo) {
    final _ = RelojController.to;

    var sFactor = _.scales[_.scale.value];
    var font = _.fonts[_.font.value];
    var color = _.colores[_.color.value];

    var fStyle = Theme.of(context).textTheme.bodyText1!.copyWith(color: color);
    var fStyleDots = fStyle.copyWith(
        color: _.light
            ? color
            : _.color.value == 0
                ? darken(color, .2)
                : lighten(color, .2));

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iParpadeo > 0)
            Text(value.substring(0, iParpadeo),
                style: font(textStyle: fStyle), textScaleFactor: sFactor),
          if (iParpadeo > -1)
            Text(value.substring(iParpadeo, iParpadeo + 1),
                style: font(textStyle: fStyleDots), textScaleFactor: sFactor),
          Text(value.substring(iParpadeo + 1),
              style: font(textStyle: fStyle),
              textScaleFactor: sFactor,
              overflow: TextOverflow.clip),
        ],
      ),
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

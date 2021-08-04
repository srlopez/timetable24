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
    print(pd.value.visible);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backwardsCompatibility: false,
          systemOverlayStyle:
              SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black),
          //foregroundColor: Colors.red,
          //toolbarTextStyle: TextStyle(color: Colors.red),
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
                    // TEXTO CENTRAL: HORA/COUNTDOWN
                    Expanded(
                      child: Obx(() {
                        final textoModo = _.modeTexts[_.mode.value];
                        final iTicTac =
                            // Dos punto / Signo menos
                            !pd.value.visible || _.mode.value == 0 ? 2 : 0;
                        return _buildReloj(context, textoModo, iTicTac);
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
        ));
  }

  Widget _buildBotoneraFormato() {
    final _ = RelojController.to;

    final pd = _.progresoData;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Obx(() => Simple(_.fontName(_.fonts[_.font.value]))),
            Spacer(),
            if (pd.value.visible) ...[
              Obx(() => Simple(
                  [
                    Icons.notifications_off,
                    Icons.notifications_on
                  ][_.alarm.value],
                  onPressed: _.setAlarm)),
              Obx(() => Simple([_.formatResto(25, 10), '12:00'][_.mode.value],
                  onPressed: _.nextMode)),
            ],
            Obx(() => Simple('⬤', //'⓰'
                onPressed: _.nextColor,
                color: _.colores[(_.color.value + 1) % _.colores.length])),
            Simple('▼|▲', onPressed: _.nextScale),
            Simple('ℱont', onPressed: _.nextFont),
            Simple(Icons.power_settings_new, onPressed: Get.back)
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
    var textoCentral = [_.modeTexts[1], _.modeTexts[0]][_.mode.value];

    var done = pd.done * 60 + int.parse(_.currentHMS[2]);
    var notdone = (pd.total - pd.done) * 60 - int.parse(_.currentHMS[2]);

    var decoProgressBar = BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(height / 2),
        bottomLeft: Radius.circular(height / 2),
        topRight: Radius.circular(height / 2),
        bottomRight: Radius.circular(height / 2),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      //textBaseline: TextBaseline.alphabetic,
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
            Container(
              decoration: decoProgressBar,
              height: height,
              clipBehavior: Clip.hardEdge,
              child: Row(
                children: [
                  Expanded(
                    flex: done,
                    child: Container(color: darken(pd.color, 0)),
                  ),
                  Expanded(
                    flex: notdone,
                    child: Container(color: lighten(pd.color, .3)),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                textoCentral,
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

  Widget _buildReloj(BuildContext context, String value, int iTicTac) {
    final _ = RelojController.to;

    var sFactor = _.scales[_.scale.value];
    var font = _.fonts[_.font.value];
    var color = _.colores[_.color.value];

    var fStyle = Theme.of(context).textTheme.bodyText1!.copyWith(color: color);
    var fStyleDots = fStyle.copyWith(
        color: _.tictac
            ? color
            : _.color.value == 0
                ? darken(color, .2)
                : lighten(color, .2));

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.end,
        // textBaseline: TextBaseline.ideographic,
        children: [
          if (iTicTac > 0)
            Text(value.substring(0, iTicTac),
                style: font(textStyle: fStyle), textScaleFactor: sFactor),
          if (iTicTac > -1)
            Text(value.substring(iTicTac, iTicTac + 1),
                style: font(textStyle: fStyleDots), textScaleFactor: sFactor),
          Text(value.substring(iTicTac + 1),
              style: font(textStyle: fStyle),
              textScaleFactor: sFactor,
              overflow: TextOverflow.clip),
        ],
      ),
    );
  }
}

class Simple extends StatelessWidget {
  final void Function()? onPressed;
  final dynamic data;
  final Color? color;

  const Simple(this.data, {this.onPressed, this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return data is IconData
        ? IconButton(
            onPressed: onPressed ?? () {},
            icon: Icon(data),
            iconSize: 16,
            color: color ?? Colors.grey)
        : TextButton(
            onPressed: onPressed ?? () {},
            child: Text(
              data,
              style: TextStyle(color: color ?? Colors.grey),
            ));
  }
}

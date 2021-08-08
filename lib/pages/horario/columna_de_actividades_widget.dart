import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global/app_controller.dart';
import '../../global/app_utils.dart';
import '../../global/app_ctes/horario.dart' as Horario;
import '../../models/actividad.dart';
import '../../models/evento.dart';
import 'horario_controller.dart';

class ActividadesColumn extends StatelessWidget {
  const ActividadesColumn({
    required this.dia,
    required this.tipoDia,
    required this.esHoy, // tru/false
    required this.esHoyActivo, // tru/false
    Key? key,
  }) : super(key: key);

  final int dia; // 0-Lunes..4-viernes
  final List<Categoria> tipoDia;
  final bool esHoy; // true/false
  final bool esHoyActivo; // true/false

  @override
  Widget build(BuildContext context) {
    final _ = HorarioController.to;
    final app = AppController.to;

    var acts = app.actividades[dia];
    var aumentar = _.aumentarActividad;
    var reducir = _.reducirActividad;
    var cambiar = _.cambiarActividad;
    var destruir = _.destruirActividad;
    var establecer = _.establecerActividad;
    // var activar = _.activar;
    // var desactivar = _.desactivar;

    return GetBuilder<HorarioController>(
        builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Horario.altoAjusteActividades),
                ...[for (var i = 0; i < acts.length; i += 1) i].map(
                  (i) {
                    var actividad = ActividadContainer(
                      actividad: acts[i],
                      index: i,
                      tipoDia: tipoDia,
                      esHoy: esHoy,
                      esHoyActivo: esHoyActivo,
                      altoMinuto:
                          getActividadesHeight(context) / app.minutosTotales,
                    );

                    return Expanded(
                      flex: acts[i].minutos,
                      child: !esHoyActivo
                          ? actividad
                          : GestureDetector(
                              child: actividad,
                              //onTap: (() => cambiar(acts[i])),
                              onDoubleTap: () async {
                                if (!acts[i].activo) {
                                  // onTap: Activamos
                                  cambiar(acts[i]);
                                  return;
                                }
                                var result = await Get.toNamed(
                                  '/actividad',
                                  arguments: acts[i],
                                );
                                if (result != null) establecer(acts[i], result);
                              },
                              onLongPress: (() => destruir(acts[i])),
                              onVerticalDragEnd: ((DragEndDetails details) {
                                var pxs = details.velocity.pixelsPerSecond;
                                if (pxs.dy > 0) aumentar(acts, i);
                                if (pxs.dy < 0) reducir(acts, i);
                              }),
                            ),
                    );
                  },
                ),
                SizedBox(height: Horario.altoAjusteActividades)
              ],
            ));
  }
}

class ActividadContainer extends StatelessWidget {
  const ActividadContainer({
    required this.actividad,
    required this.index,
    required this.tipoDia,
    required this.esHoy, // true/false
    required this.esHoyActivo, // tru/false
    required this.altoMinuto,
    Key? key,
  }) : super(key: key);

  final Actividad actividad;
  final int index;
  final List<Categoria> tipoDia;
  final bool esHoy; // true/false
  final bool esHoyActivo; // true/false
  final double altoMinuto; // altura aprox de un minuto

  @override
  Widget build(BuildContext context) {
    var colorActividad =
        actividad.activo ? actividad.color : Theme.of(context).cardColor;
    var colorText = highlightColor(colorActividad);

    if (!esHoyActivo) {
      colorActividad = actividad.activo
          ? darken(Theme.of(context).cardColor, .1)
          : Theme.of(context).canvasColor;
      colorText = Theme.of(context).primaryColor;
    }
    //CtesAgenda.agendaColors[tipoDia.first.index]

    var tituloWidget = Text('${actividad.titulo}',
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: TextStyle(
          fontSize: 15.0,
          color: colorText,
          fontWeight: FontWeight.bold,
        ));

    var subtituloWidget = actividad.subtitulo != ''
        ? Text(
            '${actividad.subtitulo}',
            overflow: TextOverflow.clip,
            maxLines: 1,
            style: TextStyle(color: colorText),
          )
        : Container();

    var pieWidget = actividad.pie != ''
        ? Text(
            '${actividad.pie}',
            overflow: TextOverflow.clip,
            maxLines: 1,
            style: TextStyle(fontSize: 10.0, color: colorText),
          )
        : Container();
    // trazas :::actividad.minutos * altoMinuto > 70
    // var am = actividad.minutos * altoMinuto;
    // var m = actividad.minutos;
    // var a = altoMinuto;
    // var d = actividad.dia;
    // var i = index;
    // trazas
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
      child: Container(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
          decoration: BoxDecoration(
            color: colorActividad,
            shape: BoxShape.rectangle,
            border: Border.all(
              width: 0.4,
              color: Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          child: actividad.minutos * altoMinuto > Horario.maxAltoActividad
              ? Column(
                  // mainAxisAlignment: MainAxisAlignment.,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      tituloWidget,
                      subtituloWidget,
                      Spacer(),
                      pieWidget,
                    ])
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      tituloWidget,
                      subtituloWidget,
                      pieWidget,
                    ],
                  ),
                )
          // : Wrap(
          //     direction: Axis.horizontal,
          //     alignment: WrapAlignment.center,
          //     crossAxisAlignment: WrapCrossAlignment.center,
          //     children: [
          //       tituloWidget,
          //       subtituloWidget,
          //       pieWidget,
          //     ],
          //   ),
          ),
    );
  }
}

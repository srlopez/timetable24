import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable24/models/marca_horaria.dart';

import '../../global/app_controller.dart';
import '../../global/app_ctes/horario.dart' as Horario;

import 'marcas_controller.dart';
import 'widgets/marcas_column.dart';

class MarcasPage extends StatelessWidget {
  MarcasPage({Key? key}) : super(key: key);
  final app = AppController.to;
  final _ = MarcasController.to;

  @override
  Widget build(BuildContext context) {
    // Recogemos las marcas del Controlador global
    _.setMarcas(app.marcasHorarias.value);
    // Establecemos las variables y funciones desde el controlador
    var marcas = _.marcas;
    var limSup = _.mSuperior;
    var limInf = _.mInferior;
    // Preparamos las funciones que vamos aa usar desde la interfaz
    limSupUp() => _.onUpdateMSuperior(-1);
    limSupDown() => _.onUpdateMSuperior(1);
    limInfUp() => _.onUpdateMInferior(1);
    limInfDown() => _.onUpdateMInferior(-1);
    marcarMarca(int h, int m) => _.turnarMarca(_.marcas, h, m);
    bool marcaActiva(int h, int m) => _.esMarcaActiva(_.marcas, h, m);

    return Scaffold(
      appBar: AppBar(title: Text('Editor de Marcas Horarias')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Exposición de los Segmentos
            _buildPreviewSegmentosHorarios(marcas),
            Divider(height: 15, thickness: 1, indent: 20, endIndent: 20),
            // Botonera de horas/minutos
            BotoneraDeMinutos(limSup, limInf, marcarMarca, marcaActiva),
            // Botonera de expansion/contracción
            _buildBotoneraDeLimites(limSupUp, limSupDown, limInfUp, limInfDown),
            // Aceptar y Clear
            _buildBotoneraAceptar(_.onPressedAceptar),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSegmentosHorarios(
    RxList<Marca> marcasHorarias,
  ) {
    return Obx(
      () => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 15),
            ColumnaDeMarcas(marcas: marcasHorarias.value),
            SizedBox(width: 5),
            ColumnaDeEspacios(marcas: marcasHorarias.value),
            SizedBox(width: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoneraDeLimites(
      void Function() limSupUp,
      void Function() limSupDown,
      void Function() limInfUp,
      void Function() limInfDown) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBotonDeLimites(Icons.arrow_upward, limSupUp),
            _buildBotonDeLimites(Icons.arrow_downward, limInfUp),
            Icon(Icons.expand, color: Colors.grey.shade400),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compress, color: Colors.grey.shade400),
            _buildBotonDeLimites(Icons.arrow_downward, limSupDown),
            _buildBotonDeLimites(Icons.arrow_upward, limInfDown),
          ],
        ),
      ],
    );
  }

  Widget _buildBotonDeLimites(IconData icon, Function onPress) {
    return RawMaterialButton(
      onPressed: () {
        onPress();
      },
      constraints: BoxConstraints(),
      elevation: 2.0,
      fillColor: Colors.white,
      child: Row(
        children: [
          Icon(icon, size: 25.0, color: Colors.black54),
        ],
      ),
      padding: EdgeInsets.all(5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    );
  }

  Widget _buildBotoneraAceptar(void Function() onAceptar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: onAceptar,
          child: Text('Aceptar'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: false),
          child: Text('Cancelar'),
        )
      ],
    );
  }
}

class BotoneraDeMinutos extends GetView<MarcasController> {
  final Rx<Marca> limSup;
  final Rx<Marca> limInf;
  final void Function(int h, int m) marcarMarca;
  final bool Function(int h, int m) marcaActiva;

  const BotoneraDeMinutos(
      this.limSup, this.limInf, this.marcarMarca, this.marcaActiva,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            ...[
              for (var i = limSup.value.inHours;
                  i <= limInf.value.inHours;
                  i += 1)
                i
            ].map(
              (h) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //direction: Axis.horizontal,
                children: [
                  _buildTextDeHoras(h),
                  ...[for (var i = 0; i < 60; i += 5) i].map(
                    (m) => GestureDetector(
                      onTap: () {
                        marcarMarca(h, m);
                      },
                      child:
                          _buildBotonDeMinutos(context, m, marcaActiva(h, m)),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _buildTextDeHoras(int h) {
    return Container(
      width: 25,
      child: Text(
        '$h:',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      //color: Colors.red
    );
  }

  Widget _buildBotonDeMinutos(
      BuildContext context, int minuto, bool? selected) {
    bool active = selected ?? false;
    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).accentColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Text(
          '  ${minuto.toString().padLeft(2, "0")}  ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active
                ? Theme.of(context).cardColor
                : Theme.of(context).accentColor,
          ),
        ),
      );
    });
  }
}

class ColumnaDeEspacios extends StatelessWidget {
  const ColumnaDeEspacios({
    required this.marcas,
    Key? key,
  }) : super(key: key);

  final marcas;
  List<int> getEspacios(List<Marca> marcas) {
    List<int> patron = [];
    for (int m = 1; m < marcas.length; m++)
      patron.add(marcas[m].diff(marcas[m - 1]));
    return patron;
  }

  // Marca add1Min(Marca marca, bool positive) {
  //   int h = marca.inHours;
  //   int m = marca.inMinutes;
  //   if (m == 0 && !positive) return Marca(h--, 59);
  //   if (!positive) return Marca(h, m--);
  //   if (m == 0 && positive) return Marca(h, m++);
  //   return Marca(h++, 1);
  // }

  @override
  Widget build(BuildContext context) {
    final _ = Get.find<MarcasController>();

    var espacios = getEspacios(marcas);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: Horario.altoAjusteActividades),
          ...[for (var i = 0; i < espacios.length; i++) i].map((index) {
            int altoEnMinutos = marcas[index + 1].diff(marcas[index]);

            return Expanded(
              flex: altoEnMinutos,
              child: Container(
                //color: Colors.transparent,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).accentColor, width: .5),
                  // border: Border(
                  //   top: BorderSide(color: Theme.of(context).disabledColor),
                  //   bottom: BorderSide(color: Theme.of(context).accentColor),
                  // ),
                ),
                //alignment: FractionalOffset.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //TextButton(onPressed: () {}, child: Text('-')),
                    Center(child: Text("$altoEnMinutos min.")),
                    //TextButton(onPressed: () {}, child: Text('+')),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: Horario.altoAjusteActividades)
        ],
      ),
    );
  }
}

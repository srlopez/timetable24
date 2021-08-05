import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import '../../../models/marca_horaria.dart';
import '../../../global/app_ctes/horario.dart' as Horario;

class ColumnaDeMarcasHorarias extends StatelessWidget {
  const ColumnaDeMarcasHorarias({
    required this.marcas,
    Key? key,
  }) : super(key: key);
  final List<Marca> marcas;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        // Linea de Hora
        ColumnaDeReloj(marcas: marcas),
        // Marcas Horarias
        ColumnaDeMarcas(marcas: marcas),
      ],
    );
  }
}

class ColumnaDeReloj extends StatelessWidget {
  const ColumnaDeReloj({
    Key? key,
    required this.marcas,
  }) : super(key: key);

  final List<Marca> marcas;

  @override
  Widget build(BuildContext context) {
    int getMinutos(List<Marca> marcas) {
      int minutos = 0;
      for (int m = 1; m < marcas.length; m++)
        minutos += marcas[m].diff(marcas[m - 1]);
      return minutos;
    }

    return TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
      var ahora = DateTime.now();
      var inicial = marcas[0];
      var actual = Marca(ahora.hour, ahora.minute);
      var total = getMinutos(marcas);
      var diff = actual.diff(inicial);
      var color = Colors.blue.shade400;
      var size = 17.0;
      final radio = Radius.circular(size / 2);
      var visible = (diff >= 0 && diff <= total);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Horario.altoAjusteActividades),
          Expanded(
              flex: diff,
              child: Container(
                alignment: FractionalOffset.bottomLeft,
                child: visible
                    ? Container(
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: new BorderRadius.only(
                              topLeft: radio,
                              topRight: radio,
                              bottomLeft: radio,
                            )),
                        height: size,
                        width: size,
                        padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                        alignment: Alignment.center,
                        child:
                            Text(ahora.minute.toString(), textScaleFactor: .8),
                      )
                    : Container(),
              )),
          if (visible)
            Divider(
              height: 2,
              color: color,
              indent: size / 2,
            ),
          Expanded(flex: total - diff, child: Container()),
          SizedBox(height: Horario.altoAjusteActividades)
        ],
      );
    });
  }
}

class ColumnaDeMarcas extends StatelessWidget {
  const ColumnaDeMarcas({
    Key? key,
    required this.marcas,
  }) : super(key: key);

  final List<Marca> marcas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...[for (var i = 0; i < marcas.length; i += 1) i].map((index) {
          int altoEnMinutos =
              index == 0 ? 0 : marcas[index].diff(marcas[index - 1]);
          return Expanded(
            flex: altoEnMinutos,
            child: Container(
              //color: Colors.transparent,
              alignment: FractionalOffset.bottomRight,
              child: Text("${marcas[index]} "),
            ),
          );
        })
      ],
    );
  }
}

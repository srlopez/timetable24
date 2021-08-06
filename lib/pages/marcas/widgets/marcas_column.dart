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
      var hora = ahora.hour.toString();
      var minute = '0' + ahora.minute.toString();
      minute = minute.substring(minute.length - 2);
      var inicial = marcas[0];
      var actual = Marca(ahora.hour, ahora.minute);
      var total = getMinutos(marcas);
      var diff = actual.diff(inicial);
      var color = Colors.blue.shade400;
      var size = 12.0;
      var visible = (diff >= 0 && diff <= total);
      var tStyle = TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: size,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Horario.altoAjusteActividades),
          Expanded(
              flex: diff,
              child: Container(
                alignment: FractionalOffset.bottomLeft,
                child: visible
                    ? RotatedBox(
                        quarterTurns: -1,
                        // decoration: BoxDecoration(
                        //     color: color,
                        //     borderRadius: new BorderRadius.only(
                        //       topLeft: radio,
                        //       topRight: radio,
                        //       bottomLeft: radio,
                        //     )),
                        // height: size,
                        // width: size,
                        // padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                        // alignment: Alignment.center,
                        child: Text(minute, style: tStyle),
                      )
                    : null,
              )),
          if (visible)
            Stack(
              children: [
                Divider(
                  height: 3,
                  color: color,
                  indent: size * 1.2,
                ),
                RotatedBox(quarterTurns: -1, child: Text(':', style: tStyle)),
              ],
            ),
          Expanded(
            flex: total - diff,
            child: Container(
              alignment: FractionalOffset.topLeft,
              child: visible
                  ? RotatedBox(
                      quarterTurns: -1, child: Text(hora, style: tStyle))
                  : null,
            ),
          ),
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

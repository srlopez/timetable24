import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:timetable24/global/app_themes.dart';
import 'package:timetable24/global/app_utils.dart';
import '../../models/marca_horaria.dart';
import '../../global/app_controller.dart';
import 'marcas_editor_controller2.dart';
import '../../../global/app_ctes/horario.dart' as Horario;

class MarcasEditorPage2 extends StatelessWidget {
  MarcasEditorPage2({Key? key}) : super(key: key);
  final app = AppController.to;
  final _ = MarcasEditorController2.to;

  @override
  Widget build(BuildContext context) {
    // Recogemos las marcas del Controlador global
    _.setMarcas(app.marcasHorarias);
    // Establecemos las variables y funciones desde el controlador
    var marcas = _.marcas;

    return Scaffold(
      appBar: AppBar(title: Text('Editor de Marcas Horarias')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildPreviewSegmentosHorarios(marcas),
            Divider(height: 15, thickness: 1, indent: 20, endIndent: 20),

            // Aceptar y Clear
            _buildBotoneraAceptar(_.onPressedAceptar),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSegmentosHorarios(RxList<Marca> marcasHorarias) {
    Widget _buildMarcaText(idx) => CircularButton(
          "${marcasHorarias[idx]} ",
          onPressed: () => _.onMarcaSelected(idx),
          color: _.selectedIdx == idx ? Colors.amber : null,
          alignment: FractionalOffset.bottomRight,
        );
    Widget _buildDeleteMarcaButton(idx) {
      return CircularButton(
        '×', //Icons.delete,
        onPressed: () {
          if (marcasHorarias.length > 2) _.onDeleteMarca(idx);
        },
        color: marcasHorarias.length > 2
            ? Colors.red.shade600
            : Colors.grey.shade600,
        alignment: FractionalOffset.bottomRight,
      );
    }

    Widget _buildAddMarcaButton(idx) {
      var esUltimo = idx == _.marcas.length - 1;
      var minutes = 0;
      if (!esUltimo) minutes = _.marcas[idx + 1].diff(_.marcas[idx]);
      return !esUltimo
          ? CircularButton(
              '+',
              onPressed: () => _.onNewMarca(idx, minutes ~/ 2),
              color: Colors.green.shade600,
              //alignment: Alignment.center
            )
          : Container();
    }

    return Obx(
      () {
        var hora = marcasHorarias[_.selectedIdx.value].horas;
        var prevHora = to00(hora == 0 ? 23 : hora - 1);
        var nextHora = to00(hora == 23 ? 0 : hora + 1);
        var min = marcasHorarias[_.selectedIdx.value].minutos;
        var prevMin = to00(min == 0 ? 59 : min - 1);
        var nextMin = to00(min == 59 ? 0 : min + 1);

        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 15),
              ColumnaDeMarcas(
                  marcas: marcasHorarias.value,
                  buildWidget: _buildDeleteMarcaButton),
              SizedBox(width: 5),
              ColumnaDeMarcas(
                  marcas: marcasHorarias.value, buildWidget: _buildMarcaText),
              SizedBox(width: 5),
              ColumnaDeMarcas(
                  marcas: marcasHorarias.value,
                  buildWidget: _buildAddMarcaButton),
              SizedBox(
                width: 15,
              ),
              ColumnaDeEspacios(marcas: marcasHorarias.value),
              Container(
                  alignment: Alignment.center,
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SwipeDetectorExample(
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(
                              nextHora,
                              textScaleFactor: 1.8,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              to00(hora),
                              textScaleFactor: 3,
                              style: TextStyle(color: Colors.amber),
                            ),
                            Text(
                              prevHora,
                              textScaleFactor: 1.8,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                          ],
                        ),
                        onSwipeDown: () =>
                            _.onUpdateMarca(_.selectedIdx.value, 60),
                        onSwipeUp: () =>
                            _.onUpdateMarca(_.selectedIdx.value, -60),
                      ),
                      Text(
                        ' : ',
                        textScaleFactor: 3,
                        style: TextStyle(color: Colors.amber),
                      ),
                      SwipeDetectorExample(
                        child: Column(
                          children: [
                            Spacer(),
                            Text(
                              nextMin,
                              textScaleFactor: 1.8,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              to00(min),
                              textScaleFactor: 3,
                              style: TextStyle(color: Colors.amber),
                            ),
                            Text(
                              prevMin,
                              textScaleFactor: 1.8,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                          ],
                        ),
                        onSwipeDown: () =>
                            _.onUpdateMarca(_.selectedIdx.value, 1),
                        onSwipeUp: () =>
                            _.onUpdateMarca(_.selectedIdx.value, -1),
                      ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBotoneraAceptar(void Function() onAceptar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancelar'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(cancelColor),
            )),
        ElevatedButton(
          onPressed: onAceptar,
          child: Text('Aceptar'),
        ),
      ],
    );
  }
}

class ColumnaDeMarcas extends StatelessWidget {
  const ColumnaDeMarcas({
    Key? key,
    required this.marcas,
    required this.buildWidget,
  }) : super(key: key);

  final List<Marca> marcas;
  final Widget Function(int) buildWidget;

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
              child: buildWidget(index),
            ),
          );
        })
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    final _ = Get.find<MarcasEditorController2>();

    var espacios = getEspacios(marcas);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: Horario.altoAjusteActividades),
          ...[for (var i = 0; i < espacios.length; i++) i].map((index) {
            int altoEnMinutos = marcas[index + 1].diff(marcas[index]);
            var border = index == espacios.length - 1
                ? Border(
                    top: BorderSide(
                        color: _.selectedIdx.value == index
                            ? Colors.amber
                            : Theme.of(context).disabledColor),
                    bottom: BorderSide(
                        color: _.selectedIdx.value == espacios.length
                            ? Colors.amber
                            : Theme.of(context).disabledColor),
                  )
                : Border(
                    top: BorderSide(
                        color: _.selectedIdx.value == index
                            ? Colors.amber
                            : Theme.of(context).disabledColor),
                  );
            return Expanded(
                flex: altoEnMinutos,
                child: Container(
                  decoration: BoxDecoration(
                    // border: Border.all(
                    //     color: Theme.of(context).accentColor, width: .5),
                    border: border,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$altoEnMinutos min",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ));
          }),
          SizedBox(height: Horario.altoAjusteActividades)
        ],
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final void Function()? onPressed;
  final dynamic data;
  final Color? color;
  final AlignmentGeometry? alignment;

  const CircularButton(this.data,
      {this.onPressed, this.color, this.alignment, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed ?? () {},
        child: Container(
          //margin: EdgeInsets.all(4),
          //padding: EdgeInsets.all(3),
          //alignment: alignment ?? Alignment.center,
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   color: color ?? Theme.of(context).accentColor,
          //   //borderRadius: BorderRadius.circular(6),
          // ),
          child: data is IconData
              ? Icon(data,
                  size: 16,
                  color: color ?? Colors.white70) //Theme.of(context).cardColor)
              : Text(
                  ' $data ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color ?? Theme.of(context).accentColor,
                  ),
                ),
        ));
  }
}

class SwipeDetectorExample extends StatefulWidget {
  final Function() onSwipeUp;
  final Function() onSwipeDown;
  final Widget child;

  SwipeDetectorExample(
      {required this.onSwipeUp,
      required this.onSwipeDown,
      required this.child});

  @override
  _SwipeDetectorExampleState createState() => _SwipeDetectorExampleState();
}

class _SwipeDetectorExampleState extends State<SwipeDetectorExample> {
  //Vertical drag details
  DragStartDetails startVerticalDragDetails = DragStartDetails();
  DragUpdateDetails updateVerticalDragDetails =
      DragUpdateDetails(globalPosition: Offset(0, 0));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onVerticalDragStart: (dragDetails) {
          startVerticalDragDetails = dragDetails;
        },
        onVerticalDragUpdate: (dragDetails) {
          updateVerticalDragDetails = dragDetails;
        },
        onVerticalDragEnd: (endDetails) {
          double dx = updateVerticalDragDetails.globalPosition.dx -
              startVerticalDragDetails.globalPosition.dx;
          double dy = updateVerticalDragDetails.globalPosition.dy -
              startVerticalDragDetails.globalPosition.dy;
          double? velocity = endDetails.primaryVelocity;

          //Convert values to be positive
          if (dx < 0) dx = -dx;
          if (dy < 0) dy = -dy;

          if (velocity! < 0) {
            widget.onSwipeUp();
          } else {
            widget.onSwipeDown();
          }
        },
        child: widget.child);
  }
}

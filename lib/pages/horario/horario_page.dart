import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timetable24/global/app_utils.dart';
import '../../models/evento.dart';
import '../marcas/widgets/marcas_column.dart';
import '../../global/app_controller.dart';
import '../../global/app_ctes/horario.dart' as Horario;
import '../../global/app_ctes/agenda.dart' as Agenda;

import 'columna_de_actividades_widget.dart';
import 'horario_controller.dart';

class HorarioPage extends StatelessWidget {
  HorarioPage({
    Key? key,
  }) : super(key: key);

  final _ = HorarioController.to;
  final app = AppController.to;

  @override
  Widget build(BuildContext context) {
    final horarioPageController = PageController(initialPage: _.nPaginaDeHoy());

    return GetBuilder<HorarioController>(
        builder: (_) => Scaffold(
              appBar: _buildAppBar(context, _, app, horarioPageController),
              body: RowLayout(
                horarioPageController: horarioPageController,
              ),
            ));
  }

  AppBar _buildAppBar(
    BuildContext context,
    HorarioController _,
    AppController app,
    PageController horarioPageController,
  ) {
    var menu = ['Marcas horarias', 'Reiniciar actividades', 'Ver reloj'];

    return AppBar(
      backwardsCompatibility: false,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Theme.of(context).canvasColor),
      title: Text(
        '${Horario.nombreMes[_.lunes.month]} ${_.lunes.year}',
        //style: Theme.of(context).textTheme.headline5
      ),
      foregroundColor: Theme.of(context).accentColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.today),
          onPressed: (() {
            horarioPageController.jumpToPage(_.nPaginaDeHoy());
            _.update();
          }),
          //color: Theme.of(context).dividerColor,
        ),
        PopupMenuButton<String>(
          onSelected: ((value) async {
            if (value == menu[0]) await Get.toNamed('/marcas');
            if (value == menu[1]) await app.inicializarActividades();
            if (value == menu[2]) await Get.toNamed('/reloj');
            _.update();
          }),
          itemBuilder: (BuildContext context) {
            return menu.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}

class RowLayout extends StatelessWidget {
  final PageController horarioPageController;

  const RowLayout({
    required this.horarioPageController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = Get.find<HorarioController>();
    final app = Get.find<AppController>();

    return Row(
      children: [
        //COLUMNA DE LA IZQUIERDA
        ColumnLayout(
          width: Horario.anchoIzquierda,
          top: Dummy('#${_.nsemana}'),
          center: ColumnaDeMarcasHorarias(marcas: app.marcasHorarias),
          bottom: Dummy(),
        ),

        //COLUMNA CENTRAL
        Expanded(
          child: PageView.builder(
              controller: horarioPageController,
              onPageChanged: (page) => _.setPagina(page),
              key: const PageStorageKey<String>('Horario'),
              itemCount: 53, // Semanas de un año
              itemBuilder: (context, page) {
                return Row(
                  children: [
                    ...[for (var i = 0; i < 5; i++) i].map(
                      (i) {
                        var fecha = _.lunes.add(Duration(days: i));
                        var esAhora = esHoy(fecha);
                        var esHoyActivo = app.esFechaConActividad(fecha);
                        var categorias = app.getCategorias(fecha);
                        var diaNumber = Text('${fecha.day}',
                            style: Theme.of(context).textTheme.headline6);
                        var diaName =
                            Text('${Horario.nombreDias[fecha.weekday]}');

                        return Flexible(
                            child: ColumnLayout(
                                top: Center(
                                  child: esAhora
                                      ? CircleAvatar(
                                          maxRadius: 20.0,
                                          backgroundColor:
                                              Theme.of(context).dividerColor,
                                          child: diaNumber,
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [diaNumber, diaName],
                                        ),
                                ),
                                center: ActividadesColumn(
                                    dia: i,
                                    tipoDia: categorias,
                                    esHoy: esAhora,
                                    esHoyActivo: esHoyActivo),
                                bottom: DiaFooter(
                                    esHoy: esAhora,
                                    tipoDia: categorias,
                                    esActivo: esHoyActivo)));
                      },
                    ),
                  ],
                );
              }),
        ),

        //COLUMNA DE LA DERECHA
        ColumnLayout(
          width: Horario.anchoDerecha,
          top: Dummy(),
          center: Dummy(),
          bottom: TextButton(
            onPressed: () => Get.toNamed('/reloj'),
            child: Text('   '),
          ),
        )
      ],
    );
  }
}

class ColumnLayout extends StatelessWidget {
  final double? width;
  final Widget top;
  final Widget center;
  final Widget bottom;

  const ColumnLayout({
    this.width,
    required this.top,
    required this.center,
    required this.bottom,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget widgets = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Horario.altoCabecera,
          child: top,
        ),
        Expanded(child: center),
        SizedBox(
          height: Horario.altoPie,
          child: bottom,
        ),
      ],
    );

    if (width == null) return widgets;

    return SizedBox(
      width: width,
      child: widgets,
    );
  }
}

class Dummy extends StatelessWidget {
  final String? text;
  final Color? color;

  Dummy([this.text, this.color]);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Theme.of(context).canvasColor,
      child: Center(
        child: Text(text ?? '', style: Theme.of(context).textTheme.bodyText1),
      ),
    );
  }
}

class DiaFooter extends StatelessWidget {
  const DiaFooter({
    required this.tipoDia,
    required this.esHoy,
    required this.esActivo,
    Key? key,
  }) : super(key: key);

  final List<Categoria> tipoDia;
  final bool esHoy;
  final bool esActivo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 1, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var c = 0; c < tipoDia.length; c++) ...[
            // if (widget.tipoDia[c] == Categoria.Destacado_L1 ||
            //     widget.tipoDia[c] ==
            //         Categoria.Personal_NL1) //PERSONAL Y DESTACADO
            Container(
              padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
              width: double.infinity,
              height: 7,
              color: Agenda.colors[tipoDia[c].index],
              //child: Text('${tipoDia[c].index}'),
            ),
          ],
        ],
      ),
    );
  }
}

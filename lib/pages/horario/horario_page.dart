import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timetable24/global/app_themes.dart';
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
    var menu = [
      'Marcas horarias ·5m',
      'Marcas horarias FineTunning',
      'Establecer huecos en marcas',
    ];
    var menuIcon = [Icons.edit, Icons.edit, Icons.restart_alt];
    var brightness = MediaQuery.of(context).platformBrightness;

    return AppBar(
      backwardsCompatibility: false,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Theme.of(context).canvasColor)
          : SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Theme.of(context).canvasColor),
      foregroundColor: Theme.of(context).accentColor,
      title: Text(
        //'${app.horarios[app.horario.value]}${_.nsemana} - ${Horario.nombreMes[_.lunes.month]} ${_.lunes.year}',
        '${Horario.nombreMes[_.lunes.month]} ${_.lunes.year}',
      ),
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
          itemBuilder: (BuildContext context) {
            return [
              for (var i = 0; i < menu.length; i++) ...[
                PopupMenuItem<String>(
                  value: menu[i],
                  child: Row(children: [
                    Icon(menuIcon[i]),
                    Text('   ' + menu[i]),
                  ]),
                ),
              ],
              //PopupMenuItem(child: Divider(), enabled: false),
              PopupMenuItem(
                child: Column(
                  children: [
                    Text('\nHorario',
                        style: Theme.of(context).textTheme.subtitle2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < app.horarios.length; i++) ...[
                          Text(app.horarios[i]),
                          Radio(
                              groupValue: app.horario.value,
                              value: i,
                              onChanged: (value) async {
                                await app.setHorario(value as int);
                                _.update();
                                Navigator.pop(context); //Cierra el menu
                              })
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
          onSelected: ((value) async {
            if (value == menu[0]) await Get.toNamed('/marcas');
            if (value == menu[1]) await Get.toNamed('/marcaseditor');
            if (value == menu[2]) {
              bool inicializar = await Get.defaultDialog(
                title: "Reiniciar Actividades",
                middleText:
                    "¿Entiendes que esta acción va a eliminar las Actividades de este Horario, y creará nuevos huecos en las Marcas establecidas?",
                // content: Column(
                //   children: [
                //     Text("Your content goes here widget"),
                //     Text("Your content goes here widget"),
                //     Text("Your content goes here widget"),
                //     Text("Your content goes here widget"),
                //   ],
                // ),
                barrierDismissible: false,
                radius: 20.0,
                // onConfirm: () => Get.back(result: true),
                // onCancel: () => Get.back(result: false),

                confirm: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    child: Text("Entendido")),
                cancel: ElevatedButton(
                    onPressed: () => Get.back(result: false),
                    child: Text("Cancelar"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(cancelColor),
                    )),
              );
              if (inicializar) await app.inicializarActividades();
            }

            _.update();
          }),
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
          top: Dummy(), //'${app.horarios[app.horario.value]}\n#${_.nsemana}'),
          center: ColumnaDeMarcasHorarias(marcas: app.marcasHorarias.value),
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
        child: Text(
          text ?? '',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
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

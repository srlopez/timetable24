import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../global/app_utils.dart';
import '../../models/evento.dart';
import '../../global/app_ctes/agenda.dart' as Agenda;
import '../../global/app_ctes/horario.dart' as Horario;
import 'agenda_controller.dart';

var backColores = [];

late GlobalKey semanaActualKey;

class AgendaPage extends StatelessWidget {
  const AgendaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = AgendaController.to;
    final _scrollController = ScrollController();

    backColores = [
      Theme.of(context).canvasColor,
      darken(Theme.of(context).canvasColor),
    ];
    var lunesHoy = lunesDeHoy();
    semanaActualKey = new GlobalKey();

    return Scaffold(
      appBar: _buildAppBar(context, _),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: GetBuilder<AgendaController>(
                builder: (_) {
                  var keys = _.weeksView.keys.toList();
                  /*
                  https://stackoverflow.com/questions/49153087/flutter-scrolling-to-a-widget-in-listview
                  Hemos sustituido ListView.builder por SingleChildScrollView+Column
                  
                  ya que es un lista pequeña y poder hacer el "Goto Esta semana"
                                  Scrollable.ensureVisible(semanaActualKey.currentContext ?? context)),

                  */
                  //var weeks = 0;
                  // return ListView.builder(
                  //     key: PageStorageKey<String>('calendario'),
                  //     controller: _scrollController,
                  //     itemCount: _.weeksView.keys.length,
                  //     itemBuilder: (context, idx) {
                  //       var onDelete = _.delete;
                  //       var onEdited = _.edited;
                  //       var lunes = keys[idx];
                  //       var nsemana = nSemandaDe(lunes);

                  //       return WidgetSemana(
                  //         semana: nsemana,
                  //         lunes: lunes,
                  //         actual: lunes == lunesHoy,
                  //         dias: _.weeksView[lunes]!,
                  //         onDelete: onDelete,
                  //         onEdited: onEdited,
                  //         key: lunes == lunesHoy ? dataKey : Key('$nsemana'),
                  //       );
                  //     });
                  return SingleChildScrollView(
                    key: PageStorageKey<String>('calendario'),
                    controller: _scrollController,
                    child: Column(
                      children: [
                        ...[for (var i = 0; i < keys.length; i++) i].map((i) {
                          var lunes = keys[i];
                          var nsemana = nSemandaDe(lunes);
                          return WidgetSemana(
                            semana: nSemandaDe(lunes),
                            lunes: lunes,
                            actual: lunes == lunesHoy,
                            dias: _.weeksView[lunes]!,
                            onDelete: _.delete,
                            onEdited: _.edited,
                            key: lunes == lunesHoy
                                ? semanaActualKey
                                : Key('$nsemana'),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ), //Obx
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          var nuevo = Evento(
            fInicio: DateTime.now(),
            titulo: '',
          );
          var result = await Get.toNamed('/evento',
              arguments: nuevo, preventDuplicates: true);
          if (result != null) {
            _.add(result);
            _.update();
          }
        },
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    AgendaController _,
  ) =>
      AppBar(
        backwardsCompatibility: false,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Theme.of(context).canvasColor),
        title: Text('Agenda ${cursoEscolar()}'),
        foregroundColor: Theme.of(context).accentColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.today),
            onPressed: (() => Scrollable.ensureVisible(
                semanaActualKey.currentContext ?? context)),
            //color: Theme.of(context).dividerColor,
          ),
          PopupMenuButton<String>(
            onSelected: ((value) async {
              //if (value == 'Reload') _.inicializarItems();
              if (value == 'Inicializar') _.deleteAll();
              //if (value == 'Ver reloj') await Get.toNamed('/reloj');

              _.update();
            }),
            itemBuilder: (BuildContext context) {
              return {'Inicializar'}.map((String choice) {
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

class WidgetSemana extends StatelessWidget {
  final semana;
  final lunes;
  final actual;

  final List<List<EventoFecha>> dias;
  final Function(Evento e) onDelete;
  final Function(Evento e, Evento nueva) onEdited;

  const WidgetSemana({
    required int this.semana,
    required DateTime this.lunes,
    required bool this.actual,
    required this.dias,
    required this.onDelete,
    required this.onEdited,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    var bcolor = backColores[lunes.month % 2];
    var luz = lighten(bcolor, .6); //Colors.grey.shade400; //
    var sombra = darken(bcolor, .3); //Colors.grey.shade800; //
    var size = .8;

    TextStyle style(actual) => TextStyle(
          color: actual ? Theme.of(context).accentColor : Colors.grey.shade600,
          fontWeight: actual ? FontWeight.bold : FontWeight.normal,
        );

    var text = '${lunes.day} de ${Horario.nombreMes[lunes.month]}';
    if (actual) text += ' de ${lunes.year}';
    return Container(
      padding: const EdgeInsets.fromLTRB(0, gap, 0, gap), //all(gap),
      decoration: BoxDecoration(
          color: bcolor,
          border: Border(
            top: BorderSide(width: size, color: luz),
            bottom: BorderSide(width: size, color: sombra),
          )
          //color: Theme.of(context).backgroundColor,
          ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: gap * 2),
              Text(text, textScaleFactor: 1.3, style: style(actual)),
              //SizedBox(width: 2),
              Spacer(),
              Text('#$semana', textScaleFactor: 1.3, style: style(false)),
              SizedBox(width: gap * 2),
            ],
          ),
          for (var i = 0; i < dias.length; i++) ...[
            if (dias[i].length > 0)
              WidgetDiaCard(
                eventos: dias[i],
                onDelete: onDelete,
                onEdited: onEdited,
              ),
          ]
        ],
      ),
    );
  }
}

class WidgetDiaCard extends StatelessWidget {
  //final String txt;
  //final semana;
  final List<EventoFecha> eventos;
  final Function(Evento e) onDelete;
  final Function(Evento e, Evento nueva) onEdited;

  const WidgetDiaCard({
    required this.eventos,
    required this.onDelete,
    required this.onEdited,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;

    var fecha = eventos[0].fecha;
    var lunes = lunesDel(fecha);
    var backcolor = lunes.month % 2;
    var esAhora = esHoy(fecha);
    //CtesAgenda.agendaColors[eventos[0].categoria.index]
    TextStyle style(actual) => TextStyle(
          color: actual ? Theme.of(context).accentColor : backColores[1],
          fontWeight: FontWeight.bold,
        );

    return Container(
      color: backColores[backcolor],
      padding: const EdgeInsets.all(gap / 2),
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(gap),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Text('${fecha.day}', textScaleFactor: 1.3),
                  backgroundColor:
                      esAhora ? Theme.of(context).accentColor : backColores[1],
                  foregroundColor: esAhora
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).accentColor,
                ),
                Text('${Horario.nombreDias[fecha.weekday]}',
                    style: style(esAhora)
                    //Theme.of(context).textTheme.subtitle1,
                    )
              ],
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < eventos.length; i++) ...[
                    WidgetDiaItem(
                        event: eventos[i],
                        onDelete: onDelete,
                        onEdited: onEdited),
                  ],
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class WidgetDiaItem extends StatelessWidget {
  const WidgetDiaItem({
    //required this.txt,
    required this.event,
    this.onDelete,
    this.onEdited,
    Key? key,
  }) : super(key: key);

  final EventoFecha event;
  final Function(Evento cnota)? onDelete;
  final Function(Evento cnota, Evento nueva)? onEdited;

  @override
  Widget build(BuildContext context) {
    final _ = Get.find<AgendaController>();
    const gap = 8.0;

    const eventoIcon = [
      Icons.stop_circle_outlined, //play_arrow_rounded not_started
      Icons.circle, //circle_outlined, //Icons.lightbulb_outline_sharp,
      Icons.play_circle_outlined, //arrow_back_ios_new_sharp,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: gap * 3,
          child: Icon(
            eventoIcon[event.evento.index],
            color: Agenda.colors[event.categoria.index],
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(gap / 4),
              //color: colores[event.categoria.index],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Text(txt),
                  Text(
                    event.titulo,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  event.notas != null
                      ? Text(
                          event.notas!,
                          maxLines: 3,
                          style: Theme.of(context).textTheme.bodyText2,
                        )
                      : Container(),
                ],
              ),
            ),
            onTap: () async {
              var result = await Get.toNamed(
                '/evento',
                arguments: event.entity,
                //parameters: {'key': 'value'},
                preventDuplicates: true,
              );
              if (result != null) onEdited!(event.entity, result);
            },
          ),
        ),
        SizedBox(
          width: gap * 3,
          child: TextButton(
            child: Text('X'),
            onPressed: () => onDelete!(event.entity),
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all(Theme.of(context).dividerColor)),
          ),
        ),
      ],
    );
  }
}

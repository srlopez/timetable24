import 'dart:collection';

import 'package:get/get.dart';

import 'package:timetable24/global/app_controller.dart';
import 'package:timetable24/global/app_utils.dart';
import 'package:timetable24/models/evento.dart';

class AgendaController extends GetxController {
  AppController app;
  AgendaController({required this.app});
  static AgendaController get to => Get.find<AgendaController>();

  // Modelo de Eventos
  late List<Evento> eventos;
  // Desglose de Eventos en Inicio/Fin/Normal
  var eItems = <EventoFecha>[];
  // Lista de Semanas, con lista de Dias y Lista de eItmes
  var weeksView = SplayTreeMap<DateTime, List<List<EventoFecha>>>();

  @override
  Future<void> onInit() async {
    super.onInit();
    eventos = app.eventos;
    //getAll('onInit');
    inicializarItems();
  }

  // void getAll(String txt) {
  //   if (app.isDoneEventos.value) {
  //     _establecerItems();
  //     return;
  //   }

  //   isLoadingAgenda.value = true;
  //   eventos.clear();

  //   var stream = db.getStream();
  //   stream.listen((item) {
  //     eventos.add(item);
  //   }).onDone(() {
  //     print('getAll $txt onDone ${eventos.length}');
  //     _establecerItems();
  //   });
  // }

  inicializarItems() {
    _createWeekView();
    _createItems();
    _addItemsToWeekView();

    //
    update();
  }

  _createItems() {
    // Creacion de los Items
    eItems.clear();

    eventos.forEach((e) {
      if (!e.esPeriodo)
        eItems.add(EventoFecha.fromEvento(e));
      else {
        eItems.add(EventoFecha.fromInicio(e));
        eItems.add(EventoFecha.fromFinal(e));
      }
    });
  }

  _addItemsToWeekView() {
    //Creacion del modelo de vista
    eItems.forEach((item) {
      _addItemsToWeekDIaView(
          lunesDel(item.fecha), item.fecha.weekday - 1, item);
    });
  }

  _addItemsToWeekDIaView(DateTime monday, int weekday, EventoFecha item) {
    weeksView[monday]![weekday].add(item);
    weeksView[monday]![weekday].sort();
  }

  _createWeekView() {
    var anoInicial = anoEscolar();
    var sept1 = DateTime(anoInicial + 1, 9, 1);

    var lunes = fechaLunesDel1Sept(); //Minimo inicio
    //
    weeksView.clear();
    // Añadir Semanas
    while (sept1.difference(lunes).inDays > 0) {
      weeksView[lunes] = [
        [], // lunes
        [], // martes ...
        [],
        [],
        [],
        [],
        []
      ];
      lunes = lunes.addCalendarDays(7);
      assert(lunes.weekday == 1);
    }
  }

  add(Evento e) {
    print('add_EvEntity ${e.key}');
    app.db.save(e.key, e);
    eventos.add(e);

    addItem(e);

    //
    update();
  }

  addItem(Evento e) {
    // Widget con un sólo Elemento de Dia
    if (!e.esPeriodo) {
      var item = EventoFecha.fromEvento(e);
      eItems.add(item);
      _addItemsToWeekDIaView(
          lunesDel(item.fecha), item.fecha.weekday - 1, item);
      // eventosView.update(widg.viewDiaKey, (List<EventoItem> val) {
      //   val.addIf(!val.contains(widg), widg);
      //   val.sort();
      //   return val;
      // }, ifAbsent: () => [widg]);
      return;
    }

    // Widget con Inicio y Fin
    var ini = EventoFecha.fromInicio(e);
    var fin = EventoFecha.fromFinal(e);
    eItems.add(ini);
    eItems.add(fin);
    _addItemsToWeekDIaView(lunesDel(ini.fecha), ini.fecha.weekday - 1, ini);
    _addItemsToWeekDIaView(lunesDel(fin.fecha), fin.fecha.weekday - 1, fin);
  }

  delete(Evento e) {
    deleteItem(e);
    app.db.remove(e.key);
    eventos.remove(e);

    //
    update();
  }

  deleteItem(Evento e) {
    var selecteds = eItems.where((item) => item.entity == e);
    selecteds.forEach((item) =>
        weeksView[lunesDel(item.fecha)]![item.fecha.weekday - 1].remove(item));

    eItems.removeWhere((item) => item.entity == e);
  }

  edited(Evento e, Evento nueva) {
    deleteItem(e);

    app.db.remove(e.key);
    eventos.remove(e);

    eventos.add(nueva);
    app.db.save(nueva.key, nueva);

    addItem(nueva);

    //
    update();
  }

  deleteAll() {
    app.db.clearAll();
    eventos.clear();
    eItems.clear();

    _createWeekView();
    _addItemsToWeekView();
  }
}

import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../global/app_controller.dart';
import '../../models/actividad.dart';

class ActividadFormController extends GetxController {
  ActividadFormController(Actividad act) {
    model = act.clone().obs;
  }

  static ActividadFormController get to => Get.find<ActividadFormController>();

  late Rx<Actividad> model;
  final patrones = <Tuple4<String, String, String, int>>[];

  void getPatrones() {
    patrones.clear();
    var set = <Tuple4<String, String, String, int>>{};

    var app = AppController.to;
    app.actividades.forEach((actividadesDia) {
      actividadesDia
          .where((act) =>
              act.activo &&
              (act.titulo != '' || act.subtitulo != '' || act.pie != ''))
          .forEach((act) => set.add(
              Tuple4(act.titulo, act.subtitulo, act.pie, act.color.value)));
    });
    set.forEach((element) => patrones.add(element));
  }
}

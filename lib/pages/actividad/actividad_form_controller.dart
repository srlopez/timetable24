import 'package:get/get.dart';
import '../../models/actividad.dart';

class ActividadFormController extends GetxController {
  ActividadFormController(Actividad act) : model = act.clone();

  static ActividadFormController get to => Get.find<ActividadFormController>();

  Actividad model;
}

import 'package:get/get.dart';
import '../../models/evento.dart';

class EventoFormController extends GetxController {
  EventoFormController(Evento evento) : nota = evento.clone();

  Evento nota;
}

import 'package:get/get.dart';
import 'package:timetable24/global/app_utils.dart';
import '../../models/actividad.dart';
import '../../global/app_controller.dart';

class HorarioController extends GetxController {
  AppController app;
  HorarioController({required this.app});
  static HorarioController get to => Get.find<HorarioController>();

  @override
  void onInit() {
    super.onInit();
    lunesDel1Sept = fechaLunesDel1Sept();
    setPaginaEnCurso();
  }

  // Actividad crearHueco(
  //     {required int dia, required int marca, required int minutos}) {
  //   return Actividad(dia: dia, minutos: minutos, marca: marca);
  // }

  activar(Actividad hueco) {
    // Si no está Inactivo volvemos
    if (hueco.activo) return;
    //
    hueco.activo = true;
    update();
    app.saveActividades();
  }

  desactivar(Actividad actividad) {
    // Si no está activo volvemos
    if (!actividad.activo) return;
    if (actividad.nHuecos > 1) return;
    //
    actividad.resetActividad();
    update();
    app.saveActividades();
  }

  cambiarActividad(Actividad actividad) {
    if (actividad.activo)
      desactivar(actividad);
    else
      activar(actividad);
  }

  aumentarActividad(List<Actividad> actividades, int index) {
    // Si no está activo volvemos
    if (!actividades[index].activo) return;
    // Si es la última volvemos
    if (index == actividades.length - 1) return;
    // Si la siguiente está activa volvemos
    if (actividades[index + 1].activo) return;
    //
    actividades[index].nHuecos += actividades[index + 1].nHuecos;
    actividades[index].minutos += actividades[index + 1].minutos;
    actividades.removeAt(index + 1);
    update();

    app.saveActividades();
  }

  reducirActividad(List<Actividad> actividades, int index, [bool save = true]) {
    if (actividades[index].nHuecos == 1) return;
    //
    var huecoIdx =
        actividades[index].marcaInicial + actividades[index].nHuecos - 1;
    var minutosARestar = app.patron[huecoIdx].minutos;
    // actualizamos la actividad
    actividades[index].minutos -= minutosARestar;
    actividades[index].nHuecos--;
    // Añadimos una nueva vacía
    actividades.insert(
        index + 1,
        Actividad(
            dia: actividades[index].dia,
            marca: huecoIdx,
            minutos: minutosARestar));

    if (!save) return;
    update();
    app.saveActividades();
  }

  destruirActividad(Actividad act) {
    var dia = act.dia;
    var idx = app.actividades[dia].indexOf(act);
    while (act.nHuecos > 1) reducirActividad(app.actividades[dia], idx, false);
    desactivar(act);
    update();
    app.saveActividades();
  }

  establecerActividad(Actividad act, Actividad data) {
    act.titulo = data.titulo;
    act.subtitulo = data.subtitulo;
    act.pie = data.pie;
    act.color = data.color;
    update();
    app.saveActividades();
  }

  // PAGINAS/SEMANA =========================================
  var page = -1;
  var nsemana = -1;
  var lunesDel1Sept =
      DateTime.now(); // fechaLunesDel1Sept() fecha de inicio de paginación
  var lunes = DateTime.now(); // fecha inicio de la página

  void setPaginaEnCurso() {
    page = nPaginaDeHoy();
    setPagina(page);
  }

  void setPagina(int nPagina) {
    page = nPagina;
    lunes = lunesDeLaPagina(nPagina);
    nsemana = nSemandaDe(lunes);
    //print('setPagina $page $nsemana');
    update();
  }

  DateTime lunesDeLaPagina(int page) =>
      //lunesDel1Sept.add(Duration(days: 7 * iSemana));
      lunesDel1Sept.addCalendarDays(7 * page);

  int nPaginaDeHoy() => nPaginaDelDia(DateTime.now());

  int nPaginaDelDia(DateTime dia) => nPaginasEntre(lunesDel1Sept, dia);

  int nPaginasEntre(DateTime dia1, DateTime dia2) {
    var nDias = dia2.difference(dia1).inDays.abs();
    var s = (nDias / 7).floor();
    return s;
  }
}

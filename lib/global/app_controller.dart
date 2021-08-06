import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/db_storagex.dart';
import '../../models/evento.dart';
import '../../models/actividad.dart';
import '../../models/marca_horaria.dart';

/*
Loader
Auxiliar para cargar datos y mantener estado
*/
class _Loader {
  bool loading = false;
  bool done = false;
  Function loader;
  _Loader(this.loader);
}

/* ================================================================
AppController 
Responsable de mantener los datos que pueden ser accedidos desde varias pantallas
*/
class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();
  final box = GetStorage();

  /*
  Variables de control de inicialización y carga de datos globales
  */
  var _loaders = <String, _Loader>{};
  var nLoading = (-1).obs;

  @override
  void onInit() {
    // Inicializacines principales
    hRead(); //Lectura del horario activo

    // Inicializaciones delegadas, invocadas desde Splash
    _loaders = {
      'Data D': _Loader(_loadD),
      'Marcas': _Loader(loadMarcas),
      'Actividades': _Loader(loadActividades),
      'Eventos': _Loader(loadEventos),
    };
    super.onInit();
  }

  @override
  void onClose() => db.dispose();

  /*
  Por decisión, invocada desde otro controller.
  Con el objeto de separar la carga de datos de la inicialización del controlador
  Se podría invocar desde onInit
  */
  void loadData() {
    nLoading.value = _loaders.length;

    _loaders.forEach((data, dl) {
      print('Cargando $data ...');
      dl.loading = true;
      dl.loader.call().then((_) {
        dl.loading = false;
        dl.done = true;
        nLoading.value--;
        print('$data cargado en memoria...');
      });
    });
  }

  // await waitUntilDone
  // Nos permite esperar que un cargador ha finalizado
  Future<void> waitUntilDone(String key) async {
    while (_loaders[key]!.done != true) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  // Devuelve el estado de un cargador
  String getDataStatus(String key) => _loaders[key]!.done
      ? 'done'
      : _loaders[key]!.loading
          ? 'loading...'
          : 'pending';

  /*
  Funciones fake de carga de datos
  Nos asegura que durante 3 segundos muestra la pantalla de splash
  */
  Future<void> _loadD() async {
    //await waitUntilDone('Marcas');
    await 3.delay();
  }

// HORARIOS =====================
  var horario = 0.obs;
  final horarios = ['A', 'B'];
  final hStorageKey = 'horario';
  int nextHorario() => (horario.value + 1) % horarios.length;

  Future<void> setNextHorario() async {
    horario.value = nextHorario();
    hWrite();
    await loadMarcas();
    await loadActividades();
  }

  // Storage
  hWrite() => box.write(hStorageKey, horario.value);
  hRead() => horario.value = box.read(hStorageKey) ?? 0;

// MARCAS HORARIAS =====================================
  var marcasHorarias = <Marca>[].obs;
  String mStorageKey() => horarios[horario.value] + 'marcas';

  void setMarcas(RxList<Marca> marcas) => marcasHorarias = marcas;

  Future<void> loadMarcas() async {
    List? marcas = box.read(mStorageKey());
    marcasHorarias.clear();

    if (marcas == null) {
      marcasHorarias.addAll([Marca(8, 0), Marca(15, 0)]);
    } else {
      marcas.forEach((item) => marcasHorarias.add(Marca.fromString(item)));
    }
  }

  void saveMarcas() {
    List marcas = marcasHorarias.map((element) => element.toString()).toList();
    box.write(mStorageKey(), marcas);
  }

// ACTIVIDADES ===========================================
  var actividades = [<Actividad>[]];
  var patron = <Actividad>[]; //=actividades[5]
  var patronIdx = 5;
  var minutosTotales = 0.1;
  String aStorageKey() => horarios[horario.value] + 'acts';

  Future<void> loadActividades() async {
    /// Inicializamos Actividades vacias
    actividades.clear();
    for (var dia = 0; dia < patronIdx + 1; dia++)
      actividades.add(<Actividad>[]);

    /// Creamos huecos vacios si no hay guardados
    List? leido = box.read('${aStorageKey()}0');
    if (leido == null) {
      inicializarActividades();
      return;
    }

    /// Leemos los actividades y el patron
    for (var dia = 0; dia < patronIdx + 1; dia++) {
      leido = box.read('${aStorageKey()}$dia');
      leido!
          .forEach((data) => actividades[dia].add(Actividad.fromString(data)));
    }
    patron = actividades[patronIdx];
    minutosTotales = patron.fold(0.0, (total, act) => total + act.minutos);
  }

  void saveActividades() {
    for (var dia = 0; dia < patronIdx + 1; dia++) {
      List diaList = actividades[dia].map((act) => act.toString()).toList();
      box.write('${aStorageKey()}$dia', diaList);
    }
  }

  // Inicializa el patron y las Actividades del Horario
  // segun las marcasHorarias
  Future<void> inicializarActividades() async {
    await waitUntilDone('Marcas');

    List<Marca> marcas = marcasHorarias;
    for (int dia = 0; dia < patronIdx + 1; dia++) {
      actividades[dia].clear();
      for (int marca = 1; marca < marcas.length; marca++) {
        actividades[dia].add(Actividad(
            dia: dia,
            marca: marca - 1,
            minutos: marcas[marca].diff(marcas[marca - 1])));
      }
    }
    //saveActividades();
    minutosTotales = patron.fold(0.0, (total, act) => total + act.minutos);
  }

  // Obtiene la actividad actual
  Actividad? getActividadActual() {
    var now = DateTime.now();
    if (now.weekday > 5) return null;
    var act = actividades[now.weekday - 1].firstWhere((act) {
      var mIni = marcasHorarias[act.marcaInicial];
      var mNow = Marca(now.hour, now.minute);
      var duracion = act.minutos;
      var diff = mNow.diff(mIni);
      if (diff >= 0 && diff <= duracion) return true;
      return false;
    }, orElse: () => Actividad(dia: 0, marca: 0, minutos: 0));
    return act.activo ? act : null;
  }

  // Marca getMarcaInicial(Actividad act) {
  //   return marcasHorarias[act.marcaInicial];
  // }

// EVENTOS ==============================================
  var eventos = <Evento>[].obs;
  final db = Get.find<DbGetXStorage>();

  Future<void> loadEventos() async {
    eventos.clear();
    var stream = db.getStream();
    print(stream);
    await for (Evento item in stream) {
      eventos.add(item);
    }
  }

  List<Categoria> getCategorias(DateTime fecha) {
    var set = <Categoria>{};

    eventos.forEach((ent) {
      if (!fecha.isBefore(ent.fInicio) && !fecha.isAfter(ent.fFin))
        set.add(ent.categoria);
    });
    var list = set.toList();
    list.sort((a, b) => a.index.compareTo(b.index));
    return list;
  }

  bool esFechaConActividad(DateTime fecha) {
    var activo = false;
    var hayFechas = false;

    eventos.forEach((e) {
      //print('$fecha ${e.fInicio} ${e.fFin}');
      var fFin = DateTime(e.fFin.year, e.fFin.month, e.fFin.day, 23, 59, 59);
      if (!fecha.isBefore(e.fInicio) && !fecha.isAfter(fFin)) {
        hayFechas = true;
        activo |= e.hayActividad;
        //print('activo $activo');
      }
    });
    if (hayFechas) return activo;
    return true;
  }
}

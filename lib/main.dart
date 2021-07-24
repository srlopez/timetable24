import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

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

/*
AppController
Responsable de mantener los datos que pueden ser accedidos desde varias pantallas
*/
class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();
  final box = GetStorage();

  var _loaders = <String, _Loader>{};
  var nLoading = (-1).obs;

  @override
  void onInit() {
    _loaders = {
      'Data A': _Loader(_loadA),
      'Data B': _Loader(_loadB),
      'Data C': _Loader(_loadC),
      'Data D': _Loader(_loadD),
    };
    super.onInit();
  }

  /*
  Por decisión invocada desde otro controller.
  Para separar la carga de datos de la inicialización del controlador
  Se podría invocar desde onInit
  */
  void loadData() {
    nLoading.value = _loaders.length;

    _loaders.forEach((data, dl) {
      print('loading $data...');
      dl.loading = true;
      dl.loader.call().then((_) {
        dl.loading = false;
        dl.done = true;
        nLoading.value--;
        print('$data loaded');
      });
    });
  }

  String getDataStatus(String key) => _loaders[key]!.done
      ? 'done'
      : _loaders[key]!.loading
          ? 'loading...'
          : 'pending';

  /*
  Funciones de carga de datos
  */
  Future<void> _loadA() async => await 4.delay();
  Future<void> _loadB() async => await 2.delay();
  Future<void> _loadC() async => await 3.delay();
  Future<void> _loadD() async => await 1.delay();
}

void main() async {
  initializeDateFormatting('es_ES', null);
  await initServices();
  //Get.put(AppController()); <-- GetMaterialApp initialBinding
  runApp(App());
}

Future<void> initServices() async {
  print('starting services ...');
  await GetStorage.init();
  print('All services started...');
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Get.deviceLocale,
      initialRoute: '/splash',
      initialBinding:
          BindingsBuilder(() => {Get.put(AppController(), permanent: true)}),
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashPage(),
          binding: BindingsBuilder(() {
            Get.put(SplashController(route: '/home', app: AppController.to));
          }),
        ),
        GetPage(
          name: '/home',
          page: () => HomePage(),
        ),
      ],
    );
  }
}

/*
SplashController
La única función actual de este Controller es realizar la navegación a HOME.
No he querido hacer la navegación en AppController (Global) para evitar dispersar 'responsabilidades'
*/
class SplashController extends GetxController {
  AppController app;
  String route;
  SplashController({required this.route, required this.app});

  late Worker _ever;
  @override
  void onInit() {
    app.loadData();
    // Revisa valores en el controlador principal
    _ever = ever(app.nLoading, (_) {
      if (app.nLoading.value == 0) Get.offAllNamed(route);
    });
    super.onInit();
  }

  @override
  void onClose() {
    _ever.dispose();
  }
}

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);
  final app = AppController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => app.nLoading.value == 0
            ? Text('Done')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Loading ${app.nLoading.value}'),
                  Text('A: ${app.getDataStatus("Data A")}'),
                  Text('B: ${app.getDataStatus("Data B")}'),
                  Text('C: ${app.getDataStatus("Data C")}'),
                  Text('D: ${app.getDataStatus("Data D")}'),
                ],
              )),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('H O M E')));
  }
}

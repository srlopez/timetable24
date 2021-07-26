import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timetable24/pages/reloj/reloj_controller.dart';

import 'global/app_controller.dart';
import 'global/app_themes.dart';
import 'models/evento.dart';
import 'pages/actividad/actividad_form_page.dart';
import 'pages/agenda/agenda_controller.dart';
import 'pages/agenda/agenda_page.dart';
import 'pages/evento/evento_form_page.dart';
import 'pages/home/home_page.dart';
import 'pages/horario/horario_controller.dart';
import 'pages/horario/horario_page.dart';
import 'pages/marcas/marcas_controller.dart';
import 'pages/marcas/marcas_page.dart';
import 'pages/reloj/reloj_page.dart';
import 'pages/splash/splash_controller.dart';
import 'pages/splash/splash_page.dart';
import 'services/db_storagex.dart';

void main() async {
  initializeDateFormatting('es_ES', null);
  await initServices();
  //Get.put(AppController()); <-- GetMaterialApp initialBinding
  runApp(App());
}

Future<void> initServices() async {
  print('Lanzando servicios ...');
  await GetStorage.init();
  await Get.putAsync(
      () => DbGetXStorage<Evento>(Evento.fromStr).init()); // Eventos
  print('Todos los servicios corriendo ...');
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Get.deviceLocale,
      theme: light(),
      darkTheme: dark(),
      initialRoute: '/splash',
      initialBinding:
          BindingsBuilder(() => {Get.put(AppController(), permanent: true)}),
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashPage(),
          binding: BindingsBuilder(() {
            Get.put(
                SplashController(nextRoute: '/home', app: AppController.to));
          }),
        ),
        GetPage(
            name: '/home',
            page: () => HomePage(),
            binding: BindingsBuilder(() {
              Get.put(HomeController());
              Get.put(HorarioController(app: AppController.to));
              Get.put(AgendaController(app: AppController.to));
              Get.lazyPut(() => RelojController(app: AppController.to));
            })),
        GetPage(
          name: '/marcas',
          page: () => MarcasPage(),
          binding: BindingsBuilder(() {
            Get.put(MarcasController(app: AppController.to));
          }),
        ),
        GetPage(
            name: '/horario',
            page: () => HorarioPage(),
            binding: BindingsBuilder(() {
              Get.put(HorarioController(app: AppController.to));
            })),
        GetPage(
          name: '/actividad',
          page: () => ActividadFormPage(),
        ),
        GetPage(
            name: '/agenda',
            page: () => AgendaPage(),
            binding: BindingsBuilder(() {
              Get.put(AgendaController(app: AppController.to));
            })),
        GetPage(
          name: '/evento',
          page: () => EventoFormPage(),
        ),
        GetPage(
            name: '/reloj',
            page: () => RelojPage(),
            binding: BindingsBuilder(() {
              Get.put(RelojController(app: AppController.to));
            }))
      ],
    );
  }
}

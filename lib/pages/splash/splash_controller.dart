import 'package:get/get.dart';
import '../../global/app_controller.dart';

/*
SplashController
La única función actual de este Controller es realizar la navegación a HOME.
No he querido hacer la navegación en AppController (Global) para evitar dispersar 'responsabilidades'
*/
class SplashController extends GetxController {
  AppController app;
  String nextRoute;
  SplashController({required this.nextRoute, required this.app});
  static SplashController get to => Get.find<SplashController>();

  late Worker _ever;
  @override
  void onInit() {
    app.loadData();
    // Revisa valores en el controlador principal
    _ever = ever(app.nLoading, (_) {
      if (app.nLoading.value == 0) Get.offAllNamed(nextRoute);
    });
    super.onInit();
  }

  @override
  void onClose() {
    _ever.dispose();
  }
}

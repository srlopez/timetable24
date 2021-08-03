import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  var tabIndex = 1.obs;

  void changeTabIndex(int index) {
    if (index == 2) {
      // En el botón 2 no presentamos pagina incluida
      //en el IndexedStack, nos vamos a otra página
      // y no cambiamos el index para poder volver.
      Get.toNamed('/reloj');
    } else {
      tabIndex.value = index;
    }
  }
}

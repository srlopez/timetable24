import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  var tabIndex = 1.obs;

  void changeTabIndex(int index) {
    if (index == 2) {
      Wakelock.enable();
      Get.toNamed('/reloj');
    } else {
      tabIndex.value = index;
      Wakelock.disable();
    }
  }
}

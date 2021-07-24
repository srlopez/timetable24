import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../agenda/agenda_page.dart';
import '../horario/horario_page.dart';
import '../reloj/reloj.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  var tabIndex = 1.obs;
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final _ = HomeController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: _.tabIndex.value,
            children: [
              AgendaPage(),
              HorarioPage(),
              RelojPage(),
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _.changeTabIndex,
        currentIndex: _.tabIndex.value,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Horario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Reloj',
          ),
        ],
      ),
    );
  }
}

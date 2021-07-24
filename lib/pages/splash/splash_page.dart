import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global/app_controller.dart';

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
                  //Text('\nCargando... ${app.nLoading.value}'),
                  Text('\nCargando...'),
                  // Text('D: ${app.getDataStatus("Data D")}'),
                  // Text(
                  //     'Marcas horarias: ${app.getDataStatus("Marcas horarias")}'),
                ],
              )),
      ),
    );
  }
}

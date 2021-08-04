import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../global/app_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);
  final app = AppController.to;

  var backColor = Colors.black54;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //elevation: 0,
        backgroundColor: Colors.transparent,
        //brightness: Brightness.dark,
        toolbarHeight: 0,
        backwardsCompatibility: false,
        systemOverlayStyle:
            SystemUiOverlayStyle.dark.copyWith(statusBarColor: backColor),
      ),
      body: Container(
        //color: backColor,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   "mi horario",
              //   textScaleFactor: 1.2,
              //   style: TextStyle(
              //     shadows: [
              //       // Shadow(
              //       //   blurRadius: 5.0,
              //       //   color: Colors.blue,
              //       //   offset: Offset(1.0, 5.0),
              //       // ),
              //       Shadow(
              //         blurRadius: 7.0,
              //         color: Colors.white,
              //         offset: Offset(2.0, 6.0),
              //       ),
              //     ],
              //     fontSize: 30,
              //   ),
              // ),
              // Divider(
              //   height: 20,
              //   color: Colors.white70,
              //   indent: 100.0,
              //   endIndent: 100.0,
              // ),
              SizedBox(height: 100),
              Obx(() => app.nLoading.value == 0
                  ? Text('entramos...')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        //Text('\nCargando... ${app.nLoading.value}'),
                        Text('\ninicializando...'),
                        // Text('D: ${app.getDataStatus("Data D")}'),
                        // Text(
                        //     'Marcas horarias: ${app.getDataStatus("Marcas horarias")}'),
                      ],
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

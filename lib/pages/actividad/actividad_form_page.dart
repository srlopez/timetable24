import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global/app_controller.dart';

import 'actividad_form_controller.dart';
import '../../global/app_ctes/horario.dart' as Horario;
import 'widgets/color_picker.dart';

class ActividadFormPage extends StatelessWidget {
  const ActividadFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = Get.put(ActividadFormController(Get.arguments));
    final app = AppController.to;

    var dia = Horario.nombreLDias[_.model.dia + 1];
    var desde = app.marcasHorarias[_.model.marcaInicial];
    var hasta = app.marcasHorarias[_.model.marcaInicial + _.model.nHuecos];

    return Scaffold(
      appBar: AppBar(title: Text('$dia    $desde - $hasta')),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final _ = Get.find<ActividadFormController>();
    var model = _.model;

    final _formKey = GlobalKey<FormState>();

    var _tituloCtrl = TextEditingController(text: model.titulo);
    var _subtituloCtrl = TextEditingController(text: model.subtitulo);
    var _pieCtrl = TextEditingController(text: model.pie);

    // Build a Form widget using the _formKey created above.
    return GetBuilder<ActividadFormController>(
        builder: (_) => Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // TITULO - MODULO
                      TextFormField(
                        controller: _tituloCtrl,
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.book),
                          hintText: 'Módulo que impartes',
                          labelText: 'Módulo',
                        ),
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Tienes que identificarlo con algún nombre';
                        //   }
                        //   return null;
                        // },
                        onChanged: (val) => model.titulo = val,
                      ),
                      // SUBTITULO - CLASE
                      TextFormField(
                        controller: _subtituloCtrl,
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.location_pin),
                          hintText: 'Clase donde impartes',
                          labelText: 'Ubicación',
                        ),
                        onChanged: (val) => model.subtitulo = val,
                      ),
                      // PIE - CICLO/GRUPO
                      TextFormField(
                        controller: _pieCtrl,
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.group),
                          hintText: 'Ciclo y Grupo de alumnos ',
                          labelText: 'Grupo',
                        ),
                        onChanged: (val) => model.pie = val,
                      ),

                      //Divider(height: 20),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(
                            Icons.color_lens,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 16),
                          Text('Color'),
                        ],
                      ),
                      ColorPicker(
                        context: context,
                        currentColor: model.color, //Color(act.color),
                        onChanged: (color) {
                          model.color = color;
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // ScaffoldMessenger.of(context)
                                  //     .showSnackBar(SnackBar(content: Text('Processing Data')));
                                  Get.back(result: _.model);
                                }
                              },
                              child: Text('Aceptar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Get.back(),
                              child: Text('Cancelar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}

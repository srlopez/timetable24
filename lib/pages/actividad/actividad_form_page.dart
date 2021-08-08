import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timetable24/global/app_utils.dart';
import 'package:tuple/tuple.dart';
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
    _.getPatrones();

    var dia = _.model.value.dia;
    var diaNombre = Horario.nombreLDias[dia + 1];

    // Partimos de la marca Inicial y sumamos duraciones.
    var i = 0;
    var desde = app.marcasHorarias[0];
    for (var m = 0;
        m < _.model.value.marcaInicial;
        m += app.actividades[dia][i].nHuecos, i++)
      desde = desde.add(app.actividades[dia][i].minutos);
    var hasta = desde.add(app.actividades[dia][i].minutos);

    return Scaffold(
      appBar: AppBar(title: Text('$diaNombre    $desde - $hasta')),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final _ = Get.find<ActividadFormController>();
    //var model = _.model.value;

    final _formKey = GlobalKey<FormState>();

    var _tituloCtrl = TextEditingController(text: _.model.value.titulo);
    var _subtituloCtrl = TextEditingController(text: _.model.value.subtitulo);
    var _pieCtrl = TextEditingController(text: _.model.value.pie);

    Function? _setNewColor;

    var _colorPicker = ColorPicker(
      context: context,
      currentColor: _.model.value.color, //Color(act.color),
      onChanged: (color) {
        _.model.value.color = color;
      },
      onForceSetNewColor: (f) {
        //Nos establece una funcion que será invocada para cambiar el color desde aquí
        _setNewColor = f;
      },
    );

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // PATRONES DE TITULOS Y COLORES
              Row(
                children: [
                  Icon(
                    Icons.list_sharp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 16),
                  Text('Patrones   ',
                      style: Theme.of(context).textTheme.subtitle1),
                  DropdownButton<Tuple4>(
                    //itemHeight: 50,
                    items: <DropdownMenuItem<Tuple4>>[
                      if (_.patrones.length == 0)
                        DropdownMenuItem(
                            child: Text('Ejemplo'),
                            value: Tuple4('Título', 'Subtítulo', 'Pie',
                                Colors.red.value)),
                      for (var p in _.patrones)
                        DropdownMenuItem(
                          child: Container(
                            //height: 33,
                            width: 170,
                            padding: EdgeInsets.all(6),
                            color: Color(p.item4),
                            child: Text(
                              '${p.item1}, ${p.item2}, ${p.item3}',
                              style: TextStyle(
                                color: highlightColor(Color(p.item4)),
                              ),
                            ),
                          ),
                          value: p,
                        )
                    ],
                    onChanged: (value) {
                      _tituloCtrl.text = value!.item1;
                      _subtituloCtrl.text = value.item2;
                      _pieCtrl.text = value.item3;

                      _.model.value.titulo = value.item1;
                      _.model.value.subtitulo = value.item2;
                      _.model.value.pie = value.item3;
                      _.model.value.color = Color(value.item4);

                      _setNewColor!(Color(value.item4));
                    },
                  ),
                ],
              ),

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
                onChanged: (val) => _.model.value.titulo = val,
              ),
              // SUBTITULO - CLASE
              TextFormField(
                controller: _subtituloCtrl,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_pin),
                  hintText: 'Clase donde impartes',
                  labelText: 'Ubicación',
                ),
                onChanged: (val) => _.model.value.subtitulo = val,
              ),
              // PIE - CICLO/GRUPO
              TextFormField(
                controller: _pieCtrl,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.group),
                  hintText: 'Ciclo y Grupo de alumnos ',
                  labelText: 'Grupo',
                ),
                onChanged: (val) => _.model.value.pie = val,
              ),
              // ESPACIO
              SizedBox(height: 16),
              // COLOR
              Row(
                children: [
                  Icon(
                    Icons.color_lens,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 16),
                  Text('Color', style: Theme.of(context).textTheme.subtitle1),
                ],
              ),
              _colorPicker,
              // ACEPTAR Y CANCELAR
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
                          Get.back(result: _.model.value);
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
    );
  }
}

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global/app_utils.dart';
import '../../global/app_ctes/agenda.dart' as Agenda;
import '../../models/evento.dart';
import 'evento_form_controller.dart';

class EventoFormPage extends StatelessWidget {
  const EventoFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = Get.put(EventoFormController(Get.arguments));

    return Scaffold(
      appBar: AppBar(title: Text('Entrada de Agenda')),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final _ = Get.find<EventoFormController>();
    var nota = _.nota;
    if (!nota.esPeriodo) nota.fFin = nota.fInicio;

    final _formKey = GlobalKey<FormState>();

    var _tituloCtrl = TextEditingController(text: nota.titulo);
    var _notasCtrl = TextEditingController(text: nota.notas);
    var _finicioCtrl = TextEditingController(text: nota.fInicio.toString());
    var _ffinCtrl = TextEditingController(text: nota.fFin.toString());
    var _minFecha = DateTime(anoEscolar(), 9, 1);
    var _maxFecha = DateTime(anoEscolar() + 1, 8, 31);

    var _iconColor = Colors.grey[400];

    // Build a Form widget using the _formKey created above.
    return GetBuilder<EventoFormController>(
        builder: (_) => Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // FECHA INICIO
                      DateTimePicker(
                        controller: _finicioCtrl,
                        // formato
                        //initialValue: _initialValue,
                        type: DateTimePickerType.date, //dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        icon: Icon(Icons.event),
                        dateLabelText: 'Fecha',
                        timeLabelText: 'Hora',
                        //locale: Locale('pt', 'BR'),
                        // Restricciones
                        firstDate: _minFecha,
                        lastDate: _maxFecha,
                        selectableDayPredicate: (date) {
                          // if (date.weekday == 6 || date.weekday == 7) {
                          //   return false;
                          // }
                          return true;
                        },
                        // recogemos el valor
                        onChanged: (val) => nota.fInicio = DateTime.parse(val),
                      ),
                      // TITULO
                      TextFormField(
                        controller: _tituloCtrl,
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.title),
                          hintText: 'Recordatorio de algo para no olvidar',
                          labelText: 'Título',
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tienes que identificarlo con algún nombre';
                          }
                          return null;
                        },
                        onChanged: (val) => nota.titulo = val,
                      ),
                      // NOTAS
                      TextFormField(
                        controller: _notasCtrl,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.edit),
                          hintText: 'Indica aquí los detalles par no olvidar',
                          labelText: 'Notas',
                        ),
                        onChanged: (val) => nota.notas = val,
                      ),
                      // ES PERIODO
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: _iconColor,
                          ),
                          SizedBox(width: 6),
                          Switch(
                              activeColor: Colors.greenAccent,
                              value: nota.esPeriodo,
                              onChanged: (val) {
                                nota.esPeriodo = val;
                                if (!val) nota.fFin = nota.fInicio;
                                _.update();
                              }),
                          Text(
                            nota.esPeriodo
                                ? 'Con fecha de finalización'
                                : 'Un único día',
                            style: TextStyle(color: _iconColor),
                          )
                        ],
                      ),
                      // FECHA DE FIN
                      !nota.esPeriodo
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DateTimePicker(
                                  type: DateTimePickerType.date,
                                  dateMask: 'd MMM, yyyy',
                                  controller: _ffinCtrl,
                                  //initialValue: _initialValue,
                                  firstDate: _minFecha,
                                  lastDate: _maxFecha,
                                  icon: Icon(Icons.event),
                                  dateLabelText: 'Fecha de finalización',
                                  //use24HourFormat: false,
                                  //locale: Locale('pt', 'BR'),
                                  selectableDayPredicate: (date) {
                                    // if (date.weekday == 6 ||
                                    //     date.weekday == 7) {
                                    //   return false;
                                    // }
                                    return true;
                                  },
                                  validator: (value) {
                                    var date = DateTime.parse(value!);
                                    if (date.isBefore(nota.fInicio)) {
                                      return 'Indica una fecha posterior a la de inicio';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) =>
                                      nota.fFin = DateTime.parse(val),
                                ),
                                SizedBox(height: 9),
                              ],
                            ),
                      // CATEGORIA == COLOR
                      Row(
                        children: [
                          Icon(
                            Icons.circle_sharp,
                            color: _iconColor,
                          ),
                          SizedBox(width: 16),
                          // DropdownButton<Categoria>(
                          //   value: nota.categoria,
                          //   onChanged: (val) {
                          //     nota.categoria = val ?? nota.categoria;
                          //     _.update();
                          //   },
                          //   items: Categoria.values.map((Categoria tipo) {
                          //     String txt(Categoria t) =>
                          //         t.toString().split('.')[1];
                          //     return DropdownMenuItem<Categoria>(
                          //       value: tipo,
                          //       child: Text(txt(tipo)),
                          //     );
                          //   }).toList(),
                          // ),
                          for (var i = 0; i < 6; i++) ...[
                            Checkbox(
                              checkColor: Colors.white,
                              fillColor:
                                  MaterialStateProperty.all(Agenda.colors[i]),
                              value: nota.categoria.index == i,
                              shape: CircleBorder(),
                              onChanged: (bool? value) {
                                if (value!)
                                  nota.categoria = Categoria.values[i];
                                _.update();
                              },
                            ),
                          ],
                        ],
                      ),
                      // HAY ACTIVIDAD
                      Row(
                        children: [
                          Icon(
                            nota.hayActividad
                                ? Icons.check
                                : Icons
                                    .clear_outlined, //Icons.beach_access_outlined ,
                            color: _iconColor,
                          ),
                          SizedBox(width: 6),
                          Switch(
                            activeColor: Colors.greenAccent,
                            value: nota.hayActividad,
                            onChanged: (val) {
                              nota.hayActividad = val;
                              _.update();
                            },
                          ),
                          Text(
                            nota.hayActividad
                                ? 'Horario programado'
                                : 'Es vacación o festivo',
                            style: TextStyle(color: _iconColor),
                          )
                        ],
                      ),
                      // ACEPTAR y CANCELAR
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (!nota.esPeriodo) nota.fFin = nota.fInicio;
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  // ScaffoldMessenger.of(context)
                                  //     .showSnackBar(SnackBar(content: Text('Processing Data')));
                                  Get.back(result: _.nota);
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

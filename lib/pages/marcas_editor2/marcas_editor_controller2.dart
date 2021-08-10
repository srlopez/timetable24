import 'package:get/get.dart';
import '../../models/marca_horaria.dart';
import '../../global/app_controller.dart';

class MarcasEditorController2 extends GetxController {
  AppController app;
  MarcasEditorController2({required this.app});
  static MarcasEditorController2 get to => Get.find<MarcasEditorController2>();

  // Lista de Marcas horarias
  var marcas = <Marca>[].obs;

  // Establecemos las marcas sobre las que vamos a trabajar
  void setMarcas(List<Marca> nuevas) {
    marcas.clear();
    marcas.value = List<Marca>.from(nuevas);
  }

  // Establece la Lista de Marcas como lista global
  void onPressedAceptar() {
    app.setMarcas(marcas);
    app.saveMarcas();
    Get.back(result: true);
  }

  // ===================================
  var selectedIdx = 0.obs;

  void onMarcaSelected(int idx) {
    selectedIdx.value = idx;
  }

  void onUpdateMarca(int marcaIdx, int minutes) {
    var nuevaMarca = marcas[marcaIdx].add(minutes);
    if (nuevaMarca.inMinutes < 0) return;
    if (nuevaMarca.inMinutes >= 24 * 60) return;

    var duplicateIdx = marcas.indexOf(nuevaMarca);

    if (duplicateIdx > -1)
      marcas.removeAt(marcaIdx);
    else
      marcas[marcaIdx] = nuevaMarca;

    marcas.sort();
    selectedIdx.value = marcas.indexOf(nuevaMarca);

    //update();
  }

  void onNewMarca(int marcaIdx, int minutes) {
    var marca = marcas[marcaIdx].add(minutes);
    if (marcas.contains(marca)) return;
    marcas.add(marca);
    marcas.sort();
  }

  void onDeleteMarca(int marcaIdx) {
    marcas.removeAt(marcaIdx);
    if (marcaIdx <= selectedIdx.value)
      selectedIdx.value = (selectedIdx.value - 1) % marcas.length;
    //update();
  }
}

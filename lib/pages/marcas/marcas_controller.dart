import 'package:get/get.dart';
import '../../models/marca_horaria.dart';
import '../../global/app_controller.dart';

class MarcasController extends GetxController {
  AppController app;
  MarcasController({required this.app});
  static MarcasController get to => Get.find<MarcasController>();

  // Lista de Marcas horarias
  var marcas = <Marca>[].obs;

  // Marcas visibles Superior e Inferior
  var mSuperior = Marca(8, 0).obs;
  var mInferior = Marca(15, 0).obs;

  // Establecemos las marcas sobre las que vamos a trabajar
  void setMarcas(List<Marca> nuevas) {
    marcas.clear();
    marcas.value = List<Marca>.from(nuevas);
  }

  // Añade/Quita la marca a la Lista
  void turnarMarca(RxList<Marca> marcas, int h, int m) {
    var marca = Marca(h, m);

    if (marcas.contains(marca))
      marcas.remove(marca);
    else
      marcas.add(marca);

    marcas.sort();
  }

  // Indica si la marca está en la lista
  bool esMarcaActiva(RxList<Marca> marcas, int h, int m) =>
      marcas.contains(Marca(h, m));

  // Modifica la Marca Superior Visible
  void onUpdateMSuperior(int increment) {
    var limite = mSuperior.value.inHours + increment;
    if (limite < 0) return;
    if (limite == mInferior.value.inHours) return;
    mSuperior.value = Marca(limite, 0);
  }

  // Modifica la Marca Inferior Visible
  void onUpdateMInferior(int increment) {
    var limite = mInferior.value.inHours + increment;
    if (limite > 23) return;
    if (limite == mSuperior.value.inHours) return;
    mInferior.value = Marca(limite, 0);
  }

  // Establece la Lista de Marcas como lista global
  void onPressedAceptar() {
    app.setMarcas(marcas);
    app.saveMarcas();
    Get.back(result: true);
  }
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'db_iservice.dart';

class DbGetXStorage<T> extends GetxService implements DbIService {
  static const String storageName = 'storage';
  late final box;
  final Function fromString; // Devuelve un <T>

  DbGetXStorage(this.fromString);

  @override
  save(String key, Object obj) => box.write(key, obj.toString());

  @override
  remove(String key) => box.remove(key);

  @override
  Stream<T> getStream() async* {
    var values = box.getValues();
    for (var value in values) {
      //await Future.delayed(Duration(milliseconds: 150));
      yield fromString(value) as T;
    }
  }

  // @override
  // List<T> getValues() {
  //   List<T> list = [];
  //   var values = box.getValues();
  //   for (var value in values) {
  //     list.add(fromString(value) as T);
  //   }
  //   return list;
  // }

  @override
  clearAll() => box.erase();

  @override
  void dispose() => box.save();

  @override
  Future<DbGetXStorage> init() async {
    await GetStorage.init(storageName);
    box = GetStorage(storageName);
    print('DbGetXStorage init');
    return this;
  }
}

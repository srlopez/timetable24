abstract class DbIService {
  Future<DbIService> init();
  void dispose();
  save(String key, Object obj);
  remove(String key);
  getStream();
  //getValues();
  clearAll();
}

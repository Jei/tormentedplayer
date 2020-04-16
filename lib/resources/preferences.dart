import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final String saveKey;

  Preferences({this.saveKey = 'app'});

  Future<int> loadInt(String valueKey, [int defaultValue]) async {
    assert(valueKey != null, 'A key must be provided');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt('$saveKey.$valueKey') ?? defaultValue;
  }

  Future<void> saveInt(String valueKey, int value) async {
    assert(valueKey != null, 'A key must be provided');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt('$saveKey.$valueKey', value);
  }
}

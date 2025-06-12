import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SPUtils {
  static SharedPreferences? _prefs;

  /// 初始化 SharedPreferences（需要在 app 启动时调用）
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存字符串
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// 读取字符串
  static String? getString(String key, {String? defaultValue}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// 保存整数
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// 读取整数
  static int? getInt(String key, {int? defaultValue}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// 保存布尔值
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// 读取布尔值
  static bool? getBool(String key, {bool? defaultValue}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// 保存双精度浮点数
  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  /// 读取双精度浮点数
  static double? getDouble(String key, {double? defaultValue}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /// 保存字符串列表
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  /// 读取字符串列表
  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  /// 保存对象（需要 JSON 编码）
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    String jsonString = jsonEncode(value);
    await _prefs?.setString(key, jsonString);
  }

  /// 读取对象（需要 JSON 解码）
  static Map<String, dynamic>? getObject(String key) {
    String? jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// 移除某个键值
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// 清空所有存储的数据
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}

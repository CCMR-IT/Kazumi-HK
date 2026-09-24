import 'package:flutter/foundation.dart';
import 'package:opencc/opencc.dart' show ZhConverter;

import 'package:kazumi/services/storage/storage.dart';

class ZhConverterService {
  ZhConverterService._();

  static final ValueNotifier<bool> hongKongTraditionalEnabled =
      ValueNotifier<bool>(true);
  static ZhConverter? _converter;
  static final Map<String, String> _cache = <String, String>{};
  static bool _initialized = false;
  static bool _openCcUnavailable = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;
    hongKongTraditionalEnabled.value = _readSetting();
  }

  static bool get enabled {
    initialize();
    return hongKongTraditionalEnabled.value;
  }

  static Future<void> setEnabled(bool enabled) async {
    initialize();
    if (hongKongTraditionalEnabled.value == enabled) return;
    await GStorage.putSetting(SettingsKeys.hongKongTraditional, enabled);
    _cache.clear();
    hongKongTraditionalEnabled.value = enabled;
  }

  static String convert(String text) {
    initialize();
    if (!hongKongTraditionalEnabled.value || text.isEmpty) return text;
    if (_openCcUnavailable) return text;
    final cached = _cache[text];
    if (cached != null) return cached;
    try {
      final converted = (_converter ??= ZhConverter('s2hk')).convert(text);
      _cache[text] = converted;
      return converted;
    } catch (_) {
      _converter = null;
      _cache.clear();
      _openCcUnavailable = true;
      return text;
    }
  }

  static String? convertNullable(String? text) {
    return text == null ? null : convert(text);
  }

  static bool _readSetting() {
    try {
      return GStorage.getSetting(SettingsKeys.hongKongTraditional);
    } catch (_) {
      return true;
    }
  }
}

String zh(String? text) => ZhConverterService.convert(text ?? '');

String? zhn(String? text) => ZhConverterService.convertNullable(text);
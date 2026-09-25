import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

import 'package:kazumi/services/logging/logger.dart';
import 'package:kazumi/services/storage/storage.dart';

typedef _ConvertText = Future<String> Function(String text);

class ZhConverterService {
  ZhConverterService._();

  static final ValueNotifier<bool> hongKongTraditionalEnabled =
      ValueNotifier<bool>(true);
  static final ValueNotifier<int> epoch = ValueNotifier<int>(0);
  static final Map<String, String> _cache = <String, String>{};
  static final Set<String> _pending = <String>{};
  static bool _initialized = false;
  static bool _converterReady = false;
  static bool _converterUnavailable = false;
  static Future<void>? _ensureReadyFuture;
  static _ConvertText _convertText = _convertWithChineseConverter;

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
    if (enabled) await ensureReady();
    hongKongTraditionalEnabled.value = enabled;
  }

  static Future<void> ensureReady() {
    initialize();
    if (!hongKongTraditionalEnabled.value) {
      return Future<void>.value();
    }
    return _ensureReadyFuture ??= _ensureReady();
  }

  static String convert(String text) {
    initialize();
    if (!hongKongTraditionalEnabled.value || text.isEmpty) return text;
    if (_converterUnavailable) return text;
    final cached = _cache[text];
    if (cached != null) return cached;
    if (!_converterReady) return text;
    _scheduleConversion(text);
    return text;
  }

  static String? convertNullable(String? text) {
    return text == null ? null : convert(text);
  }

  static Future<void> _ensureReady() async {
    if (_converterReady || _converterUnavailable) return;
    try {
      final probe = await _convertText('设置');
      if (probe == '设置' || probe.isEmpty) {
        throw StateError('S2HK probe did not return Traditional Chinese');
      }
      _converterReady = true;
    } catch (e) {
      _markUnavailable(e);
    }
  }

  static void _scheduleConversion(String text) {
    if (!_pending.add(text)) return;
    unawaited(() async {
      try {
        final converted = await _convertText(text);
        _cache[text] = converted;
        epoch.value++;
      } catch (e) {
        _markUnavailable(e);
      } finally {
        _pending.remove(text);
      }
    }());
  }

  static Future<String> _convertWithChineseConverter(String text) {
    return ChineseConverter.convert(text, S2HK());
  }

  static void _markUnavailable(Object error) {
    if (!_converterUnavailable) {
      KazumiLogger().w(
        'ZhConverter: Chinese converter unavailable; using passthrough',
        error: error,
      );
    }
    _converterReady = false;
    _converterUnavailable = true;
    _cache.clear();
    _pending.clear();
  }

  @visibleForTesting
  static void debugSetConverter(_ConvertText convertText) {
    _convertText = convertText;
    _converterReady = false;
    _converterUnavailable = false;
    _ensureReadyFuture = null;
    _cache.clear();
    _pending.clear();
  }

  @visibleForTesting
  static void debugReset({bool enabled = true}) {
    _convertText = _convertWithChineseConverter;
    _initialized = true;
    hongKongTraditionalEnabled.value = enabled;
    epoch.value = 0;
    _converterReady = false;
    _converterUnavailable = false;
    _ensureReadyFuture = null;
    _cache.clear();
    _pending.clear();
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
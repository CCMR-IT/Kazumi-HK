import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/utils/zh.dart';

void main() {
  tearDown(() {
    ZhConverterService.debugReset();
  });

  test('zh falls back when converter is unavailable', () async {
    ZhConverterService.debugReset();
    ZhConverterService.debugSetConverter((_) async {
      throw StateError('missing converter');
    });

    await ZhConverterService.ensureReady();

    expect(() => zh('设置'), returnsNormally);
    expect(zh('设置'), '设置');
  });

  test('zh returns converted text after async cache fill', () async {
    ZhConverterService.debugReset();
    ZhConverterService.debugSetConverter((text) async {
      return text.replaceAll('设置', '設定');
    });

    await ZhConverterService.ensureReady();

    expect(zh('设置'), '设置');

    await Future<void>.delayed(Duration.zero);

    expect(zh('设置'), '設定');
    expect(ZhConverterService.epoch.value, greaterThan(0));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/utils/zh.dart';

void main() {
  test('zh falls back without native OpenCC', () {
    expect(() => zh('设置'), returnsNormally);
    expect(zh('设置'), isNotEmpty);
  });
}

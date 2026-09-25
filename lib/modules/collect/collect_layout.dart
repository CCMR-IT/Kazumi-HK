import 'package:kazumi/utils/zh.dart';

enum CollectLayout {
  list('列表'),
  cards('卡片');

  const CollectLayout(this._label);

  final String _label;

  String get label => zh(_label);

  static CollectLayout fromValue(String value) =>
      value == cards.name ? cards : list;
}

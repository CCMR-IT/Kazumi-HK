import 'package:kazumi/utils/zh.dart';

enum BangumiSyncPriority {
  localFirst(0, '本地优先'),
  bangumiFirst(1, 'Bangumi优先'),
  timeFirst(2, '最新优先');

  const BangumiSyncPriority(this.value, this._label);

  final int value;
  final String _label;

  String get label => zh(_label);

  static BangumiSyncPriority fromValue(int value) {
    return BangumiSyncPriority.values.firstWhere(
      (item) => item.value == value,
      orElse: () => BangumiSyncPriority.localFirst,
    );
  }
}

import 'package:kazumi/modules/history/history_module.dart';
import 'package:kazumi/utils/zh.dart';

enum HistorySourceFilter {
  all('全部'),
  online('在线'),
  offline('缓存');

  const HistorySourceFilter(this._label);

  final String _label;

  String get label => zh(_label);

  bool _matches(History history) => switch (this) {
        all => true,
        online => HistoryEntryKind.normalize(history.entryKind) ==
            HistoryEntryKind.online,
        offline => HistoryEntryKind.normalize(history.entryKind) ==
            HistoryEntryKind.offline,
      };
}

class HistoryDateGroup {
  HistoryDateGroup._(this.date, this.entries);

  final DateTime date;
  final List<History> entries;

  String label(DateTime now) {
    final localNow = now.toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    if (date == today) return zh('今天');
    if (date == DateTime(today.year, today.month, today.day - 1)) return zh('昨天');
    final prefix = date.year == today.year ? '' : '${date.year}${zh('年')}';
    return '$prefix${date.month}${zh('月')}${date.day}${zh('日')}';
  }
}

List<HistoryDateGroup> groupHistoryEntries(
  Iterable<History> entries, {
  String query = '',
  HistorySourceFilter source = HistorySourceFilter.all,
}) {
  final keyword = query.trim().toLowerCase();
  final filtered = entries.where((entry) {
    if (!source._matches(entry)) return false;
    final item = entry.bangumiItem;
    return keyword.isEmpty ||
        [item.name, item.nameCn, ...item.alias, entry.adapterName]
            .any((value) => value.toLowerCase().contains(keyword));
  }).toList()
    ..sort((a, b) => b.lastWatchTime.compareTo(a.lastWatchTime));

  final groups = <HistoryDateGroup>[];
  for (final entry in filtered) {
    final localTime = entry.lastWatchTime.toLocal();
    final date = DateTime(localTime.year, localTime.month, localTime.day);
    if (groups.isEmpty || groups.last.date != date) {
      groups.add(HistoryDateGroup._(date, []));
    }
    groups.last.entries.add(entry);
  }
  return groups;
}

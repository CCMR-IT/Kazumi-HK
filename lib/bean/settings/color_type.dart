import 'package:flutter/material.dart';
import 'package:kazumi/utils/zh.dart';

List<Map<String, dynamic>> get colorThemeTypes => [
      {'color': Colors.green, 'label': zh('默认')},
      {'color': Colors.teal, 'label': zh('青色')},
      {'color': Colors.blue, 'label': zh('蓝色')},
      {'color': Colors.indigo, 'label': zh('靛蓝色')},
      {'color': const Color(0xff6750a4), 'label': zh('紫罗兰色')},
      {'color': Colors.pink, 'label': zh('粉红色')},
      {'color': Colors.yellow, 'label': zh('黄色')},
      {'color': Colors.orange, 'label': zh('橙色')},
      {'color': Colors.deepOrange, 'label': zh('深橙色')},
];

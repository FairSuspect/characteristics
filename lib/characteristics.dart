import 'dart:io';

import 'package:intl/intl.dart';

int calculate() {
  return 6 * 7;
}

Future<void> saveHtml(Map<String, String> characteristics) async {
  String html = "<html><body>";
  html += '<ol>';
  characteristics.forEach((key, value) {
    html += '<li><a href="$key.html"> $key </a></li><br>';
    saveOne(key, value);
  });
  html += '</ul>';
  html +=
      "<p>Дата созадния документа ${DateFormat.yMd().format(DateTime.now())}</p>";
  html += "</body></html>";
  final File file = File("output/general.html");
  await file.writeAsString(html);
}

Future<void> saveOne(String name, String characteristic) async {
  String html = "<html><body><div text=align:justify>";

  html += characteristic;

  html +=
      "<p>Дата созадния документа ${DateFormat.yMd().format(DateTime.now())}</p>";
  html += "</div></body></html>";

// Сохраняем файл
  final File file = File("output/$name.html");
  await file.writeAsString(html);
}

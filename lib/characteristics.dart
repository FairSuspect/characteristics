import 'dart:io';

import 'package:intl/intl.dart';

int calculate() {
  return 6 * 7;
}

Future<void> saveHtml(List<String> characteristics) async {
  String html = "<html><body>";

  for (var characteristic in characteristics) {
    html += "<p>$characteristic</p>";
  }
  html +=
      "<p>Дата созадния документа ${DateFormat.yMd().format(DateTime.now())}</p>";
  html += "</body></html>";

// Сохраняем файл
  File file = File("characteristics.html");
  await file.writeAsString(html);
  print('file has been written');
}

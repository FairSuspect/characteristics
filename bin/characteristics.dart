import 'dart:math';

import 'package:characteristics/characteristics.dart' as characteristics;
import 'package:characteristics/characteristics.dart';
import 'package:characteristics/models/person.dart';
import 'package:excel/excel.dart';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() async {
  Intl.defaultLocale = 'ru_RU';
  await initializeDateFormatting('ru_RU', null);

  // Считываем дату, на которую нужно создать характеристику
  print("Введите дату в формате д.месяц.гггг: ");
  String? inputDateStr;
  while (inputDateStr == null) {
    inputDateStr = stdin.readLineSync();
  }
  final DateTime moment = parseDate(inputDateStr);
  final rows = getRows();
  // Создаем характеристику для каждого сотрудника
  List<String> characteristics = [];

  Set<Person> persons = {};

  for (var row in rows) {
    final person = Person.fromXlsRow(row);
    if (persons.contains(person)) {
      var personFromSet = persons.firstWhere((element) => element == person);
      personFromSet.positionChanges.add(PositionChange.fromXlsRow(row));
      persons.remove(person);
      persons.add(personFromSet);
    } else {
      persons.add(Person.fromXlsRow(row));
    }
  }
  for (var person in persons) {
    if (person.birthDate.isAfter(moment)) {
      continue;
    }
    String characteristic = "Характеристика. <br>";

    /// Родился
    characteristic += born(person);

    if (person.hireDate.isBefore(moment)) {
      late final _pos =
          // person.positionChanges.isNotEmpty
          //     ? person.positionChanges.first.position
          //     :
          person.position;
      if (person.hireDate.isBefore(moment)) {
        characteristic +=
            '<li>${DateFormat.yMMMMd('ru').format(person.hireDate)} ${hired(person.gender)} на работу в Фонд на должность "$_pos". </li>';
      }
    }
    if (person.resignationDate != null) {
      if (person.resignationDate!.isBefore(moment)) {
        if (person.positionChanges.isEmpty) {
          characteristic +=
              '<li> Окончательно ${resigned(person.gender)} ${DateFormat.yMMMMd('ru').format(person.resignationDate!)}. </li>';
        } else {
          characteristic +=
              '<li> У${resigned(person.gender).substring(1)} ${DateFormat.yMMMMd('ru').format(person.resignationDate!)} в связи с переходом на должность "${person.positionChanges.first.position}". </li>';
        }
      }
    }
    for (int i = 0; i < person.positionChanges.length; ++i) {
      final pos = person.positionChanges[i];
      if (i == person.positionChanges.length - 1) {
        if (pos.endDate != null && pos.endDate!.isBefore(moment)) {
          characteristic +=
              "<li>Окончательно ${resigned(person.gender)} ${DateFormat.yMMMMd('ru').format(pos.endDate!)}. </li>";
        }
        break;
      }
      if (pos.endDate != null && pos.endDate!.isBefore(moment)) {
        characteristic +=
            '<li>У${resigned(person.gender).substring(1)} ${DateFormat.yMMMMd('ru').format(pos.endDate!)} в связи с переходом на должность "${person.positionChanges[i + 1].position}". </li>';
      }
    }
    characteristic += '</ul>';

    characteristics.add(characteristic);
  }
  saveHtml(characteristics);
}

String born(Person person) =>
    "${person.name} родился ${DateFormat.MMMMd('ru').format(person.birthDate)} ${person.birthDate.year} года. <br><ul>";

String hired(String gender) {
  if (gender.contains('м')) {
    return "устроился";
  }

  if (gender.contains('ж')) {
    return 'устроилась';
  }
  return 'устроится';
}

String resigned(String gender) {
  if (gender.contains('м')) {
    return "уволился";
  }

  if (gender.contains('ж')) {
    return 'уволилась';
  }
  return 'уволится';
}

void update<T>(Set<T> set, int index, T newValue) {
  set.remove(set.elementAt(index));
  set.add(newValue);
}

List<Map<String, dynamic>> getRows() {
  // Считываем данные из xls файла
  final file = File("scp-members.xlsx").readAsBytesSync();
  final excel = Excel.decodeBytes(file);
  List<Map<String, dynamic>> rows = [];
  for (var table in excel.tables.values) {
    final headers = table.rows.first;
    for (int i = 0; i < headers.length; ++i) {
      print("$i: ${headers[i]?.value}");
    }
    for (var cells in table.rows.sublist(1)) {
      Map<String, dynamic> data = {};
      for (int i = 0; i < cells.length; i++) {
        final cell = cells[i];
        late final String value;
        if (cell == null) continue;

        /// Пока нет инстурментов вычисления формулы.
        /// Так как в таблице формала только у DATETIME, я ее повторил.
        /// ДАты получаются в том же формате, что и в таблице (14.дек.2000),
        /// за исключением лишней точки, но если она внезапно появится,
        /// например, если вместо формул поставить текст с датой, то они
        /// запарсятся (см. [months]).
        /// Так что здесь всё честно
        if (cell.isFormula) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(Random().nextInt(
                  DateTime(3000, 12, 31).millisecondsSinceEpoch ~/ 10000) *
              10000);

          value =
              "${dateTime.day}.${mKeys[dateTime.month]}.${DateFormat.y().format(dateTime)}";
        } else {
          value = cells[i]!.value.toString();
        }

        data[headers[i]!.value.toString()] = value;
      }
      rows.add(data);
    }
  }
  return rows;
}

DateTime parseDate(String dateString) {
  final dateRegex = RegExp(r"(\d{2})\.([а-яА-Я]+)\.(\d{4})");
  final match = dateRegex.firstMatch(dateString)!;
  final day = int.parse(match[1]!);
  final month = match[2];
  final year = int.parse(match[3]!);

  const months = {
    "янв": 1,
    "янв.": 1,
    "февр": 2,
    "февр.": 2,
    "март": 3,
    "март.": 3,
    "апр": 4,
    "апр.": 4,
    "май": 5,
    "май.": 5,
    "июнь": 6,
    "июнь.": 6,
    "июль": 7,
    "июль.": 7,
    "авг": 8,
    "авг.": 8,
    "сент": 9,
    "сент.": 9,
    "окт": 10,
    "окт.": 10,
    "нояб": 11,
    "нояб.": 11,
    "дек": 12,
    "дек.": 12,
  };
  return DateTime(year, months[month]!, day);
}

const mKeys = {
  1: 'янв',
  2: "февр",
  3: 'март',
  4: "апр",
  5: "май",
  6: "июнь",
  7: "июль",
  8: "авг",
  9: "сент",
  10: "окт",
  11: "нояб",
  12: "дек"
};

const List<Map<String, dynamic>> _rows = [
  {
    "ФИО": "Иванов Иван Иванович",
    "пол": "мужской",
    "должность": "помощник младшего ассенизатора",
    "дата рождения": "25.04.2050",
    "дата приёма на работу": "04.01.2035",
    "дата увольнения": "31.12.2077",
  },
  {
    "ФИО": "Петров Петр Петрович",
    "пол": "мужской",
    "должность": "ассенизатор",
    "дата рождения": "15.06.2040",
    "дата приёма на работу": "01.01.2030",
    "дата увольнения": "31.12.2065",
  },
  {
    "ФИО": "Петров Петр Петрович",
    "пол": "мужской",
    "должность": "старший ассенизатор",
    "дата рождения": "15.06.2040",
    "дата приёма на работу": "01.01.2030",
    "дата увольнения": "31.12.2065",
  },
  {
    "ФИО": "Сидоров Сидор Сидорович",
    "пол": "мужской",
    "должность": "начальник отдела",
    "дата рождения": "12.12.1970",
    "дата приёма на работу": "31.12.2077",
    "дата увольнения": "31.12.2099",
  },
  {
    "ФИО": "Иванов Иван Иванович",
    "пол": "мужской",
    "должность": "старший помощник младшего ассенизатора",
    "дата рождения": "25.04.2050",
    "дата приёма на работу": "04.01.2035",
    "дата увольнения": "31.12.2077",
  },
  {
    "ФИО": "Иванов Иван Иванович",
    "пол": "мужской",
    "должность": "директор",
    "дата рождения": "25.04.2050",
    "дата приёма на работу": "31.12.2099",
    "дата увольнения": "31.12.2100",
  },
  {
    "ФИО": "Иванов Иван Иванович",
    "пол": "мужской",
    "должность": "СЕО",
    "дата рождения": "25.04.2050",
    "дата приёма на работу": "31.12.2100",
    "дата увольнения": null,
  },
];

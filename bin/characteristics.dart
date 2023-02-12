import 'dart:math';

import 'package:characteristics/characteristics.dart';
import 'package:characteristics/helpers/date_formate.dart';
import 'package:characteristics/helpers/position.dart';
import 'package:characteristics/helpers/verbs.dart';
import 'package:characteristics/models/person.dart';
import 'package:excel/excel.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() async {
  Intl.defaultLocale = 'ru_RU';
  await initializeDateFormatting('ru_RU', null);
  print(DateFormat.yMMMMEEEEd().format(DateTime.now()));

  // DateTime? moment;
  // while (moment == null) {
  //   // Считываем дату, на которую нужно создать характеристику
  //   print("Введите дату в формате день месяц гггг: ");
  //   String? inputDateStr;
  //   while (inputDateStr == null) {
  //     inputDateStr = stdin.readLineSync()?.toLowerCase().replaceAll('ё', 'е');
  //   }

  //   moment = parseDate(inputDateStr);
  // }

  final rows = getRows();
  // Создаем характеристику для каждого сотрудника
  Map<String, String> characteristics = {};

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
    // if (person.birthDate.isAfter(moment)) {
    //   continue;
    // }
    String characteristic =
        '<div align=center><H2 style="margin-left: auto; margin-right: auto;"> ХАРАКТЕРИСТИКА </H2> </div><br>';

    /// Родился
    characteristic += _born(person);

    // if (person.hireDate.isBefore(moment)) {
    late final _pos = position(person.position);
    // person.positionChanges.isNotEmpty
    //     ? person.positionChanges.first.position
    //     :

    // if (person.hireDate.isBefore(moment)) {

    final hireDate = person.hireDate.toRussianDate.replaceFirst(
        person.hireDate.toRussianDate[0],
        person.hireDate.toRussianDate[0].toUpperCase());

    /// Устроился
    characteristic +=
        '<p>$hireDate ${hired(isMale: person.isMale, inFuture: !person.isBorn)} на работу в Фонд на должность ${_pos.toLowerCase()}. </p>';
    // }
    // }
    // if (person.resignationDate != null) {
    // if (person.resignationDate.isBefore(moment)) {

    final firedString = fired(
        inFuture: person.resignationDate.isAfter(DateTime.now()),
        isMale: person.isMale);
    // Позиция - единственная
    if (person.positionChanges.isEmpty) {
      characteristic +=
          // '<p> Окончательно ${resigned(person.gender)} ${DateFormat.yMMMMd('ru').format(person.resignationDate)}. </p>';
          finalFire(firedString, person.resignationDate);
    } else {
      characteristic +=
          '<p> У$firedString ${DateFormat.yMMMMd('ru').format(person.resignationDate)} в связи с переходом на должность "${position(person.positionChanges.first.position)}". </p>';
    }
    // }
    // }
    for (int i = 0; i < person.positionChanges.length; ++i) {
      final pos = person.positionChanges[i];
      if (i == person.positionChanges.length - 1) {
        // if (pos.endDate != null && pos.endDate!.isBefore(moment)) {
        characteristic +=
            "<p>Окончательно $firedString ${DateFormat.yMMMMd('ru').format(pos.endDate!)}. </p>";
        // }
        break;
      }
      // if (pos.endDate != null && pos.endDate!.isBefore(moment)) {
      characteristic +=
          '<p>У$firedString ${pos.endDate!.toRussianDate} в связи с переходом на должность "${position(person.positionChanges[i + 1].position)}". </p>';
      // }
    }

    characteristics[person.name] = characteristic;
  }
  saveHtml(characteristics);
}

String finalFire(String firedString, DateTime resignationDate) {
  return '<p>\tОкончательно $firedString ${resignationDate.toRussianDate}. </p>';
}

String _born(Person person) => "\t${person.name} ${born(
      inFuture: person.birthDate.isAfter(DateTime.now()),
      isMale: person.isMale,
    )} ${person.birthDate.toRussianDate}. <br>";

String _hired(String gender) {
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

DateTime? parseDate(String dateString) {
  try {
    final dateRegex = RegExp(r"([а-яА-Я]+)\ ([а-яА-Я]+)\ (\d{4})");
    final match = dateRegex.firstMatch(dateString)!;
    final day = match[1]!;
    final month = match[2];
    final year = int.parse(match[3]!);

    const months = {
      "янв": 1,
      "янв.": 1,
      "января": 1,
      "февр": 2,
      "февр.": 2,
      "февраля": 2,
      "март": 3,
      "март.": 3,
      "марта": 3,
      "апр": 4,
      "апр.": 4,
      "апреля": 4,
      "май": 5,
      "май.": 5,
      "мая": 5,
      "июнь": 6,
      "июнь.": 6,
      "июня.": 6,
      "июль": 7,
      "июль.": 7,
      "июля": 7,
      "авг": 8,
      "авг.": 8,
      "августа": 8,
      "сент": 9,
      "сент.": 9,
      "сентября": 9,
      "окт": 10,
      "окт.": 10,
      "октября": 10,
      "нояб": 11,
      "нояб.": 11,
      "ноября": 11,
      "дек": 12,
      "дек.": 12,
      "декабря": 12,
    };
    return DateTime(year, months[month]!, fullDays[day]!);
  } catch (e) {
    print("Ошибка при считывании даты: $e");
    return null;
  }
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

const fullDays = {
  "первое": 1,
  "второе": 2,
  "третье": 3,
  "четвертое": 4,
  "пятое": 5,
  "шестое": 6,
  "седьмое": 7,
  "восьмое": 8,
  "девятое": 9,
  "десятое": 10,
  "одиннадцатое": 11,
  "двенадцатое": 12,
  "тринадцатое": 13,
  "четырнадцатое": 14,
  "пятнадцатое": 15,
  "шестнадцатое": 16,
  "семнадцатое": 17,
  "восемнадцатое": 18,
  "девятнадцатое": 19,
  "двадцатое": 20,
  "двадцать первое": 21,
  "двадцать второе": 22,
  "двадцать третье": 23,
  "двадцать четвертое": 24,
  "двадцать пятое": 25,
  "двадцать шестое": 26,
  "двадцать седьмое": 27,
  "двадцать восьмое": 28,
  "двадцать девятое": 29,
  "тридцатое": 30,
  "тридцать первое": 31,
};

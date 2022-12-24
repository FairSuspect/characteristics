import 'dart:io';

import 'package:intl/intl.dart';

class Person {
  final String name;
  final String gender;
  final String position;
  final DateTime birthDate;
  final DateTime hireDate;
  final DateTime resignationDate;
  final List<PositionChange> positionChanges;

  const Person(this.name, this.gender, this.position, this.birthDate,
      this.hireDate, this.resignationDate, this.positionChanges);

  factory Person.fromXlsRow(Map<String, dynamic> row) {
    try {
      final name = row["ФИО"];
      final gender = row["пол"];
      final position = row["должность"];
      final birthDate = parseDate(row["дата рождения"]);
      final hireDate = parseDate(row["дата приёма на работу"]);
      final resignationDate = parseDate(row["дата увольнения"]);
      final positionChanges = <PositionChange>[];

      // Создаем список изменений должностей

      return Person(name, gender, position, birthDate, hireDate,
          resignationDate, positionChanges);
    } catch (e, s) {
      print('failed to parse person from xls row: $row');
      print(e);
      print(s);
      exit(70);
    }
  }
  @override
  int get hashCode => name.hashCode + gender.hashCode + birthDate.hashCode;

  @override
  operator ==(Object other) =>
      other is Person &&
      hashCode == other.hashCode &&
      name == other.name &&
      gender == other.gender &&
      birthDate == other.birthDate;

  @override
  String toString() {
    return "[$name, $gender, $birthDate]";
  }
}

class PositionChange {
  final DateTime startDate;
  final DateTime? endDate;
  final String position;

  const PositionChange(this.startDate, this.endDate, this.position);
  factory PositionChange.fromXlsRow(Map<String, dynamic> row) {
    final startDate =
        DateFormat("dd.MM.yyyy").parse(row["дата приёма на работу"]);
    final endDate = row["дата увольнения"] != null
        ? DateFormat("dd.MM.yyyy").parse(row["дата увольнения"])
        : null;
    final position = row["должность"];

    return PositionChange(startDate, endDate, position);
  }
  @override
  String toString() {
    return "$position [$startDate - $endDate]";
  }
}

DateTime parseDate(String dateString) {
  final dateRegex = RegExp(r"(\d{1,2})\.([а-яА-Я]+)\.(\d{1,4})");
  try {
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
  } catch (e, s) {
    print("Failed to handle $dateString");
    print(e);
    print(s);
    rethrow;
  }
}

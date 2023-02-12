import 'package:intl/intl.dart';

extension RussianCase on DateTime {
  String get toRussianDate {
    final monthString = _months[month];
    return "$_day $monthString $year";
  }

  String get _day {
    switch (day) {
      case 1:
        return "первого";
      case 2:
        return "второго";
      case 3:
        return "третьего";
      case 4:
        return "четвертого";
      case 5:
        return "пятого";
      case 6:
        return "шестого";
      case 7:
        return "седьмого";
      case 8:
        return "восьмого";
      case 9:
        return "девятого";
      case 10:
        return "десятого";
      case 11:
        return "одиннадцатого";
      case 12:
        return "двенадцатого";
      case 13:
        return "тринадцатого";
      case 14:
        return "четырнадцатого";
      case 15:
        return "пятнадцатого";
      case 16:
        return "шестнадцатого";
      case 17:
        return "семнадцатого";
      case 18:
        return "восемнадцатого";
      case 19:
        return "девятнадцатого";
      case 20:
        return "двадцатого";
      case 30:
        return "традцатого";

      default:
        final devided = day ~/ 10;
        final first = devided == 2 ? "двадцать" : "тридцать";
        return "$first ${DateTime(year, month, day % 10)._day}";
    }
  }

  static const _months = {
    1: 'января',
    2: "февраля",
    3: 'марта',
    4: "апреля",
    5: "мая",
    6: "июня",
    7: "июля",
    8: "августа",
    9: "сентября",
    10: "октября",
    11: "ноября",
    12: "декабря"
  };
}

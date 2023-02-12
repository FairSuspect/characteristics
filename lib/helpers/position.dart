String position(String job) {
  final adjectiveMale = RegExp(r'ой( |$)');
  final adjectiveMale2 = RegExp(r'ий( |$)');
  final adjectiveFemale = RegExp(r'ая( |$)');
  final nounFemale = RegExp(r'а( |$)');
  final firstWord = RegExp(r'^.+ ');
  final soft = RegExp(r'^.+ь( |$)');
  final words = job.split(' ');
  final dash = RegExp(r'^.+-.+$');
  if (job.contains(firstWord)) {}

  if (words.length > 1) {
    String word = words.first;
    if (word.contains(adjectiveMale)) {
      word = word.replaceAll(adjectiveMale, 'ого');
    } else if (word.contains(adjectiveFemale)) {
      word = word.replaceAll(adjectiveFemale, 'ой');
    } else if (word.contains(adjectiveMale2)) {
      word = word.replaceAll(adjectiveMale2, 'его');
    } else {
      word += 'а';
    }

    words.first = word;
    String result = '';
    for (final part in words) {
      result += " $part";
    }

    return result;
  }
  if (job.contains(soft)) {
    return job.replaceAll('ь', "я");
  }
  if (job.contains(dash)) {
    var before = '${job.substring(0, job.indexOf('-'))}а';
    var after = '${job.substring(job.indexOf('-'))}а';

    return "$before$after";
  }

  return job += 'а';
}

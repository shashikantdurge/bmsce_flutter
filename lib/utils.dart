///pass `milliseconds` and get time in `HH:mm dd-MM-YYYY`
String toHrTime(String millis) {
  final DateTime ts = DateTime.fromMillisecondsSinceEpoch(int.parse(millis));
  return "${_twoDigits(ts.hour)}:${_twoDigits(ts.minute)}  ${_twoDigits(ts.day)}-${_twoDigits(ts.month)}-${_fourDigits(ts.year)}";
}

String _fourDigits(int n) {
  int absN = n.abs();
  String sign = n < 0 ? "-" : "";
  if (absN >= 1000) return "$n";
  if (absN >= 100) return "${sign}0$absN";
  if (absN >= 10) return "${sign}00$absN";
  return "${sign}000$absN";
}

String _sixDigits(int n) {
  assert(n < -9999 || n > 9999);
  int absN = n.abs();
  String sign = n < 0 ? "-" : "+";
  if (absN >= 100000) return "$sign$absN";
  return "${sign}0$absN";
}

String _threeDigits(int n) {
  if (n >= 100) return "${n}";
  if (n >= 10) return "0${n}";
  return "00${n}";
}

String _twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}

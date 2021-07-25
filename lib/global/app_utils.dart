import 'package:flutter/material.dart';
import 'app_ctes/horario.dart' as Horario;

bool esHoy(DateTime dia) {
  var hoy = DateTime.now();

  if ((dia.day == hoy.day) & (dia.month == hoy.month) & (dia.year == hoy.year))
    return true;
  return false;
}

DateTime lunesDeHoy() =>
    lunesDel(DateTime.parse(DateTime.now().toString().substring(0, 10)));

DateTime lunesDel(DateTime dia) =>
//dia.add(Duration(days: 1 - dia.weekday));
    dia.addCalendarDays(1 - dia.weekday);

DateTime fechaLunesDel1Sept() {
  var hoy = DateTime.now();
  var ano = anoEscolar(hoy);
  return lunesDel(DateTime(ano, 9, 1));
}

int anoEscolar([DateTime? fecha]) {
  fecha = fecha ?? DateTime.now();
  return fecha.month < 9 ? fecha.year - 1 : fecha.year;
}

String cursoEscolar() {
  var uno = anoEscolar();
  return '$uno/${(uno % 100) + 1}';
}

int nSemanaNatural() => nSemandaDe(DateTime.now());

int nSemandaDe(DateTime fecha) {
  var lunes0 = new DateTime(fecha.year, 1, 1, 0, 0);
  final firstMonday = lunes0.weekday;
  lunes0 = lunes0.add(Duration(days: firstMonday - 1));

  final diff = fecha.difference(lunes0).inDays;
  var weeks = (diff / 7).floor();

  // if (firstMonday < 5) weeks++;
  // if (firstMonday > 4) weeks++;

  return weeks + 2;
}

extension DateTimeAddCalendarDays on DateTime {
  DateTime addCalendarDays(int numDays) => copyWith(day: day + numDays);

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    if (this.isUtc) {
      return DateTime.utc(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );
    } else {
      return DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );
    }
  }
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color highlightColor(Color c) {
  if (c.computeLuminance() < 0.5) return Colors.white;
  return Colors.black;
}

double getActividadesHeight(BuildContext context) {
  final double mheight = MediaQuery.of(context).size.height;
  var abheight = AppBar().preferredSize.height;
  var bnheight = MediaQuery.of(context).padding.bottom;
  var pixelsHeight = mheight -
      abheight -
      bnheight -
      Horario.altoCabecera -
      Horario.altoPie -
      2 * Horario.altoAjusteActividades;

  return pixelsHeight;
}

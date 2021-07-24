import 'dart:convert';

import 'dart:ui';

enum TipoEvento { Fin, Normal, Inicio }
enum TipoWidget { Semana, Dia }
enum Categoria { Cero, Uno, Dos, Tres, Cuatro, Cinco } //Colores

class Evento implements Comparable<Evento> {
  // Evento que se va a guardar en la DB
  DateTime fInicio;
  String titulo;
  String? notas;
  Categoria categoria;
  // Período
  bool esPeriodo = false;
  DateTime fFin;
  // Actividad
  bool hayActividad = true;
  // Clave unica db
  String key;

  Evento({
    required this.fInicio,
    required this.titulo,
    this.notas,
    this.categoria = Categoria.Cinco,
    // Periodo
    this.esPeriodo = false,
    fFinal,
    // Actividad
    this.hayActividad = true,
  })  : fFin = esPeriodo ? fFinal ?? fInicio : fInicio,
        key = DateTime.now().microsecondsSinceEpoch.toString();

  static fromStr(String data) => Evento.fromJson(jsonDecode(data));
  factory Evento.fromString(String data) => fromStr(data);

  toString() => jsonEncode(toJson());

  Evento clone() => Evento.fromString(toString());

  Evento.fromJson(Map<String, dynamic> json)
      : fInicio = DateTime.parse(json['finicio']),
        titulo = json['titulo'],
        notas = json['notas'],
        categoria = Categoria.values[int.parse(json['categoria'].toString())],
        esPeriodo = int.parse(json['esPeriodo'].toString()) == 1,
        fFin = DateTime.parse(json['ffin']),
        hayActividad = int.parse(json['hayActividad'].toString()) == 1,
        key = json['key'];

  Map<String, dynamic> toJson() => {
        'finicio': fInicio.toIso8601String().substring(0, 10),
        'titulo': titulo,
        'notas': notas,
        'categoria': categoria.index,
        'esPeriodo': esPeriodo ? 1 : 0,
        'ffin': fFin.toIso8601String().substring(0, 10),
        'hayActividad': hayActividad ? 1 : 0,
        'key': key,
      };

  @override
  int compareTo(Evento other) {
    String val(Evento c) => '${c.fInicio}${c.categoria}${c.titulo}';
    return val(this).compareTo(val(other));
  }
}

class EventoFecha implements Comparable<EventoFecha> {
  // Descompsición de Evento en cada uno de sus partes
  // Un EvItem puede ser Una fecha de inicio, una de fin o una normal
  // y tambien mantiene la clave de marcador de Semana.
  DateTime fecha;
  String titulo;
  String? notas;
  TipoEvento evento;
  Categoria categoria;
  Evento entity;

  EventoFecha(this.evento, this.fecha, this.categoria, this.titulo, this.notas,
      this.entity);

  factory EventoFecha.fromInicio2(Evento e) => EventoFecha(
      TipoEvento.Inicio, e.fInicio, e.categoria, e.titulo, e.notas, e);

  EventoFecha.fromInicio(Evento e)
      : fecha = e.fInicio,
        evento = TipoEvento.Inicio,
        categoria = e.categoria,
        titulo = e.titulo,
        notas = e.notas,
        entity = e;

  EventoFecha.fromFinal(Evento e)
      : fecha = e.fFin,
        evento = TipoEvento.Fin,
        categoria = e.categoria,
        titulo = e.titulo,
        notas = e.notas,
        entity = e;

  EventoFecha.fromEvento(Evento e)
      : fecha = e.fInicio,
        evento = TipoEvento.Normal,
        categoria = e.categoria,
        titulo = e.titulo,
        notas = e.notas,
        entity = e;

  String get val => '${fecha}D${evento.index}${categoria.index}$titulo';
  //'${e.fecha}${e.evento.index}${e.categoria.index}${e.titulo}';

  @override
  int compareTo(EventoFecha other) => this.val.compareTo(other.val);

  @override
  int get hashCode => hashValues(fecha, categoria, evento, titulo);

  @override
  bool operator ==(Object other) =>
      other is EventoFecha &&
      other.fecha == fecha &&
      other.categoria == categoria &&
      other.evento == evento &&
      other.titulo == titulo;
}

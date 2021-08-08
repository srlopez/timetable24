// Marca Horaria HH:MM
class Marca extends Duration {
  Marca(int h, int m) : super(hours: h, minutes: m);

  factory Marca.fromString(String s) {
    List h = s.split(':').map((i) => int.parse(i)).toList();
    return Marca(h[0] % 24, h[1]);
  }

  int diff(Marca prev) {
    return (this - prev).inMinutes;
  }

  Marca add(int minutes) {
    return Marca(0, this.inMinutes + minutes);
  }

  String toString() =>
      super.toString().split('.').first.padLeft(8, "0").substring(0, 5);

  // factory Marca.fromJson(Map<String, dynamic> json) {
  //   return Marca.fromString(json['value']);
  // }

  // Map<String, dynamic> toJson() => {
  //       'value': toString(),
  //     };
}

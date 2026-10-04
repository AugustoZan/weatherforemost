class Clima{
  final String climaTexto;
  final int climaIcono;
  final double? temperatura;
  final bool esDeDia;
  final int tiempo;

  const Clima({
    required this.climaTexto,
    required this.climaIcono,
    this.temperatura,
    required this.esDeDia,
    required this.tiempo,
  });

  factory Clima.fromJson(Map<String, dynamic> json) {

    final climaTexto = json['climaTexto'];
    final climaIcono = json['climaIcono'];
    final temperatura = json['temperatura'];
    final esDeDia = json['esDeDia'];
    final tiempo = json['tiempo'];

    if (climaTexto is! String || climaIcono is! int || esDeDia is! bool || tiempo is! int) {
      throw const FormatException('Datos de clima corruptos');
    }

    return Clima(
      climaTexto: climaTexto,
      climaIcono: climaIcono,
      temperatura: temperatura is num ? temperatura.toDouble() : null,
      esDeDia: esDeDia,
      tiempo: tiempo,
    );
  }

  factory Clima.fromApiJson(Map<String, dynamic> json) {

    final climaTexto = json['WeatherText'];
    final climaIcono = json['WeatherIcon'];
    final esDeDia = json['IsDayTime'];
    final temperatura = json['Temperature']?['Imperial']?['Value'];
    final tiempo = json['EpochTime'];

    if (climaTexto is! String || climaIcono is! int || esDeDia is! bool || tiempo is! int) {
      throw const FormatException('Datos de API inválidos');
    }

    return Clima(
      climaTexto: climaTexto,
      climaIcono: climaIcono,
      temperatura: temperatura is num ? temperatura.toDouble() : null,
      esDeDia: esDeDia,
      tiempo: tiempo,
    );
  }

  Map<String, dynamic> toJson() {
    return
    {
      'climaTexto': climaTexto,
      'climaIcono': climaIcono,
      'temperatura': temperatura,
      'esDeDia': esDeDia,
      'tiempo': tiempo,
    };
  }
}
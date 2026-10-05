/// Entidad de dominio inmutable que representa el estado meteorológico actual.
class Clima {
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

  /// Factoría de deserialización para la base de datos o almacenamiento local.
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
      // Validación segura de tipos: Evita excepciones en runtime si el motor de JSON 
      // parsea un valor entero en lugar de un tipo flotante.
      temperatura: temperatura is num ? temperatura.toDouble() : null,
      esDeDia: esDeDia,
      tiempo: tiempo,
    );
  }

  /// Factoría de deserialización especializada en el contrato y llaves específicas de la API externa.
  factory Clima.fromApiJson(Map<String, dynamic> json) {
    final climaTexto = json['WeatherText'];
    final climaIcono = json['WeatherIcon'];
    final esDeDia = json['IsDayTime'];
    // Acceso defensivo por llaves anidadas utilizando operadores de navegación nula (Null-aware).
    final temperatura = json['Temperature']?['Metric']?['Value'];
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

  /// Serializa la instancia actual mapeando las propiedades a tipos primitivos estándar de JSON.
  Map<String, dynamic> toJson() {
    return {
      'climaTexto': climaTexto,
      'climaIcono': climaIcono,
      'temperatura': temperatura,
      'esDeDia': esDeDia,
      'tiempo': tiempo,
    };
  }
}

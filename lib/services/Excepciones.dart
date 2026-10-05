/// Firma base para errores específicos devueltos por el backend (ej: cuotas agotadas, API key inválida).
/// 
/// Implementa [Exception] para integrarse de forma nativa en bloques 'catch' y flujos de depuración.
class ExcepcionApi implements Exception {
  final String mensaje;
  // Permite almacenar el código HTTP (400, 401, 500) para facilitar el logging o telemetría.
  final int? statusCode;

  const ExcepcionApi(this.mensaje, {this.statusCode});
  
  @override
  // Sobrescribe para proporcionar un volcado legible (Stacktrace Stringification) en la consola del desarrollador.
  String toString() => 'Excepción de API: $mensaje';
}

/// Excepción orientada a fallos físicos de infraestructura (ej: falta de conectividad, Timeout, DNS down).
class ExcepcionDeRed implements Exception {
  final String mensaje;

  const ExcepcionDeRed(this.mensaje);

  @override
  String toString() => 'Excepción de red: $mensaje';
}

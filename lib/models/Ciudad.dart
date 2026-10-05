/// Entidad de dominio inmutable que representa una localización geográfica.
class Ciudad {
  final String nombre;
  final String locationKey;
  final String pais;
  final String estado;
  final String? descripcion;

  const Ciudad({
    required this.nombre,
    required this.locationKey,
    required this.pais,
    required this.estado,
    this.descripcion,
  });

  /// Factoría de deserialización para restaurar la entidad desde el almacenamiento local.
  factory Ciudad.fromJson(Map<String, dynamic> json) {
    final nombre = json['nombre'];
    final locationKey = json['locationKey'];

    if (nombre is! String || locationKey is! String) {
      throw const FormatException('Datos de ciudad corruptos');
    }

    return Ciudad(
      nombre: nombre,
      locationKey: locationKey,
      // Casteo defensivo con operador null-aware para garantizar la consistencia si la estructura local cambia.
      pais: json['pais'] as String? ?? 'Desconocido',
      estado: json['estado'] as String? ?? 'Desconocido',
      descripcion: json['descripcion'] as String?,
    );
  }

  /// Factoría de deserialización especializada en mapear la respuesta estructurada de la API.
  factory Ciudad.fromApiJson(Map<String, dynamic> json) {
    final nombre = json['LocalizedName'];
    final locationKey = json['Key'];

    if (nombre is! String || locationKey is! String) {
      throw const FormatException('Datos de API inválidos');
    }

    return Ciudad(
      nombre: nombre,
      locationKey: locationKey,
      // Navegación segura en nodos anidados del JSON de respuesta para extraer metadatos geográficos.
      pais: json['Country']?['LocalizedName'] ?? 'Desconocido',
      estado: json['AdministrativeArea']?['LocalizedName'] ?? 'Desconocido',
      descripcion: null,
    );
  }

  /// Serializa la instancia actual mapeando las propiedades a tipos primitivos estándar de JSON.
  Map<String, dynamic> toJson() => 
  {
    'nombre': nombre,
    'locationKey': locationKey,
    'pais': pais,
    'estado': estado,
    'descripcion': descripcion,
  };
}

class Ciudad{
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


    factory Ciudad.fromJson(Map<String, dynamic> json) {

    final nombre = json['nombre'];
    final locationKey = json['locationKey'];

    if (nombre is! String || locationKey is! String) {
      throw const FormatException('Datos de ciudad corruptos');
    }

    return Ciudad(
      nombre: nombre,
      locationKey: locationKey,
      pais: json['pais'] as String? ?? 'Desconocido',
      estado: json['estado'] as String? ?? 'Desconocido',
      descripcion: json['descripcion'] as String?,
    );
  }

  factory Ciudad.fromApiJson(Map<String, dynamic> json) {

    final nombre = json['LocalizedName'];
    final locationKey = json['Key'];

    if (nombre is! String || locationKey is! String) {
      throw const FormatException('Datos de API inválidos');
    }

    return Ciudad(
      nombre: nombre,
      locationKey: locationKey,
      pais: json['Country']?['LocalizedName'] ?? 'Desconocido',
      estado: json['AdministrativeArea']?['LocalizedName'] ?? 'Desconocido',
      descripcion: null,
    );
  }

    Map<String, dynamic> toJson() => 
  {
    'nombre': nombre,
    'locationKey': locationKey,
    'pais': pais,
    'estado': estado,
    'descripcion': descripcion,
  };
}
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/secrets.dart';
import '../models/ciudad.dart';
import 'excepciones.dart';

/// Cliente HTTP especializado en el consumo del endpoint de autocompletado y búsqueda de ubicaciones de AccuWeather.
class CiudadServicio {
  static const _baseUrl = 'https://dataservice.accuweather.com/locations/v1/cities/search';

  /// Realiza una consulta asíncrona por texto para obtener coincidencias geográficas del servidor.
  Future<List<Ciudad>> buscarCiudades(String query) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'apikey': climaApiKey,
        'q': query,
        'language': 'es',
      });

      // Aplica un límite de tiempo defensivo para evitar peticiones colgadas en redes inestables (Zombie Connections).
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ExcepcionApi('Error en la API: ${response.statusCode}', statusCode: response.statusCode);
      }

      final data = jsonDecode(response.body);

      if (data is! List || data.isEmpty) {
        throw const ExcepcionApi('Sin datos de ciudad');
      }

      // Filtra de manera segura elementos de tipo Map<String, dynamic> descartando anomalías moleculares del JSON.
      return data
          .whereType<Map<String, dynamic>>()
          .map(Ciudad.fromApiJson)
          .toList();
    } on ExcepcionApi {
      // Propaga la excepción controlada sin alterar ni truncar el Stacktrace original.
      rethrow;
    } catch (e) {
      throw ExcepcionApi('Error inesperado: $e');
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/secrets.dart';
import '../models/clima.dart';
import 'excepciones.dart';

/// Cliente HTTP especializado en el consumo del endpoint de condiciones actuales de AccuWeather.
class ClimaServicio {
  static const _baseUrl = 'https://dataservice.accuweather.com/currentconditions/v1';

  /// Obtiene de forma asíncrona el estado meteorológico actual asociado a un identificador geográfico.
  Future<Clima> obtenerClima(String locationKey) async {
    try {
      final uri = Uri.parse('$_baseUrl/$locationKey').replace(queryParameters: {
        'apikey': climaApiKey,
        'language': 'es',
      });

      // Aplica un límite de tiempo defensivo para evitar peticiones colgadas en redes inestables (Zombie Connections).
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ExcepcionApi('Error en la API: ${response.statusCode}', statusCode: response.statusCode);
      }

      final data = jsonDecode(response.body);

      // Validación rigurosa de tipos en tiempo de ejecución (Runtime Type Checking) ante payloads dynamic.
      if (data is! List || data.isEmpty) {
        throw const ExcepcionApi('Sin datos de clima');
      }

      final item = data[0];
      if (item is! Map<String, dynamic>) {
        throw const ExcepcionApi('Formato de clima inesperado');
      }

      // Fábrica (Factory Constructor) encargada de mapear el mapa tipado al modelo inmutable de dominio.
      return Clima.fromApiJson(item);
    } on ExcepcionApi {
      // Propaga la excepción controlada sin alterar ni truncar el Stacktrace original.
      rethrow;
    } catch (e) {
      throw ExcepcionApi('Error inesperado: $e');
    }
  }
}

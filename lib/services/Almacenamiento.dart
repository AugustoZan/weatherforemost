import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ciudad.dart';

/// Servicio de persistencia local en almacenamiento no volátil mediante Key-Value pairs.
class Almacenamiento {
  static const claveCiudades = 'ciudades_favoritas';

  /// Recupera y deserializa la lista de ciudades almacenadas en el dispositivo.
  Future<List<Ciudad>> cargarCiudades() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final jsonString = preferencias.getString(claveCiudades);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final data = jsonDecode(jsonString);
      if (data is! List) {
        return [];
      }
      return data.map((item) => Ciudad.fromJson(item as Map<String, dynamic>)).toList();

    } catch (e) {
      // Retorna una lista vacía como mecanismo de degradación aceptable (Graceful Degradation) ante corrupción de datos o fallos de E/S.
      return [];
    }
  }

  /// Serializa y persiste de forma destructiva la colección actual de ciudades.
  Future<void> guardarCiudades(List<Ciudad> ciudades) async {
    final preferencias = await SharedPreferences.getInstance();
    // Reduce la jerarquía de objetos a una cadena JSON plana para cumplir con la limitación de tipos nativos de SharedPreferences.
    final jsonString = jsonEncode(ciudades.map((ciudad) => ciudad.toJson()).toList());
    await preferencias.setString(claveCiudades, jsonString);
  }
}

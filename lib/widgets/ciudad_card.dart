import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../providers/clima_provider.dart";
import '../models/ciudad.dart';
import '../models/clima.dart';

/// Componente de presentación inmutable para la vista de una ciudad.
/// 
/// Delega la reactividad y el estado meteorológico a [ClimaProvider].
class CiudadCard extends StatelessWidget {
  final Ciudad ciudad;

  const CiudadCard({super.key, required this.ciudad});

  @override
  Widget build(BuildContext context) {
    // Registra el contexto como observador activo para disparar rebuilds acotados.
    final clima = context.watch<ClimaProvider>().climaDe(ciudad.locationKey);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildIconoClima(clima),
            const SizedBox(width: 12),

            // Absorbe el espacio residual del eje principal para mitigar excepciones de desbordamiento (Overflow).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text(
                    ciudad.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((ciudad.descripcion ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        ciudad.descripcion ?? '', 
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _textoTemperatura(clima),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _textoHora(context, clima),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Procesa la temperatura controlando de forma segura la nulabilidad del estado asíncrono.
  String _textoTemperatura(Clima? clima) {
    if (clima == null) return 'Cargando...'; 
    if (clima.temperatura == null) return 'N/D';
    // Se usa '!' con seguridad tras aplicar las cláusulas de guarda previas.
    return '${clima.temperatura!.toStringAsFixed(1)}°';
  }

  /// Convierte y localiza la marca de tiempo Unix del clima.
  String _textoHora(BuildContext context, Clima? clima) {
    if (clima == null) return '';
    
    // Multiplicación por 1000 debido a que Dart procesa milisegundos en DateTime.
    final fecha = DateTime.fromMillisecondsSinceEpoch(clima.tiempo * 1000);
    // Adapta el string implícitamente al formato local (12h/24h) configurado en el dispositivo.
    return TimeOfDay.fromDateTime(fecha).format(context);
  }

  /// Asigna el catálogo visual de Material Icons según el ID meteorológico de la API de origen.
  Widget _buildIconoClima(Clima? clima) {
    final icono = clima?.climaIcono;
    
    if (icono == null) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.wb_cloudy_outlined, size: 32, color: Colors.grey),
      );
    }

    IconData iconoData;
    Color iconoColor;

    switch (icono) {
      case 1: // Soleado (Sunny)
      case 2: // Mayormente soleado (Mostly Sunny)
      case 3: // Parcialmente soleado (Partly Sunny)
        iconoData = Icons.wb_sunny;
        iconoColor = Colors.orange;
        break;
      case 6: // Mayormente nublado (Mostly Cloudy)
      case 7: // Nublado (Cloudy)
      case 8: // Sombrío / Gris (Dreary)
      case 11: // Neblina (Fog)
        iconoData = Icons.cloud;
        iconoColor = Colors.blueGrey; 
        break;
      case 12: // Chubascos / Lloviznas (Showers)
      case 13: // Mayormente nublado con chubascos (Mostly Cloudy w/ Showers)
      case 14: // Parcialmente soleado con chubascos (Partly Sunny w/ Showers)
      case 18: // Lluvia (Rain)
        iconoData = Icons.grain;
        iconoColor = Colors.blue;
        break;
      case 15: // Tormentas eléctricas (T-Storms)
      case 16: // Mayormente nublado con tormentas eléctricas (Mostly Cloudy w/ T-Storms)
      case 17: // Parcialmente soleado con tormentas eléctricas (Partly Sunny w/ T-Storms)
        iconoData = Icons.thunderstorm;
        iconoColor = Colors.indigo;
        break;
      case 19: // Ráfagas de nieve / Aguanieve (Flurries)
      case 22: // Nieve (Snow)
        iconoData = Icons.ac_unit;
        iconoColor = Colors.lightBlueAccent;
        break;
      case 33: // Noche despejada (Clear Night)
      case 34: // Noche mayormente despejada (Mostly Clear Night)
        iconoData = Icons.nightlight_round;
        iconoColor = Colors.amber;
        break;
      case 35: // Noche parcialmente nublada (Partly Cloudy Night)
      case 36: // Noche con nubes intermitentes (Intermittent Clouds Night)
      case 38: // Noche mayormente nublada (Mostly Cloudy Night)
        iconoData = Icons.cloud_queue;
        iconoColor = Colors.blueGrey;
        break;
      default:
        // Garantiza resiliencia visual (Fallback) ante payloads inesperados o mutaciones del contrato de la API.
        iconoData = Icons.wb_cloudy_outlined;
        iconoColor = Colors.grey;
    }

    // Encapsula el icono para asegurar consistencia estructural y evitar deformaciones en el Row.
    return SizedBox(
      width: 40,
      height: 40,
      child: Icon(
        iconoData,
        size: 32,
        color: iconoColor,
      ),
    );
  }
}

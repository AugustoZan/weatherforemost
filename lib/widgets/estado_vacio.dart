import 'package:flutter/material.dart';

/// Componente de presentación inmutable para indicar la ausencia de datos.
/// 
/// Diseñado para centrarse en pantalla y guiar al usuario a realizar una acción.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        // Se define un eje secundario mínimo para que el widget pueda ser inyectado 
        // dentro de contenedores con restricciones flexibles como un ListView o CustomScrollView.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No hay ciudades agregadas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor, agrega una ciudad para seguir su clima',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

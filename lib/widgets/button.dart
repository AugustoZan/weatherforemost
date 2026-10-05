import 'package:flutter/material.dart';

/// Botón de Acción Flotante (FAB) personalizado para disparar flujos de creación o adición.
/// 
/// Expone una firma limpia mediante [VoidCallback] para delegar la lógica de negocio al componente padre.
class Button extends StatelessWidget {
  final VoidCallback onPressed;

  const Button({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Utiliza el constructor de fábrica '.large' para cumplir con las pautas de accesibilidad y 
    // proporciones visuales de Material Design 3 sin necesidad de forzar dimensiones con un SizedBox.
    return FloatingActionButton.large(
      onPressed: onPressed,
      backgroundColor: const Color.fromARGB(255, 57, 169, 221),
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 36),
    );
  }
}

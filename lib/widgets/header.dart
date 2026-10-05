import 'package:flutter/material.dart';

/// Barra de navegación superior personalizada para la identidad visual de la app.
/// 
/// Implementa [PreferredSizeWidget] para que el framework pueda calcular estáticamente 
/// sus dimensiones antes de la fase de renderizado y ser compatible con la propiedad 'appBar' de un [Scaffold].
class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  // Utiliza la constante global de Material Design para heredar el comportamiento y altura nativa de la plataforma.
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_cloudy, color: Color.fromARGB(255, 57, 169, 221), size: 36),
          const SizedBox(width: 8),
          const Text(
            'WeatherForemost',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

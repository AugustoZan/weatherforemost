import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_screen.dart';
import 'providers/clima_provider.dart';

/// Punto de entrada principal de la aplicación.
void main() {
  runApp(
    // Inyecta el ChangeNotifierProvider en la raíz del árbol para asegurar que el estado global 
    // de la capa meteorológica esté disponible en cualquiera de los subárboles de navegación.
    ChangeNotifierProvider(
      // Se utiliza el operador de cascada (..) para ejecutar la hidratación asíncrona de datos desde 
      // el almacenamiento local inmediatamente después de instanciar el objeto de negocio.
      create: (context) => ClimaProvider()..cargarCiudades(),
      child: const MyApp(),
    ),
  );
}

/// Orquestador de la configuración global del framework y del diseño del sistema.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      debugShowCheckedModeBanner: false,
      // Implementación formal de Material Design 3 mediante una paleta tipográfica y tonal coherente generada por semilla.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), 
    );
  }
}

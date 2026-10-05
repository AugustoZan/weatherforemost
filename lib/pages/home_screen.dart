import "../widgets/button.dart";
import "../widgets/ciudad_card.dart";
import "../widgets/estado_vacio.dart";
import "../widgets/header.dart";
import "../widgets/modal.dart";

import "../providers/clima_provider.dart";

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla base y contenedor principal de la experiencia de usuario.
/// 
/// Ensambla los componentes atómicos de la interfaz y reacciona a los cambios del estado global.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Despliega la interfaz de búsqueda encapsulando el modal en el contexto de navegación actual.
  void _abrirModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Modal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClimaProvider>();
    
    return Scaffold(
      appBar: const Header(),
      body: Column(
        children: [
          // Renderizado condicional declarativo para alternar la visualización según el estado de la colección.
          if (provider.ciudades.isEmpty) 
            const Expanded(
              child: Center(
                child: EstadoVacio(),
              ),
            )
          else 
            Expanded(
              // Utiliza el constructor optimizado '.builder' para reciclar celdas en memoria (View Recycler)
              // y renderizar únicamente los elementos visibles bajo demanda en listas largas.
              child: ListView.builder(
                itemCount: provider.ciudades.length,
                itemBuilder: (context, index) {
                  final ciudad = provider.ciudades[index];
                  return CiudadCard(
                    ciudad: ciudad,
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Button(onPressed: _abrirModal), 
    );
  }
}

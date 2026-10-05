import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ciudad.dart';
import "../providers/clima_provider.dart";
import '../services/excepciones.dart';

/// Hoja inferior interactiva (BottomSheet) para la búsqueda y persistencia de ciudades.
/// 
/// Controla flujos asíncronos de red, optimización de peticiones y validación interna.
class Modal extends StatefulWidget {
  const Modal({super.key});

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  List<Ciudad> _resultados = [];
  Ciudad? _seleccionada;
  bool _buscando = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    // Libera recursos del sistema para prevenir fugas de memoria (Memory Leaks).
    _busquedaController.dispose();
    _descripcionController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Cancela temporizadores previos antes de mutar el estado para mitigar Race Conditions.
  void _onBusquedaCambiada(String texto) {
    _debounce?.cancel();
    // Técnica de Debouncing: Retarda la petición HTTP 400ms para evitar saturar la API con cada pulsación.
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _buscar(texto);
    });
  }

  /// Invoca la búsqueda reactiva en la capa de datos.
  Future<void> _buscar(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _resultados = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _buscando = true;
      _error = null;
    });

    try {
      // Patrón Service Locator temporal vía context.read<T>() para operaciones puntuales no observadas.
      final ciudades =
          await context.read<ClimaProvider>().buscarCiudades(query);
      // Cláusula de guarda: Evita ejecutar setState si el widget fue removido del árbol durante el await.
      if (!mounted) return;
      setState(() {
        _resultados = ciudades;
        _buscando = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Desglose defensivo y tipado de excepciones personalizadas de la capa de infraestructura.
      final mensaje = e is ExcepcionApi
          ? e.mensaje
          : e is ExcepcionDeRed
              ? e.mensaje
              : 'Error inesperado: $e';
      setState(() {
        _error = mensaje;
        _buscando = false;
      });
    }
  }

  /// Registra la ciudad elegida en el estado local y remueve el foco de entrada.
  void _seleccionar(Ciudad ciudad) {
    setState(() {
      _seleccionada = ciudad;
      _resultados = [];
      _busquedaController.clear();
    });
    // Cierra el teclado virtual al limpiar el contexto de enfoque activo.
    FocusScope.of(context).unfocus();
  }

  /// Instancia y persiste la entidad procesada en el Provider.
  Future<void> _guardar() async {
    if (_seleccionada == null) return;

    // Sigue el principio de inmutabilidad creando una nueva instancia con la descripción agregada.
    final ciudadConDescripcion = Ciudad(
      nombre: _seleccionada!.nombre,
      locationKey: _seleccionada!.locationKey,
      pais: _seleccionada!.pais,
      estado: _seleccionada!.estado,
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    await context.read<ClimaProvider>().agregarCiudad(ciudadConDescripcion);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Desplaza dinámicamente el modal calculando la altura del teclado en pantalla (Software Keyboard).
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Agregar ciudad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (_seleccionada == null) ...[
                TextField(
                  controller: _busquedaController,
                  onChanged: _onBusquedaCambiada,
                  decoration: const InputDecoration(
                    labelText: 'Buscar ciudad',
                    hintText: 'Ej: Miami',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                _buildResultados(),
              ] else
                _buildSeleccionada(),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method para la renderización condicional de resultados de la API.
  Widget _buildResultados() {
    if (_buscando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_resultados.isEmpty) {
      final texto = _busquedaController.text.trim().isEmpty
          ? 'Escribí para buscar una ciudad'
          : 'No se encontraron resultados';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(texto, textAlign: TextAlign.center),
      );
    }

    return ConstrainedBox(
      // Define límites estrictos para mitigar excepciones de altura no acotada dentro del BottomSheet.
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _resultados.length,
        itemBuilder: (context, index) {
          final ciudad = _resultados[index];
          return ListTile(
            title: Text(ciudad.nombre),
            subtitle: Text(
              // Limpieza y formateo dinámico omitiendo campos opcionales vacíos.
              [ciudad.estado, ciudad.pais]
                  .where((s) => s.isNotEmpty)
                  .join(', '),
            ),
            onTap: () => _seleccionar(ciudad),
          );
        },
      ),
    );
  }

  /// Helper method para la vista de confirmación y metadatos adicionales.
  Widget _buildSeleccionada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            title: Text(_seleccionada!.nombre),
            subtitle: Text(
              [_seleccionada!.estado, _seleccionada!.pais]
                  .where((s) => s.isNotEmpty)
                  .join(', '),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _seleccionada = null),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            hintText: 'Ej: Casa de mamá',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _seleccionada == null ? null : _guardar,
          child: const Text('Keep / Guardar'),
        ),
      ],
    );
  }
}

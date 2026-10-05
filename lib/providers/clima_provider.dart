import 'package:flutter/foundation.dart';
import '../models/ciudad.dart';
import '../models/clima.dart';
import '../services/ciudad_servicio.dart';
import '../services/clima_servicio.dart';
import '../services/almacenamiento.dart';
import '../services/excepciones.dart';

/// Orquestador de estado global encargado de unificar la lógica de negocio y persistencia meteorológica.
/// 
/// Actúa como un intermediario reactivo aplicando políticas de caché e hidratación asíncrona de datos.
class ClimaProvider extends ChangeNotifier {
  final CiudadServicio ciudadServicio = CiudadServicio();
  final ClimaServicio climaServicio = ClimaServicio();
  final Almacenamiento almacenamiento = Almacenamiento();

  List<Ciudad> _ciudades = [];

  // Colecciones indexadas por 'locationKey' para garantizar búsquedas eficientes O(1) desde la capa de UI.
  final Map<String, Clima> _climaPorCiudad = {};
  final Map<String, DateTime> _ultimaActualizacion = {};

  bool _cargando = false;
  String? _error;

  List<Ciudad> get ciudades => _ciudades;
  bool get cargando => _cargando;
  String? get error => _error;

  Clima? climaDe(String locationKey) => _climaPorCiudad[locationKey];

  /// Estrategia de invalidación de caché (TTL): Limita el consumo de la cuota de la API a intervalos de 10 minutos.
  bool _cacheEsValido(String locationKey) {
    final ultima = _ultimaActualizacion[locationKey];
    return ultima != null &&
        DateTime.now().difference(ultima).inMinutes < 10;
  }

  /// Restaura el estado local e inicializa la recolección paralela del clima.
  Future<void> cargarCiudades() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final ciudadesGuardadas = await almacenamiento.cargarCiudades();
      _ciudades = ciudadesGuardadas;

      if (_ciudades.isNotEmpty) {
        // Ejecución secuencial controlada para no saturar los límites de concurrencia hilos/peticiones.
        for (int i = 0; i < _ciudades.length; i++) {
          await _obtenerClimaSilencioso(_ciudades[i].locationKey);
        }
      }
    } catch (e) {
      _error = 'No se pudieron cargar las ciudades: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<List<Ciudad>> buscarCiudades(String query) {
    return ciudadServicio.buscarCiudades(query);
  }

  /// Agrega y persiste una nueva entidad evitando duplicidades en la colección.
  Future<void> agregarCiudad(Ciudad ciudad) async {
    if (_ciudades.any((c) => c.locationKey == ciudad.locationKey)) {
      return;
    }

    _ciudades.add(ciudad);
    await almacenamiento.guardarCiudades(_ciudades);
    notifyListeners();

    refrescarClima(ciudad.locationKey);
  }

  /// Remueve de forma segura la entidad y limpia sus referencias de caché para evitar fugas de memoria.
  Future<void> eliminarCiudad(String locationKey) async {
    _ciudades = _ciudades.where((c) => c.locationKey != locationKey).toList();
    await almacenamiento.guardarCiudades(_ciudades);

    _climaPorCiudad.remove(locationKey);
    _ultimaActualizacion.remove(locationKey);

    notifyListeners();
  }

  Future<void> refrescarClima(String locationKey) async {
    if (_cacheEsValido(locationKey)) {
      return;
    }

    _cargando = true;
    notifyListeners();

    try {
      await _obtenerClimaSilencioso(locationKey);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Realiza la consulta de red actualizando los mapas de estado sin disparar notificaciones redundantes a la UI.
  Future<void> _obtenerClimaSilencioso(String locationKey) async {
    if (_cacheEsValido(locationKey)) return;

    try {
      final clima = await climaServicio.obtenerClima(locationKey);
      _climaPorCiudad[locationKey] = clima;
      _ultimaActualizacion[locationKey] = DateTime.now();
    } on ExcepcionApi {
      rethrow;
    } catch (e) {
      throw ExcepcionApi('Error inesperado: $e');
    }
  }
}

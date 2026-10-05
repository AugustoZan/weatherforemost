# WeatherForemost

Una aplicación móvil moderna de monitoreo meteorológico construida con **Flutter** y **Provider**, que consume la API de **AccuWeather**. El proyecto está estructurado siguiendo principios de separación de responsabilidades y buenas prácticas recomendadas por *Effective Dart*.

## Características Clave
- **Búsqueda Reactiva con Debouncing:** Optimización de peticiones HTTP en el buscador mediante un temporizador de 400ms para mitigar la saturación de la API.
- **Estrategia de Caché local (TTL):** Invalidation de datos del clima cada 10 minutos para proteger la cuota de consumo del backend y mitigar llamadas redundantes.
- **Persistencia offline:** Almacenamiento no volátil de ciudades favoritas mediante `shared_preferences` con serialización JSON nativa.
- **Manejo Defensivo de Errores:** Infraestructura de excepciones tipadas (`ExcepcionApi` y `ExcepcionDeRed`) y control estricto de nulabilidades (*Sound Null Safety*).
- **Diseño Adaptable:** Componentes construidos sobre Material Design 3 con control dinámico del área visual expuesta por el teclado virtual (`viewInsets`).

## Arquitectura y Flujo de Datos
El proyecto implementa una arquitectura desacoplada en tres capas principales:

1. **Capa de Dominio / Modelos (`/models`):** 
   - Contiene las entidades inmutables `Ciudad` y `Clima`.
   - Implementa constructores tipo *factory* independientes para mapear de manera segura tanto el almacenamiento local (`fromJson`) como las respuestas del contrato de la API (`fromApiJson`).
2. **Capa de Infraestructura / Servicios (`/services`):**
   - `CiudadServicio` y `ClimaServicio`: Clientes HTTP aislados encargados del consumo de endpoints externos con control de tiempos de espera (`timeout`).
   - `Almacenamiento`: Abstracción de persistencia local en disco.
3. **Capa de Estado y UI (`/providers` y `/widgets`):**
   - `ClimaProvider` (State Management): Orquestador central basado en el patrón Observer que expone un estado reactivo y centralizado.
   - Componentes modulares y de presentación pura (`CiudadCard`, `Button`, `Header`, `EstadoVacio`) que consumen el estado eficientemente mediante `context.watch<T>()` y `context.read<T>()`.

## Decisiones Técnicas Destacadas
- **Eficiencia en Rebuilds:** Se limitó el alcance de la reactividad acotando subárboles mediante el uso estratégico de constructores `const` y modularización interna para evitar sobrecarga en el recolector de basura.
- **Listas Optimizadas:** Uso de `ListView.builder` para garantizar la reutilización de celdas en memoria (*View Recycler*) bajo demanda visual en escenarios de colecciones densas.
- **Guardas Asíncronas:** Uso sistemático de verificaciones `if (!mounted)` tras suspensiones asíncronas (`await`) para blindar el estado de los componentes ante desmontajes repentinos de la UI.

## Primeros Pasos

### Requisitos previos
- Flutter SDK (Versión estable recomendada)
- Una API Key válida de AccuWeather

### Configuración del Entorno
Para ejecutar la aplicación de manera local, crea el archivo de configuración con tu llave privada:

1. Ve a la ruta `lib/config/secrets.dart`.
2. Define tu constante global del servicio:
   ```dart
   const String climaApiKey = 'TU_ACCUWEATHER_API_KEY';
   ```

### Instalación y Ejecución
```bash
# Descargar dependencias del pubspec.yaml
flutter pub get

# Ejecutar el proyecto en modo debug
flutter run
```

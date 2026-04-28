# Promos UI + Imagenes (Web) Design

## Contexto
La app ya carga datos desde assets/data/promomania_data.json con PromoService. Las pantallas de usuario (explore/favorites/home) usan datos hardcodeados en UI y deben pasar a datos dinamicos sin cambiar el diseño. En web, el guardado de imagen falla por MissingPluginException de path_provider.

## Objetivos
- Cargar promociones, favoritos y tiendas desde PromoService y el JSON.
- Mantener el mismo look and feel de las pantallas en lib/User.
- Arreglar el flujo de imagenes en web sin persistencia (solo en memoria).
- Preparar datos para mapa (coord por promo, ciudad en usuario) sin re-trabajar el mapa aun.

## No objetivos
- No cambiar el diseno visual de las pantallas.
- No implementar geolocalizacion real ni mapa basado en GPS.
- No persistir imagenes en web mas alla de la sesion actual.

## Enfoque elegido
Mapeo local por pantalla: cada pantalla construye sus listas de tarjetas desde PromoService con helpers privados. Esto minimiza cambios y mantiene el diseño intacto.

## Cambios de datos y modelos
- JSON (assets/data/promomania_data.json)
  - Agregar ciudad en usuarios: "ciudad".
  - Agregar coordenadas en promociones: "lat" y "lng" (double).
  - Aumentar cantidad de promociones para poblar UI.
- Modelo Usuario: agregar campo ciudad.
- Modelo Promocion: agregar campos lat, lng (double?).
- PromoService: mapear los nuevos campos y exponerlos via getters existentes.

## Mapeo de datos por pantalla (sin cambiar UI)
### lib/User/user_explore_screen.dart
- Eliminar listas _flashDeals, _nearbyStores, _promos hardcodeadas.
- Construir:
  - Flash Deals: top N por descuento (fallback por vistas si descuento null).
  - Nearby Stores: derivar de promociones + supermercados (distancia/tiempo simulados por id hasta tener GPS).
  - Todas las promociones: getPromocionesAprobadas().
- Calcular valores UI desde datos reales:
  - descuento/originalPrice: precio + descuento.
  - rating/reviews: valoraciones y comentarios.
  - time: a partir de fecha_fin (o "permanente").
  - emoji y categoryColor: por categoria.

### lib/User/user_favorites_screen.dart
- Eliminar _allPromos hardcodeado.
- Construir desde getFavoritosByUsuario + promo/supermercado.
- Urgencia:
  - today: fecha_fin en 24h.
  - thisWeek: fecha_fin en 7 dias.
  - noRush: permanente o > 7 dias.

### lib/User/user_home_screen.dart
- Reemplazar promos del mapa por promociones reales con lat/lng.
- Centro del mapa queda fijo por ahora (mapa pospuesto).

### Simplified screens
- Mantener listas actuales pero mostrar estado de carga/errores (FutureBuilder/AnimatedBuilder) usando PromoService.

### lib/User/user_promo_detail_screen.dart
- Ya usa PromoService. Solo unificar logica de imagen para soportar bytes locales.

## Imagenes en web (bug path_provider)
- Causa: path_provider no tiene implementacion en web.
- Solucion web:
  - Guardar bytes en memoria al seleccionar imagenes.
  - Pasar bytes en draftData entre pantallas (AddPromotion2 -> AddPromotion5).
  - No escribir a disco en web.
- Validacion:
  - Bloquear "Siguiente" si no hay imagen valida.
- Preview:
  - Si hay bytes, Image.memory.
  - Si hay URL, Image.network.
- Cache en memoria:
  - PromoService mantiene Map<codigo, Uint8List> para imagen principal de promos creadas en sesion.

## Manejo de carga y errores
- PromoService expone loaded + loadError.
- Pantallas muestran:
  - loading mientras se inicializa.
  - error si JSON falla.

## Riesgos y mitigaciones
- Datos incompletos en JSON: agregar valores de fallback en mapeo.
- Imagenes en web solo en memoria: dejar claro que no persisten (esperado).

## Pendiente
- Mapa por ciudad/ubicacion real del usuario (pospuesto).

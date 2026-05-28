# Guía de Migración a Provider - PromoMania

## Resumen
Migración de `ChangeNotifier + AnimatedBuilder` a `Provider + Consumer` para cumplir con lineamientos del proyecto.

## Cambios realizados

### 1. Configuración inicial
- ✅ `provider: ^6.1.2` ya está en `pubspec.yaml`
- ✅ Creado `main_provider.dart` con `MultiProvider`
- ✅ Pantalla piloto migrada: `user_explore_screen_provider.dart`

### 2. Patrón de migración

#### ANTES (AnimatedBuilder):
```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: promoService,
    builder: (context, _) {
      // UI que usa promoService
      return Scaffold(...);
    },
  );
}
```

#### DESPUÉS (Consumer):
```dart
import 'package:provider/provider.dart';
import 'features/promotions/infrastructure/services/promo_service.dart';

@override
Widget build(BuildContext context) {
  return Consumer<PromoService>(
    builder: (context, promoService, child) {
      // UI que usa promoService (sin cambios)
      return Scaffold(...);
    },
  );
}
```

## Pasos para migrar cada pantalla

### 1. Agregar imports
```dart
import 'package:provider/provider.dart';
import 'features/promotions/infrastructure/services/promo_service.dart';
```

### 2. Reemplazar AnimatedBuilder
```dart
// Buscar este patrón:
AnimatedBuilder(
  animation: promoService,
  builder: (context, _) {
    // contenido
  },
)

// Reemplazar con:
Consumer<PromoService>(
  builder: (context, promoService, child) {
    // mismo contenido
  },
)
```

### 3. Acceder a promoService
- ANTES: `promoService` (variable global)
- DESPUÉS: `promoService` (parámetro del Consumer)

## Pantallas que necesitan migración

### User Screens
- [ ] `user_favorites_screen.dart`
- [ ] `user_promo_detail_screen.dart`
- [ ] `user_profile_edit_screen.dart`

### Admin Screens
- [ ] `admin_dashboard_screen.dart`
- [ ] `admin_dashboard_simplified_screen.dart`
- [ ] `admin_usuarios_screen.dart`
- [ ] `admin_promos_screen.dart`
- [ ] `admin_store_screen.dart`
- [ ] `admin_noti_activity_screen.dart`
- [ ] `admin_noti_report_screen.dart`
- [ ] `admin_noti_alert_screen.dart`
- [ ] `admin_noti_exportar_screen.dart`

## Script de migración automatizada

Para cada archivo, ejecutar:
```powershell
# 1. Agregar imports
$file = "ruta\del\archivo.dart"
$c = Get-Content $file -Raw
$c = $c -Replace "import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';`nimport 'package:provider/provider.dart';`nimport 'features/promotions/infrastructure/services/promo_service.dart';"

# 2. Reemplazar AnimatedBuilder con Consumer
$c = $c -Replace "AnimatedBuilder\(`n      animation: promoService,`n      builder: \(context, _\) \{", "Consumer<PromoService>(`n      builder: (context, promoService, child) {"

# 3. Guardar
Set-Content $file $c -Encoding UTF8
```

## Consideraciones importantes

### 1. Performance
- `Consumer` reconstruye solo el widget contenido
- `Selector` (opcional) para reconstrucciones más granulares:
```dart
Selector<PromoService, List<Promocion>>(
  selector: (context, promoService) => promoService.getActivePromotionsSync(),
  builder: (context, promos, child) {
    return ListView.builder(...);
  },
)
```

### 2. Testing
```dart
// Para tests, envolver el widget con Provider
testWidgets('mi test', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: MockPromoService(),
      child: MaterialApp(
        home: MiPantalla(),
      ),
    ),
  );
});
```

### 3. Múltiples providers
```dart
// Para acceder a otros servicios en el futuro:
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: AppScope.promoService),
    ChangeNotifierProvider.value(value: AppScope.authController),
    ChangeNotifierProvider.value(value: AppScope.sessionManager),
  ],
  child: MyApp(),
)
```

## Validación final

### 1. Compilar
```bash
flutter analyze --no-pub
flutter build apk --debug
```

### 2. Testing manual
- [ ] Navegación funciona
- [ ] Estado se actualiza correctamente
- [ ] Performance sin degradación
- [ ] No memory leaks

### 3. Tests automatizados
```bash
flutter test
```

## Timeline estimado

- **Día 1**: Migrar 2-3 pantallas simples
- **Día 2**: Migrar pantallas admin restantes
- **Día 3**: Testing y optimización
- **Día 4**: Validación final y deployment

## Beneficios esperados

1. **Cumplimiento de lineamientos**: Uso obligatorio de Provider
2. **Mejor testabilidad**: Inyección de dependencias más clara
3. **Performance**: Reconstrucciones más controladas
4. **Maintainability**: Código más estándar en Flutter

## Risks y mitigaciones

### Risk: Regresiones en UI
- **Mitigación**: Testing exhaustivo de cada pantalla migrada

### Risk: Performance issues
- **Mitigación**: Uso de `Selector` para widgets complejos

### Risk: Learning curve
- **Mitigación**: Documentación y ejemplos claros

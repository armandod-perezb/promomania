/// README de la Arquitectura Hexagonal

# Estructura Hexagonal del Proyecto Promomania

Este proyecto utiliza **Arquitectura Hexagonal (Ports & Adapters)** para mantener
una separación clara de responsabilidades y facilitar la testabilidad y mantenibilidad.

## Estructura de Carpetas

```
lib/
├── core/                          # Código compartido
│   ├── config/                    # Configuración global
│   ├── network/                   # Cliente HTTP, interceptors
│   ├── storage/                   # Almacenamiento local/seguro
│   ├── errors/                    # Excepciones y fallos
│   ├── utils/                     # Utilidades (validators, formatters, helpers)
│   └── shared/                    # Widgets, temas, componentes compartidos
│
├── features/                      # Características del negocio
│   ├── auth/                      # Autenticación
│   ├── users/                     # Gestión de usuarios
│   ├── promotions/                # Gestión de promociones (core del negocio)
│   ├── comments/                  # Comentarios
│   ├── interactions/              # Favoritos y valoraciones
│   ├── notifications/             # Notificaciones
│   ├── moderation/                # Reportes y moderación
│   └── catalog/                   # Categorías y tipos de promoción
│
└── main.dart

```

## Capas Hexagonales por Feature

Cada feature sigue esta estructura de 4 capas:

### 1. **Domain** (Núcleo de Negocio)
```
feature/domain/
├── entities/          # Modelos de dominio (Usuario, Promocion, etc)
├── repositories/      # Interfaces de repositorios (contratos)
├── services/          # Servicios de dominio (lógica de negocio)
└── usecases/          # Casos de uso (flujos de negocio)
```

**Responsabilidades:**
- Define las reglas de negocio
- No tiene dependencias externas
- Completamente independiente de frameworks

### 2. **Application** (Capa de Aplicación)
```
feature/application/
└── dtos/              # Data Transfer Objects (transferencia de datos)
```

**Responsabilidades:**
- DTOs para transferir datos entre capas
- Mapeos entre modelos de dominio y presentación
- Coordinación de operaciones complejas

### 3. **Infrastructure** (Implementación Técnica)
```
feature/infrastructure/
├── datasources/       # Interfaces y implementaciones de acceso a datos
├── models/            # Modelos de infraestructura (compatible con API/BD)
├── repositories/      # Implementaciones de repositorios del dominio
└── services/          # Servicios técnicos (persistencia local, integración)
```

**Responsabilidades:**
- Implementa los repositorios definidos en domain
- Acceso a datos (API, BD local, caché)
- Conversión entre modelos de dominio y modelos de infraestructura

## Integración de lib/services en Hexagonal

- PromoService se movió a features/promotions/infrastructure/services/promo_service.dart
- SessionManager se movió a core/storage/session_manager.dart
- ImageStorageService se movió a core/storage/image_storage_service.dart
- lib/services quedó como capa de compatibilidad temporal con exports deprecados

### 4. **Presentation** (Interfaz de Usuario)
```
feature/presentation/
├── pages/             # Pantallas completas
├── controllers/       # Controladores de estado (GetX, Riverpod, etc)
└── widgets/           # Widgets reutilizables
```

**Responsabilidades:**
- UI y experiencia del usuario
- Gestión de estado local
- Interacción con el usuario

## Flujo de Datos

```
Presentation (UI)
    ↓ (usuario interactúa)
Controllers (lógica de UI)
    ↓ (llama usecase)
Domain: UseCases (orquesta operaciones)
    ↓ (usa repositorio)
Domain: Repositories (interfaz)
    ↓ (implementación)
Infrastructure: Repositories (implementación concreta)
    ↓ (usa datasource)
Infrastructure: DataSources (acceso a datos)
    ↓ (llamadas API, BD, etc)
External Services
```

## Ejemplos de Implementación

### Usar un Caso de Uso en un Controlador

```dart
class LoginController extends GetxController {
  final LoginUseCase loginUseCase;
  
  LoginController(this.loginUseCase);
  
  void login(String correo, String password) async {
    try {
      final user = await loginUseCase.execute(correo, password);
      // Manejar éxito
    } catch (e) {
      // Manejar error
    }
  }
}
```

### Implementar un Repositorio

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  final SessionManager sessionManager;
  
  AuthRepositoryImpl(this.authDataSource, this.sessionManager);
  
  @override
  Future<Usuario> login({
    required String correo,
    required String password,
  }) async {
    final usuarioModel = await authDataSource.login(correo, password);
    final usuario = usuarioModel.toEntity();
    await sessionManager.saveUser(usuario);
    return usuario;
  }
}
```

## Ventajas de esta Arquitectura

✅ **Independencia de Frameworks**: La lógica de negocio no depende de Flutter, GetX, etc.
✅ **Testabilidad**: Cada capa se puede testear independientemente
✅ **Mantenibilidad**: Cambios en la UI no afectan la lógica de negocio
✅ **Escalabilidad**: Fácil agregar nuevas features sin romper las existentes
✅ **Reusabilidad**: El código de dominio se puede reutilizar en otras plataformas

## Guías de Desarrollo

### Agregar una Nueva Feature

1. Crear la carpeta `features/nueva_feature`
2. Crear las 4 subcarpetas: domain, application, infrastructure, presentation
3. Empezar por domain (entities, repositories)
4. Luego infrastructure (implementación de repositories)
5. Luego presentation (UI y controllers)

### Inyección de Dependencias

Se recomienda usar **GetIt** o **Riverpod** para inyección de dependencias:

```dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  getIt.registerSingleton<PromotionRepository>(
    PromotionRepositoryImpl(getIt(), getIt()),
  );
  
  // Use Cases
  getIt.registerSingleton<GetActivePromotionsUseCase>(
    GetActivePromotionsUseCase(getIt()),
  );
  
  // Controllers
  getIt.registerFactory<PromotionController>(
    () => PromotionController(getIt()),
  );
}
```

## Archivos Base Proporcionados

- ✅ Entities (modelos de dominio)
- ✅ Repository Interfaces
- ✅ DTOs
- ✅ Exceptions y Failures

Próximos pasos:
- [ ] Implementar DataSources
- [ ] Implementar Repositories
- [ ] Crear Use Cases
- [ ] Desarrollar Presentation Layer

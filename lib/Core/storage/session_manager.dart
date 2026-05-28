import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Gestor de sesión con patrón Singleton
/// Maneja la persistencia de datos del usuario logueado usando SharedPreferences
class SessionManager {
  static final SessionManager _instance = SessionManager._();
  static SharedPreferences? _prefs;
  Usuario? _usuarioActual;

  // Claves para SharedPreferences
  static const String _keyUsuarioId = 'usuario_id';
  static const String _keyUsuarioNombre = 'usuario_nombre';
  static const String _keyUsuarioCorreo = 'usuario_correo';
  static const String _keyUsuarioRol = 'usuario_rol';
  static const String _keyUsuarioEstado = 'usuario_estado';
  static const String _keyLoginTime = 'login_time';
  static const String _keySessionExpiry = 'session_expiry';
  static const String _keyBearerToken = 'bearer_token';

  String? _token;

  /// Token Bearer activo para llamadas a la API REST.
  String? get token => _token;

  SessionManager._();

  factory SessionManager() {
    return _instance;
  }

  /// Inicializa el SessionManager con SharedPreferences
  /// Debe llamarse una sola vez al inicio de la app
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _instance._cargarSesion();
  }

  /// Carga la sesión guardada de SharedPreferences
  void _cargarSesion() {
    final usuarioId = _prefs?.getInt(_keyUsuarioId);
    if (usuarioId != null && usuarioId > 0) {
      _usuarioActual = Usuario(
        id: usuarioId,
        nombre: _prefs?.getString(_keyUsuarioNombre) ?? '',
        correo: _prefs?.getString(_keyUsuarioCorreo) ?? '',
        password: '', // No guardamos contraseña por seguridad
        rol: _prefs?.getString(_keyUsuarioRol) ?? 'user',
        estado: _prefs?.getString(_keyUsuarioEstado) ?? 'activo',
      );
    }
    _token = _prefs?.getString(_keyBearerToken);
  }

  /// Obtiene el usuario actualmente logueado
  Usuario? get usuarioActual => _usuarioActual;

  /// Verifica si hay una sesión activa
  bool get isLoggedIn => _usuarioActual != null;

  /// Verifica si el usuario actual es admin
  bool get isAdmin => _usuarioActual?.rol == 'admin';

  /// Guarda la sesión de un usuario después de login exitoso.
  /// Si se provee [token], también lo persiste para llamadas a la API.
  Future<bool> guardarSesion(Usuario usuario, {String? token}) async {
    try {
      _usuarioActual = usuario;
      await _prefs?.setInt(_keyUsuarioId, usuario.id);
      await _prefs?.setString(_keyUsuarioNombre, usuario.nombre);
      await _prefs?.setString(_keyUsuarioCorreo, usuario.correo);
      await _prefs?.setString(_keyUsuarioRol, usuario.rol);
      await _prefs?.setString(_keyUsuarioEstado, usuario.estado);
      await _prefs?.setString(_keyLoginTime, DateTime.now().toIso8601String());
      if (token != null) {
        _token = token;
        await _prefs?.setString(_keyBearerToken, token);
      }
      return true;
    } catch (e) {
      print('Error guardando sesión: $e');
      return false;
    }
  }

  /// Actualiza los datos del usuario actual sin perder la sesión
  Future<bool> actualizarUsuario(Usuario usuarioActualizado) async {
    try {
      _usuarioActual = usuarioActualizado;
      await _prefs?.setString(_keyUsuarioNombre, usuarioActualizado.nombre);
      await _prefs?.setString(_keyUsuarioCorreo, usuarioActualizado.correo);
      await _prefs?.setString(_keyUsuarioRol, usuarioActualizado.rol);
      await _prefs?.setString(_keyUsuarioEstado, usuarioActualizado.estado);
      return true;
    } catch (e) {
      print('Error actualizando usuario: $e');
      return false;
    }
  }

  /// Cierra la sesión actual y limpia los datos
  Future<bool> logout() async {
    try {
      _usuarioActual = null;
      _token = null;
      await _prefs?.remove(_keyUsuarioId);
      await _prefs?.remove(_keyUsuarioNombre);
      await _prefs?.remove(_keyUsuarioCorreo);
      await _prefs?.remove(_keyUsuarioRol);
      await _prefs?.remove(_keyUsuarioEstado);
      await _prefs?.remove(_keyLoginTime);
      await _prefs?.remove(_keyBearerToken);
      return true;
    } catch (e) {
      print('Error en logout: $e');
      return false;
    }
  }

  /// Obtiene el tiempo desde que se inició la sesión
  Duration? getTiempoSesion() {
    final loginTime = _prefs?.getString(_keyLoginTime);
    if (loginTime != null) {
      try {
        final dateTime = DateTime.parse(loginTime);
        return DateTime.now().difference(dateTime);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Obtiene todos los datos de sesión como mapa
  Map<String, dynamic> obtenerDatosSesion() {
    return {
      'usuarioId': _usuarioActual?.id,
      'usuarioNombre': _usuarioActual?.nombre,
      'usuarioCorreo': _usuarioActual?.correo,
      'usuarioRol': _usuarioActual?.rol,
      'usuarioEstado': _usuarioActual?.estado,
      'tiempoSesion': getTiempoSesion()?.toString(),
      'isLoggedIn': isLoggedIn,
      'isAdmin': isAdmin,
    };
  }

  /// Limpia todos los datos de sesión (equivalente a logout completo)
  Future<void> clear() async {
    _usuarioActual = null;
    await _prefs?.clear();
  }
}

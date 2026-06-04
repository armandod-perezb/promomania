/// Configuracion relacionada con mapas, coordenadas por defecto y proveedores de ubicacion.
class AppMapConfig {
  AppMapConfig._();

  static const tileUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static const tileSubdomains = ['a', 'b', 'c', 'd'];
  static const userAgentPackageName = 'com.example.app';
}

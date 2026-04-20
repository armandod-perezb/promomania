import 'package:flutter/material.dart';
import '../main.dart';

/// Pantalla de ejemplo que muestra cómo usar SessionManager
/// Esta es una pantalla de referencia para demostrar las funcionalidades

class SessionDemoScreen extends StatefulWidget {
  const SessionDemoScreen({super.key});

  @override
  State<SessionDemoScreen> createState() => _SessionDemoScreenState();
}

class _SessionDemoScreenState extends State<SessionDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo - Manejo de Sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ejemplos de uso de SessionManager',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildExample(
              title: '1. Verificar si hay sesión activa',
              code: '''
bool isLoggedIn = sessionManager.isLoggedIn;
if (isLoggedIn) {
  print("Usuario logueado");
} else {
  print("No hay sesión activa");
}
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '2. Obtener usuario actual',
              code: '''
Usuario? usuario = sessionManager.usuarioActual;
if (usuario != null) {
  print("Usuario: \${usuario.nombre}");
  print("Email: \${usuario.correo}");
  print("Rol: \${usuario.rol}");
}
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '3. Guardar sesión al login',
              code: '''
// En el login screen:
final usuario = promoService.getUsuarioByEmail(email);
if (usuario.password == password) {
  await sessionManager.guardarSesion(usuario);
  // Navegar a pantalla principal
}
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '4. Actualizar datos de usuario en sesión',
              code: '''
final usuarioActualizado = usuario.copyWith(
  nombre: "Nuevo nombre"
);
await sessionManager.actualizarUsuario(usuarioActualizado);
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '5. Verificar si es admin',
              code: '''
bool isAdmin = sessionManager.isAdmin;
if (isAdmin) {
  // Mostrar opciones de admin
}
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '6. Cerrar sesión (logout)',
              code: '''
await sessionManager.logout();
Navigator.pushReplacementNamed(context, AppRoutes.login);
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '7. Obtener tiempo de sesión',
              code: '''
Duration? tiempoSesion = sessionManager.getTiempoSesion();
if (tiempoSesion != null) {
  print("Sesión activa hace: \${tiempoSesion.inMinutes} minutos");
}
              ''',
            ),
            const SizedBox(height: 16),
            _buildExample(
              title: '8. Obtener todos los datos de sesión',
              code: '''
Map<String, dynamic> datos = sessionManager.obtenerDatosSesion();
print(datos);
// Retorna: {
//   'usuarioId': 2,
//   'usuarioNombre': 'Juan Pérez',
//   'usuarioCorreo': 'juan@gmail.com',
//   'usuarioRol': 'user',
//   'usuarioEstado': 'activo',
//   'tiempoSesion': '0:05:30.123456',
//   'isLoggedIn': true,
//   'isAdmin': false,
// }
              ''',
            ),
            const SizedBox(height: 16),
            _buildInfoBox(
              'INFO: El SessionManager es un SINGLETON',
              'Esto significa que hay una única instancia en toda la app. '
                  'Se accede globalmente mediante sessionManager (declarado en main.dart). '
                  'Los datos persisten en SharedPreferences automáticamente.',
            ),
            const SizedBox(height: 20),
            _buildSessionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildExample({required String title, required String code}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(8),
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.left(
          side: BorderSide(color: Colors.blue[400]!, width: 4),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: Colors.blue[800])),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado actual de la sesión:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (sessionManager.isLoggedIn) ...[
              _buildInfoRow(
                'Usuario ID',
                '${sessionManager.usuarioActual?.id}',
              ),
              _buildInfoRow(
                'Nombre',
                sessionManager.usuarioActual?.nombre ?? 'N/A',
              ),
              _buildInfoRow(
                'Email',
                sessionManager.usuarioActual?.correo ?? 'N/A',
              ),
              _buildInfoRow('Rol', sessionManager.usuarioActual?.rol ?? 'N/A'),
              _buildInfoRow(
                'Tiempo de sesión',
                _formatDuration(sessionManager.getTiempoSesion()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else
              const Text(
                'No hay sesión activa',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _logout() async {
    await sessionManager.logout();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
      setState(() {});
    }
  }
}

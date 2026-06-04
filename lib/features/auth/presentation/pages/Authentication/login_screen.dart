// Importaciones necesarias para la pantalla de inicio de sesión
import 'package:flutter/material.dart'; // UI framework principal
import '../../../../../Core/Routes/app_routes.dart'; // Definición de rutas de navegación
import '../../../../../Core/utils/validators.dart';
import '../../controllers/auth_controller.dart';

/// Pantalla de inicio de sesión de usuarios
/// Permite autenticar usuarios con email y contraseña
/// Incluye navegación basada en roles (admin/usuario) y opciones sociales
class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Estado interno de `LoginScreen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto del formulario
  final TextEditingController _emailController =
      TextEditingController(); // Campo de email
  final TextEditingController _passwordController =
      TextEditingController(); // Campo de contraseña

  // Variables de estado de UI
  bool _obscurePassword = true; // Ocultar/mostrar contraseña
  bool _rememberMe = false; // Recordar sesión (placeholder)
  bool _isLoading = false; // Estado de carga durante login

  // Colores constantes de la aplicación
  static const Color _primary = Color(
    0xFFFF4D2E,
  ); // Color primario rojo/naranja
  static const Color _darkBg = Color(0xFF1A1F2E); // Fondo oscuro para header
  static const Color _lightBg = Color(0xFFF8F9FB); // Fondo claro principal

  @override
  void dispose() {
    // Liberar recursos de los controladores para evitar memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Método principal para iniciar sesión de usuario
  /// Valida campos, busca usuario, verifica contraseña y navega según rol
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Buscar usuario en la base de datos por email
      final usuario = await widget.authController.login(
        correo: email,
        password: password,
      );

      // Si el widget aún está montado, navegar según el rol del usuario
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          usuario.rol == 'admin'
              ? AppRoutes
                    .adminDashboard // Admin va al dashboard
              : AppRoutes.userHome, // Usuario va al mapa principal
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      // Siempre detener el estado de carga al finalizar
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg, // Fondo claro principal
      body: Column(
        children: [
          // Header con título y subtítulo
          _buildHeader(),
          // Contenido del formulario scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de email
                  _buildField(
                    label: 'CORREO',
                    hint: 'ejemplo@gmail.com',
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress, // Teclado con @ y .com
                  ),
                  const SizedBox(height: 20),
                  // Campo de contraseña
                  _buildPasswordField(
                    label: 'CONTRASEÑA',
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 16),
                  // Fila con checkbox "Recuérdame" y enlace "¿Contraseña olvidada?"
                  _buildRememberRow(),
                  const SizedBox(height: 28),
                  // Botón principal de inicio de sesión
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  // Divisor con texto "Or"
                  _buildDivider(),
                  const SizedBox(height: 24),
                  // Botones de login social (placeholder)
                  _buildSocialButtons(),
                  const SizedBox(height: 28),
                  // Enlace para registrarse
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el header superior con título y subtítulo
  /// Muestra: título "Login" y mensaje instructivo centrados
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _darkBg, // Fondo oscuro
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), // Bordes redondeados inferiores
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(top: 70, left: 24, right: 24, bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          // Título principal
          Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          // Subtítulo informativo
          Text(
            'Por favor, inicia sesión en tu cuenta existente',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB0B5CC),
              fontSize: 13.5,
            ), // Gris claro
          ),
        ],
      ),
    );
  }

  /// Construye un campo de texto genérico para el formulario
  /// Muestra: etiqueta, campo de entrada con estilo personalizado
  /// Parámetros:
  /// - label: etiqueta del campo (ej: 'CORREO')
  /// - hint: texto placeholder (ej: 'ejemplo@gmail.com')
  /// - controller: controlador del campo
  /// - keyboardType: tipo de teclado (opcional)
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo
        Text(label, style: _labelStyle()),
        const SizedBox(height: 10),
        // Campo de texto con estilo personalizado
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: _inputTextStyle(),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  /// Construye un campo de contraseña con toggle de visibilidad
  /// Muestra: etiqueta, campo oculto y botón para mostrar/ocultar
  /// Parámetros:
  /// - label: etiqueta del campo
  /// - controller: controlador del campo
  /// - obscure: estado de visibilidad actual
  /// - onToggle: callback al cambiar visibilidad
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo
        Text(label, style: _labelStyle()),
        const SizedBox(height: 10),
        // Campo de contraseña con ocultación y toggle
        TextFormField(
          controller: controller,
          obscureText: obscure, // Ocultar texto
          obscuringCharacter: '•', // Carácter de ocultación
          onChanged: (_) => setState(() {}), // Actualizar UI al cambiar
          style: _inputTextStyle(),
          decoration: _inputDecoration(
            hint: '••••••••••', // Placeholder con puntos
            suffix: GestureDetector(
              onTap: onToggle, // Toggle visibilidad
              child: Icon(
                obscure
                    ? Icons
                          .visibility_outlined // Icono de mostrar
                    : Icons.visibility_off_outlined, // Icono de ocultar
                color: const Color(0xFFB0B5CC), // Gris claro
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la fila con checkbox "Recuérdame" y enlace de recuperación
  /// Muestra: checkbox personalizado y enlace clickeable para recuperar contraseña
  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Checkbox "Recuérdame" (placeholder)
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(
                  () => _rememberMe = v ?? false,
                ), // Actualizar estado
                activeColor: _primary, // Color cuando está activo
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(
                  color: Color(0xFFCDD0DB),
                  width: 1.5,
                ), // Borde gris claro
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Recuérdame',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF5A5F72),
              ), // Gris medio
            ),
          ],
        ),
        // Enlace para recuperar contraseña
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.forgotPassword,
            ); // Navegar a recuperación
          },
          child: const Text(
            '¿Contraseña olvidada?',
            style: TextStyle(
              fontSize: 13.5,
              color: _primary, // Rojo primario
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el botón principal de inicio de sesión
  /// Muestra: estado de carga con spinner o texto "Iniciar Sesión"
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        // Deshabilitar durante carga para evitar múltiples clicks
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary, // Fondo primario
          foregroundColor: Colors.white, // Texto blanco
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0, // Sin elevación
        ),
        child: _isLoading
            ? // Mostrar spinner durante carga
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : // Mostrar texto normal
              const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  /// Construye el divisor visual con texto "Or"
  /// Muestra: línea - texto - línea para separar secciones
  Widget _buildDivider() {
    return Row(
      children: const [
        // Línea izquierda
        Expanded(
          child: Divider(color: Color(0xFFDDE0EA), thickness: 1),
        ), // Gris muy claro
        // Texto central
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Or',
            style: TextStyle(
              color: Color(0xFF8A8FA8),
              fontSize: 13,
            ), // Gris claro
          ),
        ),
        // Línea derecha
        Expanded(
          child: Divider(color: Color(0xFFDDE0EA), thickness: 1),
        ), // Gris muy claro
      ],
    );
  }

  /// Construye los botones de login social (placeholder)
  /// Muestra: botones circulares para Facebook, Twitter/X y LinkedIn
  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón de Facebook
        _socialButton(
          color: const Color(0xFF1877F3), // Azul Facebook
          icon: Icons.facebook_rounded,
        ),
        const SizedBox(width: 16),
        // Botón de Twitter/X (placeholder)
        _socialButton(
          color: const Color(0xFF1DA1F2), // Azul Twitter
          icon: Icons.flutter_dash, // Icono placeholder
        ),
        const SizedBox(width: 16),
        // Botón de LinkedIn (placeholder)
        _socialButton(
          color: const Color(0xFF0A66C2), // Azul LinkedIn
          icon: Icons.linked_camera_rounded, // Icono placeholder
        ),
      ],
    );
  }

  /// Construye un botón social individual
  /// Muestra: botón circular con color de marca e icono blanco
  /// Parámetros:
  /// - color: color de fondo según marca social
  /// - icon: icono representativo de la plataforma
  Widget _socialButton({required Color color, required IconData icon}) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  /// Construye el enlace para registrarse
  /// Muestra: texto descriptivo y enlace clickeable para ir al registro
  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '¿No tienes una cuenta? ',
          style: const TextStyle(
            color: Color(0xFF8A8FA8),
            fontSize: 13.5,
          ), // Gris claro
          children: [
            // Enlace clickeable para registrarse
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.register,
                  ); // Navegar a registro
                },
                child: const Text(
                  'Regístrate',
                  style: TextStyle(
                    color: _primary, // Rojo primario
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS DE ESTILO ─────────────────────────────────────────────────────────

  /// Estilo para etiquetas de campos del formulario
  /// Características: tamaño pequeño, negrita, espaciado entre letras
  TextStyle _labelStyle() => const TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A1F2E), // Gris oscuro
    letterSpacing: 0.8, // Espaciado entre letras
  );

  /// Estilo para texto de entrada de campos
  /// Características: tamaño estándar, color oscuro
  TextStyle _inputTextStyle() =>
      const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)); // Gris oscuro

  /// Decoración personalizada para campos de texto
  /// Muestra: placeholder, bordes redondeados, colores de estado
  /// Parámetros:
  /// - hint: texto placeholder
  /// - suffix: widget adicional (opcional, ej: icono de visibilidad)
  InputDecoration _inputDecoration({required String hint, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFCDD0DB),
          fontSize: 14,
        ), // Gris muy claro
        suffixIcon: suffix, // Icono adicional
        filled: true,
        fillColor: Colors.white, // Fondo blanco
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        // Borde por defecto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE8EAF0),
            width: 1.5,
          ), // Gris claro
        ),
        // Borde cuando está habilitado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE8EAF0),
            width: 1.5,
          ), // Gris claro
        ),
        // Borde cuando está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _primary,
            width: 1.8,
          ), // Rojo primario
        ),
      );
}

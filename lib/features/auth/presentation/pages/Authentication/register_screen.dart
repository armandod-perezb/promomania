// Importaciones necesarias para la pantalla de registro
import 'package:flutter/material.dart'; // UI framework principal
import '../../../../../Core/Routes/app_routes.dart'; // Definición de rutas de navegación
import 'package:flutter/gestures.dart';
import '../../../../../Core/utils/validators.dart';
import '../../controllers/auth_controller.dart';

/// Pantalla de registro de nuevos usuarios
/// Permite crear cuenta con nombre, email y contraseña
/// Incluye validación de campos y términos y condiciones
class RegisterScreen extends StatefulWidget {
  final AuthController authController;

  const RegisterScreen({super.key, required this.authController});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// Estado interno de `RegisterScreen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto del formulario
  final TextEditingController _nameController =
      TextEditingController(); // Campo de nombre
  final TextEditingController _emailController =
      TextEditingController(); // Campo de email
  final TextEditingController _passwordController =
      TextEditingController(); // Campo de contraseña
  final TextEditingController _confirmController =
      TextEditingController(); // Campo de confirmación

  // Variables de estado de UI
  bool _obscurePassword = true; // Ocultar/mostrar contraseña
  bool _obscureConfirm = true; // Ocultar/mostrar confirmación
  bool _acceptTerms = false; // Aceptación de términos y condiciones
  bool _isLoading = false; // Estado de carga durante registro
  late final TapGestureRecognizer _termsRecognizer;

  // Colores constantes de la aplicación
  static const Color _primary = Color(
    0xFFFF4D2E,
  ); // Color primario rojo/naranja
  static const Color _darkBg = Color(0xFF1A1F2E); // Fondo oscuro para header
  static const Color _lightBg = Color(0xFFF8F9FB); // Fondo claro principal

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.pushNamed(context, AppRoutes.termsService);
    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Getter que determina si el formulario es válido para registro
  /// Verifica: campos no vacíos, contraseña de 8+ caracteres, coincidencia de contraseñas y términos aceptados
  bool get _canRegister =>
      _nameController.text.isNotEmpty &&
      Validators.validateEmail(_emailController.text.trim()) == null &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text &&
      _acceptTerms;

  String? get _validationMessage {
    if (_nameController.text.isEmpty) return 'Ingresa tu nombre';
    final emailError = Validators.validateEmail(_emailController.text.trim());
    if (emailError != null) {
      return emailError;
    }
    if (_passwordController.text.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (_passwordController.text != _confirmController.text) {
      return 'Las contraseñas no coinciden';
    }
    if (!_acceptTerms) return 'Acepta los términos y condiciones';
    return null;
  }

  /// Método principal para registrar un nuevo usuario
  /// Valida formulario, verifica email duplicado, crea usuario y guarda sesión
  void _register() async {
    // Validar que el formulario esté completo antes de continuar
    if (!_canRegister) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationMessage ?? 'Completa todos los campos'),
        ),
      );
      return;
    }

    // Obtener y limpiar datos del formulario
    final email = _emailController.text.trim(); // Email sin espacios
    final nombre = _nameController.text.trim(); // Nombre sin espacios
    final password = _passwordController.text; // Contraseña (no se limpia)

    // Activar estado de carga
    setState(() => _isLoading = true);

    try {
      await widget.authController.register(
        nombre: nombre,
        correo: email,
        password: password,
      );

      // Si el widget aún está montado, mostrar éxito y navegar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Registro exitoso!')));
        // Navegar a pantalla principal reemplazando la ruta actual
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
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
          // Header con título y botón de retroceso
          _buildHeader(),
          // Contenido del formulario scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de nombre
                  _buildField(
                    label: 'NOMBRE',
                    hint: 'John Doe',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 18),
                  // Campo de email
                  _buildField(
                    label: 'CORREO',
                    hint: 'example@gmail.com',
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress, // Teclado con @ y .com
                  ),
                  const SizedBox(height: 18),
                  // Campo de contraseña
                  _buildPasswordField(
                    label: 'CONTRASEÑA',
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 18),
                  // Campo de confirmación de contraseña
                  _buildPasswordField(
                    label: 'CONFIRMA CONTRASEÑA',
                    controller: _confirmController,
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 20),
                  // Checkbox de términos y condiciones
                  _buildTermsRow(),
                  if (_validationMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _validationMessage!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  // Botón principal de registro
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  // Enlace para iniciar sesión
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el header superior con título y botón de retroceso
  /// Muestra: botón de volver, título "Registro" y subtítulo informativo
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
      padding: const EdgeInsets.only(top: 54, left: 20, right: 20, bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Botón de retroceso
          GestureDetector(
            onTap: () => Navigator.pop(context), // Volver a pantalla anterior
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12), // Fondo semitransparente
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Columna con título y subtítulo
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Por favor, regístrate para empezar',
                style: TextStyle(
                  color: Color(0xFFB0B5CC),
                  fontSize: 13,
                ), // Gris claro
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un campo de texto genérico para el formulario
  /// Muestra: etiqueta, campo de entrada con estilo personalizado
  /// Parámetros:
  /// - label: etiqueta del campo (ej: 'NOMBRE')
  /// - hint: texto placeholder (ej: 'John Doe')
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
        // Campo de texto con validación en tiempo real
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}), // Actualizar UI al cambiar texto
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
        // Campo de contraseña con ocultación
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

  /// Construye la fila de términos y condiciones
  /// Muestra: checkbox personalizado y texto con enlaces destacados
  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Checkbox personalizado
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (v) =>
                setState(() => _acceptTerms = v ?? false), // Actualizar estado
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
        const SizedBox(width: 10),
        // Texto con enlaces destacados
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Acepto los ',
              style: TextStyle(
                color: Color(0xFF8A8FA8),
                fontSize: 13.5,
              ), // Gris claro
              children: [
                TextSpan(
                  text: 'Términos y Condiciones',
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                  ), // Rojo primario
                  recognizer: _termsRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el botón principal de registro
  /// Muestra: estado de carga con spinner o texto "Registrarse"
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        // Habilitar solo si formulario es válido y no está cargando
        onPressed: _canRegister && !_isLoading ? _register : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary, // Fondo primario
          foregroundColor: Colors.white, // Texto blanco
          disabledBackgroundColor: _primary.withOpacity(
            0.45,
          ), // Fondo deshabilitado
          disabledForegroundColor: Colors.white, // Texto deshabilitado
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
                'Registrarse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  /// Construye el enlace para iniciar sesión
  /// Muestra: texto descriptivo y enlace clickeable para volver al login
  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '¿Ya tienes una cuenta? ',
          style: const TextStyle(
            color: Color(0xFF8A8FA8),
            fontSize: 13.5,
          ), // Gris claro
          children: [
            // Enlace clickeable para iniciar sesión
            WidgetSpan(
              child: GestureDetector(
                onTap: () =>
                    Navigator.pop(context), // Volver a pantalla de login
                child: const Text(
                  'Inicia sesión',
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

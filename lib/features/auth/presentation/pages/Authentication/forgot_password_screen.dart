// Importa el paquete de Flutter para construir la interfaz gráfica
import 'package:flutter/material.dart';

// Importa las rutas nombradas de la aplicación
import '../../../../../Core/Routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

// Widget Stateful porque maneja estado (loading, input)
class ForgotPasswordScreen extends StatefulWidget {
  final AuthController authController;

  // Constructor del widget
  const ForgotPasswordScreen({super.key, required this.authController});

  // Crea el estado asociado a este widget
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

// Clase que maneja el estado de la pantalla
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  // Controlador para capturar el email ingresado
  final TextEditingController _emailController = TextEditingController();

  // Variable para controlar el estado de carga
  bool _isLoading = false;

  // Color principal de la UI
  static const Color _primary = Color(0xFFFF4D2E);

  // Color del fondo oscuro (header)
  static const Color _darkBg = Color(0xFF1A1F2E);

  // Color del fondo general de la pantalla
  static const Color _lightBg = Color(0xFFF8F9FB);

  // Método que se ejecuta cuando el widget se destruye
  @override
  void dispose() {

    // Libera memoria del controlador
    _emailController.dispose();

    // Llama al dispose padre
    super.dispose();
  }

  // Método para enviar el código de recuperación
  void _sendCode() async {

    // Valida si el campo está vacío
    if (_emailController.text.isEmpty) {

      // Muestra mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu email')),
      );

      return;
    }

    // Limpia espacios del email
    final email = _emailController.text.trim();

    // Activa estado de carga
    setState(() => _isLoading = true);

    try {

      await widget.authController.sendRecoveryCode(correo: email);

      // Navega a la pantalla de verificación
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.verifyCode, arguments: email);
      }

    } catch (e) {

      // Manejo de errores
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }

    } finally {

      // Siempre desactiva el loading
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Método principal que construye la interfaz
  @override
  Widget build(BuildContext context) {

    // Retorna la estructura visual
    return Scaffold(

      // Color de fondo
      backgroundColor: _lightBg,

      // Contenido principal
      body: Column(
        children: [

          // Header superior oscuro
          _buildHeader(),

          // Contenido principal expandible
          Expanded(
            child: SingleChildScrollView(

              // Espaciado interno
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),

              // Columna con los elementos
              child: Column(
                children: [

                  // Icono de correo
                  _buildEmailIcon(),

                  const SizedBox(height: 28),

                  // Título principal
                  const Text(
                    'Recupera tu acceso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Texto descriptivo
                  const Text(
                    'Ingresa el correo electrónico asociado a tu\ncuenta y te enviaremos un código de\nverificación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF8A8FA8),
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Campo de correo
                  _buildEmailField(),

                  const SizedBox(height: 28),

                  // Botón enviar
                  _buildSendButton(),

                  const SizedBox(height: 20),

                  // Link volver al login
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método que construye el header
  Widget _buildHeader() {
    return Container(

      // Ocupa todo el ancho
      width: double.infinity,

      // Decoración del header
      decoration: const BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      // Espaciado interno
      padding: const EdgeInsets.only(top: 54, left: 20, right: 20, bottom: 28),

      // Contenido en columna
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Botón para regresar
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Título grande
          const Text(
            'Olvidé mi\ncontraseña',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          // Subtítulo
          const Text(
            'Te enviaremos un código de verificación',
            style: TextStyle(color: Color(0xFFB0B5CC), fontSize: 13),
          ),

          const SizedBox(height: 16),

          // Indicadores de pasos
          _buildStepIndicators(currentStep: 0),
        ],
      ),
    );
  }

  // Indicadores de progreso
  Widget _buildStepIndicators({required int currentStep}) {
    return Row(
      children: List.generate(3, (i) {

        // Determina si el paso está activo
        final isActive = i == currentStep;

        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _primary : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // Icono decorativo de email
  Widget _buildEmailIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.mail_outline_rounded, color: _primary, size: 38),
    );
  }

  // Campo de entrada de email
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'CORREO ELECTRÓNICO',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // Botón enviar código
  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendCode,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('ENVIAR CÓDIGO'),
      ),
    );
  }

  // Link para volver al login
  Widget _buildLoginLink() {
    return RichText(
      text: TextSpan(
        text: 'Volver al ',
        style: const TextStyle(color: Color(0xFF8A8FA8)),
        children: [
          WidgetSpan(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'inicio de sesión',
                style: TextStyle(color: _primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

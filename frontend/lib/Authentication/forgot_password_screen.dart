import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF8F9FB);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.verifyCode,
        arguments: _emailController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          // Header oscuro con forma curva
          _buildHeader(),
          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Ícono de correo
                  _buildEmailIcon(),
                  const SizedBox(height: 28),
                  // Título y descripción
                  const Text(
                    'Recupera tu acceso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  // Volver al inicio de sesión
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(top: 54, left: 20, right: 20, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
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
          const Text(
            'Te enviaremos un código de verificación',
            style: TextStyle(color: Color(0xFFB0B5CC), fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Indicadores de paso
          _buildStepIndicators(currentStep: 0),
        ],
      ),
    );
  }

  Widget _buildStepIndicators({required int currentStep}) {
    return Row(
      children: List.generate(3, (i) {
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
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)),
          decoration: InputDecoration(
            hintText: 'nk@gmail.com',
            hintStyle: const TextStyle(color: Color(0xFFB0B5CC), fontSize: 14),
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFFB0B5CC),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE8EAF0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE8EAF0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _primary, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'ENVIAR CÓDIGO',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return RichText(
      text: TextSpan(
        text: 'Volver al ',
        style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 13.5),
        children: [
          WidgetSpan(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'inicio de sesión',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

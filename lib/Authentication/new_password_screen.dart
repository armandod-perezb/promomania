import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF8F9FB);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _passwordController.text.length >= 8 &&
      _confirmController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  void _changePassword() async {
    if (!_canSubmit) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      // Navegar a pantalla de éxito o login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Contraseña cambiada exitosamente!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  _buildLockIcon(),
                  const SizedBox(height: 28),
                  const Text(
                    'Crea una nueva contraseña',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu nueva contraseña debe ser diferente a las anteriores y\ntener al menos 8 caracteres.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A8FA8),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPasswordField(
                    label: 'NUEVA CONTRASEÑA',
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    label: 'CONFIRMAR CONTRASEÑA',
                    controller: _confirmController,
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
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
          // Botón de retroceso
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
            'Nueva\ncontraseña',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige una contraseña segura',
            style: TextStyle(color: Color(0xFFB0B5CC), fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildStepIndicators(currentStep: 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicators({required int currentStep}) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == currentStep;
        final isPast = i < currentStep;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? _primary
                : isPast
                ? _primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.lock_outline_rounded, color: _primary, size: 38),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          obscuringCharacter: '•',
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1F2E),
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: '••••••••••',
            hintStyle: const TextStyle(
              color: Color(0xFFCDD0DB),
              fontSize: 14,
              letterSpacing: 3,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFB0B5CC),
              size: 20,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFFB0B5CC),
                size: 20,
              ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _canSubmit && !_isLoading ? _changePassword : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.45),
          disabledForegroundColor: Colors.white,
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
                'CAMBIAR CONTRASEÑA',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

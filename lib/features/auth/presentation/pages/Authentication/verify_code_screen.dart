import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final AuthController authController;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.authController,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const int _codeLength = 6;
  static const int _resendSeconds = 58;

  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF8F9FB);

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _resendSeconds;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  bool get _isCodeComplete => _controllers.every((c) => c.text.length == 1);

  void _verifyCode() async {
    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el código completo')),
      );
      return;
    }

    final codigo = _controllers.map((c) => c.text).join();
    setState(() => _isVerifying = true);

    try {
      final isValid = await widget.authController.verifyRecoveryCode(
        correo: widget.email,
        code: codigo,
      );
      if (isValid) {
        // Código válido
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.newPassword,
            arguments: widget.email,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Código incorrecto')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (_secondsLeft != 0 || _isResending) {
      return;
    }

    setState(() => _isResending = true);
    try {
      await widget.authController.sendRecoveryCode(correo: widget.email);
      if (mounted) {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Codigo reenviado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
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
                  _buildShieldIcon(),
                  const SizedBox(height: 28),
                  const Text(
                    'Revisa tu correo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Ingresa el código de 6 dígitos enviado a\n',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF8A8FA8),
                        height: 1.55,
                      ),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            color: Color(0xFF1A1F2E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revisa tu correo para ver el codigo enviado.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 32),
                  _buildCodeInputs(),
                  const SizedBox(height: 32),
                  _buildVerifyButton(),
                  const SizedBox(height: 20),
                  _buildResendRow(),
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
            'Verificar\ncódigo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código enviado a ${widget.email}',
            style: const TextStyle(color: Color(0xFFB0B5CC), fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildStepIndicators(currentStep: 1),
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

  Widget _buildShieldIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.shield_outlined, color: _primary, size: 38),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '6',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_codeLength, (i) {
        final isFilled = _controllers[i].text.isNotEmpty;
        return SizedBox(
          width: 46,
          height: 54,
          child: TextFormField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: isFilled ? _primary.withOpacity(0.06) : Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE8EAF0),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isFilled ? _primary : const Color(0xFFE8EAF0),
                  width: isFilled ? 1.8 : 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 2),
              ),
            ),
            onChanged: (v) => _onCodeChanged(v, i),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final canVerify = _isCodeComplete;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canVerify && !_isVerifying ? _verifyCode : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canVerify ? _primary : _primary.withOpacity(0.5),
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.5),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'VERIFICAR CÓDIGO',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildResendRow() {
    final canResend = _secondsLeft == 0;
    return GestureDetector(
      onTap: canResend && !_isResending ? _resendCode : null,
      child: RichText(
        text: TextSpan(
          text: canResend ? 'Reenviar código' : 'Reenviar código en ',
          style: TextStyle(
            color: canResend && !_isResending ? _primary : const Color(0xFF8A8FA8),
            fontSize: 13.5,
            fontWeight: canResend && !_isResending ? FontWeight.w600 : FontWeight.w400,
          ),
          children: [
            if (_isResending)
              const TextSpan(
                text: '...',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (!canResend)
              TextSpan(
                text: '${_secondsLeft}s',
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

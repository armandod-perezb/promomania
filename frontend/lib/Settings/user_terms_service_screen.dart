import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA TÉRMINOS DE SERVICIO
// ─────────────────────────────────────────────────────────────────────────────

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);

  final ScrollController _scrollCtrl = ScrollController();

  // Detectar si el usuario llegó al fondo
  bool _reachedBottom = false;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      final current = _scrollCtrl.position.pixels;
      if (current >= max - 40 && !_reachedBottom) {
        setState(() => _reachedBottom = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToTop() {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _accept() {
    setState(() => _accepted = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  // ── Contenido de las cláusulas ────────────────────────────────────────────

  static const List<_Clause> _clauses = [
    _Clause(
      number: 'CLÁUSULA 1',
      title: 'IDENTIFICACIÓN',
      content:
          'La aplicación móvil Promomania es desarrollada en el marco académico de la Facultad de Ingeniería de la Universidad Libre. La plataforma tiene carácter académico y tecnológico, y sus desarrolladores actúan como responsables del funcionamiento y administración del sistema dentro del alcance del proyecto universitario.',
    ),
    _Clause(
      number: 'CLÁUSULA 2',
      title: 'OBJETO',
      content:
          'Promomania tiene como objeto centralizar promociones y descuentos publicados por usuarios y comercios en Colombia, permitiendo su consulta, validación y calificación dentro de un entorno digital colaborativo. La aplicación actúa como intermediario tecnológico, facilitando la difusión de información comercial sin intervenir directamente en las transacciones entre usuarios y comercios.',
    ),
    _Clause(
      number: 'CLÁUSULA 3',
      title: 'ACEPTACIÓN',
      content:
          'El acceso, registro y uso de la aplicación implica la aceptación libre, previa, expresa e informada de los presentes Términos de Servicio y de la Política de Tratamiento de Datos Personales, conforme a la Ley 1581 de 2012. En caso de desacuerdo con alguna de las disposiciones aquí establecidas, el usuario deberá abstenerse de utilizar la plataforma.',
    ),
    _Clause(
      number: 'CLÁUSULA 4',
      title: 'REGISTRO Y OBLIGACIONES DEL USUARIO',
      content:
          'Para acceder a determinadas funcionalidades, el usuario deberá registrarse proporcionando información veraz, completa y actualizada. El usuario se compromete a mantener la confidencialidad de sus credenciales de acceso y a hacer un uso adecuado de la aplicación, absteniéndose de publicar contenido falso, engañoso, ofensivo o que vulnere derechos de terceros. Promomania podrá suspender o cancelar cuentas que incumplan estas disposiciones.',
    ),
    _Clause(
      number: 'CLÁUSULA 5',
      title: 'CONTENIDO Y PROMOCIONES',
      content:
          'Las promociones publicadas en la plataforma son responsabilidad exclusiva de sus creadores. Promomania no garantiza la veracidad, disponibilidad ni vigencia de las ofertas publicadas. La plataforma se reserva el derecho de eliminar contenido que infrinja estos términos, sea engañoso, ofensivo o contrario a la ley colombiana vigente.',
    ),
    _Clause(
      number: 'CLÁUSULA 6',
      title: 'PROPIEDAD INTELECTUAL',
      content:
          'El diseño, código, marca, logotipo y demás elementos de Promomania son propiedad de sus desarrolladores y están protegidos por las leyes de propiedad intelectual vigentes. Queda prohibida la reproducción, distribución o uso comercial de cualquier elemento de la plataforma sin autorización expresa y escrita de sus creadores.',
    ),
    _Clause(
      number: 'CLÁUSULA 7',
      title: 'LIMITACIÓN DE RESPONSABILIDAD',
      content:
          'Promomania no se responsabiliza por daños derivados del uso de la plataforma, errores técnicos, interrupciones del servicio, pérdida de datos o perjuicios económicos asociados a transacciones entre usuarios y comercios. El uso de la aplicación es bajo la entera responsabilidad del usuario.',
    ),
    _Clause(
      number: 'CLÁUSULA 8',
      title: 'TRATAMIENTO DE DATOS PERSONALES',
      content:
          'En cumplimiento de la Ley 1581 de 2012 y el Decreto 1377 de 2013, Promomania recopila y trata los datos personales de los usuarios únicamente con su consentimiento y para los fines establecidos en la Política de Privacidad. El usuario tiene derecho a conocer, actualizar, rectificar y solicitar la supresión de sus datos personales en cualquier momento.',
    ),
    _Clause(
      number: 'CLÁUSULA 9',
      title: 'MODIFICACIONES',
      content:
          'Promomania se reserva el derecho de modificar estos Términos de Servicio en cualquier momento. Los cambios serán notificados a través de la aplicación. El uso continuado de la plataforma tras la notificación implica la aceptación de los nuevos términos.',
    ),
    _Clause(
      number: 'CLÁUSULA 10',
      title: 'LEY APLICABLE Y JURISDICCIÓN',
      content:
          'Los presentes Términos de Servicio se rigen por las leyes de la República de Colombia. Cualquier controversia derivada de su interpretación o aplicación será resuelta ante los jueces competentes de la ciudad de Bogotá D.C., Colombia.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Stack(
                children: [
                  // Contenido scrollable
                  SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        ..._clauses.map((c) => _buildClause(c)).toList(),
                        const SizedBox(height: 16),
                        _buildFooterNote(),
                      ],
                    ),
                  ),
                  // Gradiente inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.white, Colors.white.withOpacity(0.0)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1A1F2E),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Términos de Servicio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1F2E),
              ),
            ),
          ),
          // Indicador de progreso de lectura
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _reachedBottom
                  ? _primary.withOpacity(0.1)
                  : const Color(0xFFF0F1F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _reachedBottom
                      ? Icons.check_circle_rounded
                      : Icons.remove_red_eye_outlined,
                  size: 14,
                  color: _reachedBottom ? _primary : const Color(0xFF8A8FA8),
                ),
                const SizedBox(width: 5),
                Text(
                  _reachedBottom ? 'Leído' : 'Leer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _reachedBottom ? _primary : const Color(0xFF8A8FA8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header del documento ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'AGREEMENT',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8A8FA8),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Terminos de servicios',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: _primary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: Color(0xFF8A8FA8),
            ),
            SizedBox(width: 5),
            Text(
              'Última actualización: 04/03/2026',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Divider decorativo
        Container(
          height: 3,
          width: 48,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ── Cláusula individual ───────────────────────────────────────────────────────

  Widget _buildClause(_Clause clause) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clause.number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            clause.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _primary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            clause.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5168),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ── Nota al pie ───────────────────────────────────────────────────────────────

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Color(0xFF8A8FA8),
              ),
              SizedBox(width: 8),
              Text(
                'Información legal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Al aceptar estos términos confirmas que tienes al menos 14 años de edad y que has leído, comprendido y aceptado todas las cláusulas aquí establecidas. Estos términos constituyen un acuerdo legalmente vinculante entre tú y Promomania.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF8A8FA8),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ── Acciones del fondo ────────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón principal (Accept o Scroll to Bottom)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _reachedBottom ? _accept : _scrollToBottom,
              style: ElevatedButton.styleFrom(
                backgroundColor: _reachedBottom ? _primary : _darkBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _reachedBottom
                    ? const Row(
                        key: ValueKey('accept'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Accept & Continue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        key: ValueKey('scroll'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Scroll to Bottom',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Botón secundario (Scroll to Top)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _scrollToTop,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1F2E),
                side: const BorderSide(color: Color(0xFFE0E2EA), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Scroll to Top',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELO
// ─────────────────────────────────────────────────────────────────────────────

class _Clause {
  final String number;
  final String title;
  final String content;

  const _Clause({
    required this.number,
    required this.title,
    required this.content,
  });
}

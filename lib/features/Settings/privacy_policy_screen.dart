import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1F2E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Politica de Privacidad',
            style: TextStyle(
              color: Color(0xFF1A1F2E),
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          centerTitle: false,
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Text(
            'En Promomania cuidamos tus datos personales y aplicamos buenas practicas '
            'de seguridad para su tratamiento.\n\n'
            '1. Recolectamos solo la informacion necesaria para operar la app.\n\n'
            '2. Usamos tus datos para mejorar la experiencia, personalizar contenido y '
            'mantener la seguridad de la plataforma.\n\n'
            '3. No compartimos informacion personal con terceros sin autorizacion, salvo '
            'obligacion legal.\n\n'
            '4. Puedes solicitar actualizacion, correccion o eliminacion de tus datos '
            'segun la normativa aplicable.\n\n'
            '5. El uso continuo de la app implica aceptacion de esta politica y de sus '
            'actualizaciones futuras.',
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}

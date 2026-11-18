import 'package:flutter/material.dart';

/// Bloque inferior de acciones: botón CTA principal ("Continuar" / "Comenzar Ahora")
/// y enlace secundario para usuarios registrados ("¿Ya tienes una cuenta? Iniciar Sesión").
class OnboardingFooter extends StatelessWidget {
  final String ctaLabel;
  final VoidCallback onContinue;
  final VoidCallback onLogin;
  final bool isExiting;

  const OnboardingFooter({
    super.key,
    required this.ctaLabel,
    required this.onContinue,
    required this.onLogin,
    this.isExiting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón CTA Principal con altura mínima 52dp y contraste accesible
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isExiting ? null : onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E4E82),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF0E4E82).withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ctaLabel),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Enlace a Iniciar Sesión con área táctil cómoda (mínimo 48dp de alto)
          Semantics(
            label: 'Iniciar sesión con cuenta existente',
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: InkWell(
                onTap: isExiting ? null : onLogin,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Text.rich(
                    TextSpan(
                      text: '¿Ya tienes una cuenta? ',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Iniciar Sesión',
                          style: TextStyle(
                            color: Color(0xFF0E4E82),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

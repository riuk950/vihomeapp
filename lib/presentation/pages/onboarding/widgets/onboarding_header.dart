import 'package:flutter/material.dart';

/// Cabecera superior del onboarding con botón de retroceso condicional y acción "Saltar".
class OnboardingHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const OnboardingHeader({
    super.key,
    required this.showBackButton,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de retroceso (oculto en paso 1 para evitar control sin acción)
          Visibility(
            visible: showBackButton,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Semantics(
              label: 'Volver al paso anterior',
              button: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF0E4E82),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botón "Saltar" (visible en todos los pasos para permitir omisión rápida)
          Semantics(
            label: 'Saltar introducción',
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  textStyle: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Saltar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

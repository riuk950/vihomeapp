import 'package:flutter/material.dart';

/// Indicador animado de progreso de cuatro posiciones.
/// Estrictamente no interactivo según RF-2.6.
class OnboardingIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentPage;

  const OnboardingIndicator({
    super.key,
    required this.totalSteps,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Semantics(
        label: 'Paso ${currentPage + 1} de $totalSteps',
        readOnly: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: isActive ? 24.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF0E4E82) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4.0),
              ),
            );
          }),
        ),
      ),
    );
  }
}

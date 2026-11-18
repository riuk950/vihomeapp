/// Información visual de la tarjeta ilustrativa central del onboarding.
class OnboardingCardVisual {
  final List<String> topBadges;
  final String headline;
  final String subtitle;
  final String? highlightMetric;
  final List<String> orbitBadges;

  const OnboardingCardVisual({
    required this.topBadges,
    required this.headline,
    required this.subtitle,
    this.highlightMetric,
    required this.orbitBadges,
  });
}

/// Entidad inmutable que modela cada uno de los pasos del onboarding.
class OnboardingStep {
  final int stepNumber; // 1..4
  final String title;
  final String description;
  final String imageAsset;
  final String ctaLabel;
  final bool showBackButton;
  final bool showSkipButton;
  final OnboardingCardVisual cardVisual;

  const OnboardingStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.ctaLabel,
    required this.showBackButton,
    required this.showSkipButton,
    required this.cardVisual,
  });

  /// Pasos predefinidos inmutables de ViHome (MVP).
  static const List<OnboardingStep> defaultSteps = [
    OnboardingStep(
      stepNumber: 1,
      title: 'Conecta con tu Espacio Ideal',
      description:
          'Encuentra propiedades exclusivas, contacta directamente con arrendadores certificados y gestiona contratos seguros.',
      imageAsset: 'assets/images/onboarding/onboarding_1_space.jpg',
      ctaLabel: 'Continuar',
      showBackButton: false,
      showSkipButton: true,
      cardVisual: OnboardingCardVisual(
        topBadges: ['Verificado', 'Pisos de Lujo'],
        headline: 'Penthouse Azure Marina',
        subtitle: 'Zona Financiera',
        highlightMetric: r'$2,400/mes',
        orbitBadges: ['chat', 'verified_user', 'landlord_online', 'favorite'],
      ),
    ),
    OnboardingStep(
      stepNumber: 2,
      title: 'Conexión Directa y Transparente',
      description:
          'Comunícate en tiempo real con arrendadores y constructoras certificadas, sin intermediarios ni demoras innecesarias.',
      imageAsset: 'assets/images/onboarding/onboarding_2_connection.jpg',
      ctaLabel: 'Continuar',
      showBackButton: true,
      showSkipButton: true,
      cardVisual: OnboardingCardVisual(
        topBadges: ['Verificado'],
        headline: 'Respuesta < 5 min • En línea',
        subtitle: 'Comunicación sin intermediarios',
        highlightMetric: null,
        orbitBadges: ['send', 'advisor_online', 'security'],
      ),
    ),
    OnboardingStep(
      stepNumber: 3,
      title: 'Contratos Digitales Seguros',
      description:
          'Genera y firma contratos de arriendo con total respaldo jurídico y validez legal al instante, desde cualquier lugar.',
      imageAsset: 'assets/images/onboarding/onboarding_3_contracts.jpg',
      ctaLabel: 'Continuar',
      showBackButton: true,
      showSkipButton: true,
      cardVisual: OnboardingCardVisual(
        topBadges: ['Validez Legal 100%'],
        headline: 'Firma Electrónica • Certificación Inmediata',
        subtitle: 'Respaldo jurídico garantizado',
        highlightMetric: null,
        orbitBadges: ['lock', 'notarial_seal', 'shield'],
      ),
    ),
    OnboardingStep(
      stepNumber: 4,
      title: 'Gestión Integral Sin Fricción',
      description:
          'Administra solicitudes, pagos automáticos y el mantenimiento de tu nuevo hogar con una experiencia digital fluida.',
      imageAsset: 'assets/images/onboarding/onboarding_4_management.jpg',
      ctaLabel: 'Comenzar Ahora',
      showBackButton: true,
      showSkipButton: true,
      cardVisual: OnboardingCardVisual(
        topBadges: ['Todo En Uno', 'Acceso Conectado'],
        headline: 'Residencia Skyview 402 • Pago al día',
        subtitle: 'Mantenimiento cubierto • 100% Digital',
        highlightMetric: 'Gestión 24/7',
        orbitBadges: ['key', 'auto_debit_active', 'check_circle'],
      ),
    ),
  ];
}

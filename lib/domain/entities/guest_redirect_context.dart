/// Motivos estructurados por los cuales un usuario no autenticado
/// llega a la pantalla de inicio de sesión (`/login`).
enum GuestRedirectReason {
  profile('profile'),
  rentApplication('rent_application'),
  whatsappContact('whatsapp_contact'),
  projectContact('project_contact'),
  landlordReviews('landlord_reviews'),
  share('share'),
  externalMap('external_map'),
  privateRoute('private_route'),
  sessionExpired('session_expired'),
  onboardingLoginShortcut('onboarding_login_shortcut');

  const GuestRedirectReason(this.wireValue);

  final String wireValue;

  static GuestRedirectReason fromWireValue(String? value) {
    if (value == null || value.isEmpty) {
      return GuestRedirectReason.privateRoute;
    }
    for (final reason in GuestRedirectReason.values) {
      if (reason.wireValue == value) {
        return reason;
      }
    }
    return GuestRedirectReason.privateRoute;
  }

  /// Indica si el motivo debe presentar el banner informativo de restricción
  /// en la pantalla de inicio de sesión.
  bool get showsRestrictionBanner =>
      this != GuestRedirectReason.onboardingLoginShortcut;

  /// Mensaje informativo contextual en español neutro (RNF-4).
  String? get defaultBannerMessage {
    switch (this) {
      case GuestRedirectReason.profile:
        return 'Inicia sesión o crea una cuenta para acceder a tu perfil.';
      case GuestRedirectReason.rentApplication:
        return 'Inicia sesión o crea una cuenta para solicitar este arriendo.';
      case GuestRedirectReason.whatsappContact:
      case GuestRedirectReason.projectContact:
        return 'Inicia sesión o crea una cuenta para contactar directamente.';
      case GuestRedirectReason.landlordReviews:
        return 'Inicia sesión o crea una cuenta para consultar las reseñas del arrendador.';
      case GuestRedirectReason.share:
        return 'Inicia sesión o crea una cuenta para compartir esta publicación.';
      case GuestRedirectReason.externalMap:
        return 'Inicia sesión o crea una cuenta para abrir la ubicación en mapas externos.';
      case GuestRedirectReason.privateRoute:
        return 'Inicia sesión o crea una cuenta para usar esta función.';
      case GuestRedirectReason.sessionExpired:
        return 'Tu sesión expiró. Inicia sesión nuevamente para continuar.';
      case GuestRedirectReason.onboardingLoginShortcut:
        return null;
    }
  }
}

/// Contexto inmutable de redirección de un usuario invitado hacia `/login`.
class GuestRedirectContext {
  final GuestRedirectReason reason;
  final bool showRestrictionBanner;
  final String? bannerMessage;
  final String sourcePath;
  final bool canReturnToPreviousView;

  const GuestRedirectContext({
    required this.reason,
    required this.showRestrictionBanner,
    required this.bannerMessage,
    required this.sourcePath,
    required this.canReturnToPreviousView,
  });

  factory GuestRedirectContext.fromReason(
    GuestRedirectReason reason, {
    required String sourcePath,
    bool? canReturnToPreviousView,
    String? customMessage,
  }) {
    final showBanner = reason.showsRestrictionBanner;
    return GuestRedirectContext(
      reason: reason,
      showRestrictionBanner: showBanner,
      bannerMessage: showBanner ? (customMessage ?? reason.defaultBannerMessage) : null,
      sourcePath: sourcePath,
      canReturnToPreviousView: canReturnToPreviousView ??
          (reason != GuestRedirectReason.onboardingLoginShortcut &&
              reason != GuestRedirectReason.privateRoute),
    );
  }

  factory GuestRedirectContext.onboardingShortcut() {
    return const GuestRedirectContext(
      reason: GuestRedirectReason.onboardingLoginShortcut,
      showRestrictionBanner: false,
      bannerMessage: null,
      sourcePath: '/onboarding',
      canReturnToPreviousView: false,
    );
  }

  factory GuestRedirectContext.privateRoute({String sourcePath = '/'}) {
    return GuestRedirectContext.fromReason(
      GuestRedirectReason.privateRoute,
      sourcePath: sourcePath,
      canReturnToPreviousView: false,
    );
  }

  factory GuestRedirectContext.sessionExpired({String sourcePath = '/home'}) {
    return GuestRedirectContext.fromReason(
      GuestRedirectReason.sessionExpired,
      sourcePath: sourcePath,
      canReturnToPreviousView: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason.wireValue,
      'showRestrictionBanner': showRestrictionBanner,
      'bannerMessage': bannerMessage,
      'sourcePath': sourcePath,
      'canReturnToPreviousView': canReturnToPreviousView,
    };
  }

  factory GuestRedirectContext.fromJson(Map<String, dynamic> json) {
    final reason = GuestRedirectReason.fromWireValue(json['reason'] as String?);
    final showBanner = json['showRestrictionBanner'] is bool
        ? json['showRestrictionBanner'] as bool
        : reason.showsRestrictionBanner;
    final rawMessage = json['bannerMessage'] as String?;
    return GuestRedirectContext(
      reason: reason,
      showRestrictionBanner: showBanner,
      bannerMessage: showBanner ? (rawMessage ?? reason.defaultBannerMessage) : null,
      sourcePath: (json['sourcePath'] as String?) ?? '/',
      canReturnToPreviousView: json['canReturnToPreviousView'] is bool
          ? json['canReturnToPreviousView'] as bool
          : false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuestRedirectContext &&
        other.reason == reason &&
        other.showRestrictionBanner == showRestrictionBanner &&
        other.bannerMessage == bannerMessage &&
        other.sourcePath == sourcePath &&
        other.canReturnToPreviousView == canReturnToPreviousView;
  }

  @override
  int get hashCode =>
      reason.hashCode ^
      showRestrictionBanner.hashCode ^
      (bannerMessage?.hashCode ?? 0) ^
      sourcePath.hashCode ^
      canReturnToPreviousView.hashCode;
}

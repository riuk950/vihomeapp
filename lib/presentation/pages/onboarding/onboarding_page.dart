import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/guest_redirect_context.dart';
import '../../../domain/entities/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/onboarding_footer.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/onboarding_indicator.dart';
import 'widgets/onboarding_slide_card.dart';

/// Pantalla principal del flujo de Onboarding de ViHome.
/// Implementa presentación en 4 pasos, navegación fluida, diseño responsive y accesibilidad.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  bool _hasPrecachedImages = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Bloquear en orientación vertical para consistencia visual (MVP)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPrecachedImages) {
      _hasPrecachedImages = true;
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      for (final step in provider.steps) {
        precacheImage(AssetImage(step.imageAsset), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restaurar orientaciones por defecto del sistema al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _onPageChanged(int index) {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.setPage(index);
  }

  Future<void> _handleNextOrComplete() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    if (provider.isLastStep) {
      final success = await provider.exitOnboarding(OnboardingCompletionReason.completed);
      if (success && mounted) {
        context.go('/home');
      }
    } else {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _handlePrevious() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    if (!provider.isFirstStep && _pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _handleSkip() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final success = await provider.exitOnboarding(OnboardingCompletionReason.skipped);
    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleLoginShortcut() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final success = await provider.exitOnboarding(OnboardingCompletionReason.loginShortcut);
    if (success && mounted) {
      context.go('/login', extra: GuestRedirectContext.onboardingShortcut());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final currentStep = provider.currentStep;
        final isFirstStep = provider.isFirstStep;

        return PopScope(
          canPop: isFirstStep,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handlePrevious();
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Theme(
              data: AppTheme.ligthTheme,
              child: Scaffold(
                backgroundColor: const Color(0xFFF9F9FE),
                body: SafeArea(
                  child: Column(
                    children: [
                      // Cabecera superior (Retroceso condicional + Saltar)
                      OnboardingHeader(
                        showBackButton: !isFirstStep,
                        onBack: _handlePrevious,
                        onSkip: _handleSkip,
                      ),

                      // Cuerpo deslizable con PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const ClampingScrollPhysics(),
                          onPageChanged: _onPageChanged,
                          itemCount: provider.totalSteps,
                          itemBuilder: (context, index) {
                            final step = provider.steps[index];
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Tarjeta ilustrativa central
                                        OnboardingSlideCard(step: step),

                                        const SizedBox(height: 16),

                                        // Título principal del paso
                                        Text(
                                          step.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                            height: 1.25,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // Descripción en español
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 300),
                                          child: Text(
                                            step.description,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF64748B),
                                              height: 1.45,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Indicador animado de 4 pasos
                                        OnboardingIndicator(
                                          totalSteps: provider.totalSteps,
                                          currentPage: provider.currentPage,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Pie de página (Botón CTA + Enlace Iniciar Sesión)
                      OnboardingFooter(
                        ctaLabel: currentStep.ctaLabel,
                        isExiting: provider.isExiting,
                        onContinue: _handleNextOrComplete,
                        onLogin: _handleLoginShortcut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

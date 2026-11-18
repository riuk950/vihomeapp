import 'package:material_ui/material_ui.dart';
import 'package:vihomeapp/domain/entities/onboarding_step.dart';

/// Composición visual ilustrativa de estilo "Azure Horizon" inspirada en las pantallas de Stitch.
/// Tratada estrictamente como contenido visual no interactivo mediante IgnorePointer.
class OnboardingSlideCard extends StatelessWidget {
  final OnboardingStep step;

  const OnboardingSlideCard({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final visual = step.cardVisual;

    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 280,
          height: 270,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Tarjetas de fondo con rotación decorativa sutil
              Transform.rotate(
                angle: -0.07,
                child: Container(
                  width: 220,
                  height: 225,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Transform.rotate(
                angle: 0.05,
                child: Container(
                  width: 225,
                  height: 230,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),

              // Tarjeta principal central con la imagen arquitectónica local
              Container(
                width: 230,
                height: 235,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fotografía arquitectónica local empaquetada
                      Image.asset(
                        step.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF0E4E82).withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                size: 64,
                                color: Color(0xFF0E4E82),
                              ),
                            ),
                          );
                        },
                      ),

                      // Degradado sutil inferior para legibilidad
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              stops: const [0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Badges superiores
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: visual.topBadges.map((badge) {
                            final isVerified = badge.toLowerCase().contains('verificado') ||
                                badge.toLowerCase().contains('legal');
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? const Color(0xFF00A86B).withValues(alpha: 0.95)
                                    : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isVerified ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Tarjeta / Overlay inferior con titular y subtítulo
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              visual.headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    visual.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                                if (visual.highlightMetric != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      visual.highlightMetric!,
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0E4E82),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Badges flotantes en órbita según el paso
              ..._buildOrbitElements(step.stepNumber),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrbitElements(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return [
          _buildFloatingCircle(
            top: 24,
            left: 8,
            icon: Icons.chat_bubble_outline,
            bgColor: Colors.white,
            iconColor: const Color(0xFF0E4E82),
          ),
          _buildFloatingCircle(
            top: 36,
            right: 10,
            icon: Icons.verified_user,
            bgColor: const Color(0xFF00A86B),
            iconColor: Colors.white,
          ),
          _buildFloatingCircle(
            bottom: 30,
            right: 8,
            icon: Icons.favorite,
            bgColor: const Color(0xFFF43F5E),
            iconColor: Colors.white,
          ),
        ];
      case 2:
        return [
          _buildFloatingCircle(
            top: 30,
            left: 10,
            icon: Icons.send_rounded,
            bgColor: const Color(0xFF0E4E82),
            iconColor: Colors.white,
          ),
          _buildFloatingCircle(
            top: 26,
            right: 12,
            icon: Icons.security,
            bgColor: const Color(0xFF00A86B),
            iconColor: Colors.white,
          ),
        ];
      case 3:
        return [
          _buildFloatingCircle(
            top: 28,
            left: 10,
            icon: Icons.lock_outline,
            bgColor: Colors.white,
            iconColor: const Color(0xFF0E4E82),
          ),
          _buildFloatingCircle(
            top: 32,
            right: 10,
            icon: Icons.gavel,
            bgColor: const Color(0xFF0E4E82),
            iconColor: Colors.white,
          ),
          _buildFloatingCircle(
            bottom: 34,
            left: 8,
            icon: Icons.shield,
            bgColor: const Color(0xFF00A86B),
            iconColor: Colors.white,
          ),
        ];
      case 4:
      default:
        return [
          _buildFloatingCircle(
            top: 26,
            left: 10,
            icon: Icons.vpn_key_outlined,
            bgColor: Colors.white,
            iconColor: const Color(0xFF0E4E82),
          ),
          _buildFloatingCircle(
            top: 30,
            right: 8,
            icon: Icons.account_balance_wallet_outlined,
            bgColor: const Color(0xFF0E4E82),
            iconColor: Colors.white,
          ),
          _buildFloatingCircle(
            bottom: 32,
            right: 10,
            icon: Icons.check_circle,
            bgColor: const Color(0xFF00A86B),
            iconColor: Colors.white,
          ),
        ];
    }
  }

  Widget _buildFloatingCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }
}

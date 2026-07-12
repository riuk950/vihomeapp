import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/core/di/injection_container.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Si la inicialización del contexto requiere postergación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isPremium = authProvider.user?.isPremium ?? false;

      // Si es premium, no cargamos anuncio
      if (isPremium) return;

      _bannerAd = BannerAd(
        adUnitId: getIt<AdManager>().bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('BannerAd loaded.');
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('BannerAd failed to load: $err');
            ad.dispose();
          },
        ),
      )..load();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escucha en tiempo real si el usuario se vuelve premium
    final isPremium = context.watch<AuthProvider>().user?.isPremium ?? false;
    
    // Si es premium, ocultamos el anuncio inmediatamente (SizedBox.shrink)
    if (isPremium) {
      return const SizedBox.shrink();
    }

    if (_bannerAd != null && _isLoaded) {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}

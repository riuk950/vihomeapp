import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vihomeapp/env/env_def.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool _isInitialized = false;
  bool _showInterstitials = true;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int _maxFailedLoadAttempts = 3;

  /// Retorna si los anuncios intersticiales están activados por configuración
  bool get showInterstitials => _showInterstitials;

  /// Permite activar o desactivar manualmente los anuncios intersticiales
  void toggleInterstitials(bool value) {
    _showInterstitials = value;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _createInterstitialAd();
  }

  /// ID del anuncio Banner
  String get bannerAdUnitId {
    String adId = '';
    if (EnvDef.admobBannerId.isNotEmpty) {
      adId = EnvDef.admobBannerId;
    } else {
      // Fallback a IDs de prueba de Google
      if (Platform.isAndroid) {
        adId = 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        adId = 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    debugPrint('AdManager: Using Banner ID: $adId');
    return adId;
  }

  /// ID del anuncio Intersticial
  String get interstitialAdUnitId {
    String adId = '';
    if (EnvDef.admobInterstitialId.isNotEmpty) {
      adId = EnvDef.admobInterstitialId;
    } else {
      // Fallback a IDs de prueba de Google
      if (Platform.isAndroid) {
        adId = 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        adId = 'ca-app-pub-3940256099942544/4411468910';
      }
    }
    debugPrint('AdManager: Using Interstitial ID: $adId');
    return adId;
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < _maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  /// Muestra el anuncio Intersticial solo si está listo y si están activados
  void showInterstitialAd({required bool isPremium}) {
    // Si el usuario es premium o los desactivó desde configuración, no hacer nada
    if (isPremium || !_showInterstitials) return;

    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}

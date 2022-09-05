import 'dart:io';

import "package:flutter/material.dart";
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdClass {
  // 	ca-app-pub-3940256099942544/5224354917 test interstitial
  AdWidget?adDisplayWidget;
  InterstitialAd? _interstitialAd;

  InterstitialAdClass();



  void setUpInterstitial()async {
    //if(!SharedPrefsClass.hasPurchasedApp) {
    Platform.isAndroid ? InterstitialAd.load(
        request: AdRequest(),
        adUnitId: "$instertitialID",
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            this._interstitialAd = ad;
            this._interstitialAd?.fullScreenContentCallback =
                FullScreenContentCallback(
                  onAdShowedFullScreenContent: (InterstitialAd ad) {},
                  onAdDismissedFullScreenContent: (InterstitialAd ad) {
                    ad.dispose();
                    this._interstitialAd?.dispose();
                  },
                  onAdFailedToShowFullScreenContent: (InterstitialAd ad,
                      AdError error) {
                    ad.dispose();
                    this._interstitialAd?.dispose();
                  },
                  onAdImpression: (InterstitialAd ad) {},
                );
            if (this._interstitialAd == null) {
              setUpInterstitial();
            } else {
              this._interstitialAd?.show();
            }
          },
          onAdFailedToLoad: (LoadAdError error) {},
        )) : SizedBox();
    // }


  }
}

import 'package:midgard_repository/midgard_repository.dart';

class HelpersOfThor {

  static const String poolBUSD = 'BNB.BUSD-BD1';
  static const String poolUSDT = 'ETH.USDT-0XDAC17F958D2EE523A2206206994597C13D831EC7';
  static const String poolUSDC = 'ETH.USDC-0XA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48';

  /// Returns the USD price of RUNE and the value of USD
  static RuneUSD blendedPriceFromDepths(Map<String, ThorPool> pools) {
    List<double> usdList = [];
    List<double> runeList = [];

    if (pools.containsKey(poolBUSD)) {
      final pool = pools[poolBUSD];
      final rune = pool!.balanceAsset / pool.balanceRune;
      final usd = pool.balanceRune / pool.balanceAsset;
      runeList.add(rune);
      usdList.add(usd * rune);
    }

    if (pools
        .containsKey(poolUSDT)) {
      final pool = pools[poolUSDT];
      final rune = pool!.balanceAsset / pool.balanceRune;
      final usd = pool.balanceRune / pool.balanceAsset;
      runeList.add(rune);
      usdList.add(usd * rune);
    }
    
    if (pools
        .containsKey(poolUSDC)) {
      final pool = pools[poolUSDC];
      final rune = pool!.balanceAsset / pool.balanceRune;
      final usd = pool.balanceRune / pool.balanceAsset;
      runeList.add(rune);
      usdList.add(usd * rune);
    }

    // USD
    var usdTotal = 0.0;
    var usdCounted = 0;
    for (var x in usdList) {
      if (x != 0) {
        usdTotal = usdTotal + x;
        usdCounted = usdCounted + 1;
      }
    }
    final blendedUSD = usdTotal / usdCounted;

    // Rune
    var runeTotal = 0.0;
    var runeCounted = 0;
    for (var x in runeList) {
      if (x != 0) {
        runeTotal = runeTotal + x;
        runeCounted = runeCounted + 1;
      }
    }
    final blendedRune = runeTotal / runeCounted;

    return RuneUSD(runeUSD: blendedRune, valueUSD: blendedUSD);
  }
}

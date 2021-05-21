import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:midgard_repository/src/helpers.dart';
import 'package:midgard_repository/src/models.dart';

/// {@template midgard_api_client}
/// Dart API Client which wraps the THORChain [Thor Node API](https://gitlab.com/thorchain/thornode/-/tree/master/docs/api).
/// {@endtemplate}
class ThorNodeAPIClient {
  ThorNodeAPIClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();
  static const _baseUrl = "thornode.thorchain.info";
  static const _version = "thorchain/";
  final http.Client _httpClient;

  /// Get all pools and return a map with [PoolOfThor]
  /// for each item in the array.
  Future<Map<String, ThorPool>> getPools({int? height}) async {
    var args = <String, dynamic>{};
    height != null
        ? args = <String, dynamic>{'height': height.toString()}
        : args = <String, dynamic>{};
    final api = 'pools';
    final uri = Uri.https(_baseUrl, _version + api, args);
    final result = await _httpClient.get(uri);
    dynamic json = jsonDecode(result.body);
    var pools = <String, ThorPool>{};
    (json as List).forEach((dynamic element) {
      final pool = ThorPool.fromJson(element as Map<String, dynamic>);
      pools[pool.asset] = pool;
    });

    final runeUSD = HelpersOfThor.blendedPriceFromDepths(pools);
    for(var x in pools.values)
    {
      final poolSideUSD = x.balanceRune * runeUSD.runeUSD;

      pools[x.asset]?.assetPrice = poolSideUSD / x.balanceAsset;
    }
    return pools;
  }

  Future<ThorTransaction> getTXDetails(ActionOfThor action) async {
    final uri = Uri.https(_baseUrl, '/thorchain/tx/${action.inputs[0].txID}/signers');
    final result = await _httpClient.get(uri);
    dynamic json = jsonDecode(result.body);
    final tx = ThorTransaction.fromJson(json as Map<String, dynamic>);
    return tx;

  }
}

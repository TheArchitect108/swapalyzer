import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:midgard_repository/src/models.dart';

/// {@template midgard_api_client}
/// Dart API Client which wraps the THORChain [Midgard API](https://testnet.midgard.thorchain.info/v2/doc).
/// {@endtemplate}
class MidgardAPIClient {
  MidgardAPIClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();
  static const _baseUrl = 'midgard.thorchain.info';
  static const _version = '/v2/';
  final http.Client _httpClient;

  /// Find a [SwapAction] `/actions?txid=`
  Future<List<ActionOfThor>> getSwapActions(String txID) async {
    var args = {'txid': txID, 'offset': '0', 'limit': '5'};
    var api = 'actions';
    final uri = Uri.https(_baseUrl, _version + '$api', args);
    final result = await _httpClient.get(uri);
    dynamic json = jsonDecode(result.body);
    List<ActionOfThor> actions = [];
    (json['actions'] as List).forEach((dynamic element) {
      actions.add(ActionOfThor.fromJson(element as Map<String, dynamic>));
    });
    return actions;
  }

  /// Find a [SwapAction] `/actions?txid=`
  /// Returns a list of [ActionOfThor]
  Future<List<ActionOfThor>> getAssetActions(String asset) async {
    var args = {'asset': asset, 'offset': '0', 'limit': '50'};
    var api = 'actions';
    final uri = Uri.https(_baseUrl, _version + '$api', args);
    final result = await _httpClient.get(uri);

    dynamic json = jsonDecode(result.body);
    List<ActionOfThor> actions = [];
    (json['actions'] as List).forEach((dynamic element) {
      actions.add(ActionOfThor.fromJson(element as Map<String, dynamic>));
    });
    return actions;
  }
}

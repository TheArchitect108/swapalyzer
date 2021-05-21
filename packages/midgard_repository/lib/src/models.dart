/// Possible actions: [swap], [addLiquidity]
enum ThorActionType { swap, addLiquidity, none }

/// Action of Thor (AoT)
/// Represents a THORChain Action - requires [date],
/// the block [height], a list of [inputs],
/// [metadata],
class ActionOfThor {
  ActionOfThor(
      {required this.date,
      required this.height,
      required this.status,
      required this.inputs,
      required this.inputAsset,
      required this.inputShort,
      required this.inputsTotal,
      required this.outputs,
      required this.outputAsset,
      required this.outputShort,
      required this.outputsTotal,
      required this.metadata,
      required this.type});
  DateTime date;
  int height;
  String status;
  List<Transaction> inputs;
  List<Transaction> outputs;
  String inputAsset;
  String inputShort;
  double inputsTotal;
  String outputAsset;
  String outputShort;
  double outputsTotal;
  ThorActionType type;
  AoTMetadata? metadata;

  factory ActionOfThor.fromJson(Map<String, dynamic> json) {
    final date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['date'] as String) ~/ 1e6);
    final height = int.parse(json['height'] as String);
    final status = json['status'] as String;
    final inputs = (List<Map<String, dynamic>>.from(json['in'] as List))
        .map((e) => Transaction.fromJson(e)..combineInputs())
        .toList();
    var inputsTotal = 0.0;
    for (var x in inputs) {
      inputsTotal = inputsTotal + x.inputsTotal;
    }
    final inputAsset = inputs[0].coinInputs[0].asset;
    final String inputShort = inputAsset.contains('-') &&
            inputAsset.split('.')[1] != inputAsset.split('.')[0]
        ? inputAsset.split('.')[1].split('-')[0] +
            ' (${inputAsset.split('.')[0]})'
        : inputAsset.split('.')[1];

    final outputs = (List<Map<String, dynamic>>.from(json['out'] as List))
        .map((e) => Transaction.fromJson(e)..combineInputs())
        .toList();
    var outputsTotal = 0.0;
    for (var x in outputs) {
      outputsTotal = outputsTotal + x.inputsTotal;
    }
    final outputAsset = outputs[0].coinInputs[0].asset;

    final String outputShort = outputAsset.contains('-') &&
            outputAsset.split('.')[1] != outputAsset.split('.')[0]
        ? outputAsset.split('.')[1].split('-')[0] +
            ' (${outputAsset.split('.')[0]})'
        : outputAsset.split('.')[1];

    var type = ThorActionType.none;
    switch (json['type'] as String) {
      case 'swap':
        type = ThorActionType.swap;
        break;
      case 'addLiquidity':
        type = ThorActionType.addLiquidity;
        break;
    }

    AoTMetadata? metadata;
    switch (type) {
      case ThorActionType.swap:
        metadata = SwapMetaData.fromJson(
            json['metadata']['swap'] as Map<String, dynamic>);
        break;
      case ThorActionType.addLiquidity:
        break;
      case ThorActionType.none:
        break;
    }

    return ActionOfThor(
        date: date,
        height: height,
        inputs: inputs,
        inputAsset: inputAsset,
        inputShort: inputShort,
        inputsTotal: inputsTotal,
        outputAsset: outputAsset,
        outputShort: outputShort,
        outputsTotal: outputsTotal,
        outputs: outputs,
        type: type,
        status: status,
        metadata: metadata);
  }
}

/// A wrapper for network fees or gas costs containing
/// the [asset] and [amount].
class NetworkFee {
  NetworkFee({required this.asset, required this.amount});
  String asset;
  late String assetShort;
  double amount;

  NetworkFee.fromJson(Map<String, dynamic> json)
      : asset = (json['asset'] as String),
        assetShort = (json['asset'] as String).split('.')[1].split('-')[0],
        amount = int.parse(json['amount'].toString()) / 1e8;
}

abstract class AoTMetadata {}

/// Metadata related to a Swap Action
class SwapMetaData extends AoTMetadata {
  SwapMetaData(
      {required this.fees,
      required this.liquidityFee,
      required this.swapSlip,
      required this.swapTarget});

  /// A list of all [fees] related to the swap.
  List<NetworkFee> fees;

  /// The [liquidityFee] paid to the pool for liquidity.
  double liquidityFee;

  /// [swapSlip] -- result slippage based on
  /// pool depths at block height.
  double swapSlip;

  /// The [swapTarget] amount sent with the memo.
  double swapTarget;

  SwapMetaData.fromJson(Map<String, dynamic> json)
      : fees = (List<Map<String, dynamic>>.from(json['networkFees'] as List))
            .map((e) => NetworkFee.fromJson(e))
            .toList(),
        liquidityFee = int.parse(json['liquidityFee'].toString()) / 1e8,
        swapSlip = double.parse(json['swapSlip'] as String),
        swapTarget = int.parse(json['swapTarget'] as String) / 1e8;
}

/// Metadata related to Add Liquidity Action.
class AddLiquidityMetadata extends AoTMetadata {
  AddLiquidityMetadata({required this.liquidityUnits});

  /// The resulting [liquidityUnits] from a liquidity
  /// addition to a pool.
  int liquidityUnits;
}

class WithdrawMetadata extends AoTMetadata {}

class RefundMetadata extends AoTMetadata {}

/// Basic model [asset] ID and [amount] serialized to double -- /1e8
class CoinInput {
  CoinInput({required this.amount, required this.asset});
  double amount;
  String asset;

  CoinInput.fromJson(Map<String, dynamic> json)
      : amount = int.parse(json['amount'] as String) / 1e8,
        asset = (json['asset'] as String);
}

/// Model for both inputs and outputs,
/// Originating [address], [txID] of input, and [coinInputs] as a
/// list incase multiple coins are involved.
class Transaction {
  Transaction(
      {required this.address, required this.txID, required this.coinInputs});

  Transaction.fromJson(Map<String, dynamic> json)
      : address = (json['address'] as String),
        txID = (json['txID'] as String),
        coinInputs = (List<Map<String, dynamic>>.from(json['coins'] as List))
            .map((e) => CoinInput.fromJson(e))
            .toList();
  String address;
  String txID;
  List<CoinInput> coinInputs;
  late double inputsTotal;

  void combineInputs() {
    var total = 0.0;
    for (var x = 0; x < coinInputs.length; x++) {
      total = total + coinInputs[x].amount;
    }
    inputsTotal = total;
  }
}

/// Model for pool information such as
/// the [status], and depth
class ThorPool {
  ThorPool({
    required this.balanceRune,
    required this.balanceAsset,
    required this.pendingInboundRune,
    required this.pendingInboundAsset,
    required this.poolUnits,
    required this.asset,
    required this.status,
  });

  ThorPool.fromJson(Map<String, dynamic> json)
      : balanceRune = int.parse(json['balance_rune'].toString()) / 1e8,
        balanceAsset = int.parse(json['balance_asset'].toString()) / 1e8,
        pendingInboundRune =
            int.parse(json['pending_inbound_rune'].toString()) / 1e8,
        pendingInboundAsset =
            int.parse(json['pending_inbound_asset'].toString()) / 1e8,
        poolUnits = int.parse(json['pool_units'].toString()) / 1e8,
        asset = json['asset'].toString(),
        status = json['status'].toString();

  late double assetPrice;
  double balanceRune;
  double balanceAsset;
  double pendingInboundRune;
  double pendingInboundAsset;
  double poolUnits;
  String asset;
  String status;
}

/// The value of blended synthetic USD and
/// the price of RUNE in blended synthetic USD
class RuneUSD {
  /// Value of USD on the platform;
  double valueUSD;

  /// Value of Rune on the platform;
  double runeUSD;

  RuneUSD({required this.valueUSD, required this.runeUSD});
}

enum ThorTXDirection { txin, txout }

class ThorTX {
  ThorTX(
      {required this.txID,
      required this.chain,
      required this.fromAddress,
      required this.toAddress,
      required this.fees,
      required this.coinInputs,
      required this.memo,
      required this.direction});

  ThorTX.fromJson(Map<String, dynamic> json, ThorTXDirection dir)
      : txID = json['id'].toString(),
        chain = json['chain'].toString(),
        fromAddress = json['from_address'].toString(),
        toAddress = json['to_address'].toString(),
        fees = (List<Map<String, dynamic>>.from(json['gas'] as List))
            .map((e) => NetworkFee.fromJson(e))
            .toList(),
        coinInputs = (List<Map<String, dynamic>>.from(json['coins'] as List))
            .map((e) => CoinInput.fromJson(e))
            .toList(),
        memo = json['memo'].toString(),
        direction = dir;

  String txID;
  String chain;
  String fromAddress;
  String toAddress;
  List<NetworkFee> fees;
  List<CoinInput> coinInputs;
  String memo;
  ThorTXDirection direction;
}

/// Mirrors the node transaction model
class ThorTransaction {
  ThorTransaction(
      {required this.txID,
      required this.input,
      required this.output,
      required this.height});

  factory ThorTransaction.fromJson(Map<String, dynamic> json) {
    final txID = json['tx_id'].toString();
    final input = ThorTX.fromJson(
        json['tx']['tx'] as Map<String, dynamic>, ThorTXDirection.txin);
    ThorTX output;
    output = json['out_txs'] != null
        ? ThorTX.fromJson(
            json['out_txs'][0] as Map<String, dynamic>, ThorTXDirection.txout)
        : ThorTX.fromJson(
            json['txs'][0] as Map<String, dynamic>, ThorTXDirection.txout);
    final height = json['finalised_height'] as int;
    return ThorTransaction(
        txID: txID, input: input, output: output, height: height);
  }

  String txID;
  ThorTX input;
  ThorTX? output;
  int height;
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:midgard_repository/midgard_repository.dart';

part 'swapaction_event.dart';
part 'swapaction_state.dart';

class SwapActionBloc extends Bloc<SwapActionEvent, SwapActionState> {
  SwapActionBloc() : super(SwapActionEmptyState());

  MidgardAPIClient midAPI = new MidgardAPIClient();
  ThorNodeAPIClient nodeAPI = new ThorNodeAPIClient();

  @override
  Stream<SwapActionState> mapEventToState(
    SwapActionEvent event,
  ) async* {
    if (event is SwapActionGetEvent) {
      yield SwapActionLoadingState();
      try {
        var txID = event.txID;
        if (event.txID.toLowerCase().startsWith('0x')) {
          txID = event.txID.substring(2);
        }
        final List<ActionOfThor> actions =
            await midAPI.getSwapActions(txID);
        final transaction = await nodeAPI.getTXDetails(actions[0]);
        final pools = await nodeAPI.getPools(height: transaction.height);
        final runeUSD = HelpersOfThor.blendedPriceFromDepths(pools);
        if (actions.isNotEmpty)
          yield SwapActionActiveState(
              action: actions[0],
              thorTX: transaction,
              runeUSD: runeUSD,
              pools: pools);
        else
          yield SwapActionEmptyState();
      } catch (e) {
        yield SwapActionEmptyState();
      }
    }
  }
}

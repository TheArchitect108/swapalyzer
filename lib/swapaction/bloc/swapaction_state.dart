part of 'swapaction_bloc.dart';

@immutable
abstract class SwapActionState {}

class SwapActionEmptyState extends SwapActionState {}

/// Provides a state containing the last requested [action]
class SwapActionActiveState extends SwapActionState {
  SwapActionActiveState(
      {required this.action,
      required this.thorTX,
      required this.runeUSD,
      required this.pools});
  final ActionOfThor action;
  final ThorTransaction thorTX;
  final RuneUSD runeUSD;
  final Map<String, ThorPool> pools;
}

class SwapActionLoadingState extends SwapActionState {}

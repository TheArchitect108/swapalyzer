part of 'swapaction_bloc.dart';

@immutable
abstract class SwapActionEvent {}

class SwapActionGetEvent extends SwapActionEvent {
  SwapActionGetEvent(this.txID);
  final String txID;
}

class SwapActionClearEvent extends SwapActionEvent {}

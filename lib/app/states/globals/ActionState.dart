abstract class ActionState<T> {}

class IdleState extends ActionState {}

class SuccessState<T> extends ActionState<T> {
  final T value;

  SuccessState({this.value});
}

class ErrorState extends ActionState {
  final String errorMessage;

  ErrorState(this.errorMessage);
}

class LoadingState extends ActionState {}

class FailedState extends ActionState {}

class CancelState extends ActionState {}

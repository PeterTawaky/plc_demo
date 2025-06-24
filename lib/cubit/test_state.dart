part of 'test_cubit.dart';

@immutable
abstract class TestState {}

class TestInitial extends TestState {}

class TestConnecting extends TestState {}

class TestConnected extends TestState {}

class TestConnectionFailed extends TestState {
  final String error;
  
  TestConnectionFailed(this.error);
}

class TestReading extends TestState {}

class TestDataUpdated extends TestState {}

class TestWriting extends TestState {}

class TestWriteSuccess extends TestState {}

class TestDisconnected extends TestState {}

class TestError extends TestState {
  final String message;
  
  TestError(this.message);
}
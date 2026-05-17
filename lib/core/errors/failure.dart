import 'package:equatable/equatable.dart';

import 'app_exception.dart';

class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  factory Failure.fromException(AppException e) =>
      Failure(message: e.message, code: e.code);

  @override
  List<Object?> get props => [message, code];
}

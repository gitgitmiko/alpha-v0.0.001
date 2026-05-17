import 'package:equatable/equatable.dart';

sealed class AppException extends Equatable implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

final class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

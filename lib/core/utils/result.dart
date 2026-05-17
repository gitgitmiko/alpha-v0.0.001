import '../errors/failure.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class ErrorResult<T> extends Result<T> {
  const ErrorResult(this.failure);
  final Failure failure;
}

extension ResultX<T> on Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      ErrorResult(:final failure) => error(failure),
    };
  }
}

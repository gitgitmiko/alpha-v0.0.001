import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failure.dart';
import '../../presentation/widgets/error_retry_widget.dart';
import '../../presentation/widgets/loading_widget.dart';

extension AsyncValueUI<T> on AsyncValue<T> {
  Widget whenWidget({
    required Widget Function(T data) data,
    Widget? loading,
    Widget Function(Failure failure, VoidCallback onRetry)? error,
    VoidCallback? onRetry,
  }) {
    return when(
      data: data,
      loading: () => loading ?? const LoadingWidget(),
      error: (e, _) {
        final failure = Failure(message: e.toString());
        return error?.call(failure, onRetry ?? () {}) ??
            ErrorRetryWidget(
              message: failure.message,
              onRetry: onRetry,
            );
      },
    );
  }
}

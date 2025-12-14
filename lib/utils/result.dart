// lib/utils/result.dart (FAIL BARU - ERROR HANDLING WRAPPER)

/// Generic Result class untuk handle success/failure dengan type-safe
///
/// Guna macam ni:
/// ```dart
/// Result<User, String> result = await getUserData();
/// if (result.isSuccess) {
///   print(result.data.name);
/// } else {
///   print('Error: ${result.error}');
/// }
/// ```
class Result<T, E> {
  final T? data;
  final E? error;
  final bool isSuccess;

  // Private constructor
  Result._({this.data, this.error, required this.isSuccess});

  // Factory constructor untuk success
  factory Result.success(T data) {
    return Result._(data: data, error: null, isSuccess: true);
  }

  // Factory constructor untuk failure
  factory Result.failure(E error) {
    return Result._(data: null, error: error, isSuccess: false);
  }

  // Helper getter
  bool get isFailure => !isSuccess;

  // Safe data access dengan default value
  T dataOr(T defaultValue) => data ?? defaultValue;

  // Transform data bila success
  Result<R, E> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data!));
      } catch (e) {
        return Result.failure(e as E);
      }
    }
    return Result.failure(error as E);
  }

  // Handle bila failure
  Result<T, E> onError(void Function(E error) handler) {
    if (isFailure && error != null) {
      handler(error!);
    }
    return this;
  }

  // Handle bila success
  Result<T, E> onSuccess(void Function(T data) handler) {
    if (isSuccess && data != null) {
      handler(data!);
    }
    return this;
  }
}

/// Extension untuk Future<Result> - shortcut methods
extension ResultFutureExtension<T, E> on Future<Result<T, E>> {
  Future<T?> getDataOrNull() async {
    final result = await this;
    return result.data;
  }

  Future<T> getDataOr(T defaultValue) async {
    final result = await this;
    return result.dataOr(defaultValue);
  }
}
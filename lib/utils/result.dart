// lib/utils/result.dart
class Result<T, E> {
  final T?   data;
  final E?   error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data)  => Result._(data: data,  error: null,  isSuccess: true);
  factory Result.failure(E error) => Result._(data: null,  error: error, isSuccess: false);

  bool get isFailure => !isSuccess;

  T dataOr(T def) => data ?? def;

  Result<R, E> map<R>(R Function(T d) fn) {
    if (isSuccess && data != null) {
      try { return Result.success(fn(data!)); }
      catch (e) { return Result.failure(e as E); }
    }
    return Result.failure(error as E);
  }

  Result<T, E> onError(void Function(E e) fn) {
    if (isFailure && error != null) fn(error!);
    return this;
  }

  Result<T, E> onSuccess(void Function(T d) fn) {
    if (isSuccess && data != null) fn(data!);
    return this;
  }
}

extension ResultFutureExt<T, E> on Future<Result<T, E>> {
  Future<T?> getDataOrNull()          async => (await this).data;
  Future<T>  getDataOr(T def)         async => (await this).dataOr(def);
}

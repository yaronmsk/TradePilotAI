class StorageResult<T> {
  const StorageResult.success(this.value) : error = null;

  const StorageResult.failure(this.error) : value = null;

  final T? value;

  final Object? error;

  bool get isSuccess => error == null;

  bool get isFailure => error != null;
}

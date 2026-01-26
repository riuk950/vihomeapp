/// Tipo funcional para manejar éxito o fallo
abstract class Either<L, R> {
  const Either();
  
  bool get isLeft;
  bool get isRight;
  
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);
  
  Either<L, T> map<T>(T Function(R right) f);
  Either<T, R> mapLeft<T>(T Function(L left) f);
  
  R getOrElse(R Function(L left) orElse);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
  
  @override
  bool get isLeft => true;
  
  @override
  bool get isRight => false;
  
  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(value);
  }
  
  @override
  Either<L, T> map<T>(T Function(R right) f) {
    return Left<L, T>(value);
  }
  
  @override
  Either<T, R> mapLeft<T>(T Function(L left) f) {
    return Left<T, R>(f(value));
  }
  
  @override
  R getOrElse(R Function(L left) orElse) {
    return orElse(value);
  }
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
  
  @override
  bool get isLeft => false;
  
  @override
  bool get isRight => true;
  
  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(value);
  }
  
  @override
  Either<L, T> map<T>(T Function(R right) f) {
    return Right<L, T>(f(value));
  }
  
  @override
  Either<T, R> mapLeft<T>(T Function(L left) f) {
    return Right<T, R>(value);
  }
  
  @override
  R getOrElse(R Function(L left) orElse) {
    return value;
  }
}


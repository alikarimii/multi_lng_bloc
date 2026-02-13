import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repo.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? name,
  }) {
    return _repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repo.dart';

@lazySingleton
class GetUsersUseCase {
  final ProfileRepository _repository;

  const GetUsersUseCase(this._repository);

  Future<Either<Failure, List<User>>> call() {
    return _repository.getUsers();
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repo.dart';

@lazySingleton
class GetProfileUseCase {
  final ProfileRepository _repository;

  const GetProfileUseCase(this._repository);

  Future<Either<Failure, User>> call({String? userId}) {
    return _repository.getProfile(userId: userId);
  }
}

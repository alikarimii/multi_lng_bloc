import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/get_users.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfile;
  final GetUsersUseCase _getUsers;

  ProfileBloc(this._getProfile, this._getUsers)
      : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final profileResult = await _getProfile(userId: event.userId);
    final usersResult = await _getUsers();

    Failure? failure;
    User? profileUser;
    List<User>? users;

    profileResult.fold(
      (f) => failure = f,
      (value) => profileUser = value,
    );
    usersResult.fold(
      (f) => failure ??= f,
      (value) => users = value,
    );

    if (failure != null || profileUser == null || users == null) {
      emit(ProfileError(failure?.message ?? 'Failed to load profile'));
      return;
    }

    emit(ProfileLoaded(profileUser: profileUser!, users: users!));
  }
}

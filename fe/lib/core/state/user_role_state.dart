import 'package:hackathon/core/services/auth_state.dart';

class UserRoleState {
  bool isPsychologist = false;

  Future<void> fetchRole() async {
    await authState.init();
    isPsychologist = authState.isPsychologist;
  }
}

final UserRoleState userRoleState = UserRoleState();
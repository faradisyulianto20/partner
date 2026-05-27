import 'package:supabase_flutter/supabase_flutter.dart';

class UserRoleState {
  bool isPsychologist = false;

  Future<void> fetchRole() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    final response = await supabase
        .from('profiles') // sesuaikan nama tabel kamu
        .select('role')
        .eq('id', userId)
        .single();

    isPsychologist = response['role'] == 'psychologist';
  }
}

final UserRoleState userRoleState = UserRoleState();
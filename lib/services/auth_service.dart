import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider.autoDispose((ref) => AuthService());

final authStateProvider = StreamProvider.autoDispose((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((data) => data.session?.user);
});

final currentUserProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  
  return Supabase.instance.client
      .from('users')
      .stream(primaryKey: ['id'])
      .eq('id', authUser.id)
      .limit(1)
      .map((data) => data.isEmpty ? null : UserModel.fromMap(data.first));
});

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> signUp({
    required String email, required String password, required String name,
    required UserRole role, String? waNumber,
  }) async {
    final authResponse = await _supabase.auth.signUp(email: email, password: password);
    if (authResponse.user == null) throw const AuthException('Sign up failed: User is null.');

    final userModel = UserModel(
      id: authResponse.user!.id, name: name, email: email,
      role: role, waNumber: waNumber, createdAt: DateTime.now(),
    );
    await _supabase.from('users').insert(userModel.toMap());
  }

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    final data = await _supabase.from('users').select().eq('id', user.id).single();
    return UserModel.fromMap(data);
  }

  Future<void> updateUserProfile({required String userId, required Map<String, dynamic> data}) async {
    await _supabase.from('users').update(data).eq('id', userId);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart'; // Pastikan UserModel.dart sudah disesuaikan jika perlu

// Provider untuk AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Provider untuk Stream perubahan status autentikasi dari Supabase
final authStateProvider = StreamProvider<supabase.User?>((ref) {
  // `onAuthStateChange` di Supabase mengembalikan AuthChangeEvent dan Session?
  // Kita hanya tertarik pada User di dalam Session
  return Supabase.instance.client.auth.onAuthStateChange.map((data) => data.session?.user);
});

// Provider untuk mendapatkan data UserModel dari Supabase
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      
      // Ambil data pengguna dari tabel 'users' di Supabase
      return Supabase.instance.client
          .from('users') // Nama tabel pengguna Anda di Supabase
          .stream(primaryKey: ['id']) // Mendengarkan perubahan pada baris ini (pastikan 'id' adalah PK)
          .eq('id', user.id) // Filter berdasarkan ID pengguna Supabase
          .limit(1) // Hanya perlu satu hasil
          .map((List<Map<String, dynamic>> data) {
            if (data.isEmpty) return null;
            return UserModel.fromMap(data.first);
          });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null), // Menangani error jika ada
  );
});

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan User yang saat ini login (GoTrueUser dari Supabase)
  supabase.User? get currentUser => _supabase.auth.currentUser;

  // Metode untuk registrasi pengguna baru
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role, // Pastikan UserRole adalah enum atau kelas yang valid
    String? waNumber,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final supabase.User? user = response.user; // Ini adalah GoTrueUser dari Supabase
      if (user != null) {
        final UserModel userModel = UserModel(
          id: user.id, // Gunakan user.id dari Supabase User
          name: name,
          email: email,
          role: role,
          waNumber: waNumber,
          createdAt: DateTime.now(),
        );

        // Simpan data tambahan pengguna ke tabel 'users' di Supabase
        await _supabase.from('users').insert(userModel.toMap());
        return userModel;
      }
    } on AuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
    return null;
  }

  // Metode untuk login pengguna
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supabase.User? user = response.user; // Ini adalah GoTrueUser dari Supabase
      if (user != null) {
        // Ambil data tambahan pengguna dari tabel 'users'
        final List<Map<String, dynamic>> data = await _supabase
            .from('users')
            .select() // Ambil semua kolom
            .eq('id', user.id) // Filter berdasarkan ID pengguna Supabase
            .limit(1); // Hanya perlu satu hasil

        if (data.isNotEmpty) {
          return UserModel.fromMap(data.first);
        }
      }
    } on AuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
    return null;
  }

  // Metode untuk logout pengguna
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Failed to sign out: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Metode untuk mendapatkan data pengguna saat ini dari tabel 'users'
  Future<UserModel?> getCurrentUserData() async {
    try {
      final supabase.User? user = _supabase.auth.currentUser; // Ini adalah GoTrueUser
      if (user != null) {
        final List<Map<String, dynamic>> data = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .limit(1);

        if (data.isNotEmpty) {
          return UserModel.fromMap(data.first);
        }
      }
    } on AuthException catch (e) { // Tangani AuthException jika user null/tidak valid
       throw Exception('Failed to get current user data: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
    return null;
  }

  // Metode untuk memperbarui profil pengguna di tabel 'users'
  Future<void> updateUserProfile({
    String? name,
    String? waNumber,
  }) async {
    try {
      final supabase.User? user = _supabase.auth.currentUser;
      if (user != null) {
        final Map<String, dynamic> updates = {};
        if (name != null) updates['name'] = name;
        if (waNumber != null) updates['wa_number'] = waNumber;
        
        if (updates.isNotEmpty) {
          await _supabase
              .from('users')
              .update(updates)
              .eq('id', user.id); // Perbarui baris yang sesuai dengan ID pengguna
        }
      }
    } on AuthException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
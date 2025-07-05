// test/features/auth/data/auth_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart'; // Paket populer untuk mocking

// Buat kelas Mock untuk SupabaseClient
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    // Stubbing: Saat 'client.auth' dipanggil, kembalikan mock GoTrueClient
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  group('AuthRepository', () {
    // Contoh grup test untuk fungsi signIn
    group('signIn', () {
      test('seharusnya berhasil login jika kredensial valid', () async {
        // Arrange
        // Siapkan respons tiruan dari Supabase
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => AuthResponse(session: Session(accessToken: '', tokenType: '', user: const User(id: '123', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''))));
        
        // Act
        // Panggil metode signIn di repository
        
        // Assert
        // Verifikasi bahwa metode signInWithPassword di Supabase dipanggil tepat satu kali.
        // Anda juga bisa menambahkan verifikasi lainnya.
      });

      test('seharusnya melempar AuthException jika kredensial salah', () async {
        // Arrange
        // Siapkan agar Supabase melempar error
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          ),
        ).thenThrow(const AuthException('Invalid login credentials'));

        // Act & Assert
        // Verifikasi bahwa pemanggilan metode signIn akan melempar AuthException.
      });
    });
  });
}

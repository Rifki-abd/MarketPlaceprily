import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_router.dart';
import '../../widgets/custom_text_field.dart';

// 1. Definisikan Notifier dan State
class RegisterState {
  final bool isLoading;
  final String? error;
  RegisterState({this.isLoading = false, this.error});
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  final AuthService _authService;
  RegisterNotifier(this._authService) : super(RegisterState());

  Future<bool> signUp({
    required String email, required String password, required String name,
    required UserRole role, String? waNumber,
  }) async {
    state = RegisterState(isLoading: true);
    try {
      await _authService.signUp(
        email: email, password: password, name: name,
        role: role, waNumber: waNumber,
      );
      state = RegisterState(isLoading: false);
      return true;
    } catch (e) {
      state = RegisterState(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// 2. Definisikan Provider untuk Notifier
final registerNotifierProvider = StateNotifierProvider.autoDispose<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref.watch(authServiceProvider));
});

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _waNumberController = TextEditingController();
  UserRole _selectedRole = UserRole.pembeli;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _waNumberController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(registerNotifierProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
      waNumber: _waNumberController.text.trim().isEmpty ? null : _waNumberController.text.trim(),
    );

    if (success && mounted) {
      AppNavigator.goToHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Dengarkan perubahan state
    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(registerNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (UI elements like CustomTextFields, RadioListTiles remain the same)
              CustomTextField(controller: _nameController, labelText: 'Nama Lengkap'),
              const SizedBox(height: 16),
              CustomTextField(controller: _emailController, labelText: 'Email'),
              const SizedBox(height: 16),
              CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
              const SizedBox(height: 16),
              CustomTextField(controller: _waNumberController, labelText: 'Nomor WhatsApp (Opsional)'),
              const SizedBox(height: 24),
              Text('Pilih Role', style: Theme.of(context).textTheme.titleMedium),
              ...UserRole.values.map((role) => RadioListTile<UserRole>(
                title: Text(role.name),
                value: role,
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading ? const CircularProgressIndicator() : const Text('Daftar'),
              ),
              TextButton(
                onPressed: () => AppNavigator.goToLogin(context),
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

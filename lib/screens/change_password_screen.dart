import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_card.dart';
import '../widgets/medieval_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await provider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sandi rahasia berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal memperbarui sandi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, VoidCallback onToggleVisibility, bool isObscured) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.merriweather(color: AppColors.textPrimary.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: AppColors.secondary),
      suffixIcon: IconButton(
        icon: Icon(isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.secondary),
        onPressed: onToggleVisibility,
      ),
      filled: true,
      fillColor: AppColors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ganti Sandi Rahasia',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ParchmentBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                MedievalCard(
                  child: Column(
                    children: [
                      Text(
                        'Amankan Akun Anda',
                        style: GoogleFonts.cinzel(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Perbarui kunci rahasia untuk menjaga keamanan harta Anda.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merriweather(
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                        decoration: _buildInputDecoration('Sandi Saat Ini', Icons.lock_outline, () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        }, _obscureCurrent),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                        decoration: _buildInputDecoration('Sandi Baru', Icons.lock, () {
                          setState(() => _obscureNew = !_obscureNew);
                        }, _obscureNew),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          if (v.length < 8) return 'Minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                        decoration: _buildInputDecoration('Konfirmasi Sandi Baru', Icons.lock_clock, () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        }, _obscureConfirm),
                        validator: (v) {
                          if (v != _newPasswordController.text) return 'Sandi tidak cocok';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Consumer<AuthProvider>(
                  builder: (context, provider, child) {
                    return MedievalButton(
                      label: 'Perbarui Sandi',
                      icon: Icons.save,
                      type: MedievalButtonType.primary,
                      isLoading: provider.isLoading,
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_card.dart';
import '../widgets/medieval_button.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParchmentBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      color: AppColors.white,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      'assets/images/AUCTOBID-Logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'AUCTOBID',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 36,
                    ),
                  ),
                  
                  Text(
                    'Gerbang Masuk',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      color: AppColors.textPrimary.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  MedievalCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Surat Elektronik (Email)',
                              prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email wajib diisi';
                              if (!value.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Kata Sandi (Password)',
                              prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password wajib diisi';
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return MedievalButton(
                                label: 'Masuki Gerbang',
                                icon: Icons.login,
                                isLoading: authProvider.isLoading,
                                onPressed: _login,
                                type: MedievalButtonType.primary,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum menjadi warga? ',
                        style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'Daftar Sekarang',
                          style: GoogleFonts.cinzel(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

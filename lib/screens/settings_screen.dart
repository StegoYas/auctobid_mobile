import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_card.dart';
import '../widgets/medieval_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'id';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: ParchmentBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Section
            _SectionHeader(title: 'Akun'),
            const SizedBox(height: 8),
            
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return MedievalCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: GoogleFonts.cinzel(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      user?.name ?? 'Pengguna',
                      style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      user?.email ?? '',
                      style: GoogleFonts.merriweather(fontSize: 12, color: AppColors.textPrimary.withOpacity(0.7)),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Notifications Section
            _SectionHeader(title: 'Notifikasi'),
            const SizedBox(height: 8),
            
            MedievalCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text('Push Notification', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                subtitle: Text('Terima notifikasi lelang dan bid', style: GoogleFonts.merriweather(fontSize: 12, color: AppColors.textPrimary.withOpacity(0.7))),
                value: _notificationsEnabled,
                activeColor: AppColors.secondary,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Display Section
            _SectionHeader(title: 'Tampilan'),
            const SizedBox(height: 8),
            
            MedievalCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text('Mode Gelap', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                    subtitle: Text('Aktifkan tema gelap', style: GoogleFonts.merriweather(fontSize: 12, color: AppColors.textPrimary.withOpacity(0.7))),
                    value: _darkMode,
                    activeColor: AppColors.secondary,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur mode gelap akan segera hadir'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: AppColors.secondary.withOpacity(0.3)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text('Bahasa', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                    subtitle: Text(_language == 'id' ? 'Bahasa Indonesia' : 'English', style: GoogleFonts.merriweather(fontSize: 12, color: AppColors.textPrimary.withOpacity(0.7))),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // About Section
            _SectionHeader(title: 'Tentang'),
            const SizedBox(height: 8),
            
            MedievalCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(Icons.info_outline, color: AppColors.primary),
                    title: Text('Versi Aplikasi', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                    trailing: Text('1.0.0', style: GoogleFonts.cinzel(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  Divider(height: 1, color: AppColors.secondary.withOpacity(0.3)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                    title: Text('Syarat & Ketentuan', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      _showInfoDialog(
                        'Syarat & Ketentuan',
                        'Dengan menggunakan aplikasi AUCTOBID, Anda setuju untuk mematuhi semua syarat dan ketentuan yang berlaku. Kami berhak untuk mengubah syarat dan ketentuan sewaktu-waktu.',
                      );
                    },
                  ),
                  Divider(height: 1, color: AppColors.secondary.withOpacity(0.3)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: Text('Kebijakan Privasi', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      _showInfoDialog(
                        'Kebijakan Privasi',
                        'Data pribadi Anda dilindungi dan hanya digunakan untuk keperluan layanan lelang online AUCTOBID. Kami tidak akan membagikan data Anda kepada pihak ketiga tanpa persetujuan.',
                      );
                    },
                  ),
                  Divider(height: 1, color: AppColors.secondary.withOpacity(0.3)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(Icons.help_outline, color: AppColors.primary),
                    title: Text('Bantuan', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                    onTap: () {
                      _showInfoDialog(
                        'Bantuan',
                        'Jika Anda memiliki pertanyaan atau masalah, silakan hubungi kami melalui email: support@auctobid.com',
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return MedievalButton(
                  label: 'Keluar dari Wilayah',
                  icon: Icons.logout,
                  type: MedievalButtonType.danger,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        title: Text('Konfirmasi', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        content: Text('Yakin ingin keluar dari akun?', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Batal', style: GoogleFonts.cinzel(color: AppColors.primary)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: Text('Keluar', style: GoogleFonts.cinzel()),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    }
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // App Info
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/AUCTOBID-Favicon.png',
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.gavel, size: 48, color: AppColors.primary);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AUCTOBID',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '© 2024 AUCTOBID. All rights reserved.',
                    style: GoogleFonts.merriweather(
                      fontSize: 12,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary, width: 2),
        ),
        title: Text('Pilih Bahasa', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Bahasa Indonesia', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
              value: 'id',
              groupValue: _language,
              activeColor: AppColors.secondary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('English', style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
              value: 'en',
              groupValue: _language,
              activeColor: AppColors.secondary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('English language coming soon'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary, width: 2),
        ),
        title: Text(title, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Text(content, style: GoogleFonts.merriweather(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.cinzel(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}

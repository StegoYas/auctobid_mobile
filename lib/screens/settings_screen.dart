import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

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
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _SectionHeader(title: 'Akun'),
          const SizedBox(height: 8),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(user?.name ?? 'Pengguna'),
                  subtitle: Text(user?.email ?? ''),
                  trailing: const Icon(Icons.chevron_right),
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
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notification'),
                  subtitle: const Text('Terima notifikasi lelang dan bid'),
                  value: _notificationsEnabled,
                  activeColor: AppColors.secondary,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Display Section
          _SectionHeader(title: 'Tampilan'),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode Gelap'),
                  subtitle: const Text('Aktifkan tema gelap'),
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
                const Divider(height: 1),
                ListTile(
                  title: const Text('Bahasa'),
                  subtitle: Text(_language == 'id' ? 'Bahasa Indonesia' : 'English'),
                  trailing: const Icon(Icons.chevron_right),
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
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('Versi Aplikasi'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: const Text('Syarat & Ketentuan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      'Syarat & Ketentuan',
                      'Dengan menggunakan aplikasi AUCTOBID, Anda setuju untuk mematuhi semua syarat dan ketentuan yang berlaku. Kami berhak untuk mengubah syarat dan ketentuan sewaktu-waktu.',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                  title: const Text('Kebijakan Privasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      'Kebijakan Privasi',
                      'Data pribadi Anda dilindungi dan hanya digunakan untuk keperluan layanan lelang online AUCTOBID. Kami tidak akan membagikan data Anda kepada pihak ketiga tanpa persetujuan.',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.primary),
                  title: const Text('Bantuan'),
                  trailing: const Icon(Icons.chevron_right),
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
              return OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Yakin ingin keluar dari akun?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Keluar'),
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
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Keluar dari Akun',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '© 2024 AUCTOBID. All rights reserved.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Bahasa Indonesia'),
              value: 'id',
              groupValue: _language,
              activeColor: AppColors.secondary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
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
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
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
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_card.dart';
import '../widgets/medieval_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Warga',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: ParchmentBackground(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  MedievalCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.background,
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? '?',
                              style: GoogleFonts.cinzel(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'Pengguna Misterius',
                          style: GoogleFonts.cinzel(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.merriweather(
                            fontSize: 14,
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Text(
                            'Warga Resmi',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Menu Items
                  _buildSectionTitle(context, 'Pengaturan Akun'),
                  const SizedBox(height: 8),
                  
                  MedievalCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.edit_outlined,
                          title: 'Ubah Data Diri',
                          onTap: () {
                             Navigator.pushNamed(context, AppRoutes.editProfile);
                          },
                          showDivider: true,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.history_edu,
                          title: 'Riwayat Penawaran',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.bidHistory);
                          },
                          showDivider: true,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.emoji_events_outlined,
                          title: 'Lelang Dimenangkan',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.wonAuctions);
                          },
                          showDivider: true,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.vpn_key_outlined,
                          title: 'Ganti Kata Sandi',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.changePassword);
                          },
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  MedievalButton(
                    label: 'Keluar dari Wilayah',
                    icon: Icons.logout,
                    type: MedievalButtonType.danger,
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'AUCTOBID v1.0.0',
                    style: GoogleFonts.merriweather(
                      fontSize: 12,
                      color: AppColors.textPrimary.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          // Using standard ListTile props
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.merriweather(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 60,
            endIndent: 20,
            color: AppColors.secondary.withOpacity(0.2),
          ),
      ],
    );
  }
}

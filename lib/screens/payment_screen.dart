import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PaymentScreen extends StatelessWidget {
  final int auctionId;

  const PaymentScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.darkBrown],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 1.500.000',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Bayar sebelum: 24 Jam',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            // Payment Methods (Mock)
            _PaymentMethodCard(
              icon: Icons.account_balance,
              title: 'Transfer Bank',
              subtitle: 'BCA, BNI, Mandiri, BRI',
              isSelected: true,
            ),
            _PaymentMethodCard(
              icon: Icons.wallet,
              title: 'E-Wallet',
              subtitle: 'GoPay, OVO, Dana',
              isSelected: false,
            ),
            _PaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Kartu Kredit',
              subtitle: 'Visa, Mastercard',
              isSelected: false,
            ),
            
            const SizedBox(height: 32),
            
            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ini adalah simulasi pembayaran. Tidak ada transaksi nyata yang terjadi.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate payment
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pembayaran Berhasil'),
                      content: const Text(
                        'Pembayaran Anda telah berhasil diproses. Terima kasih!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.radio_button_unchecked),
      ),
    );
  }
}

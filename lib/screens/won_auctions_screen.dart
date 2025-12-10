import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auction_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/auction_card.dart';

class WonAuctionsScreen extends StatefulWidget {
  const WonAuctionsScreen({super.key});

  @override
  State<WonAuctionsScreen> createState() => _WonAuctionsScreenState();
}

class _WonAuctionsScreenState extends State<WonAuctionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuctionProvider>(context, listen: false).fetchWonAuctions(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lelang Dimenangkan',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ParchmentBackground(
        child: Consumer<AuctionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.auctions.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (provider.auctions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textPrimary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada kemenangan',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bertarunglah di pelelangan untuk meraih kemenangan!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merriweather(
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchWonAuctions(refresh: true);
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.auctions.length,
                itemBuilder: (context, index) {
                  final auction = provider.auctions[index];
                  return AuctionCard(
                    auction: auction,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.auctionDetail,
                        arguments: auction.id,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

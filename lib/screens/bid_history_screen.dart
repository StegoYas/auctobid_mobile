import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/bid_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_card.dart';

class BidHistoryScreen extends StatefulWidget {
  const BidHistoryScreen({super.key});

  @override
  State<BidHistoryScreen> createState() => _BidHistoryScreenState();
}

class _BidHistoryScreenState extends State<BidHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BidProvider>().refreshAll();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Catatan Pertarungan',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary.withOpacity(0.9),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          labelStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
          unselectedLabelColor: AppColors.parchment.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Semua Jejak'),
            Tab(text: 'Sedang Bertanding'),
            Tab(text: 'Kemenangan'),
          ],
        ),
      ),
      body: ParchmentBackground(
        child: Consumer<BidProvider>(
          builder: (context, bidProvider, child) {
            if (bidProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            
            return TabBarView(
              controller: _tabController,
              children: [
                // All Bids Tab
                _buildBidList(
                  bidProvider.myBids,
                  currencyFormat,
                  emptyMessage: 'Belum ada jejak pertarungan dalam sejarah.',
                ),
                
                // Active Bids Tab
                _buildBidList(
                  bidProvider.myActiveBids,
                  currencyFormat,
                  emptyMessage: 'Tidak ada pertarungan yang sedang berlangsung.',
                ),
                
                // Wins Tab
                _buildWinsList(bidProvider.myWins, currencyFormat),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildBidList(List<Bid> bids, NumberFormat currencyFormat, {required String emptyMessage}) {
    if (bids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu,
              size: 64,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                color: AppColors.textPrimary.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => context.read<BidProvider>().refreshAll(),
      color: AppColors.primary,
      backgroundColor: AppColors.parchment,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
        itemCount: bids.length,
        itemBuilder: (context, index) {
          final bid = bids[index];
          return _BidCard(
            bid: bid,
            currencyFormat: currencyFormat,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.auctionDetail,
                arguments: bid.auctionId,
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildWinsList(List<Map<String, dynamic>> wins, NumberFormat currencyFormat) {
    if (wins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kemenangan yang diraih, Ksatria.',
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                color: AppColors.textPrimary.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => context.read<BidProvider>().fetchMyWins(),
      color: AppColors.primary,
      backgroundColor: AppColors.parchment,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
        itemCount: wins.length,
        itemBuilder: (context, index) {
          final win = wins[index];
          return _WinCard(
            win: win,
            currencyFormat: currencyFormat,
            onTap: () {
              final auctionId = win['auction_id'] ?? win['id'];
              Navigator.pushNamed(
                context,
                AppRoutes.auctionDetail,
                arguments: auctionId,
              );
            },
            onPayment: () {
              final auctionId = win['auction_id'] ?? win['id'];
              Navigator.pushNamed(
                context,
                AppRoutes.payment,
                arguments: auctionId,
              );
            },
          );
        },
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final Bid bid;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  
  const _BidCard({
    required this.bid,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                  ),
                  child: bid.auctionImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                            bid.auctionImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: AppColors.parchment),
                          ),
                        )
                      : const Icon(Icons.gavel, color: AppColors.gold),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.auctionTitle ?? 'Lelang #${bid.auctionId}',
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tawaran: ${currencyFormat.format(bid.amount)}',
                        style: GoogleFonts.merriweather(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: AppColors.textPrimary.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(bid.createdAt),
                            style: GoogleFonts.merriweather(
                              fontSize: 10,
                              color: AppColors.textPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status indicator
                _buildStatusBadge(bid.auctionStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String? status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'open':
        color = AppColors.success;
        label = 'AKTIF';
        icon = Icons.local_fire_department;
        break;
      case 'closed':
        color = AppColors.textPrimary;
        label = 'SELESAI';
        icon = Icons.lock;
        break;
      default:
        color = AppColors.secondary;
        label = 'MENUNGGU';
        icon = Icons.hourglass_empty;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 8,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinCard extends StatelessWidget {
  final Map<String, dynamic> win;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onPayment;
  
  const _WinCard({
    required this.win,
    required this.currencyFormat,
    required this.onTap,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final paymentStatus = win['payment_status'] ?? 'pending';
    final isPaid = paymentStatus == 'paid';
    
    return Stack(
      children: [
        // Card Content
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.parchment,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Trophy icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gold, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PEMENANG LELANG',
                              style: GoogleFonts.cinzel(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              win['item']?['name'] ?? 'Lelang #${win['id']}',
                              style: GoogleFonts.merriweather(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.darkBrown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currencyFormat.format(win['final_price'] ?? win['winning_bid'] ?? 0),
                                style: GoogleFonts.cinzel(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  Divider(color: AppColors.primary.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  
                  // Payment button
                  if (!isPaid)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onPayment,
                        icon: const Icon(Icons.payment, color: AppColors.white),
                        label: Text(
                          'Penuhi Pembayaran',
                          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.gold),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Upeti Telah Diserahkan',
                            style: GoogleFonts.cinzel(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Decorative Ribbons (Visual flourish)
        Positioned(
          top: 12,
          right: 12,
          child: Icon(Icons.star, color: AppColors.gold.withOpacity(0.3), size: 16),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/bid_provider.dart';

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
      appBar: AppBar(
        title: const Text('Riwayat Bid'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Aktif'),
            Tab(text: 'Menang'),
          ],
        ),
      ),
      body: Consumer<BidProvider>(
        builder: (context, bidProvider, child) {
          if (bidProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // All Bids Tab
              _buildBidList(
                bidProvider.myBids,
                currencyFormat,
                emptyMessage: 'Belum ada riwayat bid',
              ),
              
              // Active Bids Tab
              _buildBidList(
                bidProvider.myActiveBids,
                currencyFormat,
                emptyMessage: 'Tidak ada bid aktif',
              ),
              
              // Wins Tab
              _buildWinsList(bidProvider.myWins, currencyFormat),
            ],
          );
        },
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
              Icons.gavel,
              size: 64,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => context.read<BidProvider>().refreshAll(),
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
              Icons.emoji_events,
              size: 64,
              color: AppColors.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kemenangan',
              style: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => context.read<BidProvider>().fetchMyWins(),
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: bid.auctionImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          bid.auctionImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                        ),
                      )
                    : const Icon(Icons.gavel, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.auctionTitle ?? 'Lelang #${bid.auctionId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bid: ${currencyFormat.format(bid.amount)}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(bid.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
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
    );
  }
  
  Widget _buildStatusBadge(String? status) {
    final colors = {
      'open': AppColors.success,
      'closed': AppColors.textPrimary,
      'pending': AppColors.secondary,
    };
    
    final labels = {
      'open': 'Aktif',
      'closed': 'Selesai',
      'pending': 'Menunggu',
    };
    
    final color = colors[status] ?? AppColors.textPrimary;
    final label = labels[status] ?? status ?? 'N/A';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Trophy icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          win['item']?['name'] ?? 'Lelang #${win['id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${currencyFormat.format(win['final_price'] ?? win['winning_bid'] ?? 0)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Payment button
              if (!isPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPayment,
                    icon: const Icon(Icons.payment),
                    label: const Text('Bayar Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pembayaran Selesai',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

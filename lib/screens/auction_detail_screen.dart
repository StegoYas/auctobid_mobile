import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../providers/auction_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class AuctionDetailScreen extends StatefulWidget {
  final int auctionId;

  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final _bidController = TextEditingController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAuction();
  }

  void _loadAuction() {
    final provider = Provider.of<AuctionProvider>(context, listen: false);
    provider.fetchAuctionDetail(widget.auctionId);
  }

  @override
  void dispose() {
    _bidController.dispose();
    Provider.of<AuctionProvider>(context, listen: false).clearCurrentAuction();
    super.dispose();
  }

  void _showBidDialog() {
    final auction = Provider.of<AuctionProvider>(context, listen: false).currentAuction;
    if (auction == null) return;

    final minimumBid = auction.currentPrice + (auction.item?.minimumBidIncrement ?? 10000);
    _bidController.text = minimumBid.toInt().toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ajukan Tawaran',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Minimal tawaran: Rp ${NumberFormat('#,###', 'id_ID').format(minimumBid)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _bidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Tawaran',
                  prefixText: 'Rp ',
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<AuctionProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : () => _placeBid(minimumBid),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Ajukan Tawaran'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeBid(double minimumBid) async {
    final bidAmount = double.tryParse(_bidController.text.replaceAll(',', ''));
    if (bidAmount == null || bidAmount < minimumBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tawaran minimal Rp ${NumberFormat('#,###', 'id_ID').format(minimumBid)}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = Provider.of<AuctionProvider>(context, listen: false);
    final success = await provider.placeBid(widget.auctionId, bidAmount);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tawaran berhasil diajukan!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal mengajukan tawaran'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuctionProvider>(
        builder: (context, provider, child) {
          final auction = provider.currentAuction;

          if (provider.isLoading && auction == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auction == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('Lelang tidak ditemukan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          final images = auction.item?.images ?? [];
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isOwner = auction.item?.owner?.id == authProvider.user?.id;

          return CustomScrollView(
            slivers: [
              // Image Gallery
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: images.isEmpty ? 1 : images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          if (images.isEmpty) {
                            return Container(
                              color: AppColors.parchment,
                              child: const Icon(
                                Icons.image,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            );
                          }
                          return CachedNetworkImage(
                            imageUrl: ApiConfig.storageUrl(images[index].url),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.parchment,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.parchment,
                              child: const Icon(Icons.error),
                            ),
                          );
                        },
                      ),
                      // Image indicators
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? AppColors.secondary
                                      : AppColors.white.withOpacity(0.5),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: auction.isActive ? AppColors.success : AppColors.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              auction.isActive ? 'Lelang Aktif' : auction.status.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (auction.isActive && auction.timeRemaining != null)
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 18, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  auction.timeRemaining!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        auction.item?.name ?? 'Barang Lelang',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 8),

                      // Category & Condition
                      Wrap(
                        spacing: 8,
                        children: [
                          if (auction.item?.category != null)
                            Chip(
                              label: Text(auction.item!.category!.name),
                              backgroundColor: AppColors.secondary.withOpacity(0.1),
                            ),
                          if (auction.item?.condition != null)
                            Chip(
                              label: Text(auction.item!.condition!.name),
                              backgroundColor: AppColors.bronze.withOpacity(0.1),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Price Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.darkBrown],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Harga Saat Ini',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              auction.formattedPrice,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Total Bid',
                                  value: '${auction.totalBids}',
                                ),
                                _StatItem(
                                  label: 'Harga Awal',
                                  value: 'Rp ${NumberFormat('#,###', 'id_ID').format(auction.item?.startingPrice ?? 0)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        auction.item?.description ?? '-',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      // Bid History
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat Tawaran',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton(
                            onPressed: () => provider.fetchAuctionBids(widget.auctionId),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (provider.bids.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Belum ada tawaran',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.5),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.bids.take(10).length,
                          itemBuilder: (context, index) {
                            final bid = provider.bids[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index == 0
                                    ? AppColors.secondary
                                    : AppColors.parchment,
                                child: Text(
                                  bid.user.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: index == 0
                                        ? AppColors.textPrimary
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              title: Text(bid.user.name),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(bid.createdAt),
                              ),
                              trailing: Text(
                                bid.formattedAmount,
                                style: TextStyle(
                                  color: index == 0 ? AppColors.success : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuctionProvider>(
        builder: (context, provider, child) {
          final auction = provider.currentAuction;
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isOwner = auction?.item?.owner?.id == authProvider.user?.id;

          if (auction == null || !auction.isActive || isOwner) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: _showBidDialog,
            icon: const Icon(Icons.gavel),
            label: const Text('Ajukan Tawaran'),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../providers/auction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_button.dart';
import '../widgets/medieval_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      builder: (context) => Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.secondary, width: 2)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                   SvgPicture.asset(
                    'assets/images/parchment_bg.svg',
                    fit: BoxFit.cover,
                    color: AppColors.parchment.withOpacity(0.5), // Optional tint
                  ),
                  SingleChildScrollView(
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
                                color: AppColors.primary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Ajukan Tawaran',
                            style: GoogleFonts.cinzel(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Minimal tawaran: Rp ${NumberFormat('#,###', 'id_ID').format(minimumBid)}',
                            style: GoogleFonts.merriweather(
                              fontSize: 14,
                              color: AppColors.textPrimary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _bidController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Jumlah Emas (IDR)',
                              labelStyle: GoogleFonts.merriweather(color: AppColors.primary),
                              prefixText: 'Rp ',
                              prefixStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.primary),
                              prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppColors.secondary),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Consumer<AuctionProvider>(
                            builder: (context, provider, child) {
                              return MedievalButton(
                                label: 'Kirim Tawaran',
                                icon: Icons.gavel,
                                isLoading: provider.isLoading,
                                type: MedievalButtonType.primary,
                                onPressed: () => _placeBid(minimumBid),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          content: Text('Tawaran dikirim melalui kurir kerajaan!'),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ParchmentBackground(
        child: Consumer<AuctionProvider>(
          builder: (context, provider, child) {
            final auction = provider.currentAuction;

            if (provider.isLoading && auction == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (auction == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Lelang Tidak Ditemukan', style: GoogleFonts.cinzel(fontSize: 18, color: AppColors.error)),
                    const SizedBox(height: 16),
                    MedievalButton(
                      label: 'Kembali',
                      onPressed: () => Navigator.pop(context),
                      type: MedievalButtonType.outline,
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
                  expandedHeight: 350,
                  pinned: false,
                  backgroundColor: Colors.transparent,
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
                                color: AppColors.darkBrown,
                                child: const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: AppColors.parchment,
                                ),
                              );
                            }
                            return CachedNetworkImage(
                              imageUrl: ApiConfig.storageUrl(images[index].url),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.parchment,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.parchment,
                                child: const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                        // Gradient Overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, AppColors.background],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        // Image Indicators
                        if (images.length > 1)
                          Positioned(
                            bottom: 20,
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
                                    border: Border.all(color: AppColors.darkBrown),
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
                                border: Border.all(color: AppColors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    auction.isActive ? Icons.check_circle : Icons.cancel,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    auction.isActive ? 'LELANG AKTIF' : auction.status.toUpperCase(),
                                    style: GoogleFonts.cinzel(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (auction.isActive && auction.timeRemaining != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.hourglass_empty, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      auction.timeRemaining!,
                                      style: GoogleFonts.merriweather(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          auction.item?.name ?? 'Barang Lelang',
                          style: GoogleFonts.cinzel(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tags
                        Wrap(
                          spacing: 8,
                          children: [
                            if (auction.item?.category != null)
                              Chip(
                                label: Text(
                                  auction.item!.category!.name.toUpperCase(),
                                  style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.secondary.withOpacity(0.1),
                                side: const BorderSide(color: AppColors.secondary),
                              ),
                            if (auction.item?.condition != null)
                              Chip(
                                label: Text(
                                  auction.item!.condition!.name.toUpperCase(),
                                  style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.bronze.withOpacity(0.1),
                                side: const BorderSide(color: AppColors.bronze),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Price Card (Medieval Style)
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200, // Fixed height for background, content will overlay
                              decoration: BoxDecoration(
                                color: AppColors.darkBrown,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.secondary, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SvgPicture.asset(
                                  'assets/images/parchment_bg.svg',
                                  fit: BoxFit.cover,
                                  color: AppColors.parchment.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Container(
                               width: double.infinity,
                               padding: const EdgeInsets.all(24),
                               child: Column(
                                children: [
                                  Text(
                                    'HARGA SAAT INI',
                                    style: GoogleFonts.cinzel(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    auction.formattedPrice,
                                    style: GoogleFonts.cinzel(
                                      color: AppColors.parchment,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(color: AppColors.secondary.withOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatItem(
                                        label: 'Total Bid',
                                        value: '${auction.totalBids}',
                                        icon: Icons.groups,
                                      ),
                                      Container(width: 1, height: 40, color: AppColors.secondary.withOpacity(0.3)),
                                      _StatItem(
                                        label: 'Harga Awal',
                                        value: 'Rp ${NumberFormat.compact(locale: 'id_ID').format(auction.item?.startingPrice ?? 0)}',
                                        icon: Icons.start,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Owners Info
                        MedievalCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.secondary),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    auction.item?.owner?.name.substring(0, 1).toUpperCase() ?? '?',
                                    style: GoogleFonts.cinzel(
                                      color: AppColors.parchment,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pemilik Harta',
                                    style: GoogleFonts.cinzel(
                                      fontSize: 10,
                                      color: AppColors.textPrimary.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    auction.item?.owner?.name ?? 'Tidak Diketahui',
                                    style: GoogleFonts.merriweather(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Legenda & Deskripsi',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 2,
                          margin: const EdgeInsets.only(top: 4, bottom: 12),
                          color: AppColors.secondary,
                        ),
                        Text(
                          auction.item?.description ?? '-',
                          style: GoogleFonts.merriweather(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textPrimary.withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Bid History Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Riwayat Pertarungan',
                              style: GoogleFonts.cinzel(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => provider.fetchAuctionBids(widget.auctionId),
                              icon: const Icon(Icons.refresh, color: AppColors.secondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (provider.bids.isEmpty)
                          MedievalCard(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.history_toggle_off, size: 48, color: AppColors.textPrimary.withOpacity(0.3)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada ksatria yang menawar',
                                    style: GoogleFonts.merriweather(
                                      color: AppColors.textPrimary.withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.bids.take(5).length,
                            itemBuilder: (context, index) {
                              final bid = provider.bids[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: index == 0 ? AppColors.success.withOpacity(0.1) : AppColors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: index == 0 ? AppColors.success.withOpacity(0.3) : AppColors.primary.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (index == 0)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: Icon(Icons.emoji_events, color: AppColors.success, size: 24),
                                      ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bid.user.name,
                                            style: GoogleFonts.cinzel(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: index == 0 ? AppColors.success : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM HH:mm').format(bid.createdAt),
                                            style: GoogleFonts.merriweather(
                                              fontSize: 10,
                                              color: AppColors.textPrimary.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      bid.formattedAmount,
                                      style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: index == 0 ? AppColors.success : AppColors.primary,
                                      ),
                                    ),
                                  ],
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
      ),
      floatingActionButton: Consumer<AuctionProvider>(
        builder: (context, provider, child) {
          final auction = provider.currentAuction;
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isOwner = auction?.item?.owner?.id == authProvider.user?.id;

          if (auction == null || !auction.isActive || isOwner) {
            return const SizedBox.shrink();
          }

          return Container(
             padding: const EdgeInsets.symmetric(horizontal: 24),
             width: double.infinity,
             child: MedievalButton(
               label: 'Ajukan Tawaran',
               icon: Icons.gavel,
               type: MedievalButtonType.primary,
               onPressed: _showBidDialog,
             ),
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
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.merriweather(
            color: AppColors.parchment,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: AppColors.parchment.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

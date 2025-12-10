import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../config/app_theme.dart';
import '../providers/item_provider.dart';
import '../widgets/parchment_background.dart';
import '../widgets/medieval_button.dart';
import '../widgets/medieval_card.dart';

class SubmitItemScreen extends StatefulWidget {
  const SubmitItemScreen({super.key});

  @override
  State<SubmitItemScreen> createState() => _SubmitItemScreenState();
}

class _SubmitItemScreenState extends State<SubmitItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _bidIncrementController = TextEditingController(text: '10000');
  
  int? _selectedCategoryId;
  int? _selectedConditionId;
  final List<XFile> _selectedImages = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = Provider.of<ItemProvider>(context, listen: false);
    provider.fetchCategories();
    provider.fetchConditions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bidIncrementController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 gambar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final List<XFile> pickedImages = await _picker.pickMultiImage();
    
    if (pickedImages.isNotEmpty) {
      setState(() {
        for (var image in pickedImages) {
          if (_selectedImages.length < 5) {
            _selectedImages.add(image);
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 gambar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null || _selectedConditionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori dan kondisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = Provider.of<ItemProvider>(context, listen: false);
    
    final success = await provider.submitItem(
      categoryId: _selectedCategoryId!,
      conditionId: _selectedConditionId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      startingPrice: double.parse(_priceController.text.replaceAll(',', '')),
      minimumBidIncrement: double.tryParse(_bidIncrementController.text.replaceAll(',', '')),
      images: _selectedImages,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harta berhasil diajukan! Menunggu titah admin.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal mengajukan barang'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {String? prefixText}) {
     return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.merriweather(color: AppColors.textPrimary.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: AppColors.secondary),
      prefixText: prefixText,
      prefixStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajukan Harta',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ParchmentBackground(
        child: Consumer<ItemProvider>(
          builder: (context, provider, child) {
             return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    MedievalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image_outlined, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'VISUALISASI HARTA',
                                style: GoogleFonts.cinzel(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Add Button
                                GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.secondary, style: BorderStyle.solid, width: 2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 32, color: AppColors.secondary),
                                        const SizedBox(height: 4),
                                        Text('${_selectedImages.length}/5', style: GoogleFonts.cinzel(color: AppColors.secondary)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Images
                                ..._selectedImages.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final image = entry.value;
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(11),
                                            child: kIsWeb
                                                ? Image.network(
                                                    image.path,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => const Center(
                                                      child: Icon(Icons.broken_image, size: 30, color: AppColors.error),
                                                    ),
                                                  )
                                                : Image.file(
                                                    File(image.path),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => const Center(
                                                      child: Icon(Icons.broken_image, size: 30, color: AppColors.error),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 14,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 1.5),
                                              ),
                                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Main Form
                    MedievalCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            decoration: _buildInputDecoration('Nama Barang', Icons.inventory_2_outlined),
                            validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: _buildInputDecoration('Bayangan Kategori', Icons.category_outlined),
                            items: provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: GoogleFonts.merriweather()))).toList(),
                            onChanged: (v) => setState(() => _selectedCategoryId = v),
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<int>(
                            value: _selectedConditionId,
                            decoration: _buildInputDecoration('Kondisi Fisik', Icons.verified_outlined),
                             items: provider.conditions.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: GoogleFonts.merriweather()))).toList(),
                            onChanged: (v) => setState(() => _selectedConditionId = v),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: GoogleFonts.merriweather(color: AppColors.textPrimary),
                            decoration: _buildInputDecoration('Kisah & Deskripsi', Icons.description_outlined),
                            validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                          ),
                           const SizedBox(height: 16),

                           TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                             style: GoogleFonts.cinzel(color: AppColors.primary, fontWeight: FontWeight.bold),
                            decoration: _buildInputDecoration('Harga Pembuka', Icons.monetization_on_outlined, prefixText: 'Rp '),
                            validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                          ),
                           const SizedBox(height: 16),

                           TextFormField(
                            controller: _bidIncrementController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.cinzel(color: AppColors.secondary, fontWeight: FontWeight.bold),
                            decoration: _buildInputDecoration('Min. Kenaikan', Icons.trending_up, prefixText: 'Rp '),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit
                    Consumer<ItemProvider>(
                      builder: (context, provider, child) {
                         return MedievalButton(
                          label: 'Serahkan ke Gudang',
                          icon: Icons.send,
                          type: MedievalButtonType.primary,
                          isLoading: provider.isLoading,
                          onPressed: _submitItem,
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    
                    Center(
                      child: Text(
                        'Barang mesti diperiksa oleh Petugas Kerajaan\nsebelum dilelangkan.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merriweather(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:auctobid_mobile/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class MedievalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const MedievalCard({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Parchment Texture Overlay (simulated with gradient)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [AppColors.secondary, AppColors.background],
                        center: Alignment.center,
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Decorative Corners
              _buildCorner(top: 0, left: 0),
              _buildCorner(top: 0, right: 0),
              _buildCorner(bottom: 0, left: 0),
              _buildCorner(bottom: 0, right: 0),

              Padding(
                padding: padding ?? const EdgeInsets.all(16.0),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: AppColors.secondary, width: 2) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: AppColors.secondary, width: 2) : BorderSide.none,
            left: left != null ? const BorderSide(color: AppColors.secondary, width: 2) : BorderSide.none,
            right: right != null ? const BorderSide(color: AppColors.secondary, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

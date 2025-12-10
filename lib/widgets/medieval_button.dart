import 'package:flutter/material.dart';
import 'package:auctobid_mobile/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

enum MedievalButtonType { primary, secondary, outline, danger }

class MedievalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MedievalButtonType type;
  final IconData? icon;
  final bool isLoading;

  const MedievalButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.type = MedievalButtonType.primary,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    switch (type) {
      case MedievalButtonType.primary:
        backgroundColor = AppColors.primary;
        textColor = AppColors.lightGold;
        borderSide = const BorderSide(color: AppColors.secondary, width: 2);
        break;
      case MedievalButtonType.secondary:
        backgroundColor = AppColors.secondary;
        textColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 2);
        break;
      case MedievalButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 2);
        break;
      case MedievalButtonType.danger:
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        borderSide = const BorderSide(color: Color(0xFF8B0000), width: 2);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: type == MedievalButtonType.primary || type == MedievalButtonType.secondary
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          disabledForegroundColor: textColor.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
          elevation: 0, 
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

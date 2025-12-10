import 'package:flutter/material.dart';
import 'package:auctobid_mobile/config/app_theme.dart';

class ParchmentBackground extends StatelessWidget {
  final Widget child;

  const ParchmentBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        // In a real app, we would use an ImageProvider here for texture
        // image: DecorationImage(
        //   image: AssetImage('assets/images/parchment_bg.png'), 
        //   fit: BoxFit.cover,
        //   opacity: 0.1,
        // ),
      ),
      child: Stack(
        children: [
          // Simulated Texture Noise
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                color: Colors.black, // Simple noise placeholder styling often done with images
              ),
            ),
          ),
          
          // Vignette Effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.1),
                  ],
                  center: Alignment.center,
                  radius: 0.8,
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ),
          
          child,
        ],
      ),
    );
  }
}

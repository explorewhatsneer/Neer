import 'package:flutter/material.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

class FriendPrivateView extends StatelessWidget {
  const FriendPrivateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // KİLİT İKONU
          Icon(
            Icons.lock_rounded, 
            size: 80, 
            color: theme.disabledColor.withOpacity(0.3)
          ),
          
          const SizedBox(height: 20),
          
          // BAŞLIK: "Bu Hesap Gizli"
          Text(
            AppStrings.accountPrivate, 
            style: AppTextStyles.h3.copyWith(
              color: theme.textTheme.bodyLarge?.color, 
              fontWeight: FontWeight.bold
            ),
          ),
          
          const SizedBox(height: 10),
          
          // AÇIKLAMA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              AppStrings.accountPrivateDesc, 
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.disabledColor, 
                height: 1.5
              ),
            ),
          ),
          
          const SizedBox(height: 50), // Alt boşluk
        ],
      ),
    );
  }
}
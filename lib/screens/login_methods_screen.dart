import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../core/constants.dart';
import '../core/theme_styles.dart'; 
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

class LoginMethodsScreen extends StatefulWidget {
  const LoginMethodsScreen({super.key});

  @override
  State<LoginMethodsScreen> createState() => _LoginMethodsScreenState();
}

class _LoginMethodsScreenState extends State<LoginMethodsScreen> {
  // 🔥 SUPABASE AUTH
  final _supabase = Supabase.instance.client;
  
  bool _isEmailLinked = false;
  bool _isGoogleLinked = false;
  bool _isAppleLinked = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkLinkedProviders();
  }

  // Hangi yöntemlerin bağlı olduğunu kontrol et
  void _checkLinkedProviders() {
    final User? user = _supabase.auth.currentUser;
    
    if (user != null) {
      if (mounted) {
        setState(() {
          _userEmail = user.email;
          
          // Supabase'de identities listesi hangi sağlayıcıların bağlı olduğunu gösterir.
          final identities = user.identities ?? [];
          
          for (var identity in identities) {
            if (identity.provider == 'email') _isEmailLinked = true;
            if (identity.provider == 'google') _isGoogleLinked = true;
            if (identity.provider == 'apple') _isAppleLinked = true;
          }
        });
      }
    }
  }

  // Bağlama/Koparma İşlemi (Mock)
  void _handleLinkAction(String provider) {
    HapticFeedback.lightImpact(); // Titreşim
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider ${AppStrings.featureComingSoon}"), 
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: Text(
          AppStrings.loginMethodsTitle, 
          style: AppTextStyles.h3.copyWith(fontSize: 20)
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- PREMIUM BİLGİ KARTI ---
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.08),
                borderRadius: AppThemeStyles.radius24,
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.link_rounded, size: 40, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.linkAccounts, 
                    style: AppTextStyles.h3.copyWith(
                      color: theme.primaryColor,
                      fontSize: 18
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.linkAccountsDesc, 
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? Colors.white70 : AppColors.primaryDark,
                      height: 1.4,
                      fontSize: 13
                    ),
                  ),
                ],
              ),
            ),

            // Yöntemler Listesi
            _buildPremiumMethodCard(
              context: context,
              title: AppStrings.emailAddressLogin,
              subtitle: _userEmail ?? AppStrings.notConnected,
              icon: Icons.email_outlined,
              color: Colors.blueAccent,
              isConnected: _isEmailLinked,
              onTap: () {}, // E-posta genelde ana yöntemdir
            ),

            _buildPremiumMethodCard(
              context: context,
              title: AppStrings.googleAccount,
              subtitle: _isGoogleLinked ? AppStrings.connected : AppStrings.notConnected,
              icon: Icons.g_mobiledata_rounded, 
              color: const Color(0xFFDB4437), // Google Red
              isConnected: _isGoogleLinked,
              onTap: () => _handleLinkAction("Google"),
            ),

            _buildPremiumMethodCard(
              context: context,
              title: AppStrings.appleAccount,
              subtitle: _isAppleLinked ? AppStrings.connected : AppStrings.notConnected,
              icon: Icons.apple,
              color: isDark ? Colors.white : Colors.black, // Apple logosu temaya göre değişir
              isConnected: _isAppleLinked,
              onTap: () => _handleLinkAction("Apple"),
            ),
          ],
        ),
      ),
    );
  }

  // --- PREMIUM METHOD CARD ---
  Widget _buildPremiumMethodCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title, 
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
        ),
        subtitle: Text(
          subtitle, 
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.disabledColor, 
            fontWeight: FontWeight.w600
          )
        ),
        trailing: isConnected
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.15), // Green bg
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  AppStrings.connected, // "Bağlı"
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF34C759), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  )
                ),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
                ),
                child: Text(
                  AppStrings.connect, // "Bağla"
                  style: AppTextStyles.button.copyWith(fontSize: 12)
                ),
              ),
      ),
    );
  }
}
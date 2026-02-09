import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback için
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../main.dart'; // Gerek kalmadı, instance kullanıyoruz

// CORE IMPORTLARI
import '../core/constants.dart';
import '../core/theme_styles.dart'; 
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  // 🔥 SUPABASE CLIENT
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- VERİ YÜKLEME ---
  Future<void> _loadData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";
      
      try {
        // Profil tablosundan telefon bilgisini çek
        final data = await _supabase
            .from('profiles')
            .select('phone')
            .eq('id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _phoneController.text = data['phone'] ?? "";
          });
        }
      } catch (e) {
        debugPrint("Veri çekme hatası: $e");
      }
    }
  }

  // --- DEĞİŞİKLİKLERİ KAYDETME ---
  Future<void> _saveChanges() async {
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact(); 

    setState(() => _isLoading = true);
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      String uid = user.id;
      
      // 1. Telefonu Veritabanına Kaydet (profiles tablosu)
      await _supabase.from('profiles').update({
        'phone': _phoneController.text.trim(),
      }).eq('id', uid);

      // 2. E-posta İşlemleri (Auth Güncelleme)
      String newEmail = _emailController.text.trim();
      
      if (newEmail != user.email) {
        // Supabase'de e-posta güncelleme
        await _supabase.auth.updateUser(
          UserAttributes(email: newEmail)
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                // "Doğrulama linki gönderildi" gibi bir mesaj daha doğru olur ama orijinali koruduk
                "${AppStrings.reLoginRequired} (Lütfen yeni e-postanızı doğrulayın)", 
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.infoUpdated, 
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
              ), 
              backgroundColor: Colors.green
            )
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temadan renkleri alıyoruz (Dark/Light uyumu için)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: Text(
          AppStrings.accountInfoTitle, 
          style: AppTextStyles.h3.copyWith(fontSize: 20) 
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.contactInfo, 
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700, 
                letterSpacing: 1.2,
                color: theme.disabledColor
              )
            ),
            const SizedBox(height: 20),
            
            _buildPremiumInput(
              context,
              label: AppStrings.emailAddress,
              controller: _emailController,
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
              isDark: isDark,
            ),
            
            const SizedBox(height: 20),
            
            _buildPremiumInput(
              context,
              label: AppStrings.phoneNumber,
              controller: _phoneController,
              icon: Icons.phone_iphone_rounded,
              inputType: TextInputType.phone,
              isDark: isDark,
            ),

            const SizedBox(height: 30),
            
            // --- BİLGİ KUTUSU (PREMIUM) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08), 
                borderRadius: AppThemeStyles.radius16,
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.emailChangeWarning, 
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? Colors.white70 : AppColors.primaryDark,
                        height: 1.4
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- KAYDET BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: _isLoading ? 0 : 8,
                  shadowColor: theme.primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) 
                  : Text(
                      AppStrings.saveChanges, 
                      style: AppTextStyles.button.copyWith(fontSize: 16)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE PREMIUM INPUT WIDGET ---
  Widget _buildPremiumInput(BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType inputType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark 
            ? [] 
            : AppThemeStyles.shadowLow, 
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: AppTextStyles.bodyLarge.copyWith(color: theme.textTheme.bodyLarge?.color), 
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          icon: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.8)),
          border: InputBorder.none,
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
          floatingLabelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
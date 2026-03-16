import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:provider/provider.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/theme_manager.dart';
import '../core/language_manager.dart';

import '../services/supabase_service.dart';
import '../providers/auth_provider.dart';

// WIDGETLAR
import '../widgets/settings/settings_widgets.dart'; 
import '../widgets/dialogs/anonymous_popup.dart'; 

// DİĞER EKRANLAR
import 'login_screen.dart';
import 'account_info_screen.dart';
import 'change_password_screen.dart';
import 'login_methods_screen.dart';
import 'premium_screen.dart';
import 'blocked_users_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = SupabaseService();

  // Switch Durumları
  bool _isPrivateAccount = false; // 🔥 YENİ: Gizli Hesap Durumu
  bool _hideActiveStatus = false;
  bool _notificationsEnabled = true;
  bool _dataSaver = false;
  bool _isLoading = true; // Veri yükleniyor mu?

  @override
  void initState() {
    super.initState();
    _loadProfileSettings(); // Ayarları çek
  }

  // 🔥 PROFİL AYARLARINI ÇEK
  Future<void> _loadProfileSettings() async {
    try {
      final userId = _service.client.auth.currentUser?.id;
      if (userId != null) {
        final data = await _service.getProfileFields(userId, 'is_private');
        
        if (mounted) {
          setState(() {
            _isPrivateAccount = data?['is_private'] ?? false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔥 GİZLİ HESAP GÜNCELLEME
  Future<void> _togglePrivateAccount(bool value) async {
    // 1. Optimistic UI (Anında değişim)
    setState(() => _isPrivateAccount = value);
    
    try {
      final userId = _service.client.auth.currentUser?.id;
      if (userId != null) {
        await _service.updateProfile(userId, {'is_private': value});
      }
    } catch (e) {
      // Hata olursa geri al
      if (mounted) {
        setState(() => _isPrivateAccount = !value);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${AppStrings.error}: $e")));
      }
    }
  }

  // --- FONKSİYONLAR ---

  // 🔥 TEMA DEĞİŞTİRME MENÜSÜ
  void _showThemeSelector() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.themeSelection, 
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              
              _buildThemeOption(context, AppStrings.systemTheme, ThemeMode.system, Icons.smartphone_rounded),
              _buildThemeOption(context, AppStrings.lightMode, ThemeMode.light, Icons.light_mode_rounded),
              _buildThemeOption(context, AppStrings.darkMode, ThemeMode.dark, Icons.dark_mode_rounded),
            ],
          ),
        );
      }
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode, IconData icon) {
    final isSelected = context.read<ThemeManager>().themeMode == mode;
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        context.read<ThemeManager>().toggleTheme(mode); // Temayı değiştir
        Navigator.pop(context);
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isSelected ? theme.primaryColor : theme.disabledColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.primaryColor) : null,
    );
  }

  // 🌍 DİL DEĞİŞTİRME MENÜSÜ
  void _showLanguageSelector() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.languageSelection, 
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              
              _buildLanguageOption(context, "Türkçe", const Locale('tr'), "🇹🇷"),
              _buildLanguageOption(context, "English", const Locale('en'), "🇺🇸"),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, Locale locale, String flag) {
    final isSelected = context.read<LanguageManager>().locale.languageCode == locale.languageCode;
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        context.read<LanguageManager>().changeLanguage(locale); // Dili değiştir
        Navigator.pop(context);
      },
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.primaryColor) : null,
    );
  }

  // 🔥 ÇIKIŞ YAP (SUPABASE)
  void _signOut() async {
    bool? confirm = await _showConfirmationDialog(AppStrings.signOut, AppStrings.signOutConfirm);
    if (confirm != true) return;
    
    HapticFeedback.mediumImpact();
    
    await context.read<AuthProvider>().signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  // 🔥 HESAP SİL (SUPABASE)
  void _deleteAccount() async {
    bool? confirm = await _showConfirmationDialog(AppStrings.deleteAccount, AppStrings.deleteAccountConfirm, isDestructive: true);
    if (confirm != true) return;
    
    HapticFeedback.heavyImpact();
    try {
      String? uid = _service.client.auth.currentUser?.id;
      if (uid != null) {
        // 1. Profil verisini sil (Cascade ile diğer veriler de silinir)
        await _service.deleteProfile(uid);

        // 2. Çıkış yap
        await _service.client.auth.signOut();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    }
  }

  void _requestDataDownload() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.dataPreparing), 
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  void _backupData() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.backingUp), 
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  Future<bool?> _showConfirmationDialog(String title, String content, {bool isDestructive = false}) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius24),
        title: Text(title, style: AppTextStyles.h3),
        content: Text(content, style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text(AppStrings.cancel, style: AppTextStyles.button.copyWith(color: theme.disabledColor))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(
              isDestructive ? AppStrings.delete : AppStrings.confirm, 
              style: AppTextStyles.button.copyWith(
                color: isDestructive ? Colors.redAccent : theme.primaryColor, 
                fontWeight: FontWeight.bold
              )
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final user = _service.client.auth.currentUser;
    final userImage = user?.userMetadata?['avatar_url'] ?? "https://i.pravatar.cc/150?img=60";
    final userName = user?.userMetadata?['full_name'] ?? "Kullanıcı";

    // Şu anki tema adını al
    String currentThemeName;
    final tm = context.watch<ThemeManager>();
    final lm = context.watch<LanguageManager>();

    switch (tm.themeMode) {
      case ThemeMode.light: currentThemeName = AppStrings.lightMode; break;
      case ThemeMode.dark: currentThemeName = AppStrings.darkMode; break;
      case ThemeMode.system: currentThemeName = AppStrings.systemTheme; break;
    }

    // Şu anki dil adını al
    String currentLangName = lm.locale.languageCode == 'tr' ? "Türkçe (TR)" : "English (US)";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.settingsTitle, 
          style: AppTextStyles.h3.copyWith(fontSize: 20)
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          
          // --- 1. PREMIUM PROFİL KARTI ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, const Color(0xFF6A002F)], 
                begin: Alignment.topLeft, end: Alignment.bottomRight
              ),
              borderRadius: AppThemeStyles.radius24,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.4), 
                  blurRadius: 20, 
                  offset: const Offset(0, 10)
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(userImage),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5)
                        ),
                        child: const Text("Free Üyelik", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                // QR Code Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                    }, 
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 2. HESAP AYARLARI ---
          SettingsGroup(
            title: AppStrings.accountSecurity,
            children: [
              SettingsItem(
                icon: Icons.person_outline_rounded, color: Colors.blueAccent, title: AppStrings.accountInfo,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountInfoScreen())),
              ),
              SettingsItem(
                icon: Icons.lock_outline_rounded, color: Colors.blueAccent, title: AppStrings.passwordSecurity,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
              ),
              SettingsItem(
                icon: Icons.link_rounded, color: Colors.blueAccent, title: AppStrings.linkedAccounts,
                trailing: Text("Google", style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginMethodsScreen())),
              ),

              // 🔥 PREMIUM KARTI
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700), // Altın Rengi
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)), 
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.black87, size: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.goPremiumBtn, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 14)),
                            Text(AppStrings.unlimitedFeatures, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                        child: Text(AppStrings.upgrade, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFFFD700))),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- 3. UYGULAMA AYARLARI ---
          SettingsGroup(
            title: AppStrings.appAppearance,
            children: [
              SettingsItem(
                icon: Icons.dark_mode_outlined, color: Colors.deepPurple, title: AppStrings.theme,
                trailing: Text(currentThemeName, style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)),
                onTap: _showThemeSelector, 
              ),
              SettingsItem(
                icon: Icons.language_rounded, color: Colors.deepPurple, title: AppStrings.language,
                trailing: Text(currentLangName, style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)),
                onTap: _showLanguageSelector, 
              ),
              SettingsSwitch(
                icon: Icons.notifications_active_outlined, color: Colors.pinkAccent, title: AppStrings.notifications, value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
            ],
          ),

          // --- 4. GİZLİLİK VE VERİ ---
          SettingsGroup(
            title: AppStrings.privacyData,
            children: [
              // 🔥🔥🔥 YENİ: GİZLİ HESAP AYARI 🔥🔥🔥
              SettingsSwitch(
                icon: Icons.lock_person_rounded, 
                color: Colors.indigo, 
                title: "Gizli Hesap", // AppStrings.privateAccount olmalı (core'a eklediysen)
                value: _isPrivateAccount,
                onChanged: _isLoading ? (v){} : _togglePrivateAccount, // Yüklenirken tıklamayı engelle
              ),
              SettingsItem(
                icon: Icons.visibility_off_outlined, color: Colors.indigo, title: AppStrings.anonymousMode,
                onTap: () => showAnonymousDialog(context),
              ),
              SettingsSwitch(
                icon: Icons.timelapse_rounded, color: Colors.indigo, title: AppStrings.hideLastSeen, value: _hideActiveStatus,
                onChanged: (v) => setState(() => _hideActiveStatus = v),
              ),
              SettingsItem(
                icon: Icons.block_rounded, color: Colors.indigo, title: AppStrings.blockedUsers,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockedUsersScreen())),
              ),
              SettingsSwitch(
                icon: Icons.data_saver_on_rounded, color: Colors.teal, title: AppStrings.dataSaver, value: _dataSaver,
                onChanged: (v) => setState(() => _dataSaver = v),
              ),
              SettingsItem(
                icon: Icons.download_rounded, color: Colors.teal, title: AppStrings.downloadData,
                onTap: _requestDataDownload,
              ),
              SettingsItem(
                icon: Icons.backup_rounded, color: Colors.teal, title: AppStrings.chatBackup,
                onTap: _backupData,
              ),
            ],
          ),

          // --- 5. DESTEK ---
          SettingsGroup(
            title: AppStrings.support,
            children: [
              SettingsItem(
                icon: Icons.help_outline_rounded, color: Colors.orange, title: AppStrings.helpCenter,
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.mail_outline_rounded, color: Colors.orange, title: AppStrings.contactUs,
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.star_rate_rounded, color: Colors.orange, title: AppStrings.rateApp,
                onTap: () {},
              ),
            ],
          ),

          // --- 6. ÇIKIŞ ---
          SettingsGroup(
            title: AppStrings.session,
            children: [
              SettingsItem(
                icon: Icons.logout_rounded, color: Colors.redAccent, title: AppStrings.signOut, isDestructive: true,
                onTap: _signOut,
              ),
              SettingsItem(
                icon: Icons.delete_forever_rounded, color: Colors.redAccent, title: AppStrings.deleteAccount, isDestructive: true,
                onTap: _deleteAccount, 
              ),
            ],
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(AppStrings.appName, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("v1.0.8 (Premium)", style: TextStyle(color: theme.disabledColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
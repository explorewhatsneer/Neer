import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/theme_manager.dart';
import '../core/language_manager.dart';
import '../core/app_router.dart';
import '../core/snackbar_helper.dart';
import '../widgets/common/app_confirm_dialog.dart';

import '../services/supabase_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/app_cached_image.dart';

// WIDGETLAR
import '../widgets/settings/settings_widgets.dart';
import '../widgets/dialogs/anonymous_popup.dart';
import 'dart:ui';

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
    
    final userId = _service.client.auth.currentUser?.id;
    if (userId != null) {
      final result = await _service.updateProfile(userId, {'is_private': value});
      if (result.isFailure && mounted) {
        setState(() => _isPrivateAccount = !value);
        AppSnackBar.error(context, "${AppStrings.error}: ${result.error.message}");
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
                style: NeerTypography.h3.copyWith(fontWeight: FontWeight.bold)
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
                style: NeerTypography.h3.copyWith(fontWeight: FontWeight.bold)
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
      context.go(AppRoutes.login);
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
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, "Hata: $e");
    }
  }

  void _requestDataDownload() {
    HapticFeedback.lightImpact();
    AppSnackBar.info(context, AppStrings.dataPreparing);
  }

  void _backupData() {
    HapticFeedback.lightImpact();
    AppSnackBar.info(context, AppStrings.backingUp);
  }

  Future<bool> _showConfirmationDialog(String title, String content, {bool isDestructive = false}) {
    return AppConfirmDialog.show(
      context: context,
      title: title,
      content: content,
      confirmText: isDestructive ? AppStrings.delete : AppStrings.confirm,
      isDestructive: isDestructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    return GradientScaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.settingsTitle,
          style: NeerTypography.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: theme.iconTheme.color),
              ),
            ),
          ),
        ),
      ),
      
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          
          // --- 1. PREMIUM PROFİL KARTI (Glass Morphism) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: NeerGradients.purplePink,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NeerColors.primary.withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      ),
                      child: CachedAvatar(
                        imageUrl: userImage,
                        name: userName,
                        radius: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: NeerTypography.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.5),
                            ),
                            child: Text(
                              "Free",
                              style: NeerTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // QR Code Button (glass)
                    GestureDetector(
                      onTap: () => HapticFeedback.selectionClick(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- 2. HESAP AYARLARI ---
          SettingsGroup(
            title: AppStrings.accountSecurity,
            children: [
              SettingsItem(
                icon: Icons.person_outline_rounded, color: Colors.blueAccent, title: AppStrings.accountInfo,
                onTap: () => context.push(AppRoutes.accountInfo),
              ),
              SettingsItem(
                icon: Icons.lock_outline_rounded, color: Colors.blueAccent, title: AppStrings.passwordSecurity,
                onTap: () => context.push(AppRoutes.changePassword),
              ),
              SettingsItem(
                icon: Icons.link_rounded, color: Colors.blueAccent, title: AppStrings.linkedAccounts,
                trailing: Text("Google", style: NeerTypography.bodySmall.copyWith(color: theme.disabledColor)),
                onTap: () => context.push(AppRoutes.loginMethods),
              ),

              // Premium upgrade card
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(AppRoutes.premium);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.goPremiumBtn,
                              style: NeerTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              AppStrings.unlimitedFeatures,
                              style: NeerTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.upgrade,
                          style: NeerTypography.caption.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: const Color(0xFFFF8C00),
                          ),
                        ),
                      ),
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
                trailing: Text(currentThemeName, style: NeerTypography.bodySmall.copyWith(color: theme.disabledColor)),
                onTap: _showThemeSelector, 
              ),
              SettingsItem(
                icon: Icons.language_rounded, color: Colors.deepPurple, title: AppStrings.language,
                trailing: Text(currentLangName, style: NeerTypography.bodySmall.copyWith(color: theme.disabledColor)),
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
                onTap: () => context.push(AppRoutes.blockedUsers),
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
                Text(
                  AppStrings.appName,
                  style: NeerTypography.h3.copyWith(
                    color: theme.primaryColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "v1.0.8",
                  style: NeerTypography.caption.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.25),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
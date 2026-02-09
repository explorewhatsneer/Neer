import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';

// ==========================================
// 1. AYARLAR GRUBU (PROFESYONEL GÖRÜNÜM)
// ==========================================
class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              title!,
              // 🔥 Core Style: Caption (Bold)
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: theme.disabledColor, 
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            // Dinamik Arka Plan
            color: theme.cardColor, 
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: Colors.white12, width: 0.5) : null,
            boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                // Son eleman değilse araya ince çizgi koy
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 56, // İkon hizasından başlasın
                    endIndent: 16,
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. AYAR SATIRI (SADELEŞTİRİLDİ)
// ==========================================
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isPremium;
  final Widget? trailing; 

  const SettingsItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.isPremium = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact(); // Titreşim
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Sol İkon
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      // Başlık
      title: Text(
        title,
        // 🔥 Core Style: BodyLarge (Semibold)
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? theme.colorScheme.error : theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Sağ Taraf
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("PRO", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],

          Icon(Icons.chevron_right_rounded, size: 20, color: theme.disabledColor),
        ],
      ),
    );
  }
}

// ==========================================
// 3. SWITCH AYAR SATIRI (SADELEŞTİRİLDİ)
// ==========================================
class SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        // 🔥 Core Style: BodyLarge (Semibold)
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: (val) {
            HapticFeedback.selectionClick(); // Switch titreşimi
            onChanged(val);
          },
          activeColor: theme.primaryColor,
          inactiveThumbColor: theme.disabledColor,
          inactiveTrackColor: theme.dividerColor.withOpacity(0.3),
        ),
      ),
    );
  }
}
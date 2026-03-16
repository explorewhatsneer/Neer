import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../common/glass_panel.dart'; 

class RatingBottomSheet extends StatefulWidget {
  final String placeName;

  const RatingBottomSheet({super.key, required this.placeName});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  final Map<String, int> _ratings = {
    "service": 0, // Keyleri string id olarak tutuyoruz
    "taste": 0,
    "atmosphere": 0,
    "price": 0,
  };

  final List<String> _selectedTags = [];

  // Etiket Listesi (Getter olarak tanımladık ki dil değişince güncellensin)
  List<String> get _tags => [
    AppStrings.tagFastService,
    AppStrings.tagDelicious,
    AppStrings.tagClean,
    AppStrings.tagNoisy,
    AppStrings.tagExpensive,
    AppStrings.tagView,
  ];

  // Ortalama Puan
  double get _averageRating {
    double total = 0;
    _ratings.values.forEach((v) => total += v);
    return _ratings.isNotEmpty ? total / _ratings.length : 0.0;
  }

  // Ortalamaya Göre Renk
  Color get _averageScoreColor {
    double avg = _averageRating;
    if (avg == 0) return Colors.grey;
    if (avg < 2.5) return const Color(0xFFFF3B30); // Kırmızı
    if (avg < 3.8) return const Color(0xFFFF9500); // Turuncu
    if (avg < 4.8) return const Color(0xFF34C759); // Açık Yeşil
    return const Color(0xFF00C853); // Koyu Yeşil
  }

  // Tekil Puan Rengi
  Color _getColorForScore(int score) {
    if (score == 0) return Colors.grey.withValues(alpha: 0.5);
    if (score <= 2) return const Color(0xFFFF3B30);
    if (score == 3) return const Color(0xFFFF9500);
    if (score == 4) return const Color(0xFF34C759);
    return const Color(0xFF00C853);
  }

  String get _scoreTitle {
    double avg = _averageRating;
    if (avg == 0) return AppStrings.rate;
    if (avg < 2.5) return AppStrings.needsImprovement;
    if (avg < 3.8) return AppStrings.average;
    if (avg < 4.8) return AppStrings.veryGood;
    return AppStrings.perfect;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel.sheet(
          darkAlpha: 0.85,
          lightAlpha: 0.92,
          height: MediaQuery.of(context).size.height * 0.9,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1)),
          child: Column(
            children: [
              const SizedBox(height: 15),
              // Grab Bar
              Container(
                width: 40, height: 5, 
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.5), 
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, bottomPadding + 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // --- SKOR HALKASI ---
                      const SizedBox(height: 25),
                      _buildScoreIndicator(theme),
                      
                      const SizedBox(height: 15),
                      
                      Text(
                        widget.placeName, 
                        // 🔥 Core Style: H2
                        style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900), 
                        textAlign: TextAlign.center
                      ),
                      
                      const SizedBox(height: 30),

                      // --- PUANLAMA SLOTLARI ---
                      _buildAdvancedRatingSlot(AppStrings.service, Icons.room_service_rounded, "service", theme),
                      const SizedBox(height: 12),
                      _buildAdvancedRatingSlot(AppStrings.taste, Icons.restaurant_menu_rounded, "taste", theme),
                      const SizedBox(height: 12),
                      _buildAdvancedRatingSlot(AppStrings.atmosphere, Icons.weekend_rounded, "atmosphere", theme),
                      const SizedBox(height: 12),
                      _buildAdvancedRatingSlot(AppStrings.price, Icons.account_balance_wallet_rounded, "price", theme),

                      const SizedBox(height: 30),

                      // --- ETİKETLER ---
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: Text(
                          AppStrings.highlights, 
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
                        )
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _tags.map((tag) => _buildGlassChip(tag, theme)).toList(),
                      ),

                      const SizedBox(height: 30),

                      // --- YORUM ALANI ---
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: Colors.white12) : null,
                        ),
                        child: TextField(
                          style: AppTextStyles.bodyLarge,
                          cursorColor: theme.primaryColor,
                          decoration: InputDecoration(
                            hintText: AppStrings.commentHint,
                            hintStyle: AppTextStyles.bodyLarge.copyWith(color: theme.disabledColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            prefixIcon: Icon(Icons.edit_note_rounded, color: theme.disabledColor),
                          ),
                          maxLines: 3,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- GÖNDER BUTONU ---
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppStrings.ratingSubmitted,
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                                ), 
                                backgroundColor: const Color(0xFF34C759),
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                          },
                          child: Text(
                            AppStrings.submitRating, 
                            style: AppTextStyles.button.copyWith(letterSpacing: 1)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // --- WIDGETLAR ---

  Widget _buildScoreIndicator(ThemeData theme) {
    double progress = _averageRating / 5.0; 
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100, height: 100, 
              child: CircularProgressIndicator(
                value: 1.0, 
                strokeWidth: 8, 
                valueColor: AlwaysStoppedAnimation<Color>(theme.dividerColor.withValues(alpha: 0.2)), 
                strokeCap: StrokeCap.round
              )
            ),
            SizedBox(
              width: 100, height: 100, 
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress), 
                duration: const Duration(milliseconds: 800), 
                curve: Curves.easeOutCubic, 
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value, 
                  strokeWidth: 8, 
                  valueColor: AlwaysStoppedAnimation<Color>(_averageScoreColor), 
                  strokeCap: StrokeCap.round
                )
              )
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(
                  _averageRating == 0 ? "-" : _averageRating.toStringAsFixed(1), 
                  // 🔥 Core Style: H1 (Çok Büyük)
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900, 
                    color: _averageScoreColor, 
                    letterSpacing: -1
                  )
                )
              ]
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300), 
          child: Text(
            _scoreTitle, 
            key: ValueKey(_scoreTitle), 
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              color: _averageScoreColor, 
              letterSpacing: 0.5
            )
          )
        ),
      ],
    );
  }

  Widget _buildAdvancedRatingSlot(String label, IconData icon, String key, ThemeData theme) {
    int currentRating = _ratings[key] ?? 0;
    bool isRated = currentRating > 0;
    Color slotColor = _getColorForScore(currentRating); 

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isRated ? slotColor.withValues(alpha: 0.1) : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRated ? slotColor.withValues(alpha: 0.4) : theme.dividerColor.withValues(alpha: 0.5), 
          width: 1.5
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isRated ? theme.cardColor : theme.dividerColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: isRated 
                ? [BoxShadow(color: slotColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                : []
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: isRated ? slotColor : theme.disabledColor
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label, 
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold, 
              fontSize: 15,
              color: isRated ? theme.textTheme.bodyLarge?.color : theme.disabledColor
            )
          ),
          
          const Spacer(),

          // Yıldızlar
          Row(
            children: List.generate(5, (index) {
              int starValue = index + 1;
              bool isSelected = currentRating >= starValue;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _ratings[key] = starValue);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isSelected ? slotColor : theme.disabledColor.withValues(alpha: 0.3),
                      size: 30, 
                    ),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildGlassChip(String tag, ThemeData theme) {
    bool isSelected = _selectedTags.contains(tag);

    return GestureDetector(
      onTap: () { 
        HapticFeedback.selectionClick(); 
        setState(() => isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag)); 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor, 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.dividerColor, 
            width: 1
          ), 
          boxShadow: isSelected 
            ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))] 
            : []
        ), 
        child: Text(
          tag, 
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color, 
            fontWeight: FontWeight.w600, 
            fontSize: 13
          )
        )
      ),
    );
  }
}
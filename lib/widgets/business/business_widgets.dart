import 'package:flutter/material.dart';

// CORE IMPORTLARI
import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';
import '../common/app_cached_image.dart';
import '../common/empty_state.dart';

// 1. BÖLÜM BAŞLIĞI
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: NeerTypography.h3.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18
            )
          ),
        ],
      ),
    );
  }
}

// 2. MEKAN İSTATİSTİKLERİ (Puan, Yorum, Canlı Kullanıcı, Durum)
class PlaceStatsRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final int liveUserCount;
  final String category;

  const PlaceStatsRow({
    super.key,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.liveUserCount = 0,
    this.category = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 25, top: 5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: NeerRadius.cardRadius,
        boxShadow: isDark ? [] : NeerShadows.soft(),
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            rating > 0 ? rating.toStringAsFixed(1) : "-",
            AppStrings.rating,
            Icons.star_rounded,
            Colors.orange,
            theme,
          ),
          _divider(theme),
          _buildItem(
            reviewCount.toString(),
            AppStrings.reviews,
            Icons.chat_bubble_rounded,
            Colors.blue,
            theme,
          ),
          _divider(theme),
          _buildItem(
            liveUserCount.toString(),
            AppStrings.peopleCount,
            Icons.people_alt_rounded,
            Colors.green,
            theme,
          ),
          _divider(theme),
          _buildItem(
            category.isNotEmpty ? category : AppStrings.generalPlace,
            AppStrings.status,
            Icons.category_rounded,
            theme.primaryColor,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) => Container(width: 1, height: 30, color: theme.dividerColor.withValues(alpha: 0.5));

  Widget _buildItem(String value, String label, IconData icon, Color color, ThemeData theme) {
    return Flexible(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: NeerTypography.caption.copyWith(
              color: theme.disabledColor,
              fontWeight: FontWeight.w600
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// 3. ETKİNLİK BİLETİ (Henüz events tablosu yok — placeholder kalıyor)
class EventTicketCard extends StatelessWidget {
  const EventTicketCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: NeerRadius.buttonRadius,
        boxShadow: isDark ? [] : NeerShadows.soft(),
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Row(
        children: [
          // Sol Tarih Kısmı
          Container(
            width: 90,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.comingSoon, style: NeerTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Icon(Icons.event_rounded, color: Colors.white, size: 28),
              ],
            ),
          ),

          // Sağ Bilgi Kısmı
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.upcomingEvents,
                    style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: theme.disabledColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          AppStrings.noEventsYet,
                          style: NeerTypography.caption.copyWith(color: theme.disabledColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. ETKİLEŞİM GRİD (Ziyaret/Fotoğraf/Review sayıları)
class InteractionStatsGrid extends StatelessWidget {
  final int visitCount;
  final int photoCount;
  final int reviewCount;

  const InteractionStatsGrid({
    super.key,
    this.visitCount = 0,
    this.photoCount = 0,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildInfoBox(visitCount.toString(), AppStrings.visits, Icons.location_on_rounded, Colors.blue, context)),
        const SizedBox(width: 10),
        Expanded(child: _buildInfoBox(photoCount.toString(), AppStrings.photos, Icons.camera_alt_rounded, Colors.purple, context)),
        const SizedBox(width: 10),
        Expanded(child: _buildInfoBox(reviewCount.toString(), AppStrings.reviews, Icons.rate_review_rounded, Colors.orange, context)),
      ],
    );
  }

  Widget _buildInfoBox(String val, String label, IconData icon, Color color, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: NeerRadius.buttonRadius,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(val, style: NeerTypography.h3.copyWith(fontSize: 18)),
          Text(label, style: NeerTypography.caption.copyWith(fontSize: 11, color: theme.disabledColor)),
        ],
      ),
    );
  }
}

// 5. LİDERLİK TABLOSU
class VenueLeaderboard extends StatelessWidget {
  final List<Map<String, dynamic>> topVisitors;

  const VenueLeaderboard({super.key, this.topVisitors = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (topVisitors.isEmpty) {
      return EmptyState(
        icon: Icons.emoji_events_outlined,
        title: AppStrings.noDataYet,
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: NeerRadius.buttonRadius,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        children: [
          for (int i = 0; i < topVisitors.length; i++) ...[
            if (i > 0) Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
            _buildUserRow(
              i + 1,
              _getName(topVisitors[i]),
              "${topVisitors[i]['visit_count']} ${AppStrings.visits}",
              _getAvatar(topVisitors[i]),
              theme,
            ),
          ],
        ],
      ),
    );
  }

  String _getName(Map<String, dynamic> visitor) {
    final profiles = visitor['profiles'];
    if (profiles is Map) return profiles['username'] ?? profiles['full_name'] ?? '?';
    return '?';
  }

  String _getAvatar(Map<String, dynamic> visitor) {
    final profiles = visitor['profiles'];
    if (profiles is Map) return profiles['avatar_url'] ?? '';
    return '';
  }

  Widget _buildUserRow(int rank, String name, String detail, String img, ThemeData theme) {
    return Row(
      children: [
        Text(
          "#$rank",
          style: NeerTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w900,
            color: rank == 1 ? Colors.orange : theme.disabledColor,
          )
        ),
        const SizedBox(width: 15),
        CachedAvatar(imageUrl: img, name: name, radius: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text("@$name",
            style: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)
          )
        ),
        Text(
          detail,
          style: NeerTypography.caption.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}

// 6. ARKADAŞ NOTU (Bubble) — İlk review'ı gösterir
class FriendNoteBubble extends StatelessWidget {
  final String? comment;
  final String? authorName;
  final String? authorAvatar;

  const FriendNoteBubble({
    super.key,
    this.comment,
    this.authorName,
    this.authorAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (comment == null || comment!.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: AppStrings.noReviewsYet,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)
            ),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\"$comment\"",
                style: NeerTypography.bodySmall.copyWith(fontStyle: FontStyle.italic)
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "- ${authorName ?? '?'}",
                    style: NeerTypography.caption.copyWith(fontWeight: FontWeight.bold, color: theme.disabledColor),
                  )
                ]
              )
            ],
          ),
        ),
        Positioned(
          top: -10, left: -5,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2)
            ),
            child: CachedAvatar(
              imageUrl: authorAvatar ?? '',
              name: authorName ?? '?',
              radius: 20,
            ),
          ),
        )
      ],
    );
  }
}

// 7. DETAYLI PUAN ÇUBUKLARI
class DetailedRatingBars extends StatelessWidget {
  final Map<String, double> ratings;

  const DetailedRatingBars({super.key, this.ratings = const {}});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final taste = (ratings['taste'] ?? 0).clamp(0.0, 5.0);
    final service = (ratings['service'] ?? 0).clamp(0.0, 5.0);
    final ambiance = (ratings['ambiance'] ?? 0).clamp(0.0, 5.0);
    final price = (ratings['price'] ?? 0).clamp(0.0, 5.0);

    final hasData = taste > 0 || service > 0 || ambiance > 0 || price > 0;

    if (!hasData) {
      return EmptyState(
        icon: Icons.tune_outlined,
        title: AppStrings.noRatingsYet,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: NeerRadius.buttonRadius,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        children: [
          _buildBarItem(AppStrings.taste, taste / 5, theme),
          const SizedBox(height: 15),
          _buildBarItem(AppStrings.serviceSpeed, service / 5, theme),
          const SizedBox(height: 15),
          _buildBarItem(AppStrings.cleanliness, ambiance / 5, theme),
          const SizedBox(height: 15),
          _buildBarItem(AppStrings.pricePerf, price / 5, theme),
        ],
      ),
    );
  }

  Widget _buildBarItem(String label, double percent, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: NeerTypography.caption.copyWith(fontWeight: FontWeight.w600)),
            Text(
              (percent * 5).toStringAsFixed(1),
              style: NeerTypography.caption.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
            color: theme.primaryColor,
            minHeight: 6
          ),
        ),
      ],
    );
  }
}

// 8. KONUM VE QR SATIRI
class LocationQrRow extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const LocationQrRow({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lat = latitude ?? 41.0082;
    final lng = longitude ?? 28.9784;

    return Row(
      children: [
        // Harita Önizleme
        Expanded(
          flex: 2,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.1),
              borderRadius: NeerRadius.buttonRadius,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    "${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}",
                    style: NeerTypography.caption.copyWith(color: theme.disabledColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),

        // Menü QR
        Expanded(
          flex: 1,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: NeerRadius.buttonRadius,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2_rounded, size: 40, color: theme.textTheme.bodyLarge?.color),
                const SizedBox(height: 5),
                Text(AppStrings.menu, style: NeerTypography.caption.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

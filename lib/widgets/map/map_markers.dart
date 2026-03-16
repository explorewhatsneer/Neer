import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/place_model.dart';
import 'map_styles.dart';
import 'info_sheets.dart';

/// Mekan: Mini Nokta (zoom 14-16)
class MiniDotMarker extends StatelessWidget {
  final String category;
  const MiniDotMarker({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(category);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1))
        ],
      ),
    );
  }
}

/// Mekan: Premium Pin (zoom 16+)
class PremiumPinMarker extends StatelessWidget {
  final PlaceModel place;
  const PremiumPinMarker({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(place.category);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final dataMap = {
          'name': place.name,
          'category': place.category,
          'image': place.image,
          'average_rating': place.averageRating,
          'latitude': place.latitude,
          'longitude': place.longitude,
        };
        InfoSheets.showPlaceCard(context, dataMap, place.id.toString());
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(getCategoryIcon(place.category), color: Colors.white, size: 22),
          ),
          Positioned(
            bottom: 12,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(color: color, width: 12, height: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arkadaş Marker (Yeşil çerçeve)
class FriendAvatarMarker extends StatelessWidget {
  final Map<String, dynamic> friend;
  final String userId;
  const FriendAvatarMarker({super.key, required this.friend, required this.userId});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = friend['avatar_url'] ?? '';
    const Color friendColor = Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        InfoSheets.showUserCard(context, friend, userId);
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: friendColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[900],
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            ),
          ),
          Positioned(
            bottom: 22,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(color: friendColor, width: 10, height: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kendi konum marker (Mavi çerçeve)
class MyLocationMarker extends StatelessWidget {
  final String? profileImage;
  const MyLocationMarker({super.key, this.profileImage});

  @override
  Widget build(BuildContext context) {
    const Color myColor = Colors.blue;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: myColor.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: myColor, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: profileImage != null ? NetworkImage(profileImage!) : null,
            child: profileImage == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }
}

/// İnsan kümesi (Yüzen mini profil fotoğrafları)
class FloatingAvatarsCluster extends StatelessWidget {
  final List<String> imageUrls;
  const FloatingAvatarsCluster({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final displayCount = imageUrls.length > 3 ? 3 : imageUrls.length;
    final remaining = imageUrls.length - 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(displayCount, (index) {
            double alignX = 0, alignY = 0;
            if (index == 0) { alignX = -0.5; alignY = -0.5; }
            else if (index == 1) { alignX = 0.5; alignY = -0.2; }
            else if (index == 2) { alignX = -0.1; alignY = 0.6; }

            return Align(
              alignment: Alignment(alignX, alignY),
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageUrls[index].isNotEmpty ? NetworkImage(imageUrls[index]) : null,
                  child: imageUrls[index].isEmpty ? const Icon(Icons.person, size: 12, color: Colors.grey) : null,
                ),
              ),
            );
          }),
          if (remaining > 0)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: Text("+$remaining", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

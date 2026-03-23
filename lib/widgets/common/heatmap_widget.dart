import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';
import 'glass_panel.dart';
import '../friend/friend_profile_widgets.dart' show FriendEmptyCard;
import '../../services/supabase_service.dart';

class HeatmapWidget extends StatefulWidget {
  final String userId;
  const HeatmapWidget({super.key, required this.userId});
  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  String _period = '30d';
  static const _periods = ['7d', '30d', '6m', 'all'];
  static const _periodLabels = {'7d': '7 gün', '30d': '30 gün', '6m': '6 ay', 'all': 'Tümü'};
  late Future<List<Map<String, dynamic>>> _pointsFuture;
  final _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  void _loadPoints() {
    _pointsFuture = _service.getUserHeatmapPoints(widget.userId, period: _period);
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel.card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Text(AppStrings.cityMapTitle, style: NeerTypography.h3),
                const Spacer(),
                ..._periods.map((p) => GestureDetector(
                  onTap: () => setState(() { _period = p; _loadPoints(); }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _period == p
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _period == p
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(_periodLabels[p]!,
                      style: NeerTypography.caption.copyWith(
                        color: _period == p
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        fontSize: 10,
                      )),
                  ),
                )),
              ],
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _pointsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: FriendEmptyCard(
                    icon: Icons.map_outlined,
                    title: 'Harita Boş',
                    subtitle: AppStrings.zeroHeatmap,
                  ),
                );
              }
              return _HeatmapMap(points: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

class _HeatmapMap extends StatelessWidget {
  final List<Map<String, dynamic>> points;
  const _HeatmapMap({required this.points});

  @override
  Widget build(BuildContext context) {
    final center = points.first;
    final maxVisit = points.map((p) => (p['visit_count'] as num).toInt()).reduce(math.max);

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              (center['latitude'] as num).toDouble(),
              (center['longitude'] as num).toDouble(),
            ),
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/dataviz-dark/{z}/{x}/{y}.png?key={api_key}',
              additionalOptions: const {'api_key': 'YOUR_MAPTILER_KEY'},
            ),
            CircleLayer(
              circles: points.map((p) {
                final visits = (p['visit_count'] as num).toInt();
                final intensity = visits / maxVisit;
                return CircleMarker(
                  point: LatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ),
                  radius: 15 + (intensity * 35),
                  color: Color.lerp(
                    const Color(0x448B5CF6),
                    const Color(0xCC8B5CF6),
                    intensity,
                  )!,
                  borderColor: const Color(0x668B5CF6),
                  borderStrokeWidth: 1,
                  useRadiusInMeter: true,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

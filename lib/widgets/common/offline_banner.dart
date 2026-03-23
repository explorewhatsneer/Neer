import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/connectivity_service.dart';
import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

/// Ekranın üstünde çevrimdışı uyarısı gösteren widget.
/// Scaffold'un body'sini sarmalayarak kullanılır.
///
/// ```dart
/// OfflineAwareBody(child: YourContent())
/// ```
class OfflineAwareBody extends StatefulWidget {
  final Widget child;

  const OfflineAwareBody({super.key, required this.child});

  @override
  State<OfflineAwareBody> createState() => _OfflineAwareBodyState();
}

class _OfflineAwareBodyState extends State<OfflineAwareBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _slideAnim;
  StreamSubscription<bool>? _sub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    final connectivity = ConnectivityService.instance;
    _isOffline = !connectivity.isOnline;
    if (_isOffline) _animController.value = 1.0;

    _sub = connectivity.onStatusChange.listen((online) {
      if (!mounted) return;
      setState(() => _isOffline = !online);
      if (_isOffline) {
        _animController.forward();
      } else {
        // Kısa süre "tekrar bağlandı" göster, sonra kapat
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _animController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _slideAnim,
          axisAlignment: -1,
          child: _OfflineBanner(isOffline: _isOffline),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const _OfflineBanner({required this.isOffline});

  @override
  Widget build(BuildContext context) {
    final color = isOffline ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final icon = isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded;
    final text = isOffline ? AppStrings.offline : AppStrings.backOnline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: NeerTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

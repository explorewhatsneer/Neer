import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Uygulama genelinde internet bağlantısı durumunu yöneten servis.
///
/// Kullanım:
/// ```dart
/// final connectivity = ConnectivityService.instance;
/// if (!connectivity.isOnline) { ... }
/// connectivity.onStatusChange.listen((online) { ... });
/// ```
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _controller.stream;

  /// Uygulamanın başlangıcında bir kez çağrılmalı
  Future<void> init() async {
    // İlk kontrol
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Dinle
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(online);
      debugPrint('🌐 Bağlantı durumu: ${online ? "Çevrimiçi" : "Çevrimdışı"}');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

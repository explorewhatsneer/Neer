import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/catch_service.dart';
import '../services/availability_service.dart';
import '../services/watcher_service.dart';

class CatchProvider with ChangeNotifier {
  final CatchService _catchService = CatchService();
  final AvailabilityService _availabilityService = AvailabilityService();
  final WatcherService _watcherService = WatcherService();

  // State
  String _myStatus = 'busy';
  DateTime? _availableUntil;
  List<Map<String, dynamic>> _friends = [];
  Set<String> _watchedIds = {};
  Map<String, int> _cooldowns = {};
  String? _acceptedCatchReceiverId;
  bool _isLoading = true;

  // Timers
  Timer? _cooldownTimer;
  Timer? _statusTimer;

  // Subscriptions
  StreamSubscription? _profileSub;
  StreamSubscription? _catchesSub;
  StreamSubscription? _sentCatchesSub;
  StreamSubscription? _friendsSub;

  // Getters
  String get myStatus => _myStatus;
  DateTime? get availableUntil => _availableUntil;
  List<Map<String, dynamic>> get friends => _friends;
  Set<String> get watchedIds => _watchedIds;
  Map<String, int> get cooldowns => _cooldowns;
  String? get acceptedCatchReceiverId => _acceptedCatchReceiverId;
  bool get isLoading => _isLoading;

  /// Sıralanmış arkadaş listesi (available > pending > busy)
  List<Map<String, dynamic>> get sortedFriends {
    final sorted = List<Map<String, dynamic>>.from(_friends);
    sorted.sort((a, b) {
      const order = {'available': 0, 'pending': 1, 'busy': 2};
      return (order[a['status']] ?? 2).compareTo(order[b['status']] ?? 2);
    });
    return sorted;
  }

  /// Initialize: verileri yükle ve realtime başlat
  Future<void> init(String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadFriends(userId),
      _loadWatchedIds(),
      _loadMyStatus(userId),
    ]);

    _startRealtimeListeners(userId);
    _startTimers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMyStatus(String userId) async {
    try {
      final data = await _availabilityService.streamMyStatus().first;
      if (data != null) {
        _myStatus = data['status'] ?? 'busy';
        _availableUntil = data['available_until'] != null
            ? DateTime.tryParse(data['available_until'])
            : null;
      }
    } catch (_) {}
  }

  Future<void> _loadFriends(String userId) async {
    _friends = await _availabilityService.getFriendsWithStatus(userId);
    for (final f in _friends) {
      final remaining = await _catchService.getCooldownRemaining(f['id']);
      if (remaining > 0) _cooldowns[f['id']] = remaining;
    }
  }

  Future<void> _loadWatchedIds() async {
    _watchedIds = await _watcherService.getWatchedIds();
  }

  void _startRealtimeListeners(String userId) {
    _profileSub = _availabilityService.streamMyStatus().listen((data) {
      if (data != null) {
        _myStatus = data['status'] ?? 'busy';
        _availableUntil = data['available_until'] != null
            ? DateTime.tryParse(data['available_until'])
            : null;
        notifyListeners();
      }
    });

    _catchesSub = _catchService.streamIncomingCatches(userId).listen((catches) {
      // Incoming catch'ler UI tarafında handle edilecek (bottom sheet)
      // Bu provider sadece state tutar, UI logic catch_screen'de
      notifyListeners();
    });

    _sentCatchesSub = _catchService.streamSentCatches(userId).listen((catches) {
      if (catches.isNotEmpty) {
        final latest = catches.first;
        if (latest['status'] == 'accepted') {
          _acceptedCatchReceiverId = latest['receiver_id'];
          notifyListeners();
          Future.delayed(const Duration(seconds: 2), () {
            _acceptedCatchReceiverId = null;
            notifyListeners();
          });
        }
      }
    });

    final friendIds = _friends.map((f) => f['id'] as String).toList();
    if (friendIds.isNotEmpty) {
      _friendsSub = _availabilityService.streamFriendsStatus(friendIds).listen((profiles) {
        for (final profile in profiles) {
          final idx = _friends.indexWhere((f) => f['id'] == profile['id']);
          if (idx != -1) _friends[idx] = profile;
        }
        notifyListeners();
      });
    }
  }

  void _startTimers() {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final expired = <String>[];
      _cooldowns.forEach((id, remaining) {
        if (remaining <= 1) {
          expired.add(id);
        } else {
          _cooldowns[id] = remaining - 1;
        }
      });
      for (final id in expired) {
        _cooldowns.remove(id);
      }
      notifyListeners();
    });

    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      notifyListeners(); // Kalan süre güncelleme
    });
  }

  // ═══ ACTIONS ═══

  Future<void> setAvailable(int durationMinutes) async {
    final success = await _availabilityService.setAvailable(durationMinutes);
    if (success) {
      _myStatus = 'available';
      _availableUntil = DateTime.now().add(Duration(minutes: durationMinutes));
      notifyListeners();
    }
  }

  Future<void> setBusy() async {
    final success = await _availabilityService.setBusy();
    if (success) {
      _myStatus = 'busy';
      _availableUntil = null;
      notifyListeners();
    }
  }

  Future<bool> sendCatch(String receiverId) async {
    final result = await _catchService.sendCatch(receiverId);
    if (result != null) {
      _cooldowns[receiverId] = CatchService.cooldownSeconds;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> acceptCatch(String catchId) async {
    return await _catchService.acceptCatch(catchId);
  }

  Future<bool> rejectCatch(String catchId) async {
    return await _catchService.rejectCatch(catchId);
  }

  Future<void> toggleWatch(String targetId) async {
    final isNowWatching = await _watcherService.toggleWatch(targetId);
    if (isNowWatching) {
      _watchedIds.add(targetId);
    } else {
      _watchedIds.remove(targetId);
    }
    notifyListeners();
  }

  /// Gelen catch stream'i (UI'da bottom sheet göstermek için)
  Stream<List<Map<String, dynamic>>> streamIncomingCatches(String userId) {
    return _catchService.streamIncomingCatches(userId);
  }

  void clear() {
    _cooldownTimer?.cancel();
    _statusTimer?.cancel();
    _profileSub?.cancel();
    _catchesSub?.cancel();
    _sentCatchesSub?.cancel();
    _friendsSub?.cancel();
    _friends = [];
    _watchedIds = {};
    _cooldowns = {};
    _myStatus = 'busy';
    _availableUntil = null;
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _statusTimer?.cancel();
    _profileSub?.cancel();
    _catchesSub?.cancel();
    _sentCatchesSub?.cancel();
    _friendsSub?.cancel();
    super.dispose();
  }
}

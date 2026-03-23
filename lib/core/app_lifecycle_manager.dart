import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/catch_provider.dart';

/// Uygulama yaşam döngüsü yöneticisi — Batarya Kalkanı
///
/// Uygulama arka plana atıldığında (paused) tüm Supabase Realtime
/// soketlerini uyutur, geri açıldığında (resumed) yeniden bağlar.
/// Bu sayede arka planda gereksiz şarj tüketimi engellenir.
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final catchProvider = context.read<CatchProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Uygulama arka plana atıldı — soketleri uyut
        debugPrint('[Lifecycle] paused → stream\'ler duraklatılıyor');
        catchProvider.pauseStreams();
        break;

      case AppLifecycleState.resumed:
        // Uygulama geri açıldı — soketleri uyandır
        debugPrint('[Lifecycle] resumed → stream\'ler yeniden başlatılıyor');
        catchProvider.resumeStreams();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Uygulama tamamen kapatıldı — dispose halleder
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

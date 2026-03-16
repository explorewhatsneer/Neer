import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_strings.dart';
import '../../services/supabase_service.dart'; 

class FriendActionButton extends StatefulWidget {
  final String targetUserId;
  final String currentUserId;
  final bool isTargetPrivate;
  // Durum değiştiğinde üst ekrana (Profile Screen) haber verir
  final Function(String status) onStatusChanged;

  const FriendActionButton({
    super.key,
    required this.targetUserId,
    required this.currentUserId,
    required this.isTargetPrivate,
    required this.onStatusChanged,
  });

  @override
  State<FriendActionButton> createState() => _FriendActionButtonState();
}

class _FriendActionButtonState extends State<FriendActionButton> {
  final _service = SupabaseService();
  
  // Olası Durumlar: 
  // 'follow'      -> Nötr (Takip Et)
  // 'following'   -> Ben Takip Ediyorum (Takip Ediliyor)
  // 'follow_back' -> O Beni Takip Ediyor (Sen de Takip Et)
  // 'friend'      -> Karşılıklı (Arkadaş)
  // 'requested'   -> İstek Gönderildi (Gizli Hesap)
  String _status = 'loading'; 

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // 🔥 MANTIK MOTORU BURADA
  Future<void> _checkStatus() async {
    try {
      // 1. BEN ONU TAKİP EDİYOR MUYUM?
      bool iFollowHim = await _service.isFollowing(widget.currentUserId, widget.targetUserId);

      // 2. O BENİ TAKİP EDİYOR MU?
      bool heFollowsMe = await _service.isFollowing(widget.targetUserId, widget.currentUserId);

      // 3. İSTEK VAR MI? (Sadece ben ona attıysam ve beklemedeyse)
      final req = await _service.getSentFollowRequest(widget.currentUserId, widget.targetUserId);

      if (mounted) {
        setState(() {
          if (req != null) {
            _status = 'requested'; // İstek Beklemede
          } else if (iFollowHim && heFollowsMe) {
            _status = 'friend'; // Karşılıklı = Arkadaş
          } else if (iFollowHim && !heFollowsMe) {
            _status = 'following'; // Sadece ben = Takip Ediliyor
          } else if (!iFollowHim && heFollowsMe) {
            _status = 'follow_back'; // Sadece o = Sen de Takip Et
          } else {
            _status = 'follow'; // Hiçbiri = Takip Et
          }
        });
        
        // Ekrana durumu bildir (İçerik kilidini açmak/kapatmak için)
        widget.onStatusChanged(_status);
      }
    } catch (e) {
      if(mounted) setState(() => _status = 'follow');
    }
  }

  Future<void> _handlePress() async {
    HapticFeedback.mediumImpact();

    // --- TAKİP ETME İŞLEMİ (follow veya follow_back butonuna basınca) ---
    if (_status == 'follow' || _status == 'follow_back') {
      if (widget.isTargetPrivate) {
        // GİZLİ HESAP -> İstek Tablosuna Ekle
        // Not: Gizli hesapta "Sen de takip et" olsa bile istek onayı gerekir.
        setState(() => _status = 'requested');
        widget.onStatusChanged('requested');
        
        final result = await _service.sendFollowRequest(widget.currentUserId, widget.targetUserId);
        if (result.isFailure) { _checkStatus(); }
      } else {
        // AÇIK HESAP -> Direkt Takip Et (Followers tablosuna ekle)
        // Eğer 'follow_back' durumundaysak, ben de ekleyince 'friend' oluruz.
        // Eğer 'follow' durumundaysak, ben ekleyince 'following' olurum.
        String nextStatus = (_status == 'follow_back') ? 'friend' : 'following';
        
        setState(() => _status = nextStatus);
        widget.onStatusChanged(nextStatus); // Ekranı Aç
        
        final result = await _service.follow(widget.currentUserId, widget.targetUserId);
        if (result.isFailure) { _checkStatus(); }
      }
    } 
    
    // --- İSTEK İPTAL ---
    else if (_status == 'requested') {
      setState(() => _status = 'follow');
      widget.onStatusChanged('follow');
      try {
        await _service.deleteFollowRequestByMatch(widget.currentUserId, widget.targetUserId);
      } catch (e) { _checkStatus(); }
    } 
    
    // --- TAKİPTEN ÇIK ---
    else if (_status == 'following' || _status == 'friend') {
      _showUnfollowDialog();
    }
  }

  Future<void> _unfollow() async {
    // Takipten çıkınca eski durum neydi?
    // Eğer 'friend' isek (o beni takip ediyor), ben çıkınca 'follow_back' (Sen de takip et) kalır.
    // Eğer 'following' isek (o beni etmiyor), ben çıkınca 'follow' (Takip et) kalır.
    
    String nextStatus = (_status == 'friend') ? 'follow_back' : 'follow';
    
    setState(() => _status = nextStatus);
    widget.onStatusChanged(nextStatus); // Ekranı Kilitle (Eğer kural sadece takip edense)

    final result = await _service.unfollow(widget.currentUserId, widget.targetUserId);
    if (result.isFailure) { _checkStatus(); }
  }

  void _showUnfollowDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.removeFriend, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Takipten çıkmak istediğine emin misin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c), 
            child: Text(AppStrings.cancel, style: TextStyle(color: Theme.of(context).disabledColor))
          ),
          TextButton(
            onPressed: () { 
              Navigator.pop(c); 
              _unfollow(); 
            }, 
            child: Text("Çıkar", style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_status == 'loading') return const SizedBox(height: 45, width: 45, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));

    String text;
    Color bgColor;
    Color textColor;
    BorderSide border;

    // 🔥 BUTON TASARIMLARI
    switch (_status) {
      case 'friend': 
        text = "Arkadaş"; 
        bgColor = theme.primaryColor; 
        textColor = Colors.white; 
        border = BorderSide(color: theme.dividerColor); 
        break;
      case 'following': 
        text = "Takip Ediliyor"; 
        bgColor = theme.primaryColor; 
        textColor = Colors.white; 
        border = BorderSide(color: theme.dividerColor); 
        break;
      case 'requested': 
        text = AppStrings.requestSent; 
        bgColor = theme.cardColor; 
        textColor = theme.disabledColor; 
        border = BorderSide(color: theme.dividerColor); 
        break;
      case 'follow_back': 
        text = AppStrings.followBack; // "Sen de Takip Et"
        bgColor = theme.primaryColor; 
        textColor = Colors.white; 
        border = BorderSide.none; 
        break;
      default: // 'follow'
        text = "Takip Et"; 
        bgColor = theme.primaryColor; 
        textColor = Colors.white; 
        border = BorderSide.none;
    }

    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor, 
          foregroundColor: textColor, 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: border),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
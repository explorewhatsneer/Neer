import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart'; 
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

// PROFİL EKRANI
import 'friend_profile_screen.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _supabase = Supabase.instance.client;
  late String _currentUserId;

  // Anlık gizleme listesi (Optimistic UI)
  final Set<String> _hiddenRequestIds = {};

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
  }

  // --- İSTEK KABUL ETME ---
  Future<void> _acceptRequest(String requestId, String senderId) async {
    HapticFeedback.mediumImpact();
    
    // 1. Listeden hemen gizle
    setState(() {
      _hiddenRequestIds.add(requestId);
    });

    try {
      // 2. YENİ MANTIK: Followers tablosuna ekle
      // Sender (O) -> Beni takip ediyor (Follower: O, Following: Ben)
      await _supabase.from('followers').insert({
        'follower_id': senderId,      // O beni takip edecek
        'following_id': _currentUserId, // Ben takip edilenim
      });

      // 3. İsteği sil
      await _supabase.from('friend_requests').delete().eq('id', requestId);

    } catch (e) {
      // Hata olursa geri getir
      if (mounted) {
        setState(() => _hiddenRequestIds.remove(requestId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${AppStrings.error}: $e")));
      }
    }
  }

  // --- İSTEK REDDETME ---
  Future<void> _declineRequest(String requestId) async {
    HapticFeedback.lightImpact();

    // 1. Gizle
    setState(() {
      _hiddenRequestIds.add(requestId);
    });

    try {
      // 2. Sadece isteği sil
      await _supabase.from('friend_requests').delete().eq('id', requestId);
    } catch (e) {
      if (mounted) setState(() => _hiddenRequestIds.remove(requestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(AppStrings.followRequestsTitle, style: AppTextStyles.h2.copyWith(fontSize: 24)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withValues(alpha: 0.1), height: 1.0), 
        ),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('friend_requests')
            .stream(primaryKey: ['id'])
            .eq('receiver_id', _currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }

          final allRequests = snapshot.data ?? [];

          // Gizlenenleri filtrele
          final visibleRequests = allRequests.where((req) {
            return !_hiddenRequestIds.contains(req['id'].toString());
          }).toList();

          if (visibleRequests.isEmpty) {
            return _buildEmptyState(theme);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: visibleRequests.length,
            itemBuilder: (context, index) {
              final request = visibleRequests[index];
              return _RequestCard(
                key: ValueKey(request['id']),
                senderId: request['sender_id'],
                requestId: request['id'].toString(), 
                onAccept: () => _acceptRequest(request['id'].toString(), request['sender_id']),
                onDecline: () => _declineRequest(request['id'].toString()),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle, boxShadow: AppThemeStyles.shadowLow),
            child: Icon(Icons.person_add_disabled_rounded, size: 50, color: theme.disabledColor),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.noRequests, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 8),
          Text(AppStrings.noRequestsDesc, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)),
        ],
      ),
    );
  }
}

// --- TEKİL İSTEK KARTI ---
class _RequestCard extends StatelessWidget {
  final String senderId;
  final String requestId; 
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    super.key,
    required this.senderId,
    required this.requestId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;

    return FutureBuilder<Map<String, dynamic>>(
      future: supabase.from('profiles').select().eq('id', senderId).single(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: 70, margin: const EdgeInsets.only(bottom: 12), child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
        }

        final user = snapshot.data!;
        final String name = user['full_name'] ?? "İsimsiz";
        final String username = user['username'] ?? "kullanici";
        final String avatar = user['avatar_url'] ?? "https://i.pravatar.cc/300";

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(targetUserId: senderId)));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppThemeStyles.shadowLow,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatar), backgroundColor: theme.dividerColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("@$username", style: AppTextStyles.caption.copyWith(color: theme.disabledColor)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: onDecline,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: theme.dividerColor)),
                        child: Icon(Icons.close_rounded, size: 20, color: theme.disabledColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onAccept,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]),
                        child: const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
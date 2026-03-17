import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';

import '../services/supabase_service.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';
import '../core/snackbar_helper.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _service = SupabaseService();
  late String _currentUserId;

  // Anlık gizleme listesi (Optimistic UI)
  final Set<String> _hiddenRequestIds = {};

  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentUserId = _service.client.auth.currentUser?.id ?? '';
  }

  Future<void> _refreshRequests() async {
    HapticFeedback.lightImpact();
    setState(() => _refreshKey = UniqueKey());
  }

  // --- İSTEK KABUL ETME ---
  Future<void> _acceptRequest(String requestId, String senderId) async {
    HapticFeedback.mediumImpact();
    
    // 1. Listeden hemen gizle
    setState(() {
      _hiddenRequestIds.add(requestId);
    });

    // 2. YENİ MANTIK: SupabaseService ile kabul et
    final result = await _service.acceptFollowRequest(requestId, senderId, _currentUserId);

    if (result.isFailure && mounted) {
      setState(() => _hiddenRequestIds.remove(requestId));
      AppSnackBar.error(context, "${AppStrings.error}: ${result.error.message}");
    }
  }

  // --- İSTEK REDDETME ---
  Future<void> _declineRequest(String requestId) async {
    HapticFeedback.lightImpact();

    // 1. Gizle
    setState(() {
      _hiddenRequestIds.add(requestId);
    });

    // 2. Sadece isteği sil
    final result = await _service.declineFollowRequest(requestId);
    if (result.isFailure && mounted) {
      setState(() => _hiddenRequestIds.remove(requestId));
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

      body: RefreshIndicator(
        onRefresh: _refreshRequests,
        color: theme.primaryColor,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          key: _refreshKey,
          stream: _service.streamFollowRequests(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerList(itemCount: 5);
            }

            final allRequests = snapshot.data ?? [];

            // Gizlenenleri filtrele
            final visibleRequests = allRequests.where((req) {
              return !_hiddenRequestIds.contains(req['id'].toString());
            }).toList();

            if (visibleRequests.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.25), _buildEmptyState(theme)],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: visibleRequests.length,
              itemBuilder: (context, index) {
                final request = visibleRequests[index];
                return AnimatedListItem(
                  index: index,
                  child: _RequestCard(
                    key: ValueKey(request['id']),
                    senderId: request['sender_id'],
                    requestId: request['id'].toString(),
                    onAccept: () => _acceptRequest(request['id'].toString(), request['sender_id']),
                    onDecline: () => _declineRequest(request['id'].toString()),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyState(
      icon: Icons.person_add_disabled_rounded,
      title: AppStrings.noRequests,
      description: AppStrings.noRequestsDesc,
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
    final service = SupabaseService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: service.getProfileSingle(senderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerProfileCard());
        }

        final user = snapshot.data!;
        final String name = user['full_name'] ?? "İsimsiz";
        final String username = user['username'] ?? "kullanici";
        final String avatar = user['avatar_url'] ?? "https://i.pravatar.cc/300";

        return GestureDetector(
          onTap: () {
            context.push('/profile/$senderId');
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
                CachedAvatar(imageUrl: avatar, name: name, radius: 24),
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
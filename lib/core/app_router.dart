import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'page_transitions.dart';

import '../main_layout.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/account_info_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/login_methods_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/blocked_users_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/follow_requests_screen.dart';
import '../screens/polls_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/group_chat_screen.dart';
import '../screens/friend_profile_screen.dart';
import '../screens/business_profile_screen.dart';

/// Route names — type-safe referans
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String settings = '/settings';
  static const String accountInfo = '/settings/account';
  static const String changePassword = '/settings/password';
  static const String loginMethods = '/settings/login-methods';
  static const String premium = '/settings/premium';
  static const String blockedUsers = '/settings/blocked';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String followRequests = '/follow-requests';
  static const String polls = '/polls';
  static const String chat = '/chat';
  static const String groupChat = '/group-chat';
  static const String friendProfile = '/profile/:userId';
  static const String businessProfile = '/venue/:venueId';
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,

  // Auth redirect: giriş yapılmamışsa login'e yönlendir
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;

    if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },

  routes: [
    // ═══ AUTH (fade geçiş) ═══
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => buildFadeTransition(context, state, const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const RegisterScreen()),
    ),

    // ═══ ANA SAYFA (fade geçiş — login'den gelince yumuşak) ═══
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => buildFadeTransition(context, state, const MainLayout()),
    ),

    // ═══ AYARLAR (iOS sağdan kayma) ═══
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.accountInfo,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const AccountInfoScreen()),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const ChangePasswordScreen()),
    ),
    GoRoute(
      path: AppRoutes.loginMethods,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const LoginMethodsScreen()),
    ),
    GoRoute(
      path: AppRoutes.premium,
      pageBuilder: (context, state) => buildModalTransition(context, state, const PremiumScreen()),
    ),
    GoRoute(
      path: AppRoutes.blockedUsers,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const BlockedUsersScreen()),
    ),

    // ═══ PROFİL (iOS sağdan kayma) ═══
    GoRoute(
      path: AppRoutes.editProfile,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const EditProfileScreen()),
    ),

    // ═══ BİLDİRİMLER (iOS sağdan kayma) ═══
    GoRoute(
      path: AppRoutes.notifications,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const NotificationsScreen()),
    ),
    GoRoute(
      path: AppRoutes.followRequests,
      pageBuilder: (context, state) => buildSlideTransition(context, state, const FriendRequestsScreen()),
    ),

    // ═══ ANKETLER (modal alttan yukarı) ═══
    GoRoute(
      path: AppRoutes.polls,
      pageBuilder: (context, state) => buildModalTransition(context, state, const PollsScreen()),
    ),

    // ═══ CHAT (iOS sağdan kayma) ═══
    GoRoute(
      path: AppRoutes.chat,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return buildSlideTransition(
          context,
          state,
          ChatScreen(
            userId: extra['userId'] ?? '',
            userName: extra['userName'] ?? '',
            userImage: extra['userImage'],
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.groupChat,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return buildSlideTransition(
          context,
          state,
          GroupChatScreen(
            groupId: extra['groupId'] ?? '',
            groupName: extra['groupName'] ?? '',
            groupImage: extra['groupImage'],
          ),
        );
      },
    ),

    // ═══ FRIEND PROFILE (iOS sağdan kayma) ═══
    GoRoute(
      path: '/profile/:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return buildSlideTransition(
          context, state, FriendProfileScreen(targetUserId: userId),
        );
      },
    ),

    // ═══ BUSINESS PROFILE (modal alttan yukarı) ═══
    GoRoute(
      path: '/venue/:venueId',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final venueId = state.pathParameters['venueId'] ?? '';
        return buildModalTransition(
          context,
          state,
          BusinessProfileScreen(
            venueId: venueId,
            venueName: extra['venueName'] ?? '',
            imageUrl: extra['imageUrl'] ?? '',
          ),
        );
      },
    ),
  ],
);

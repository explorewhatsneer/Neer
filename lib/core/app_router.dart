import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    // ═══ AUTH ═══
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ═══ ANA SAYFA (Tab navigation) ═══
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(),
    ),

    // ═══ AYARLAR ═══
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountInfo,
      builder: (context, state) => const AccountInfoScreen(),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.loginMethods,
      builder: (context, state) => const LoginMethodsScreen(),
    ),
    GoRoute(
      path: AppRoutes.premium,
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: AppRoutes.blockedUsers,
      builder: (context, state) => const BlockedUsersScreen(),
    ),

    // ═══ PROFİL ═══
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),

    // ═══ BİLDİRİMLER ═══
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.followRequests,
      builder: (context, state) => const FriendRequestsScreen(),
    ),

    // ═══ ANKETLER ═══
    GoRoute(
      path: AppRoutes.polls,
      builder: (context, state) => const PollsScreen(),
    ),

    // ═══ CHAT ═══
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ChatScreen(
          userId: extra['userId'] ?? '',
          userName: extra['userName'] ?? '',
          userImage: extra['userImage'],
        );
      },
    ),
    GoRoute(
      path: AppRoutes.groupChat,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return GroupChatScreen(
          groupId: extra['groupId'] ?? '',
          groupName: extra['groupName'] ?? '',
          groupImage: extra['groupImage'],
        );
      },
    ),

    // ═══ FRIEND PROFILE ═══
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return FriendProfileScreen(targetUserId: userId);
      },
    ),

    // ═══ BUSINESS PROFILE ═══
    GoRoute(
      path: '/venue/:venueId',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final venueId = state.pathParameters['venueId'] ?? '';
        return BusinessProfileScreen(
          venueId: venueId,
          venueName: extra['venueName'] ?? '',
          imageUrl: extra['imageUrl'] ?? '',
        );
      },
    ),
  ],
);

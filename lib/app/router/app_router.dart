import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/sign_up_page.dart';
import '../../features/auth/presentation/verify_email_page.dart';
import '../../features/members/presentation/members_page.dart';
import '../../features/members/presentation/pages/admin_members_page.dart';
import '../../features/roles/presentation/pages/roles_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/screens/presentation/pages/screens_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/payments/presentation/pages/lesson_packages_page.dart';
import '../../features/about/presentation/pages/about_page.dart';
import '../../features/lesson_schedules/presentation/pages/lesson_schedules_page.dart';
import '../../features/lesson_schedules/presentation/pages/lesson_schedule_detail_page.dart';
import '../../features/lesson_schedules/presentation/pages/lesson_schedule_add_page.dart';
import '../../features/lesson_schedules/presentation/pages/lesson_schedule_update_page.dart';
import '../../features/rooms/presentation/pages/rooms_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String members = '/members';
  static const String adminMembers = '/admin-members';
  static const String roles = '/roles';
  static const String groups = '/groups';
  static const String screens = '/screens';
  static const String notifications = '/notifications';
  static const String events = '/events';
  static const String payments = '/payments';
  static const String lessonPackages = '/lesson-packages';
  static const String about = '/about';
  static const String lessonSchedules = '/lesson-schedules';
  static const String lessonScheduleDetail = '/lesson-schedules/:id';
  static const String lessonScheduleAdd = '/lesson-schedules/add';
  static const String lessonScheduleUpdate = '/lesson-schedules/:id/edit';
  static const String rooms = '/rooms';
}

GoRouter createRouter() {
  return GoRouter(
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Sayfa bulunamadı: ${state.uri}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go(AppRoutes.members),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const _SplashScreen();
        },
      ),
      GoRoute(path: AppRoutes.members, builder: (_, __) => const MembersPage()),
      GoRoute(
        path: AppRoutes.adminMembers,
        builder: (_, __) => const AdminMembersPage(),
      ),
      GoRoute(path: AppRoutes.roles, builder: (_, __) => const RolesPage()),
      GoRoute(path: AppRoutes.groups, builder: (_, __) => const GroupsPage()),
      GoRoute(path: AppRoutes.screens, builder: (_, __) => const ScreensPage()),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsPage(),
      ),
      GoRoute(path: AppRoutes.events, builder: (_, __) => const EventsPage()),
      GoRoute(
        path: AppRoutes.payments,
        builder: (_, __) => const PaymentsPage(),
      ),
      GoRoute(
        path: AppRoutes.lessonPackages,
        builder: (_, __) => const LessonPackagesPage(),
      ),
      GoRoute(path: AppRoutes.about, builder: (_, __) => const AboutPage()),
      GoRoute(
        path: AppRoutes.lessonSchedules,
        builder: (_, __) => const LessonSchedulesPage(),
      ),
      GoRoute(
        path: AppRoutes.lessonScheduleAdd,
        builder: (_, __) => const LessonScheduleAddPage(),
      ),
      GoRoute(
        path: AppRoutes.lessonScheduleDetail,
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return LessonScheduleDetailPage(scheduleId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.lessonScheduleUpdate,
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return LessonScheduleUpdatePage(scheduleId: id);
        },
      ),
      GoRoute(path: AppRoutes.rooms, builder: (_, __) => const RoomsPage()),
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInPage()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpPage()),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, state) => VerifyEmailPage(
          email: state.uri.queryParameters['email'],
          message: state.uri.queryParameters['message'],
        ),
      ),
    ],
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      Future.microtask(() => GoRouter.of(context).go(AppRoutes.signIn));
    } else {
      Future.microtask(() => GoRouter.of(context).go(AppRoutes.members));
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

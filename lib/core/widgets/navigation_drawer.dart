import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/members/presentation/members_page.dart';
import '../services/role_service.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key, this.currentRoute});

  final String? currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 28,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FlowEdu',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Eğitim Yönetim Sistemi',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer(
                      builder: (context, ref, child) {
                        final memberAsync = ref.watch(currentMemberProvider);
                        return memberAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                          data: (member) {
                            if (member == null) return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    size: 16, // Icon boyutunu küçülttüm
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ), // Spacing'i azalttım
                                  Expanded(
                                    child: Text(
                                      member.email,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12, // Font boyutunu küçülttüm
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'Üyeler',
                  route: '/members',
                  isSelected: currentRoute == '/members',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Roller',
                  route: '/roles',
                  isSelected: currentRoute == '/roles',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.group,
                  title: 'Gruplar',
                  route: '/groups',
                  isSelected: currentRoute == '/groups',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.screen_share,
                  title: 'Ekranlar',
                  route: '/screens',
                  isSelected: currentRoute == '/screens',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Bildirimler',
                  route: '/notifications',
                  isSelected: currentRoute == '/notifications',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event,
                  title: 'Etkinlikler',
                  route: '/events',
                  isSelected: currentRoute == '/events',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.payment,
                  title: 'Ödemeler',
                  route: '/payments',
                  isSelected: currentRoute == '/payments',
                ),
                FutureBuilder<bool>(
                  future: RoleService.isAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return _buildDrawerItem(
                        context,
                        icon: Icons.inventory_2,
                        title: 'Ders Paketleri',
                        route: '/lesson-packages',
                        isSelected: currentRoute == '/lesson-packages',
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.schedule,
                  title: 'Ders Programı',
                  route: '/lesson-schedules',
                  isSelected: currentRoute == '/lesson-schedules',
                ),
                FutureBuilder<bool>(
                  future: RoleService.isAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return _buildDrawerItem(
                        context,
                        icon: Icons.meeting_room,
                        title: 'Oda Yönetimi',
                        route: '/rooms',
                        isSelected: currentRoute == '/rooms',
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'Hakkımızda',
                  route: '/about',
                  isSelected: currentRoute == '/about',
                ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Çıkış Yap'),
                  onTap: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        context.go('/signin');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Çıkış yapılırken hata oluştu: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(); // Close drawer
          if (route != currentRoute && context.mounted) {
            context.go(route);
          }
        },
      ),
    );
  }
}

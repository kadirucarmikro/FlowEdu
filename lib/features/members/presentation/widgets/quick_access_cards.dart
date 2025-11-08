import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_grid_list.dart';

class QuickAccessCards extends StatelessWidget {
  const QuickAccessCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ResponsiveGridList(
          items: [
            _QuickAccessCard(
              icon: Icons.schedule,
              title: 'Ders Programı',
              subtitle: 'Derslerinizi görüntüleyin',
              color: Colors.blue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ders Programı - TODO: Implement'),
                  ),
                );
              },
            ),
            _QuickAccessCard(
              icon: Icons.notifications,
              title: 'Bildirimler',
              subtitle: 'Yeni bildirimlerinizi kontrol edin',
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bildirimler - TODO: Implement'),
                  ),
                );
              },
            ),
            _QuickAccessCard(
              icon: Icons.event,
              title: 'Etkinlikler',
              subtitle: 'Yaklaşan etkinlikleri görün',
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Etkinlikler - TODO: Implement'),
                  ),
                );
              },
            ),
            _QuickAccessCard(
              icon: Icons.payment,
              title: 'Ödemeler',
              subtitle: 'Ödeme durumunuzu kontrol edin',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ödemeler - TODO: Implement')),
                );
              },
            ),
          ],
          itemBuilder: (context, card, index) => card,
          aspectRatio: 1.2,
          maxColumns: 4,
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

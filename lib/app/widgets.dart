import 'package:flutter/material.dart';
import 'l10n.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.description,
    this.icon = Icons.receipt_long_outlined,
    this.action,
    super.key,
  });
  final String title;
  final String? description;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(description!, textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loading,
    child: ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Container(
        height: 84,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

const categoryIcons = <String, IconData>{
  'groceries': Icons.shopping_basket_outlined,
  'dairy': Icons.local_drink_outlined,
  'meat': Icons.set_meal_outlined,
  'produce': Icons.eco_outlined,
  'bread': Icons.bakery_dining_outlined,
  'sweets': Icons.cake_outlined,
  'drink': Icons.local_cafe_outlined,
  'alcohol': Icons.wine_bar_outlined,
  'cleaning': Icons.cleaning_services_outlined,
  'care': Icons.spa_outlined,
  'pharmacy': Icons.local_pharmacy_outlined,
  'clothing': Icons.checkroom_outlined,
  'electronics': Icons.devices_outlined,
  'restaurant': Icons.restaurant_outlined,
  'transport': Icons.directions_car_outlined,
  'other': Icons.more_horiz,
};

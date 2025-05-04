import 'package:flutter/material.dart';
import 'ShelterListItem.dart';

class ShelterListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> shelters;
  final void Function(Map<String, dynamic>) onTapItem;
  final void Function(Map<String, dynamic>) onFavoriteToggle;
  final void Function(Map<String, dynamic>) onNavigate;

  const ShelterListView({
    super.key,
    required this.scrollController,
    required this.shelters,
    required this.onTapItem,
    required this.onFavoriteToggle,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 30),
      itemCount: shelters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index){
        final shelter = shelters[index];
        
        return GestureDetector(
          onTap: () => onTapItem(shelter),
          child: ShelterListItem(
            title: shelter['name'] ?? 'nonData',
            address: shelter['address'] ?? 'nonData',
            distance: shelter['distance'] ?? 0.0,
            isFavorite: shelter['isFavorite'] ?? false,
            isEarthquakeSafe: shelter['earthquake'] ?? false,
            isTsunamiSafe: shelter['earthquake'] ?? false,
            onTap: () => onTapItem(shelter),
            onFavoriteToggle: () => onFavoriteToggle(shelter),
            onNavigatePressed: () => onNavigate(shelter),
          ),
        );
      },
    );
  }
}
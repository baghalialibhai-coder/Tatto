// lib/widgets/navigation/side_menu.dart
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final List<String> items;
  final List<IconData> icons;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.icons,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.blue.shade900,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: const Column(
              children: [
                Icon(Icons.brush, size: 50, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Temple of Tattooz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white54),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      icons[index],
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    title: Text(
                      items[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected ? Colors.blue.shade700 : Colors.transparent,
                    selectedTileColor: Colors.blue.shade700,
                    selected: isSelected,
                    onTap: () => onItemSelected(index),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white54),
          // Logout Button
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // Logout logic
              },
            ),
          ),
        ],
      ),
    );
  }
}
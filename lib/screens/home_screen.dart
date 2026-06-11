import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'add_edit_contact_screen.dart';
import 'contacts_tab.dart';
import 'favorites_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _contactsKey  = GlobalKey<ContactsTabState>();
  final _favoritesKey = GlobalKey<FavoritesTabState>();

  Future<void> _openAddScreen() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
    );
    if (changed == true) _contactsKey.currentState?.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ContactsTab(key: _contactsKey),
          FavoritesTab(key: _favoritesKey),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add_alt_1, size: 24),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black12,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          // Reload favorites whenever the tab is opened so starred contacts appear immediately
          if (i == 1) _favoritesKey.currentState?.loadFavorites();
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.people_outline, size: 22),
            selectedIcon: Icon(Icons.people, size: 22, color: AppColors.primary),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_outline, size: 22),
            selectedIcon: Icon(Icons.star, size: 22, color: AppColors.primary),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../utils/app_colors.dart';
import '../utils/phone_utils.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  FavoritesTabState createState() => FavoritesTabState();
}

class FavoritesTabState extends State<FavoritesTab> {
  List<Contact> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }
  Future<void> loadFavorites() async {
    setState(() => _loading = true);
    try {
      final favs = await DatabaseHelper.instance.getFavorites();
      if (mounted) setState(() { _favorites = favs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unfavorite(Contact contact) async {
    await DatabaseHelper.instance.toggleFavorite(contact.id!, false);
    loadFavorites();
  }

  Future<void> _openDetail(Contact contact) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
    );
    if (changed == true) loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_favorites.isEmpty) return _buildEmptyState();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 600 ? 3 : 2;
        return RefreshIndicator(
          onRefresh: loadFavorites,
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: _favorites.length,
            itemBuilder: (_, i) => _FavoriteCard(
              contact: _favorites[i],
              onTap: () => _openDetail(_favorites[i]),
              onCall: () => PhoneUtils.call(_favorites[i].phone),
              onUnfavorite: () => _unfavorite(_favorites[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    const amber = Color(0xFFFFC107);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: amber.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, size: 44, color: amber),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your starred contacts will appear here for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textGrey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: amber.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: amber.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: amber.withValues(alpha: 0.8)),
                  const SizedBox(width: 10),
                  const Text(
                    'Tap ⭐ on a contact  or  swipe left → Star',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onUnfavorite;

  const _FavoriteCard({
    required this.contact,
    required this.onTap,
    required this.onCall,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ContactAvatar(contact: contact, radius: 30, fontSize: 18),
                  GestureDetector(
                    onTap: onUnfavorite,
                    child: const Icon(Icons.star_rounded,
                        color: Color(0xFFFFC107), size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                contact.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 3),
              Text(
                contact.phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textGrey, fontSize: 11),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('Call',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

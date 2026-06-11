import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../utils/app_colors.dart';
import '../widgets/contact_list_tile.dart';
import 'contact_detail_screen.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  ContactsTabState createState() => ContactsTabState();
}

class ContactsTabState extends State<ContactsTab> {
  List<Contact> _contacts = [];
  List<Contact> _filtered = [];
  bool _loading = true;
  String _search = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // Public — called by HomeScreen after saving a new contact via the FAB
  Future<void> loadContacts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final all = await DatabaseHelper.instance.getAllContacts();
      if (mounted) {
        setState(() {
          _contacts = all;
          _filtered = _applyFilter(all, _search);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<Contact> _applyFilter(List<Contact> all, String q) {
    if (q.isEmpty) return all;
    final lq = q.toLowerCase();
    return all.where((c) =>
        c.name.toLowerCase().contains(lq) ||
        c.phone.contains(lq) ||
        (c.email?.toLowerCase().contains(lq) ?? false)).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
      _filtered = _applyFilter(_contacts, value);
    });
  }

  Future<void> _deleteContact(Contact contact) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Contact',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        content: Text(
          'Remove "${contact.name}" from your contacts?',
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteContact(contact.id!);
      loadContacts();
    }
  }

  Future<void> _toggleFavorite(Contact contact) async {
    await DatabaseHelper.instance.toggleFavorite(contact.id!, !contact.isFavorite);
    loadContacts();
  }

  Future<void> _openDetail(Contact contact) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
    );
    if (changed == true) loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: TextField(
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Search contacts',
              hintStyle: const TextStyle(
                  color: AppColors.textGrey, fontSize: 14),
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textGrey, size: 20),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

        if (!_loading && _error == null && _contacts.isNotEmpty)
          Container(
            color: Colors.white,
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              _search.isEmpty
                  ? '${_contacts.length} contact${_contacts.length == 1 ? '' : 's'}'
                  : '${_filtered.length} result${_filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGrey),
            ),
          ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _error != null
                  ? _buildErrorState()
                  : _filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final c = _filtered[i];
                            return ContactListTile(
                              contact: c,
                              onTap: () => _openDetail(c),
                              onDelete: () => _deleteContact(c),
                              onToggleFavorite: () => _toggleFavorite(c),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_search.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off,
                    size: 36,
                    color: AppColors.primary.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              Text(
                'No results for "$_search"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try searching by name, phone, or email.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No contacts yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your contacts will appear here.\nTap + to add your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textGrey, height: 1.5),
            ),
            const SizedBox(height: 28),
            _hintRow(Icons.swap_horiz_rounded,
                'Swipe left on a contact to star or delete'),
            const SizedBox(height: 12),
            _hintRow(Icons.star_outline_rounded,
                'Star contacts to pin them in Favorites'),
          ],
        ),
      ),
    );
  }

  Widget _hintRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textGrey),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Could not load contacts',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: loadContacts,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

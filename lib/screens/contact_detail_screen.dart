import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../utils/app_colors.dart';
import '../utils/phone_utils.dart';
import '../widgets/contact_avatar.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _contact;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _toggleFavorite() async {
    await DatabaseHelper.instance
        .toggleFavorite(_contact.id!, !_contact.isFavorite);
    setState(() {
      _contact = _contact.copyWith(isFavorite: !_contact.isFavorite);
      _changed = true;
    });
  }

  Future<void> _edit() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: _contact)),
    );
    if (saved == true) {
      final all = await DatabaseHelper.instance.getAllContacts();
      final updated = all.where((c) => c.id == _contact.id).firstOrNull;
      if (updated != null && mounted) {
        setState(() { _contact = updated; _changed = true; });
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Contact',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        content: Text(
          'Remove "${_contact.name}" from your contacts?',
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
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteContact(_contact.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: BackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context, _changed),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _contact.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: _contact.isFavorite
                      ? const Color(0xFFFFC107)
                      : Colors.white,
                  size: 24,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 22),
                onPressed: _edit,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: Colors.white, size: 22),
                onSelected: (v) { if (v == 'delete') _delete(); },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                alignment: Alignment.center,
                // top padding accounts for the pinned app-bar height (56 px)
                padding: const EdgeInsets.only(top: 56),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContactAvatar(
                        contact: _contact, radius: 42, fontSize: 26),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64),
                      child: Text(
                        _contact.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionBtn(
                    icon: Icons.phone,
                    label: 'Call',
                    color: AppColors.green,
                    onTap: () => PhoneUtils.call(_contact.phone),
                  ),
                  _actionBtn(
                    icon: Icons.chat_bubble_outline,
                    label: 'Message',
                    color: AppColors.primary,
                    onTap: () => PhoneUtils.sms(_contact.phone),
                  ),
                  if (_contact.email != null)
                    _actionBtn(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      color: const Color(0xFFEA8600),
                      onTap: () => PhoneUtils.email(_contact.email!),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(Icons.phone_outlined, 'Phone', _contact.phone),
                  if (_contact.email != null)
                    _infoRow(Icons.mail_outline, 'Email', _contact.email!),
                  if (_contact.company != null)
                    _infoRow(
                        Icons.business_outlined, 'Company', _contact.company!),
                  if (_contact.address != null)
                    _infoRow(Icons.location_on_outlined, 'Address',
                        _contact.address!),
                  if (_contact.notes != null)
                    _infoRow(Icons.notes, 'Notes', _contact.notes!,
                        isLast: true),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGrey)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textDark)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 50, endIndent: 16,
              color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

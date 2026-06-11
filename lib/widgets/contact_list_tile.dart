import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/contact.dart';
import '../utils/app_colors.dart';
import 'contact_avatar.dart';
class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.44,
        children: [
          SlidableAction(
            onPressed: (_) => onToggleFavorite(),
            backgroundColor:
                contact.isFavorite ? Colors.orange : AppColors.primary,
            foregroundColor: Colors.white,
            icon: contact.isFavorite ? Icons.star : Icons.star_border,
            label: contact.isFavorite ? 'Unfav' : 'Star',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              bottomLeft: Radius.circular(0),
            ),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ContactAvatar(contact: contact, radius: 22, fontSize: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (contact.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.star_rounded,
                      color: Color(0xFFFFC107), size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

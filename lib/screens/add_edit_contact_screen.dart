import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../utils/app_colors.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;
  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _company;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  String? _avatarPath;
  bool _isSaving = false;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _name    = TextEditingController(text: c?.name ?? '');
    _phone   = TextEditingController(text: c?.phone ?? '');
    _email   = TextEditingController(text: c?.email ?? '');
    _company = TextEditingController(text: c?.company ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _notes   = TextEditingController(text: c?.notes ?? '');
    _avatarPath = c?.avatarPath;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _company, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400, maxHeight: 400, imageQuality: 80,
    );
    if (picked != null) setState(() => _avatarPath = picked.path);
  }

  bool get _hasValidAvatar =>
      !kIsWeb && _avatarPath != null && File(_avatarPath!).existsSync();

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[\s\-().+]'), '');
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
      return 'Enter a valid phone number';
    }
    if (digits.length < 7)  return 'Phone number is too short (min 7 digits)';
    if (digits.length > 15) return 'Phone number is too long (max 15 digits)';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // email is optional
    final email = value.trim();
    final regex = RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(email)) return 'Enter a valid email (e.g. name@example.com)';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final name    = _name.text.trim();
      final phone   = _phone.text.trim();
      final email   = _email.text.trim().isEmpty ? null : _email.text.trim();
      final company = _company.text.trim().isEmpty ? null : _company.text.trim();
      final address = _address.text.trim().isEmpty ? null : _address.text.trim();
      final notes   = _notes.text.trim().isEmpty ? null : _notes.text.trim();

      if (_isEditing) {
        await DatabaseHelper.instance.updateContact(widget.contact!.copyWith(
          name: name, phone: phone, email: email, company: company,
          address: address, notes: notes, avatarPath: _avatarPath,
        ));
      } else {
        await DatabaseHelper.instance.insertContact(Contact(
          name: name, phone: phone, email: email, company: company,
          address: address, notes: notes, avatarPath: _avatarPath,
          isFavorite: false, createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Contact' : 'New Contact',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: kIsWeb ? null : _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _hasValidAvatar
                            ? CircleAvatar(
                                radius: 38,
                                backgroundImage: FileImage(File(_avatarPath!)),
                              )
                            : CircleAvatar(
                                radius: 38,
                                backgroundColor: AppColors.avatarColor(
                                    _name.text.isNotEmpty ? _name.text : 'A'),
                                child: Text(
                                  _name.text.isNotEmpty
                                      ? _name.text[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                        if (!kIsWeb)
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                          ),
                      ],
                    ),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickImage,
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4)),
                      child: const Text('Change Photo',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Form(
                key: _formKey,
                // Validate each field as soon as the user interacts with it
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('REQUIRED'),
                    _field(
                      controller: _name,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      controller: _phone,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 18),
                    _sectionLabel('OPTIONAL'),
                    _field(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      controller: _company,
                      label: 'Company',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      controller: _address,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      controller: _notes,
                      label: 'Notes',
                      icon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? helperText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

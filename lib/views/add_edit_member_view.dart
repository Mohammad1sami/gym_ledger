import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AddEditMemberView extends StatefulWidget {
  final Member? member;
  final Function(Map<String, dynamic> data) onSave;
  final VoidCallback onCancel;

  const AddEditMemberView({
    super.key,
    this.member,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddEditMemberView> createState() => _AddEditMemberViewState();
}

class _AddEditMemberViewState extends State<AddEditMemberView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _plan;
  late DateTime _startDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _phoneController = TextEditingController(text: widget.member?.phone ?? '');
    _plan = widget.member?.plan ?? 'Monthly';
    _startDate = widget.member?.start ?? DateTime.now();
    _imagePath = widget.member?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  DateTime get _computedEnd {
    final days = Member.planDays[_plan] ?? 30;
    return _startDate.add(Duration(days: days));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF0F172A)),
              title: const Text('Choose from Gallery', style: TextStyle(color: Color(0xFF0F172A))),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (image != null) {
                  setState(() => _imagePath = image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0F172A)),
              title: const Text('Take a Photo', style: TextStyle(color: Color(0xFF0F172A))),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (image != null) {
                  setState(() => _imagePath = image.path);
                }
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFE11D48)),
                title: const Text('Remove Photo', style: TextStyle(color: Color(0xFFE11D48))),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFFF8FAFC),
              onSurface: Color(0xFF0F172A),
            ),
            dialogBackgroundColor: const Color(0xFFF8FAFC),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  bool get _hasImage =>
      _imagePath != null && _imagePath!.isNotEmpty && File(_imagePath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassCard(
                onTap: widget.onCancel,
                borderRadius: 12,
                padding: EdgeInsets.zero,
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(Icons.close_rounded, color: Color(0xFF0F172A), size: 18),
                ),
              ),
              Text(
                widget.member != null ? 'Edit Member' : 'New Member',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
          const SizedBox(height: 22),

          // Add Photo Avatar Picker
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.65),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.85),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F0F172A),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _hasImage
                        ? ClipOval(
                            child: Image.file(
                              File(_imagePath!),
                              width: 86,
                              height: 86,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFF64748B)),
                              SizedBox(height: 4),
                              Text(
                                'ADD PHOTO',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x336366F1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _hasImage ? Icons.edit_outlined : Icons.add_a_photo_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Name Field
          _FormField(
            label: 'Full name',
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
              decoration: _inputDecoration('e.g. Rohan Patil'),
            ),
          ),

          // Phone Field
          _FormField(
            label: 'Phone number',
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
              decoration: _inputDecoration('10-digit number'),
            ),
          ),

          // Plan Field
          _FormField(
            label: 'Membership plan',
            child: Row(
              children: Member.planDays.keys.map((p) {
                final isSelected = _plan == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _plan = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.primaryGradient : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.85)),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x336366F1),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Start Date Field
          _FormField(
            label: 'Start date',
            child: GestureDetector(
              onTap: _selectStartDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: AppTheme.glassDecoration(borderRadius: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_startDate),
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),

          // Auto End Date Field
          _FormField(
            label: 'End date (auto-calculated)',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: Text(
                DateFormat('dd MMM yyyy').format(_computedEnd),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Save Button
          GestureDetector(
            onTap: () {
              widget.onSave({
                'name': _nameController.text.isEmpty ? 'New Member' : _nameController.text,
                'phone': _phoneController.text,
                'plan': _plan,
                'start': _startDate,
                'end': _computedEnd,
                'imagePath': _imagePath,
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x336366F1),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.save_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Save Member',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.85)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1)),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

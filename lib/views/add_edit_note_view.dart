import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../models/training_note.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AddEditNoteView extends StatefulWidget {
  final TrainingNote? note;
  final List<Member> members;
  final int? defaultMemberId;
  final Function(Map<String, dynamic> data) onSave;
  final VoidCallback onCancel;

  const AddEditNoteView({
    super.key,
    this.note,
    required this.members,
    this.defaultMemberId,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddEditNoteView> createState() => _AddEditNoteViewState();
}

class _AddEditNoteViewState extends State<AddEditNoteView> {
  late int _memberId;
  late TextEditingController _dietController;
  late TextEditingController _workoutController;

  @override
  void initState() {
    super.initState();
    _memberId = widget.note?.memberId ?? widget.defaultMemberId ?? (widget.members.isNotEmpty ? widget.members.first.id : 0);
    _dietController = TextEditingController(text: widget.note?.diet ?? '');
    _workoutController = TextEditingController(text: widget.note?.workout ?? '');
  }

  @override
  void dispose() {
    _dietController.dispose();
    _workoutController.dispose();
    super.dispose();
  }

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
                widget.note != null ? 'Edit Note' : 'New Training Note',
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

          // Client Selector Dropdown
          _FormField(
            label: 'Client',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: AppTheme.glassDecoration(borderRadius: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _memberId,
                  dropdownColor: const Color(0xFFF8FAFC),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: widget.members.map((m) {
                    return DropdownMenuItem<int>(
                      value: m.id,
                      child: Text(
                        m.name,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _memberId = val);
                    }
                  },
                ),
              ),
            ),
          ),

          // Diet Plan Field
          _FormField(
            label: 'Diet plan given',
            child: TextField(
              controller: _dietController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
              decoration: _inputDecoration('e.g. 2200 kcal, 160g protein. Dal, roti, paneer, eggs...'),
            ),
          ),

          // Workout Plan Field
          _FormField(
            label: 'Workout plan given',
            child: TextField(
              controller: _workoutController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
              decoration: _inputDecoration('e.g. Upper/Lower split, 4 days/week...'),
            ),
          ),
          const SizedBox(height: 8),

          // Save Button
          GestureDetector(
            onTap: () {
              widget.onSave({
                'memberId': _memberId,
                'diet': _dietController.text,
                'workout': _workoutController.text,
                'date': widget.note?.date ?? DateTime(2026, 6, 19),
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
                    'Save Note',
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

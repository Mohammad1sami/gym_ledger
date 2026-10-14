import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../models/training_note.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';

class TrainingNotesView extends StatefulWidget {
  final List<Member> members;
  final List<TrainingNote> notes;
  final VoidCallback onAddNote;
  final Function(TrainingNote) onSelectNote;

  const TrainingNotesView({
    super.key,
    required this.members,
    required this.notes,
    required this.onAddNote,
    required this.onSelectNote,
  });

  @override
  State<TrainingNotesView> createState() => _TrainingNotesViewState();
}

class _TrainingNotesViewState extends State<TrainingNotesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final sortedNotes = [...widget.notes]..sort((a, b) => b.date.compareTo(a.date));

    final filtered = sortedNotes.where((n) {
      if (query.isEmpty) return true;
      final member = widget.members.firstWhere(
        (m) => m.id == n.memberId,
        orElse: () => Member(
          id: -1,
          name: '',
          phone: '',
          plan: 'Monthly',
          start: DateTime.now(),
          end: DateTime.now(),
        ),
      );
      return member.name.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Training Notes',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: widget.onAddNote,
                child: Container(
                  width: 40,
                  height: 40,
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
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Diet and workout plans logged for each client.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 16),

        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Filter by client name',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.85)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Notes List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No training notes logged yet',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final n = filtered[index];
                    final member = widget.members.firstWhere(
                      (m) => m.id == n.memberId,
                      orElse: () => Member(
                        id: -1,
                        name: 'Unknown',
                        phone: '',
                        plan: 'Monthly',
                        start: DateTime.now(),
                        end: DateTime.now(),
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NoteCard(
                        note: n,
                        member: member,
                        onTap: () => widget.onSelectNote(n),
                        showName: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

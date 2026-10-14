import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';
import '../widgets/member_card.dart';

class MembersListView extends StatefulWidget {
  final List<Member> members;
  final Function(Member) onSelectMember;
  final VoidCallback onAddMember;
  final String initialFilter;

  const MembersListView({
    super.key,
    required this.members,
    required this.onSelectMember,
    required this.onAddMember,
    this.initialFilter = 'all',
  });

  @override
  State<MembersListView> createState() => _MembersListViewState();
}

class _MembersListViewState extends State<MembersListView> {
  late String _filter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState() ;
    _filter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = widget.members.where((m) {
      final matchesQuery = m.name.toLowerCase().contains(query) || m.phone.contains(query);
      bool matchesFilter = true;
      if (_filter == 'attention') {
        matchesFilter = m.status != MemberStatus.active;
      } else if (_filter != 'all') {
        matchesFilter = m.statusKey == _filter;
      }
      return matchesQuery && matchesFilter;
    }).toList();

    return Column(
      children: [
        // Header Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: widget.onAddMember,
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

        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Search by name or number',
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
        const SizedBox(height: 14),

        // Filter Pills Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: ['all', 'active', 'expiring', 'expired'].map((f) {
              final isSelected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.85)),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x336366F1),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      f[0].toUpperCase() + f.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Member List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No members match this search',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MemberCard(
                        member: m,
                        onTap: () => widget.onSelectMember(m),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

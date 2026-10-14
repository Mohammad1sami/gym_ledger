import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/payment_card.dart';

class BillingView extends StatefulWidget {
  final List<Member> members;
  final List<Payment> payments;
  final VoidCallback onRecordPayment;
  final Function(Payment) onTogglePaymentStatus;
  final Function(Payment) onSelectPayment;

  const BillingView({
    super.key,
    required this.members,
    required this.payments,
    required this.onRecordPayment,
    required this.onTogglePaymentStatus,
    required this.onSelectPayment,
  });

  @override
  State<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends State<BillingView> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all'; // all, paid, pending, overdue

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final paidPayments = widget.payments.where((p) => p.status == PaymentStatus.paid);
    final pendingPayments = widget.payments.where((p) => p.status == PaymentStatus.pending);
    final overduePayments = widget.payments.where((p) => p.status == PaymentStatus.overdue);

    final double totalCollected = paidPayments.fold(0.0, (sum, p) => sum + p.amount);
    final double totalPending = pendingPayments.fold(0.0, (sum, p) => sum + p.amount) +
        overduePayments.fold(0.0, (sum, p) => sum + p.amount);

    final filtered = widget.payments.where((p) {
      final matchesSearch = p.memberName.toLowerCase().contains(query) ||
          p.plan.toLowerCase().contains(query) ||
          p.paymentMethod.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (_filter != 'all') {
        matchesFilter = p.statusKey == _filter;
      }
      return matchesSearch && matchesFilter;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gym Billing',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: widget.onRecordPayment,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    children: const [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Record',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Track client fees, revenue, and WhatsApp payment reminders.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 16),

        // Financial Overview Metric Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.account_balance_wallet_rounded, size: 18, color: Color(0xFF0D9488)),
                          SizedBox(width: 6),
                          Text(
                            'Collected',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalCollected.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${paidPayments.length} transactions paid',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.pending_actions_rounded, size: 18, color: Color(0xFFE11D48)),
                          SizedBox(width: 6),
                          Text(
                            'Dues Pending',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalPending.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pendingPayments.length + overduePayments.length} payments due',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
              hintText: 'Search payment by client or method',
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

        // Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: ['all', 'paid', 'pending', 'overdue'].map((f) {
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

        // Payments History List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No payments match this search',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    final member = widget.members.firstWhere(
                      (m) => m.id == p.memberId,
                      orElse: () => Member(
                        id: -1,
                        name: p.memberName,
                        phone: '',
                        plan: p.plan,
                        start: DateTime.now(),
                        end: DateTime.now(),
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PaymentCard(
                        payment: p,
                        member: member,
                        onStatusToggle: () => widget.onTogglePaymentStatus(p),
                        onTap: () => widget.onSelectPayment(p),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

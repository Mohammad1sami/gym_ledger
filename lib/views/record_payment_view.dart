import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class RecordPaymentView extends StatefulWidget {
  final Payment? payment;
  final List<Member> members;
  final int? defaultMemberId;
  final Function(Map<String, dynamic> data) onSave;
  final VoidCallback onCancel;

  const RecordPaymentView({
    super.key,
    this.payment,
    required this.members,
    this.defaultMemberId,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<RecordPaymentView> createState() => _RecordPaymentViewState();
}

class _RecordPaymentViewState extends State<RecordPaymentView> {
  late int _memberId;
  late TextEditingController _amountController;
  late TextEditingController _refController;
  late String _plan;
  late String _paymentMethod;
  late PaymentStatus _status;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _memberId = widget.payment?.memberId ??
        widget.defaultMemberId ??
        (widget.members.isNotEmpty ? widget.members.first.id : 0);
    _plan = widget.payment?.plan ?? 'Monthly';
    final initialAmount = widget.payment?.amount ?? Payment.defaultPlanPrices[_plan] ?? 1500.0;
    _amountController = TextEditingController(text: initialAmount.toStringAsFixed(0));
    _refController = TextEditingController(text: widget.payment?.transactionRef ?? '');
    _paymentMethod = widget.payment?.paymentMethod ?? 'UPI';
    _status = widget.payment?.status ?? PaymentStatus.paid;
    _date = widget.payment?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _onPlanChanged(String newPlan) {
    setState(() {
      _plan = newPlan;
      final defaultPrice = Payment.defaultPlanPrices[newPlan] ?? 1500.0;
      _amountController.text = defaultPrice.toStringAsFixed(0);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
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
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMember = widget.members.firstWhere(
      (m) => m.id == _memberId,
      orElse: () => widget.members.isNotEmpty
          ? widget.members.first
          : Member(
              id: -1,
              name: 'Client',
              phone: '',
              plan: 'Monthly',
              start: DateTime.now(),
              end: DateTime.now(),
            ),
    );

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
                widget.payment != null ? 'Edit Payment' : 'Record Payment',
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

          // Client Dropdown
          _FormField(
            label: 'Member',
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
                        '${m.name} (${m.phone})',
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final m = widget.members.firstWhere((element) => element.id == val);
                      setState(() {
                        _memberId = val;
                        _onPlanChanged(m.plan);
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          // Plan Selector
          _FormField(
            label: 'Plan',
            child: Row(
              children: Member.planDays.keys.map((p) {
                final isSelected = _plan == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => _onPlanChanged(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.primaryGradient : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.85)),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontSize: 12,
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

          // Amount Input
          _FormField(
            label: 'Amount (₹)',
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
              decoration: _inputDecoration('e.g. 1500'),
            ),
          ),

          // Payment Method Selector
          _FormField(
            label: 'Payment Method',
            child: Row(
              children: ['UPI', 'Cash', 'Card', 'Bank'].map((m) {
                final isSelected = _paymentMethod.toLowerCase() == m.toLowerCase();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _paymentMethod = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.85)),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontSize: 12,
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

          // Payment Status Radio Group
          _FormField(
            label: 'Payment Status',
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = PaymentStatus.paid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _status == PaymentStatus.paid
                            ? const Color(0xFF0D9488)
                            : Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: _status == PaymentStatus.paid
                            ? null
                            : Border.all(color: Colors.white.withOpacity(0.85)),
                      ),
                      child: Text(
                        'PAID',
                        style: TextStyle(
                          color: _status == PaymentStatus.paid ? Colors.white : const Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = PaymentStatus.pending),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _status == PaymentStatus.pending
                            ? const Color(0xFFD97706)
                            : Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: _status == PaymentStatus.pending
                            ? null
                            : Border.all(color: Colors.white.withOpacity(0.85)),
                      ),
                      child: Text(
                        'PENDING',
                        style: TextStyle(
                          color: _status == PaymentStatus.pending ? Colors.white : const Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = PaymentStatus.overdue),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _status == PaymentStatus.overdue
                            ? const Color(0xFFE11D48)
                            : Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: _status == PaymentStatus.overdue
                            ? null
                            : Border.all(color: Colors.white.withOpacity(0.85)),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: _status == PaymentStatus.overdue ? Colors.white : const Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date Trigger
          _FormField(
            label: 'Transaction / Due Date',
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: AppTheme.glassDecoration(borderRadius: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(_date),
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),

          // Reference / Notes Field
          _FormField(
            label: 'Transaction Ref / Receipt Note (Optional)',
            child: TextField(
              controller: _refController,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
              decoration: _inputDecoration('e.g. UPI Ref #98124 or Receipt #104'),
            ),
          ),
          const SizedBox(height: 12),

          // Save Payment Button
          GestureDetector(
            onTap: () {
              final amountParsed = double.tryParse(_amountController.text) ?? 1500.0;
              widget.onSave({
                'memberId': selectedMember.id,
                'memberName': selectedMember.name,
                'amount': amountParsed,
                'plan': _plan,
                'paymentMethod': _paymentMethod,
                'status': _status,
                'date': _date,
                'transactionRef': _refController.text.trim().isEmpty ? null : _refController.text.trim(),
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
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Save Payment Record',
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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/member.dart';
import 'models/payment.dart';
import 'models/training_note.dart';
import 'theme/app_theme.dart';
import 'views/add_edit_member_view.dart';
import 'views/add_edit_note_view.dart';
import 'views/billing_view.dart';
import 'views/dashboard_view.dart';
import 'views/member_detail_view.dart';
import 'views/members_list_view.dart';
import 'views/note_detail_view.dart';
import 'views/notifications_view.dart';
import 'views/record_payment_view.dart';
import 'views/training_notes_view.dart';

import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BruteWingApp());
}

class BruteWingApp extends StatelessWidget {
  const BruteWingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BruteWing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<Member> _members = [];
  List<TrainingNote> _notes = [];
  List<Payment> _payments = [];
  bool _isLoading = true;

  String _screen = 'dashboard';
  Member? _selectedMember;
  TrainingNote? _selectedNote;
  Payment? _editingPayment;
  Member? _editingMember;
  TrainingNote? _editingNote;
  int? _addingNoteFor;
  int? _addingPaymentFor;
  String _memberFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final members = await StorageService.getMembers();
      final notes = await StorageService.getNotes();
      final payments = await StorageService.getPayments();
      setState(() {
        _members = members;
        _notes = notes;
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Storage load fallback: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectMember(Member m) {
    setState(() {
      _selectedMember = m;
      _screen = 'memberDetail';
    });
  }

  Future<void> _saveMember(Map<String, dynamic> data) async {
    List<Member> updatedMembers;
    Member targetMember;

    final String name = (data['name'] as String).trim().isEmpty ? 'New Member' : (data['name'] as String).trim();
    final String phone = (data['phone'] as String).trim().isEmpty ? 'Not Provided' : (data['phone'] as String).trim();

    if (_editingMember != null) {
      targetMember = _editingMember!.copyWith(
        name: name,
        phone: phone,
        plan: data['plan'] as String,
        start: data['start'] as DateTime,
        end: data['end'] as DateTime,
        imagePath: data['imagePath'] as String?,
      );
      updatedMembers = _members.map((m) => m.id == _editingMember!.id ? targetMember : m).toList();
    } else {
      targetMember = Member(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        phone: phone,
        plan: data['plan'] as String,
        start: data['start'] as DateTime,
        end: data['end'] as DateTime,
        imagePath: data['imagePath'] as String?,
      );
      updatedMembers = [targetMember, ..._members];
    }

    setState(() {
      _members = updatedMembers;
      _selectedMember = targetMember;
      _editingMember = null;
      _screen = 'memberDetail';
    });

    await StorageService.saveMembers(updatedMembers);
  }

  Future<void> _deleteMember() async {
    if (_selectedMember == null) return;
    final id = _selectedMember!.id;
    final updatedMembers = _members.where((m) => m.id != id).toList();
    final updatedNotes = _notes.where((n) => n.memberId != id).toList();
    final updatedPayments = _payments.where((p) => p.memberId != id).toList();

    setState(() {
      _members = updatedMembers;
      _notes = updatedNotes;
      _payments = updatedPayments;
      _selectedMember = null;
      _screen = 'members';
    });

    await StorageService.saveMembers(updatedMembers);
    await StorageService.saveNotes(updatedNotes);
    await StorageService.savePayments(updatedPayments);
  }

  Future<void> _saveNote(Map<String, dynamic> data) async {
    List<TrainingNote> updatedNotes;
    TrainingNote targetNote;

    if (_editingNote != null) {
      targetNote = _editingNote!.copyWith(
        memberId: data['memberId'] as int,
        diet: data['diet'] as String,
        workout: data['workout'] as String,
        date: data['date'] as DateTime,
      );
      updatedNotes = _notes.map((n) => n.id == _editingNote!.id ? targetNote : n).toList();
    } else {
      targetNote = TrainingNote(
        id: DateTime.now().millisecondsSinceEpoch,
        memberId: data['memberId'] as int,
        diet: data['diet'] as String,
        workout: data['workout'] as String,
        date: data['date'] as DateTime,
      );
      updatedNotes = [targetNote, ..._notes];
    }

    setState(() {
      _notes = updatedNotes;
      _selectedNote = targetNote;
      _editingNote = null;
      _screen = _selectedMember != null ? 'memberDetail' : 'noteDetail';
    });

    await StorageService.saveNotes(updatedNotes);
  }

  Future<void> _savePayment(Map<String, dynamic> data) async {
    List<Payment> updatedPayments;
    Payment targetPayment;

    if (_editingPayment != null) {
      targetPayment = _editingPayment!.copyWith(
        memberId: data['memberId'] as int,
        memberName: data['memberName'] as String,
        amount: data['amount'] as double,
        plan: data['plan'] as String,
        paymentMethod: data['paymentMethod'] as String,
        status: data['status'] as PaymentStatus,
        date: data['date'] as DateTime,
        transactionRef: data['transactionRef'] as String?,
      );
      updatedPayments = _payments.map((p) => p.id == _editingPayment!.id ? targetPayment : p).toList();
    } else {
      targetPayment = Payment(
        id: DateTime.now().millisecondsSinceEpoch,
        memberId: data['memberId'] as int,
        memberName: data['memberName'] as String,
        amount: data['amount'] as double,
        plan: data['plan'] as String,
        paymentMethod: data['paymentMethod'] as String,
        status: data['status'] as PaymentStatus,
        date: data['date'] as DateTime,
        transactionRef: data['transactionRef'] as String?,
      );
      updatedPayments = [targetPayment, ..._payments];
    }

    setState(() {
      _payments = updatedPayments;
      _editingPayment = null;
      _screen = _selectedMember != null ? 'memberDetail' : 'billing';
    });

    await StorageService.savePayments(updatedPayments);
  }

  Future<void> _togglePaymentStatus(Payment p) async {
    final nextStatus = p.status == PaymentStatus.paid ? PaymentStatus.pending : PaymentStatus.paid;
    final updatedPayment = p.copyWith(status: nextStatus);
    final updatedPayments = _payments.map((item) => item.id == p.id ? updatedPayment : item).toList();

    setState(() {
      _payments = updatedPayments;
    });

    await StorageService.savePayments(updatedPayments);
  }

  @override
  Widget build(BuildContext context) {
    final notifCount = _members.where((m) => m.status != MemberStatus.active).length;
    final hideBottomNav = ['addEditMember', 'addEditNote', 'recordPayment'].contains(_screen);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Screen Body Routing
              Positioned.fill(
                child: _buildCurrentScreen(),
              ),

              // Bottom Glass Navigation Bar
              if (!hideBottomNav)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomNav(notifCount),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }
    switch (_screen) {
      case 'dashboard':
        return DashboardView(
          members: _members,
          recentNotes: [..._notes]..sort((a, b) => b.date.compareTo(a.date)),
          payments: _payments,
          onSelectMember: _selectMember,
          goFilter: (f) {
            setState(() {
              _memberFilter = f;
              _screen = 'members';
            });
          },
          onOpenNotes: () => setState(() => _screen = 'notes'),
          onOpenBilling: () => setState(() => _screen = 'billing'),
        );
      case 'members':
        return MembersListView(
          members: _members,
          initialFilter: _memberFilter,
          onSelectMember: _selectMember,
          onAddMember: () {
            setState(() {
              _editingMember = null;
              _screen = 'addEditMember';
            });
          },
        );
      case 'billing':
        return BillingView(
          members: _members,
          payments: _payments,
          onRecordPayment: () {
            setState(() {
              _editingPayment = null;
              _addingPaymentFor = null;
              _screen = 'recordPayment';
            });
          },
          onTogglePaymentStatus: _togglePaymentStatus,
          onSelectPayment: (p) {
            setState(() {
              _editingPayment = p;
              _screen = 'recordPayment';
            });
          },
        );
      case 'recordPayment':
        return RecordPaymentView(
          payment: _editingPayment,
          members: _members,
          defaultMemberId: _addingPaymentFor ?? _selectedMember?.id,
          onSave: _savePayment,
          onCancel: () {
            setState(() {
              _screen = _editingPayment != null
                  ? (_selectedMember != null ? 'memberDetail' : 'billing')
                  : (_selectedMember != null ? 'memberDetail' : 'billing');
            });
          },
        );
      case 'memberDetail':
        if (_selectedMember == null) return const SizedBox.shrink();
        return MemberDetailView(
          member: _selectedMember!,
          notes: _notes,
          payments: _payments,
          onBack: () => setState(() => _screen = 'members'),
          onEdit: () {
            setState(() {
              _editingMember = _selectedMember;
              _screen = 'addEditMember';
            });
          },
          onDelete: _deleteMember,
          onAddNote: () {
            setState(() {
              _editingNote = null;
              _addingNoteFor = _selectedMember!.id;
              _screen = 'addEditNote';
            });
          },
          onSelectNote: (n) {
            setState(() {
              _selectedNote = n;
              _screen = 'noteDetail';
            });
          },
          onRecordPayment: () {
            setState(() {
              _editingPayment = null;
              _addingPaymentFor = _selectedMember!.id;
              _screen = 'recordPayment';
            });
          },
          onTogglePaymentStatus: _togglePaymentStatus,
        );
      case 'notes':
        return TrainingNotesView(
          members: _members,
          notes: _notes,
          onAddNote: () {
            setState(() {
              _selectedMember = null;
              _editingNote = null;
              _addingNoteFor = null;
              _screen = 'addEditNote';
            });
          },
          onSelectNote: (n) {
            setState(() {
              _selectedNote = n;
              _screen = 'noteDetail';
            });
          },
        );
      case 'noteDetail':
        if (_selectedNote == null) return const SizedBox.shrink();
        final member = _members.firstWhere(
          (m) => m.id == _selectedNote!.memberId,
          orElse: () => _members.first,
        );
        return NoteDetailView(
          note: _selectedNote!,
          member: member,
          onBack: () {
            setState(() {
              _screen = _selectedMember != null ? 'memberDetail' : 'notes';
            });
          },
          onEdit: () {
            setState(() {
              _editingNote = _selectedNote;
              _screen = 'addEditNote';
            });
          },
        );
      case 'addEditMember':
        return AddEditMemberView(
          member: _editingMember,
          onSave: _saveMember,
          onCancel: () {
            setState(() {
              _screen = _editingMember != null ? 'memberDetail' : 'members';
            });
          },
        );
      case 'addEditNote':
        return AddEditNoteView(
          note: _editingNote,
          members: _members,
          defaultMemberId: _addingNoteFor,
          onSave: _saveNote,
          onCancel: () {
            setState(() {
              _screen = _editingNote != null
                  ? 'noteDetail'
                  : (_selectedMember != null ? 'memberDetail' : 'notes');
            });
          },
        );
      case 'notifications':
        return NotificationsView(members: _members);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNav(int notifCount) {
    final tabs = [
      {'k': 'dashboard', 'icon': Icons.home_rounded, 'label': 'Home'},
      {'k': 'members', 'icon': Icons.people_alt_rounded, 'label': 'Members'},
      {'k': 'billing', 'icon': Icons.account_balance_wallet_rounded, 'label': 'Billing'},
      {'k': 'notes', 'icon': Icons.menu_book_rounded, 'label': 'Notes'},
      {'k': 'notifications', 'icon': Icons.notifications_rounded, 'label': 'Alerts'},
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.85)),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: tabs.map((t) {
              final key = t['k'] as String;
              final icon = t['icon'] as IconData;
              final label = t['label'] as String;

              final isActive = _screen == key ||
                  (_screen == 'memberDetail' && key == 'members') ||
                  (_screen == 'noteDetail' && key == 'notes' && _selectedMember == null) ||
                  (_screen == 'recordPayment' && key == 'billing' && _selectedMember == null);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _screen = key;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 34,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF6366F1).withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              icon,
                              size: 18,
                              color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                            ),
                          ),
                          if (key == 'notifications' && notifCount > 0)
                            Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE11D48),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                child: Text(
                                  '$notifCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}


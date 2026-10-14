import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment.dart';
import '../models/member.dart';
import 'avatar_widget.dart';
import 'glass_card.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final Member? member;
  final VoidCallback? onStatusToggle;
  final VoidCallback? onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    this.member,
    this.onStatusToggle,
    this.onTap,
  });

  Future<void> _sendWhatsAppReminder(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final msg = Uri.encodeComponent(
      'Hi ${payment.memberName}, your BruteWing membership fee of ${payment.formattedAmount} for ${payment.plan} Plan is currently ${payment.statusKey.toUpperCase()}. Kindly clear the payment or share the screenshot if already done. Thank you!',
    );
    final whatsappSchemeUrl = Uri.parse('whatsapp://send?phone=91$cleanPhone&text=$msg');
    final whatsappWebUrl = Uri.parse('https://wa.me/91$cleanPhone?text=$msg');

    try {
      if (await canLaunchUrl(whatsappSchemeUrl)) {
        await launchUrl(whatsappSchemeUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsApp launch exception: $e');
    }
  }

  Color get _statusColor {
    switch (payment.status) {
      case PaymentStatus.paid:
        return const Color(0xFF0D9488); // Teal
      case PaymentStatus.pending:
        return const Color(0xFFD97706); // Amber
      case PaymentStatus.overdue:
        return const Color(0xFFE11D48); // Rose
    }
  }

  Color get _statusBg {
    switch (payment.status) {
      case PaymentStatus.paid:
        return const Color(0x220D9488);
      case PaymentStatus.pending:
        return const Color(0x22D97706);
      case PaymentStatus.overdue:
        return const Color(0x22E11D48);
    }
  }

  IconData get _methodIcon {
    switch (payment.paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'upi':
        return Icons.qr_code_2_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = member?.phone ?? '';

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              AvatarWidget(
                name: payment.memberName,
                size: 40,
                imagePath: member?.imagePath,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.memberName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(_methodIcon, size: 13, color: const Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          '${payment.plan} · ${payment.paymentMethod}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.formattedAmount,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      payment.statusKey.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${payment.formattedDateShort} ${payment.transactionRef != null ? "• ${payment.transactionRef}" : ""}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Row(
                children: [
                  if (phone.isNotEmpty && payment.status != PaymentStatus.paid)
                    GestureDetector(
                      onTap: () => _sendWhatsAppReminder(context, phone),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x1F25D366),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x5525D366)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.chat_bubble_outline, size: 11, color: Color(0xFF128C7E)),
                            SizedBox(width: 4),
                            Text(
                              'Remind',
                              style: TextStyle(fontSize: 11, color: Color(0xFF128C7E), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (onStatusToggle != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onStatusToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: payment.status == PaymentStatus.paid
                              ? const Color(0x1F64748B)
                              : const Color(0x1F6366F1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: payment.status == PaymentStatus.paid
                                ? const Color(0x3364748B)
                                : const Color(0x556366F1),
                          ),
                        ),
                        child: Text(
                          payment.status == PaymentStatus.paid ? 'Mark Unpaid' : 'Mark Paid',
                          style: TextStyle(
                            fontSize: 11,
                            color: payment.status == PaymentStatus.paid
                                ? const Color(0xFF64748B)
                                : const Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

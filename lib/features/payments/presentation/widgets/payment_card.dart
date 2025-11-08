import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_with_details.dart';

class PaymentCard extends StatelessWidget {
  final dynamic payment; // Can be Payment or PaymentWithDetails
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final memberName = payment is PaymentWithDetails
        ? (payment as PaymentWithDetails).memberName
        : 'Ödeme #${payment.id.substring(0, 8)}';
    final packageName = payment is PaymentWithDetails
        ? '${(payment as PaymentWithDetails).packageName} (${(payment as PaymentWithDetails).packageLessonCount} Ders)'
        : 'Paket Bilgisi Yok';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showPaymentDetails(context, payment),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ÜST BÖLÜM: Üye Adı + Durum Badge + Aksiyon Butonları
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üye Adı - EN ÖNEMLİ (Büyük, Bold)
                        Text(
                          memberName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Paket Bilgisi (Küçük, Gri)
                        Text(
                          packageName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Durum Badge - SAĞ ÜST
                  _buildStatusChip(payment.status),
                  const SizedBox(width: 4),
                  // Aksiyon Butonları
                  if (onEdit != null || onDelete != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: onEdit,
                            tooltip: 'Düzenle',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: onDelete,
                            tooltip: 'Sil',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // ORTA BÖLÜM: Net Tutar - EN BÜYÜK, BOLD
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${payment.finalAmount.toStringAsFixed(2)} TL',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  // İndirim varsa göster
                  if (payment.discountAmount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'İndirim: -${payment.discountAmount.toStringAsFixed(2)} TL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                            fontSize: 11,
                          ),
                    ),
                    // Brüt tutar (opsiyonel, küçük, strikethrough)
                    Text(
                      'Brüt: ${payment.amount.toStringAsFixed(2)} TL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // ALT BÖLÜM: Ders Programı Tarihleri (varsa)
              if (payment is PaymentWithDetails)
                _buildScheduleDates(context, payment),
              // ALT BÖLÜM: Tarih Bilgileri (Duruma göre)
              _buildDateInfo(context, payment),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context, dynamic payment) {
    // Beklemede ise vade tarihi göster
    if (payment.status == PaymentStatus.pending && payment.dueDate != null) {
      final isDueSoon = _isDueSoon(payment.dueDate!);
      return Row(
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: isDueSoon ? Colors.red : Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Vade: ${_formatDate(payment.dueDate!)}${isDueSoon ? ' (Yaklaşıyor!)' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDueSoon ? Colors.red[700] : Colors.orange[700],
                    fontSize: 11,
                    fontWeight: isDueSoon ? FontWeight.w500 : FontWeight.normal,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    // Ödendi ise ödeme tarihi göster
    else if (payment.status == PaymentStatus.paid && payment.paidAt != null) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Ödendi: ${_formatDate(payment.paidAt!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                    fontSize: 11,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    // Diğer durumlarda oluşturma tarihi göster
    else {
      return Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Oluşturulma: ${_formatDate(payment.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }

  bool _isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  Widget _buildStatusChip(PaymentStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case PaymentStatus.pending:
        color = Colors.orange;
        text = 'Beklemede';
        icon = Icons.schedule;
        break;
      case PaymentStatus.paid:
        color = Colors.green;
        text = 'Ödendi';
        icon = Icons.check_circle;
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        text = 'Başarısız';
        icon = Icons.error;
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      avatar: Icon(icon, size: 14, color: Colors.white),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showPaymentDetails(BuildContext context, dynamic payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          payment is PaymentWithDetails
              ? 'Ödeme Detayları - ${payment.memberName}'
              : 'Ödeme Detayları #${payment.id.substring(0, 8)}',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (payment is PaymentWithDetails) ...[
                _buildDetailRow('Üye', payment.memberName),
                _buildDetailRow(
                  'Paket',
                  '${payment.packageName} (${payment.packageLessonCount} Ders)',
                ),
              ] else ...[
                _buildDetailRow('Üye ID', payment.memberId),
                _buildDetailRow('Paket ID', payment.packageId),
              ],
              _buildDetailRow(
                'Tutar',
                '${payment.amount.toStringAsFixed(2)} TL',
              ),
              _buildDetailRow(
                'İndirim',
                '${payment.discountAmount.toStringAsFixed(2)} TL',
              ),
              _buildDetailRow(
                'Net Tutar',
                '${payment.finalAmount.toStringAsFixed(2)} TL',
              ),
              _buildDetailRow('Durum', _getStatusText(payment.status)),
              if (payment.dueDate != null)
                _buildDetailRow(
                  'Vade Tarihi',
                  _formatFullDate(payment.dueDate!),
                ),
              if (payment.paidAt != null)
                _buildDetailRow(
                  'Ödeme Tarihi',
                  _formatFullDate(payment.paidAt!),
                ),
              _buildDetailRow(
                'Oluşturma Tarihi',
                _formatFullDate(payment.createdAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.paid:
        return 'Ödendi';
      case PaymentStatus.failed:
        return 'Başarısız';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Ders programı tarihlerini gösteren widget
  Widget _buildScheduleDates(BuildContext context, PaymentWithDetails payment) {
    // Schedule bilgisi varsa göster
    if (payment.scheduleStartDate != null || payment.scheduleEndDate != null) {
      return Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _buildScheduleDateText(payment),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _buildScheduleDateText(PaymentWithDetails payment) {
    if (payment.scheduleStartDate != null && payment.scheduleEndDate != null) {
      return 'Ders: ${_formatDate(payment.scheduleStartDate!)} - ${_formatDate(payment.scheduleEndDate!)}';
    } else if (payment.scheduleStartDate != null) {
      return 'Başlangıç: ${_formatDate(payment.scheduleStartDate!)}';
    } else if (payment.scheduleEndDate != null) {
      return 'Bitiş: ${_formatDate(payment.scheduleEndDate!)}';
    }
    return '';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payments_providers.dart';
import '../widgets/payment_card.dart';
import '../widgets/payment_form_dialog.dart';
import '../../../../core/widgets/navigation_drawer.dart' as nav;
import '../../../../core/widgets/centered_error_widget.dart';
import '../../../../core/widgets/admin_filter_widget.dart';
import '../../../../core/widgets/responsive_grid_list.dart';
import '../../../../core/widgets/role_based_form.dart';
import '../../../../core/widgets/app_bar_logo.dart';
import '../../../../core/services/role_service.dart';
import '../../domain/entities/payment_with_details.dart';
import '../../domain/entities/payment.dart';
import '../../../groups/presentation/providers/groups_providers.dart';
import '../../../members/data/providers/members_providers.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLogo(),
        title: const Text('Ödemeler'),
        actions: [
          FutureBuilder<bool>(
            future: RoleService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreatePaymentDialog(context),
                  tooltip: 'Yeni Ödeme Ekle',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const nav.NavigationDrawer(),
      body: RoleBasedForm(
        adminForm: _buildAdminView(),
        memberForm: _buildMemberView(),
      ),
    );
  }

  Widget _buildAdminView() {
    final paymentsAsync = ref.watch(paymentsWithDetailsProvider);
    final groupsAsync = ref.watch(groupsListProvider);
    final membersAsync = ref.watch(membersProvider);
    final packagesAsync = ref.watch(lessonPackagesProvider);

    return Column(
      children: [
        groupsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
          data: (groups) {
            return membersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (members) {
                return packagesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                  data: (packages) {
                    return AdminFilterWidget(
                      filterOptions: _buildFilterOptions(
                        groups,
                        members,
                        packages,
                      ),
                      onFilterChanged: (filters) {
                        setState(() {
                          _filters = filters;
                        });
                      },
                    );
                  },
                );
              },
            );
          },
        ),
        Expanded(
          child: paymentsAsync.when(
            loading: () => const CenteredLoadingWidget(),
            error: (error, stack) => CenteredErrorWidget.generalError(
              message: 'Hata: $error',
              onRetry: () => ref.invalidate(paymentsWithDetailsProvider),
            ),
            data: (payments) {
              final filteredPayments = _applyFilters(payments);

              if (filteredPayments.isEmpty) {
                return CenteredEmptyWidget(
                  title: _filters.isEmpty
                      ? 'Henüz ödeme kaydı bulunmuyor'
                      : 'Filtreye uygun ödeme bulunamadı',
                  message: _filters.isEmpty
                      ? 'İlk ödemeyi eklemek için + butonuna tıklayın'
                      : 'Filtreleri değiştirerek tekrar deneyin',
                  icon: Icons.payment_outlined,
                  onAction: _filters.isEmpty
                      ? () => _showCreatePaymentDialog(context)
                      : null,
                  actionText: _filters.isEmpty ? 'Yeni Ödeme Ekle' : null,
                );
              }

              return RefreshableResponsiveGridList<PaymentWithDetails>(
                items: filteredPayments,
                onRefresh: () async {
                  ref.invalidate(paymentsWithDetailsProvider);
                },
                aspectRatio: 1.2,
                maxColumns: 4,
                itemBuilder: (context, payment, index) {
                  return PaymentCard(
                    payment: payment,
                    onEdit: () => _showEditPaymentDialog(context, payment),
                    onDelete: () => _deletePayment(context, payment.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberView() {
    final currentMemberAsync = ref.watch(currentMemberProvider);
    final paymentsAsync = ref.watch(paymentsWithDetailsProvider);
    final packagesAsync = ref.watch(lessonPackagesProvider);

    return currentMemberAsync.when(
      loading: () => const CenteredLoadingWidget(),
      error: (error, stack) => CenteredErrorWidget.generalError(
        message: 'Hata: $error',
        onRetry: () => ref.invalidate(currentMemberProvider),
      ),
      data: (currentMember) {
        if (currentMember == null) {
          return const CenteredEmptyWidget(
            title: 'Kullanıcı bilgisi bulunamadı',
            message: 'Lütfen tekrar giriş yapın',
            icon: Icons.error_outline,
          );
        }

        return Column(
          children: [
            // Member için basitleştirilmiş filtre
            packagesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (packages) {
                return AdminFilterWidget(
                  filterOptions: _buildMemberFilterOptions(packages),
                  onFilterChanged: (filters) {
                    setState(() {
                      _filters = filters;
                    });
                  },
                );
              },
            ),
            // Ödeme Listesi - Sadece kendi ödemeleri
            Expanded(
              child: paymentsAsync.when(
                loading: () => const CenteredLoadingWidget(),
                error: (error, stack) => CenteredErrorWidget.generalError(
                  message: 'Hata: $error',
                  onRetry: () => ref.invalidate(paymentsWithDetailsProvider),
                ),
                data: (payments) {
                  // Sadece kendi ödemelerini filtrele
                  final ownPayments = payments
                      .where((payment) => payment.memberId == currentMember.id)
                      .toList();

                  // Filtreleme uygula
                  final filteredPayments = _applyFilters(ownPayments);

                  if (filteredPayments.isEmpty) {
                    return const CenteredEmptyWidget(
                      title: 'Henüz ödeme kaydı bulunmuyor',
                      message: 'Ödeme kayıtlarınız burada görüntülenecektir',
                      icon: Icons.payment_outlined,
                    );
                  }

                  return RefreshableResponsiveGridList<PaymentWithDetails>(
                    items: filteredPayments,
                    onRefresh: () async {
                      ref.invalidate(paymentsWithDetailsProvider);
                    },
                    aspectRatio: 1.2,
                    maxColumns: 4,
                    itemBuilder: (context, payment, index) {
                      return PaymentCard(
                        payment: payment,
                        onEdit: null, // Member ödemeleri düzenleyemez
                        onDelete: null, // Member ödemeleri silemez
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<FilterOption> _buildFilterOptions(
    List<dynamic> groups,
    List<dynamic> members,
    List<dynamic> packages,
  ) {
    // Üye seçenekleri
    final memberOptions = <String>[
      'Tümü',
      ...members.map((member) => '${member.firstName} ${member.lastName}'),
    ];

    // Grup seçenekleri
    final groupOptions = <String>[
      'Tümü',
      ...groups.map((group) => group.name as String),
    ];

    // Paket seçenekleri
    final packageOptions = <String>[
      'Tümü',
      ...packages.map((package) => package.name as String),
    ];

    return [
      FilterOption(
        key: 'member',
        label: 'Üye',
        type: FilterType.dropdown,
        options: memberOptions,
      ),
      FilterOption(
        key: 'group',
        label: 'Grup',
        type: FilterType.dropdown,
        options: groupOptions,
      ),
      FilterOption(
        key: 'status',
        label: 'Ödeme Durumu',
        type: FilterType.dropdown,
        options: ['Tümü', 'Beklemede', 'Ödendi', 'Başarısız'],
      ),
      FilterOption(
        key: 'package',
        label: 'Paket',
        type: FilterType.dropdown,
        options: packageOptions,
      ),
      FilterOption(
        key: 'min_amount',
        label: 'Min Tutar',
        type: FilterType.text,
        hint: 'Örn: 1000',
      ),
      FilterOption(
        key: 'max_amount',
        label: 'Max Tutar',
        type: FilterType.text,
        hint: 'Örn: 5000',
      ),
      FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
      FilterOption(
        key: 'due_date',
        label: 'Vade Tarihi',
        type: FilterType.dateRange,
      ),
      FilterOption(
        key: 'paid_date',
        label: 'Ödeme Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  List<FilterOption> _buildMemberFilterOptions(List<dynamic> packages) {
    // Paket seçenekleri
    final packageOptions = <String>[
      'Tümü',
      ...packages.map((package) => package.name as String),
    ];

    return [
      FilterOption(
        key: 'status',
        label: 'Ödeme Durumu',
        type: FilterType.dropdown,
        options: ['Tümü', 'Beklemede', 'Ödendi', 'Başarısız'],
      ),
      FilterOption(
        key: 'package',
        label: 'Paket',
        type: FilterType.dropdown,
        options: packageOptions,
      ),
      FilterOption(
        key: 'due_date',
        label: 'Vade Tarihi',
        type: FilterType.dateRange,
      ),
      FilterOption(
        key: 'paid_date',
        label: 'Ödeme Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  List<PaymentWithDetails> _applyFilters(List<PaymentWithDetails> payments) {
    if (_filters.isEmpty) return payments;

    return payments.where((payment) {
      // Üye filtresi
      if (_filters.containsKey('member') &&
          _filters['member'] != null &&
          _filters['member'] != 'Tümü') {
        final filterMember = _filters['member'] as String;
        if (payment.memberName != filterMember) {
          return false;
        }
      }

      // Grup filtresi (üye üzerinden - burada member'ın group bilgisini almamız gerekir)
      // Şimdilik atlayalım, çünkü PaymentWithDetails'te group bilgisi yok
      // İleride PaymentWithDetails'e groupName eklenebilir

      // Durum filtresi
      if (_filters.containsKey('status') &&
          _filters['status'] != null &&
          _filters['status'] != 'Tümü') {
        final filterStatus = _filters['status'] as String;
        String paymentStatus;
        switch (payment.status) {
          case PaymentStatus.pending:
            paymentStatus = 'Beklemede';
            break;
          case PaymentStatus.paid:
            paymentStatus = 'Ödendi';
            break;
          case PaymentStatus.failed:
            paymentStatus = 'Başarısız';
            break;
        }
        if (paymentStatus != filterStatus) {
          return false;
        }
      }

      // Paket filtresi
      if (_filters.containsKey('package') &&
          _filters['package'] != null &&
          _filters['package'] != 'Tümü') {
        final filterPackage = _filters['package'] as String;
        if (payment.packageName != filterPackage) {
          return false;
        }
      }

      // Min tutar filtresi
      if (_filters.containsKey('min_amount') &&
          _filters['min_amount'] != null &&
          _filters['min_amount'].toString().isNotEmpty) {
        final minAmount = double.tryParse(_filters['min_amount'].toString());
        if (minAmount != null && payment.finalAmount < minAmount) {
          return false;
        }
      }

      // Max tutar filtresi
      if (_filters.containsKey('max_amount') &&
          _filters['max_amount'] != null &&
          _filters['max_amount'].toString().isNotEmpty) {
        final maxAmount = double.tryParse(_filters['max_amount'].toString());
        if (maxAmount != null && payment.finalAmount > maxAmount) {
          return false;
        }
      }

      // Oluşturma tarihi filtresi
      if (_filters.containsKey('created_date') &&
          _filters['created_date'] != null) {
        final filterDate = DateTime.parse(_filters['created_date']);
        final paymentDate = DateTime(
          payment.createdAt.year,
          payment.createdAt.month,
          payment.createdAt.day,
        );
        final filterDay = DateTime(
          filterDate.year,
          filterDate.month,
          filterDate.day,
        );
        if (paymentDate.isBefore(filterDay)) {
          return false;
        }
      }

      // Vade tarihi filtresi
      if (_filters.containsKey('due_date') &&
          _filters['due_date'] != null &&
          payment.dueDate != null) {
        final filterDate = DateTime.parse(_filters['due_date']);
        final paymentDate = DateTime(
          payment.dueDate!.year,
          payment.dueDate!.month,
          payment.dueDate!.day,
        );
        final filterDay = DateTime(
          filterDate.year,
          filterDate.month,
          filterDate.day,
        );
        if (paymentDate.isBefore(filterDay)) {
          return false;
        }
      }

      // Ödeme tarihi filtresi
      if (_filters.containsKey('paid_date') &&
          _filters['paid_date'] != null &&
          payment.paidAt != null) {
        final filterDate = DateTime.parse(_filters['paid_date']);
        final paymentDate = DateTime(
          payment.paidAt!.year,
          payment.paidAt!.month,
          payment.paidAt!.day,
        );
        final filterDay = DateTime(
          filterDate.year,
          filterDate.month,
          filterDate.day,
        );
        if (paymentDate.isBefore(filterDay)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showCreatePaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        onSave: (paymentData) async {
          try {
            final createPayment = ref.read(createPaymentProvider);
            await createPayment.call(
              memberId: paymentData['memberId'],
              packageId: paymentData['packageId'],
              amount: paymentData['amount'],
              discountAmount: paymentData['discountAmount'] ?? 0.0,
              dueDate: paymentData['dueDate'],
              scheduleId: paymentData['scheduleId'],
            );
            ref.invalidate(paymentsWithDetailsProvider);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ödeme oluşturuldu')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
            }
          }
        },
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, dynamic payment) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        payment: payment is PaymentWithDetails ? payment.payment : payment,
        onSave: (paymentData) async {
          try {
            final updatePayment = ref.read(updatePaymentProvider);
            final basePayment = payment is PaymentWithDetails
                ? payment.payment
                : payment;
            final updatedPayment = basePayment.copyWith(
              amount: paymentData['amount'],
              discountAmount: paymentData['discountAmount'] ?? 0.0,
              dueDate: paymentData['dueDate'],
              status: paymentData['status'],
              scheduleId: paymentData['scheduleId'],
            );
            await updatePayment.call(updatedPayment);
            ref.invalidate(paymentsWithDetailsProvider);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ödeme güncellendi')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
            }
          }
        },
      ),
    );
  }

  void _deletePayment(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödemeyi Sil'),
        content: const Text('Bu ödemeyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deletePayment = ref.read(deletePaymentProvider);
        await deletePayment.call(id);
        ref.invalidate(paymentsProvider);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Ödeme silindi')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
        }
      }
    }
  }
}

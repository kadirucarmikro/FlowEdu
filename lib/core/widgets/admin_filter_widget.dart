import 'package:flutter/material.dart';

/// Admin filter widget for database-related filtering
class AdminFilterWidget extends StatefulWidget {
  final List<FilterOption> filterOptions;
  final Function(Map<String, dynamic>) onFilterChanged;
  final Map<String, dynamic>? initialFilters;

  const AdminFilterWidget({
    super.key,
    required this.filterOptions,
    required this.onFilterChanged,
    this.initialFilters,
  });

  @override
  State<AdminFilterWidget> createState() => _AdminFilterWidgetState();
}

class _AdminFilterWidgetState extends State<AdminFilterWidget> {
  final Map<String, dynamic> _filters = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false; // Başlangıçta kapalı

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _filters.addAll(widget.initialFilters!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(_filters);
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _searchController.clear();
    });
    widget.onFilterChanged({});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header - Her zaman görünür
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtreleme Seçenekleri',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  // Aktif filtre sayısı gösterimi
                  if (_filters.isNotEmpty && !_isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_filters.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          // Filtre içeriği - Sadece açıkken görünür
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ara',
                      hintText: 'Arama yapın...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _filters['search'] = value;
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filter options
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.filterOptions.map((option) {
                      return _buildFilterOption(option);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Temizle'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_alt),
                        label: const Text('Filtrele'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(FilterOption option) {
    switch (option.type) {
      case FilterType.dropdown:
        return _buildDropdownFilter(option);
      case FilterType.dateRange:
        return _buildDateRangeFilter(option);
      case FilterType.checkbox:
        return _buildCheckboxFilter(option);
      case FilterType.text:
        return _buildTextFilter(option);
    }
  }

  Widget _buildDropdownFilter(FilterOption option) {
    // Default değer: _filters'da varsa onu kullan, yoksa ilk seçeneği (genellikle "Tümü") kullan
    final defaultValue = _filters[option.key] as String? ??
        (option.options?.isNotEmpty == true ? option.options!.first : null);
    
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: defaultValue,
        decoration: InputDecoration(
          labelText: option.label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: option.options?.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return option.options?.map((value) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList() ?? [];
        },
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _filters[option.key] = value;
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildDateRangeFilter(FilterOption option) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: TextEditingController(
          text: _filters[option.key] != null
              ? _formatDate(DateTime.parse(_filters[option.key]))
              : '',
        ),
        decoration: InputDecoration(
          labelText: option.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _filters[option.key] != null
                ? DateTime.parse(_filters[option.key])
                : DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() {
              _filters[option.key] = date.toIso8601String();
            });
            _applyFilters();
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildCheckboxFilter(FilterOption option) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _filters[option.key] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters[option.key] = value;
            });
            _applyFilters();
          },
        ),
        Text(option.label),
      ],
    );
  }

  Widget _buildTextFilter(FilterOption option) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: option.label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          _filters[option.key] = value;
          _applyFilters();
        },
      ),
    );
  }
}

/// Filter option model
class FilterOption {
  final String key;
  final String label;
  final FilterType type;
  final List<String>? options;
  final String? hint;

  const FilterOption({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.hint,
  });
}

/// Filter types
enum FilterType { dropdown, dateRange, checkbox, text }

/// Common filter options for different modules
class CommonFilterOptions {
  static List<FilterOption> getMemberFilters() {
    return [
      const FilterOption(
        key: 'group',
        label: 'Grup',
        type: FilterType.dropdown,
        options: ['Tümü', 'Grup 1', 'Grup 2', 'Grup 3'],
      ),
      const FilterOption(
        key: 'role',
        label: 'Rol',
        type: FilterType.dropdown,
        options: ['Tümü', 'Admin', 'Member'],
      ),
      const FilterOption(
        key: 'status',
        label: 'Durum',
        type: FilterType.dropdown,
        options: ['Tümü', 'Aktif', 'Pasif', 'Beklemede'],
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Kayıt Tarihi',
        type: FilterType.dateRange,
      ),
      const FilterOption(
        key: 'is_active',
        label: 'Aktif Üyeler',
        type: FilterType.checkbox,
      ),
    ];
  }

  static List<FilterOption> getNotificationFilters() {
    return [
      const FilterOption(
        key: 'time_range',
        label: 'Zaman Aralığı',
        type: FilterType.dropdown,
        options: ['Tümü', 'Son 24 saat', 'Son hafta'],
      ),
      const FilterOption(
        key: 'type',
        label: 'Bildirim Türü',
        type: FilterType.dropdown,
        options: ['Tümü', 'Otomatik', 'Manuel', 'Etkileşimli'],
      ),
      const FilterOption(
        key: 'target_group',
        label: 'Hedef Grup',
        type: FilterType.dropdown,
        options: ['Tümü', 'Grup 1', 'Grup 2', 'Grup 3'],
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Gönderim Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  static List<FilterOption> getEventFilters() {
    return [
      const FilterOption(
        key: 'type',
        label: 'Etkinlik Türü',
        type: FilterType.dropdown,
        options: ['Tümü', 'Normal', 'Etkileşimli', 'Anket'],
      ),
      const FilterOption(
        key: 'status',
        label: 'Durum',
        type: FilterType.dropdown,
        options: ['Tümü', 'Aktif', 'Tamamlandı', 'İptal'],
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  static List<FilterOption> getPaymentFilters() {
    return [
      const FilterOption(
        key: 'status',
        label: 'Ödeme Durumu',
        type: FilterType.dropdown,
        options: ['Tümü', 'Beklemede', 'Ödendi', 'Başarısız'],
      ),
      const FilterOption(
        key: 'member',
        label: 'Üye',
        type: FilterType.text,
        hint: 'Üye adı ile ara',
      ),
      const FilterOption(
        key: 'amount_range',
        label: 'Tutar Aralığı',
        type: FilterType.text,
        hint: 'Min - Max tutar',
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Ödeme Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  static List<FilterOption> getLessonScheduleFilters() {
    return [
      const FilterOption(
        key: 'package_name',
        label: 'Paket Adı',
        type: FilterType.dropdown,
        options: ['Tümü'], // Dinamik olarak doldurulacak
      ),
      const FilterOption(
        key: 'day_of_week',
        label: 'Hafta Günü',
        type: FilterType.dropdown,
        options: [
          'Tümü',
          'Pazartesi',
          'Salı',
          'Çarşamba',
          'Perşembe',
          'Cuma',
          'Cumartesi',
          'Pazar',
        ],
      ),
      const FilterOption(
        key: 'time_range',
        label: 'Saat Aralığı',
        type: FilterType.text,
        hint: 'Örn: 19:00-20:30',
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }

  static List<FilterOption> getLessonPackageFilters() {
    return [
      const FilterOption(
        key: 'lesson_count',
        label: 'Ders Sayısı',
        type: FilterType.dropdown,
        options: ['Tümü', '1-5 ders', '6-10 ders', '11-20 ders', '20+ ders'],
      ),
      const FilterOption(
        key: 'status',
        label: 'Durum',
        type: FilterType.dropdown,
        options: ['Tümü', 'Aktif', 'Pasif'],
      ),
      const FilterOption(
        key: 'is_active',
        label: 'Sadece Aktif Paketler',
        type: FilterType.checkbox,
      ),
      const FilterOption(
        key: 'created_date',
        label: 'Oluşturma Tarihi',
        type: FilterType.dateRange,
      ),
    ];
  }
}

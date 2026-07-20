import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackify/core/constants/app_colors.dart';
import 'package:trackify/screens/auth/widgets/bg_glow.dart';


class AddBillResult {
  final String title;
  final String category;
  final double amount;
  final DateTime dueDate;
  final IconData icon;
  final Color color;
  final bool isRecurring;

  const AddBillResult({
    required this.title,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.color,
    required this.isRecurring,
  });
}

class _CategoryOption {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryOption(this.label, this.icon, this.color);
}

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  static const _categories = [
    _CategoryOption('Housing', Icons.house_outlined, Color(0xFF818CF8)),
    _CategoryOption('Utilities', Icons.bolt_outlined, Color(0xFFFBBF24)),
    _CategoryOption('Internet', Icons.wifi_rounded, Color(0xFF38BDF8)),
    _CategoryOption(
        'Entertainment', Icons.movie_outlined, Color(0xFFA78BFA)),
    _CategoryOption(
        'Insurance', Icons.favorite_outline_rounded, Color(0xFFF472B6)),
    _CategoryOption(
        'Loan', Icons.directions_car_filled_outlined, Color(0xFFF87171)),
    _CategoryOption('Other', Icons.receipt_long_outlined, Color(0xFF4ADE80)),
  ];

  int? _selectedCategory;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  bool _saving = false;

  String? _titleError;
  String? _amountError;
  String? _categoryError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.bg,
              onSurface: AppColors.cream,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveBill() async {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());

    setState(() {
      _titleError = title.isEmpty ? 'Enter a bill name' : null;
      _amountError =
      (amount == null || amount <= 0) ? 'Enter a valid amount' : null;
      _categoryError =
      _selectedCategory == null ? 'Pick a category' : null;
    });

    if (_titleError != null ||
        _amountError != null ||
        _categoryError != null) {
      return;
    }

    setState(() => _saving = true);

    final category = _categories[_selectedCategory!];

    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pop(
      context,
      AddBillResult(
        title: title,
        category: category.label,
        amount: amount!,
        dueDate: _dueDate,
        icon: category.icon,
        color: category.color,
        isRecurring: _isRecurring,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const BgGlow(),
          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.muted.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.muted.withOpacity(0.15),
                                width: 1),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: AppColors.muted),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Add Bill',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the details of your bill',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Bill title ───────────────────────────
                        _FieldLabel('Bill Name'),
                        const SizedBox(height: 8),
                        _InputBox(
                          hasError: _titleError != null,
                          child: TextField(
                            controller: _titleCtrl,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cream,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Electricity Bill',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: AppColors.muted.withOpacity(0.4),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) =>
                                setState(() => _titleError = null),
                          ),
                        ),
                        if (_titleError != null)
                          _ErrorText(_titleError!),

                        const SizedBox(height: 20),

                        // ── Amount ───────────────────────────────
                        _FieldLabel('Amount'),
                        const SizedBox(height: 8),
                        _InputBox(
                          hasError: _amountError != null,
                          child: Row(
                            children: [
                              const Text(
                                '₹',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _amountCtrl,
                                  keyboardType: const TextInputType
                                      .numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cream,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '1000',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      color: AppColors.muted.withOpacity(0.4),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) =>
                                      setState(() => _amountError = null),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_amountError != null)
                          _ErrorText(_amountError!),

                        const SizedBox(height: 20),

                        // ── Due date ─────────────────────────────
                        _FieldLabel('Due Date'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDueDate,
                          child: _InputBox(
                            hasError: false,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 16,
                                    color: AppColors.accent.withOpacity(0.8)),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDate(_dueDate),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cream,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: AppColors.muted.withOpacity(0.6)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Category ─────────────────────────────
                        _FieldLabel('Category'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (int i = 0; i < _categories.length; i++)
                              _CategoryChip(
                                option: _categories[i],
                                selected: _selectedCategory == i,
                                onTap: () => setState(() {
                                  _selectedCategory = i;
                                  _categoryError = null;
                                }),
                              ),
                          ],
                        ),
                        if (_categoryError != null)
                          _ErrorText(_categoryError!),

                        const SizedBox(height: 20),

                        // ── Recurring toggle ─────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.muted.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.muted.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.autorenew_rounded,
                                  size: 18,
                                  color: AppColors.muted.withOpacity(0.7)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Recurring bill',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cream.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              Switch(
                                value: _isRecurring,
                                onChanged: (v) =>
                                    setState(() => _isRecurring = v),
                                activeColor: AppColors.accent,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Save button ───────────────────────────
                        GestureDetector(
                          onTap: _saving ? null : _saveBill,
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _saving
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Save Bill',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.muted.withOpacity(0.8),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 13, color: Colors.redAccent.shade200),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.redAccent.shade200,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final Widget child;
  final bool hasError;
  const _InputBox({required this.child, required this.hasError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? Colors.redAccent.shade200
              : AppColors.accent.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _CategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withOpacity(0.18)
              : AppColors.muted.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? option.color.withOpacity(0.5)
                : AppColors.muted.withOpacity(0.15),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon,
                size: 16,
                color: selected ? option.color : AppColors.muted),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? option.color : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
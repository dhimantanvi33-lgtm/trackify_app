import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackify/core/constants/app_colors.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/model/expense_model.dart';

class _Category {
  final String label;
  final IconData icon;
  final Color color;

  const _Category(
      {required this.label, required this.icon, required this.color});
}

const _categories = [
  _Category(
      label: 'Food',
      icon: Icons.restaurant_outlined,
      color: Color(0xFF818CF8)),
  _Category(
      label: 'Travel',
      icon: Icons.directions_transit_outlined,
      color: Color(0xFF38BDF8)),
  _Category(
      label: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFFBBF24)),
  _Category(
      label: 'Bills',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFF87171)),
  _Category(
      label: 'Health',
      icon: Icons.favorite_outline_rounded,
      color: Color(0xFFF472B6)),
  _Category(
      label: 'Entertainment',
      icon: Icons.movie_outlined,
      color: Color(0xFFA78BFA)),
  _Category(
      label: 'Education',
      icon: Icons.school_outlined,
      color: Color(0xFF34D399)),
  _Category(
      label: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF94A3B8)),
];


class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _titleError;
  String? _amountError;

  int _selectedCategory = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _loading = false;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _enterAnim,
          curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _enterAnim.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _titleError = null;
      _amountError = null;

      if (_titleCtrl.text.trim().isEmpty) {
        _titleError = 'Title is required';
        valid = false;
      }
      if (_amountCtrl.text.trim().isEmpty) {
        _amountError = 'Amount is required';
        valid = false;
      } else if (double.tryParse(_amountCtrl.text.trim()) == null ||
          double.parse(_amountCtrl.text.trim()) <= 0) {
        _amountError = 'Enter a valid amount';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accent,
            surface: const Color(0xFF1C1C28),
            onSurface: AppColors.cream,
          ),
          dialogBackgroundColor: const Color(0xFF1C1C28),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);

    final expense = ExpenseModel(
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _categories[_selectedCategory].label,
      date: _selectedDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      isExpense: _isExpense,
    );

    Navigator.pop(context, expense);
  }

  String _formatDate(DateTime d) {
    if (_isSameDay(d, DateTime.now())) return 'Today';
    if (_isSameDay(d, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const BgGlow(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // ── Top bar ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          _IconBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          const Text(
                            'Add Transaction',
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

                    // ── Scrollable body ──────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Type toggle ──────────────────────────────
                            _TypeToggle(
                              isExpense: _isExpense,
                              onChanged: (val) =>
                                  setState(() => _isExpense = val),
                            ),

                            const SizedBox(height: 24),

                            // ── Amount display ───────────────────────────
                            _AmountField(
                              controller: _amountCtrl,
                              isExpense: _isExpense,
                              errorText: _amountError,
                              onChanged: (_) =>
                                  setState(() => _amountError = null),
                            ),

                            const SizedBox(height: 24),

                            // ── Category picker ──────────────────────────
                            _SectionLabel(label: 'Category'),
                            const SizedBox(height: 12),
                            _CategoryGrid(
                              categories: _categories,
                              selected: _selectedCategory,
                              onSelect: (i) =>
                                  setState(() => _selectedCategory = i),
                            ),

                            const SizedBox(height: 24),

                            // ── Title ────────────────────────────────────
                            _SectionLabel(label: 'Title'),
                            const SizedBox(height: 10),
                            _InputField(
                              controller: _titleCtrl,
                              hint: 'e.g. Swiggy Order',
                              prefixIcon: Icons.title_rounded,
                              errorText: _titleError,
                              onChanged: (_) =>
                                  setState(() => _titleError = null),
                            ),

                            const SizedBox(height: 20),

                            // ── Date ─────────────────────────────────────
                            _SectionLabel(label: 'Date'),
                            const SizedBox(height: 10),
                            _DatePicker(
                              label: _formatDate(_selectedDate),
                              onTap: _pickDate,
                            ),

                            const SizedBox(height: 20),

                            // ── Note (optional) ───────────────────────────
                            _SectionLabel(label: 'Note  (optional)'),
                            const SizedBox(height: 10),
                            _InputField(
                              controller: _noteCtrl,
                              hint: 'Add a short note...',
                              prefixIcon: Icons.notes_rounded,
                              maxLines: 3,
                            ),

                            const SizedBox(height: 32),

                            // ── Save button ──────────────────────────────
                            _SaveButton(
                              label: 'Save Transaction',
                              isLoading: _loading,
                              color: _isExpense
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFF4ADE80),
                              onTap: _save,
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const _TypeToggle({required this.isExpense, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: AppColors.muted.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            selected: isExpense,
            activeColor: const Color(0xFFF87171),
            onTap: () => onChanged(true),
          ),
          _ToggleTab(
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            selected: !isExpense,
            activeColor: const Color(0xFF4ADE80),
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? activeColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: activeColor.withOpacity(0.35), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? activeColor : AppColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? activeColor : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool isExpense;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _AmountField({
    required this.controller,
    required this.isExpense,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isExpense ? const Color(0xFFF87171) : const Color(0xFF4ADE80);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent.shade200
                  : color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cream,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted.withOpacity(0.3),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 13, color: Colors.redAccent.shade200),
                const SizedBox(width: 5),
                Text(
                  errorText!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.redAccent.shade200,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<_Category> categories;
  final int selected;
  final ValueChanged<int> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withOpacity(0.15)
                  : AppColors.muted.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? cat.color.withOpacity(0.5)
                    : AppColors.muted.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon,
                    size: 22,
                    color: isSelected ? cat.color : AppColors.muted),
                const SizedBox(height: 6),
                Text(
                  cat.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? cat.color : AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.muted.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent.shade200
                  : AppColors.muted.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.cream,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.muted.withOpacity(0.4),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(prefixIcon,
                    size: 18, color: AppColors.muted.withOpacity(0.5)),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            onChanged: onChanged,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 13, color: Colors.redAccent.shade200),
                const SizedBox(width: 5),
                Text(
                  errorText!,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.redAccent.shade200),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePicker({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.muted.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.muted.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.muted.withOpacity(0.5)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.cream,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.muted.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  const _SaveButton({
    required this.label,
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.muted.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.muted.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.muted.withOpacity(0.15), width: 1),
        ),
        child: Icon(icon, size: 18, color: AppColors.muted),
      ),
    );
  }
}
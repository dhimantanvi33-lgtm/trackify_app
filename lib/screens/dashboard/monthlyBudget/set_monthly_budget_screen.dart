import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackify/core/constants/app_colors.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';

class SetMonthlyBudgetScreen extends StatefulWidget {
  const SetMonthlyBudgetScreen({super.key});

  @override
  State<SetMonthlyBudgetScreen> createState() =>
      _SetMonthlyBudgetScreenState();
}

class _SetMonthlyBudgetScreenState extends State<SetMonthlyBudgetScreen> {
  final _budgetCtrl = TextEditingController();
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_budgetCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Enter a valid amount');
      return;
    }

    setState(() {
      _errorText = null;
      _saving = true;
    });

    // TODO: wire this up to a BudgetProvider/BudgetService once ready,
    // e.g. await context.read<BudgetProvider>().setMonthlyBudget(amount);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, amount);
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
                        'Monthly Budget',
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Set how much you want to spend this month',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _errorText != null
                                  ? Colors.redAccent.shade200
                                  : AppColors.accent.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '₹',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _budgetCtrl,
                                  keyboardType: const TextInputType
                                      .numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.cream,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '15000',
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
                                  onChanged: (_) =>
                                      setState(() => _errorText = null),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    size: 13,
                                    color: Colors.redAccent.shade200),
                                const SizedBox(width: 5),
                                Text(
                                  _errorText!,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.redAccent.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _saving ? null : _saveBudget,
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
                                'Save Budget',
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
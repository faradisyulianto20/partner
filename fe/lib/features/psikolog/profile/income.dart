import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);
  bool _isWithdrawing = false;

  final List<_IncomeItem> _items = const [
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '10:00 WIB',
      amount: '+Rp. 150.000',
    ),
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '14:00 WIB',
      amount: '+Rp. 150.000',
    ),
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '14:00 WIB',
      amount: '+Rp. 150.000',
    ),
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '14:00 WIB',
      amount: '+Rp. 150.000',
    ),
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '14:00 WIB',
      amount: '+Rp. 150.000',
    ),
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '14:00 WIB',
      amount: '+Rp. 150.000',
    ),
    _IncomeItem(
      title: 'Pembayaran Masuk',
      date: '12 September 2026',
      time: '14:00 WIB',
      amount: '+Rp. 150.000',
    ),
  ];

  Future<void> _withdrawBalance() async {
    if (_isWithdrawing) return;
    setState(() => _isWithdrawing = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isWithdrawing = false);
    _showSnackBar('Permintaan tarik saldo berhasil dikirim.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Riwayat Pendapatan',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalCard(),
              const SizedBox(height: 18),
              Text(
                'Riwayat Pembayaran',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildHistoryCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _buildWithdrawButton(),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F4C7A), Color(0xFF0E3A63)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Saldo',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rp. 10.650.000',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBlue, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: _items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => Divider(height: 1, color: _softBlue),
        itemBuilder: (context, index) => _buildHistoryItem(_items[index]),
      ),
    );
  }

  Widget _buildHistoryItem(_IncomeItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _softBlue, width: 1),
              color: const Color(0xFFEAF0F7),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: _primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.date} - ${item.time}',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.amount,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isWithdrawing ? null : _withdrawBalance,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isWithdrawing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 18,
              ),
        label: Text(
          _isWithdrawing ? 'Memproses...' : 'Tarik Saldo',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _IncomeItem {
  final String title;
  final String date;
  final String time;
  final String amount;

  const _IncomeItem({
    required this.title,
    required this.date,
    required this.time,
    required this.amount,
  });
}

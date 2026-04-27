import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/services/import_service.dart';
import '../../data/services/calculate_service.dart';
import '../../data/services/export_service.dart';
import 'widgets/step_card.dart';
import 'widgets/console_panel.dart';

class DashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const DashboardScreen({super.key, required this.themeProvider});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _importService = ImportService();
  final _calculateService = CalculateService();
  final _exportService = ExportService();
  final List<String> _logs = [];
  final _scrollController = ScrollController();

  String _step1State = 'ready', _step2State = 'ready', _step3State = 'ready';
  String _step1Msg = '', _step2Msg = '', _step3Msg = '';

  void _log(String msg) {
    setState(() => _logs.add('[${TimeOfDay.now().format(context)}] $msg'));
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
    if (result == null) return;
    setState(() { _step1State = 'processing'; _step1Msg = 'Đang nhập...'; });
    try {
      final stats = await _importService.importFromExcel(result.files.single.path!, _log);
      setState(() {
        _step1State = 'completed';
        _step1Msg = '✅ ${stats['records']} bản ghi, ${stats['levels']} cấp độ, ${stats['holidays']} ngày lễ';
        _step2State = 'ready';
      });
    } catch (e) {
      setState(() { _step1State = 'error'; _step1Msg = '❌ $e'; });
    }
  }

  Future<void> _calculate() async {
    setState(() { _step2State = 'processing'; _step2Msg = 'Đang tính toán...'; });
    try {
      final stats = await _calculateService.calculate(_log, (_) => setState(() {}));
      setState(() {
        _step2State = 'completed';
        _step2Msg = '✅ ${stats['total_records']} bản ghi, Tổng: ${stats['total_bonus']}';
        _step3State = 'ready';
      });
    } catch (e) {
      setState(() { _step2State = 'error'; _step2Msg = '❌ $e'; });
    }
  }

  Future<void> _export() async {
    final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Xuất kết quả', fileName: 'result.xlsx',
        type: FileType.custom, allowedExtensions: ['xlsx']);
    if (path == null) return;
    setState(() { _step3State = 'processing'; _step3Msg = 'Đang xuất...'; });
    try {
      await _exportService.exportToExcel(path, _log);
      setState(() { _step3State = 'completed'; _step3Msg = '✅ Đã xuất file'; });
    } catch (e) {
      setState(() { _step3State = 'error'; _step3Msg = '❌ $e'; });
    }
  }

  void _reset() => setState(() {
    _step1State = _step2State = _step3State = 'ready';
    _step1Msg = _step2Msg = _step3Msg = '';
    _logs.clear();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Matching'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.themeProvider.mode == ThemeMode.light
                ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.themeProvider.toggle,
            tooltip: 'Đổi theme',
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(flex: 3, child: _buildMainContent()),
          Expanded(flex: 2, child: ConsolePanel(logs: _logs, scrollController: _scrollController)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Quy trình tính chiết khấu',
              style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          StepCard(step: 1, title: 'Nhập dữ liệu', subtitle: 'Import Excel',
              state: _step1State, message: _step1Msg,
              onPressed: _step1State != 'processing' ? _import : null, buttonLabel: 'Chọn file'),
          const SizedBox(height: 16),
          StepCard(step: 2, title: 'Tính toán', subtitle: 'Đối trừ FIFO & thưởng',
              state: _step2State, message: _step2Msg,
              onPressed: _step1State == 'completed' && _step2State != 'processing' ? _calculate : null,
              buttonLabel: 'Tính toán'),
          const SizedBox(height: 16),
          StepCard(step: 3, title: 'Xuất kết quả', subtitle: 'Export Excel',
              state: _step3State, message: _step3Msg,
              onPressed: _step2State == 'completed' && _step3State != 'processing' ? _export : null,
              buttonLabel: 'Xuất file'),
          const Spacer(),
          if (_step3State == 'completed')
            FilledButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh),
                label: const Text('Bắt đầu tính toán mới')),
        ],
      ),
    );
  }
}

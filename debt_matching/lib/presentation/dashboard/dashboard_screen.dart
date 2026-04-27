import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/services/import_service.dart';
import '../../data/services/calculate_service.dart';
import '../../data/services/export_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _importService = ImportService();
  final _calculateService = CalculateService();
  final _exportService = ExportService();

  final List<String> _logs = [];
  final _scrollController = ScrollController();

  // Step states: 'ready', 'processing', 'completed', 'error'
  String _step1State = 'ready';
  String _step2State = 'ready';
  String _step3State = 'ready';
  String _step1Message = '';
  String _step2Message = '';
  String _step3Message = '';

  void _addLog(String msg) {
    setState(() {
      _logs.add('[${TimeOfDay.now().format(context)}] $msg');
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result == null) return;

    setState(() {
      _step1State = 'processing';
      _step1Message = 'Đang nhập dữ liệu...';
    });

    try {
      final stats = await _importService.importFromExcel(
        result.files.single.path!,
        _addLog,
      );
      setState(() {
        _step1State = 'completed';
        _step1Message = '✅ ${stats['records']} bản ghi, ${stats['levels']} cấp độ, ${stats['holidays']} ngày lễ';
        _step2State = 'ready';
      });
    } catch (e) {
      setState(() {
        _step1State = 'error';
        _step1Message = '❌ $e';
      });
    }
  }

  Future<void> _calculate() async {
    setState(() {
      _step2State = 'processing';
      _step2Message = 'Đang tính toán...';
    });

    try {
      final stats = await _calculateService.calculate(
        _addLog,
        (step) => setState(() {}),
      );
      setState(() {
        _step2State = 'completed';
        _step2Message = '✅ ${stats['total_records']} bản ghi, Tổng thưởng: ${stats['total_bonus']}';
        _step3State = 'ready';
      });
    } catch (e) {
      setState(() {
        _step2State = 'error';
        _step2Message = '❌ $e';
      });
    }
  }

  Future<void> _export() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Xuất kết quả',
      fileName: 'result.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null) return;

    setState(() {
      _step3State = 'processing';
      _step3Message = 'Đang xuất...';
    });

    try {
      await _exportService.exportToExcel(result, _addLog);
      setState(() {
        _step3State = 'completed';
        _step3Message = '✅ Đã xuất file';
      });
    } catch (e) {
      setState(() {
        _step3State = 'error';
        _step3Message = '❌ $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Matching'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Main content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Quy trình tính chiết khấu',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildStepCard(
                    step: 1,
                    title: 'Nhập dữ liệu',
                    subtitle: 'Import file Excel (Data + Config)',
                    state: _step1State,
                    message: _step1Message,
                    onPressed: _step1State != 'processing' ? _importData : null,
                    buttonLabel: 'Chọn file Excel',
                  ),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    step: 2,
                    title: 'Tính toán',
                    subtitle: 'Đối trừ FIFO & tính thưởng',
                    state: _step2State,
                    message: _step2Message,
                    onPressed: _step1State == 'completed' && _step2State != 'processing'
                        ? _calculate
                        : null,
                    buttonLabel: 'Tính toán',
                  ),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    step: 3,
                    title: 'Xuất kết quả',
                    subtitle: 'Export Excel có format',
                    state: _step3State,
                    message: _step3Message,
                    onPressed: _step2State == 'completed' && _step3State != 'processing'
                        ? _export
                        : null,
                    buttonLabel: 'Xuất file',
                  ),
                  const Spacer(),
                  if (_step3State == 'completed')
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _step1State = 'ready';
                        _step2State = 'ready';
                        _step3State = 'ready';
                        _step1Message = '';
                        _step2Message = '';
                        _step3Message = '';
                        _logs.clear();
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Bắt đầu tính toán mới'),
                    ),
                ],
              ),
            ),
          ),
          // Console log
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Console', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(_logs[i], style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required String subtitle,
    required String state,
    required String message,
    required VoidCallback? onPressed,
    required String buttonLabel,
  }) {
    IconData icon;
    Color iconColor;
    switch (state) {
      case 'processing':
        icon = Icons.hourglass_top;
        iconColor = Colors.orange;
        break;
      case 'completed':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'error':
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.circle_outlined;
        iconColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bước $step: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(message, style: TextStyle(fontSize: 13, color: state == 'error' ? Colors.red : Colors.green[700])),
                  ],
                  if (state == 'processing') ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

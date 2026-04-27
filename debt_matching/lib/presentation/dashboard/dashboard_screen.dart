import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/services/import_service.dart';
import '../../data/services/calculate_service.dart';
import '../../data/services/export_service.dart';
import 'widgets/console_panel.dart';
import 'widgets/preview_panel.dart';
import 'dashboard_state_views.dart';

enum AppState { initial, processing, preview, exported, error }

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

  AppState _state = AppState.initial;
  String _errorMsg = '';
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _topResults = [];
  int _invalidCount = 0;
  String _exportedPath = '';

  void _log(String msg) {
    setState(() => _logs.add('[${TimeOfDay.now().format(context)}] $msg'));
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _processFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
    if (result == null) return;
    setState(() { _state = AppState.processing; _logs.clear(); });
    try {
      await _importService.importFromExcel(result.files.single.path!, _log);
      final stats = await _calculateService.calculate(_log, (_) {});
      await _loadPreviewData(stats);
      setState(() => _state = AppState.preview);
    } catch (e) {
      setState(() { _state = AppState.error; _errorMsg = e.toString(); });
    }
  }

  Future<void> _loadPreviewData(Map<String, dynamic> stats) async {
    _stats = stats;
    final db = AppDatabase.instance;
    final results = await db.select(db.results).get();
    final mainDatas = await db.select(db.mainDatas).get();
    final dataMap = {for (final d in mainDatas) d.id: d};

    _invalidCount = results.where((r) => r.calculateStatus != 'valid').length;
    final bonusResults = results.where((r) => r.bonus1 > 0 || r.bonus2 > 0 || r.bonus3 > 0).toList()
      ..sort((a, b) => (b.bonus1 + b.bonus2 + b.bonus3).compareTo(a.bonus1 + a.bonus2 + a.bonus3));

    _topResults = bonusResults.take(20).map((r) {
      final d = dataMap[r.mainDataId];
      return {'customer': d?.customerCode ?? '', 'doc': d?.documentNumber ?? '',
        'bonus_1': r.bonus1, 'bonus_2': r.bonus2, 'bonus_3': r.bonus3};
    }).toList();

    _stats['bonus_1'] = results.fold<int>(0, (s, r) => s + r.bonus1);
    _stats['bonus_2'] = results.fold<int>(0, (s, r) => s + r.bonus2);
    _stats['bonus_3'] = results.fold<int>(0, (s, r) => s + r.bonus3);
  }

  Future<void> _export() async {
    final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Xuất kết quả', fileName: 'result.xlsx',
        type: FileType.custom, allowedExtensions: ['xlsx']);
    if (path == null) return;
    setState(() => _state = AppState.processing);
    try {
      await _exportService.exportToExcel(path, _log);
      setState(() { _state = AppState.exported; _exportedPath = path; });
    } catch (e) {
      setState(() { _state = AppState.error; _errorMsg = e.toString(); });
    }
  }

  void _reset() => setState(() {
    _state = AppState.initial; _logs.clear(); _stats = {};
    _topResults = []; _invalidCount = 0; _errorMsg = '';
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Matching'), centerTitle: true,
        actions: [IconButton(
          icon: Icon(widget.themeProvider.mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
          onPressed: widget.themeProvider.toggle, tooltip: 'Đổi theme',
        )],
      ),
      body: Row(children: [
        Expanded(flex: 3, child: _buildMainContent()),
        Expanded(flex: 2, child: ConsolePanel(logs: _logs, scrollController: _scrollController)),
      ]),
    );
  }

  Widget _buildMainContent() => switch (_state) {
    AppState.initial => buildInitialView(context, _processFile),
    AppState.processing => buildProcessingView(),
    AppState.preview => PreviewPanel(stats: _stats, topResults: _topResults,
        invalidCount: _invalidCount, onExport: _export, onReset: _reset),
    AppState.exported => buildExportedView(_exportedPath, _reset),
    AppState.error => buildErrorView(_errorMsg, _reset),
  };
}

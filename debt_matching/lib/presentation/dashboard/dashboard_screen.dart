import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../../core/theme/theme_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/services/import_service.dart';
import '../../data/services/calculate_service.dart';
import '../../data/services/export_service.dart';
import 'widgets/console_panel.dart';
import 'widgets/preview_panel.dart';
import 'widgets/run_selector.dart';
import 'dashboard_state_views.dart';
import 'preview_loader.dart';

enum AppState { initial, processing, preview, exported, error }

class DashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const DashboardScreen({super.key, required this.themeProvider});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _import = ImportService();
  final _calc = CalculateService();
  final _export = ExportService();
  final List<String> _logs = [];
  final _scroll = ScrollController();

  AppState _state = AppState.initial;
  String _errorMsg = '', _exportedPath = '';
  String? _currentRunId;
  List<RunHistory> _runs = [];
  PreviewData _preview = PreviewData(stats: {}, topResults: [], invalidCount: 0);

  @override
  void initState() { super.initState(); _loadRuns(); }

  Future<void> _loadRuns() async {
    final db = AppDatabase.instance;
    final runs = await (db.select(db.runHistories)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();
    setState(() {
      _runs = runs;
      if (runs.isNotEmpty && _currentRunId == null) { _currentRunId = runs.first.id; }
    });
  }

  void _log(String msg) {
    setState(() => _logs.add('[${TimeOfDay.now().format(context)}] $msg'));
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _processFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
    if (result == null) return;
    setState(() { _state = AppState.processing; _logs.clear(); });
    try {
      final ir = await _import.importFromExcel(result.files.single.path!, _log);
      final runId = ir['runId'] as String;
      final stats = await _calc.calculate(runId, _log, (_) {});
      _currentRunId = runId;
      _preview = await loadPreviewData(runId, stats);
      await _loadRuns();
      setState(() => _state = AppState.preview);
    } catch (e) {
      setState(() { _state = AppState.error; _errorMsg = e.toString(); });
    }
  }

  Future<void> _selectRun(String runId) async {
    _currentRunId = runId;
    final run = _runs.firstWhere((r) => r.id == runId);
    if (run.status == 'completed') {
      _preview = await loadPreviewData(runId, null);
      setState(() => _state = AppState.preview);
    } else {
      setState(() => _state = AppState.initial);
    }
  }

  Future<void> _exportRun() async {
    if (_currentRunId == null) return;
    final path = await FilePicker.platform.saveFile(dialogTitle: 'Xuất kết quả', fileName: 'result.xlsx',
        type: FileType.custom, allowedExtensions: ['xlsx']);
    if (path == null) return;
    setState(() => _state = AppState.processing);
    try {
      await _export.exportToExcel(_currentRunId!, path, _log);
      setState(() { _state = AppState.exported; _exportedPath = path; });
    } catch (e) {
      setState(() { _state = AppState.error; _errorMsg = e.toString(); });
    }
  }

  Future<void> _deleteRun(String runId) async {
    await _export.deleteRun(runId);
    _currentRunId = null;
    await _loadRuns();
    setState(() => _state = AppState.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debt Matching'), centerTitle: true, actions: [
        IconButton(icon: Icon(widget.themeProvider.mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.themeProvider.toggle, tooltip: 'Đổi theme'),
      ]),
      body: Column(children: [
        RunSelector(runs: _runs, selectedRunId: _currentRunId, onSelect: _selectRun, onDelete: _deleteRun),
        Expanded(child: Row(children: [
          Expanded(flex: 3, child: _buildMain()),
          Expanded(flex: 2, child: ConsolePanel(logs: _logs, scrollController: _scroll)),
        ])),
      ]),
    );
  }

  Widget _buildMain() => switch (_state) {
    AppState.initial => buildInitialView(context, _processFile),
    AppState.processing => buildProcessingView(),
    AppState.preview => PreviewPanel(stats: _preview.stats, topResults: _preview.topResults,
        invalidCount: _preview.invalidCount, onExport: _exportRun, onReset: _processFile),
    AppState.exported => buildExportedView(_exportedPath, () => setState(() => _state = AppState.preview)),
    AppState.error => buildErrorView(_errorMsg, () => setState(() => _state = AppState.initial)),
  };
}

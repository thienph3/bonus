import 'package:flutter/material.dart';

class ConsolePanel extends StatefulWidget {
  final List<String> logs;
  final ScrollController scrollController;

  const ConsolePanel({super.key, required this.logs, required this.scrollController});

  @override
  State<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _buildBar(),
      if (_expanded) SizedBox(height: MediaQuery.of(context).size.height * 0.2, child: _buildLogList()),
    ]);
  }

  Widget _buildBar() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(children: [
          Icon(_expanded ? Icons.expand_more : Icons.expand_less, size: 16),
          const SizedBox(width: 8),
          Text('Console (${widget.logs.length})', style: Theme.of(context).textTheme.labelSmall),
          const Spacer(),
          if (widget.logs.isNotEmpty) Flexible(
            child: Text(widget.logs.last, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }

  Widget _buildLogList() {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: widget.logs.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(widget.logs[i], style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
      ),
    );
  }
}

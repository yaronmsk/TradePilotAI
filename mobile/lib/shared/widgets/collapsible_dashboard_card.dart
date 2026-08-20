import 'package:flutter/material.dart';

class CollapsibleDashboardCard extends StatefulWidget {
  const CollapsibleDashboardCard({
    required this.title,
    required this.child,
    this.collapsedSummary,
    this.actions = const [],
    this.initiallyExpanded = true,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? collapsedSummary;
  final List<Widget> actions;
  final bool initiallyExpanded;

  @override
  State<CollapsibleDashboardCard> createState() =>
      _CollapsibleDashboardCardState();
}

class _CollapsibleDashboardCardState extends State<CollapsibleDashboardCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!_isExpanded &&
                            widget.collapsedSummary != null) ...[
                          const SizedBox(width: 12),
                          Flexible(child: widget.collapsedSummary!),
                        ],
                      ],
                    ),
                  ),
                  ...widget.actions,
                  IconButton(
                    tooltip: _isExpanded ? 'Collapse' : 'Expand',
                    onPressed: _toggleExpanded,
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.expand_more),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: widget.child,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

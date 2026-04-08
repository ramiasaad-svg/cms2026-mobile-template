import 'package:flutter/material.dart';

/// Provides tablet (>600px) and phone layouts.
class ResponsiveLayout extends StatelessWidget {
  final Widget phoneLayout;
  final Widget tabletLayout;
  static const tabletBreakpoint = 600.0;

  const ResponsiveLayout({super.key, required this.phoneLayout, required this.tabletLayout});

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= tabletBreakpoint) return tabletLayout;
      return phoneLayout;
    });
  }
}

/// Tablet shell: persistent side navigation + content area.
class TabletShell extends StatelessWidget {
  final Widget sideNav;
  final Widget content;

  const TabletShell({super.key, required this.sideNav, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 280, child: sideNav),
        const VerticalDivider(width: 1),
        Expanded(child: content),
      ],
    );
  }
}

/// Two-column master-detail for tablet list screens.
class MasterDetailLayout extends StatefulWidget {
  final Widget masterList;
  final Widget Function(int id)? detailBuilder;
  final Widget emptyDetail;

  const MasterDetailLayout({super.key, required this.masterList, this.detailBuilder, required this.emptyDetail});

  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: widget.masterList),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _selectedId != null && widget.detailBuilder != null
          ? widget.detailBuilder!(_selectedId!)
          : widget.emptyDetail),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';

class TimelineViewLayout {
  final bool isCompact;
  final bool showSidebar;
  final bool overlaySidebar;
  
  const TimelineViewLayout({required this.isCompact, required this.showSidebar, required this.overlaySidebar});

  factory TimelineViewLayout.resolve(BuildContext context, {required bool overlayRequested}) {
    final isCompact = MediaQuery.sizeOf(context).width < TimelineConstants.compactBreakpoint;
    final showSidebar = !isCompact;
    return TimelineViewLayout(isCompact: isCompact, showSidebar: showSidebar, overlaySidebar: showSidebar && overlayRequested);
  }
}
import 'package:flutter/material.dart';

import 'history_list.dart';

class HistoryBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 1,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => HistoryList(
        showHandle: true,
        controller: scrollController,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pop the current route if possible, otherwise navigate to [fallbackPath].
///
/// Needed because routes reached via `context.go(...)` replace the
/// navigation stack, leaving nothing for a back button to pop.
void popOrGo(BuildContext context, String fallbackPath) {
  if (GoRouter.of(context).canPop()) {
    context.pop();
  } else {
    context.go(fallbackPath);
  }
}

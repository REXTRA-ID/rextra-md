import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

void popOrGo(BuildContext context, String fallbackPath) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    context.pop();
  } else {
    context.go(fallbackPath);
  }
}

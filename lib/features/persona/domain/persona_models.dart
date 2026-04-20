import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum PersonaType { pathfinder, builder, achiever }

class Mission {
  final String title;
  final String iconAsset;
  final int point;
  final bool done;
  final VoidCallback? onTap;

  const Mission({
    required this.title,
    required this.iconAsset,
    required this.point,
    this.done = false,
    this.onTap,
  });
}

PersonaType resolvePersona({
  required bool tujuan,
  required bool porto,
  required bool rekrut,
}) {
  if (!tujuan) return PersonaType.pathfinder;
  if (!porto) return PersonaType.builder;
  if (!rekrut) return PersonaType.builder;
  return PersonaType.achiever;
}
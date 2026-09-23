import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum PersonaType { pathfinder, builder, achiever }

class Mission {
  final String title;
  final String iconAsset;
  final String imageAsset;
  final int point;
  final bool done;
  final bool isMandatory;
  final String description;
  final VoidCallback? onTap;

  const Mission({
    required this.title,
    required this.iconAsset,
    required this.imageAsset,
    required this.point,
    this.done = false,
    this.isMandatory = true,
    this.description = '',
    this.onTap,
  });

  Mission copyWith({bool? done}) => Mission(
        title: title,
        iconAsset: iconAsset,
        imageAsset: imageAsset,
        point: point,
        done: done ?? this.done,
        isMandatory: isMandatory,
        description: description,
        onTap: onTap,
      );
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

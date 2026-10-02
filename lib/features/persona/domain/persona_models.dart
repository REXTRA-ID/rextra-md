import 'package:flutter/material.dart';

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

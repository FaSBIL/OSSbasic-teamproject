import 'package:flutter/material.dart';
import 'package:shelter/theme/color.dart';

enum SheetMode { list, detail }

class ShelterBottomSheet extends StatelessWidget {
  final Widget child;
  final SheetMode mode;

  const ShelterBottomSheet({
    super.key,
    required this.child,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final initialSize = mode == SheetMode.list ? 0.5 : 0.4;
    final snapSizes = mode == SheetMode.list
        ? [0.085, 0.5, 0.95]
        : [0.085, 0.4, 0.95];

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.085,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                spreadRadius: 3,
                color: AppColors.black.withOpacity(0.07),
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 5),
                child: Container(
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(top:25, bottom:30),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
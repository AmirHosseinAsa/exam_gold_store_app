import 'package:flutter/material.dart';
import '../utils/constants.dart';

class WidgetCustomAppbar extends StatelessWidget {
  const WidgetCustomAppbar({
    super.key,
    required this.isLoading,
    required this.doWhenPressed,
    required this.appBarTitle,
    required this.showIcon,
  });
  final bool isLoading;
  final Function() doWhenPressed;
  final String appBarTitle;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cCardBackground,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          SizedBox(width: 45),
          Text(
            appBarTitle,
            style: TextStyle(
              color: cTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 40,
            height: 40,
            child: showIcon
                ? IconButton(
                    icon: const Icon(Icons.refresh, color: cTextPrimary),
                    onPressed: isLoading ? null : doWhenPressed,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

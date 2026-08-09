import 'package:flutter/material.dart';
import '../theme/themedata.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String value;
  final String? subtitle;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.tileInner,
      decoration: AppDecorations.summaryCard(gradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: AppDecorations.summaryIcon(),
                child: Icon(icon, size: 19, color: Colors.white),
              ),
              AppPadding.space8,
              Expanded(
                child: Text(title, style: AppTextStyles.summaryTitle),
              ),
            ],
          ),
          AppPadding.space12,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.summaryValue,
          ),
          if (subtitle != null) ...[
            AppPadding.space6,
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.summarySubtitle,
            ),
          ],
        ],
      ),
    );
  }
}

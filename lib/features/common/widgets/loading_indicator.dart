import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 36.0,
    this.strokeWidth = 4.0,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? Theme.of(context).primaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (!isOverlay) {
      return Center(child: indicator);
    }

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(child: indicator),
    );
  }
}

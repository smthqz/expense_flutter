import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MyPercentIndicatorGoal extends StatelessWidget {
  final double goalAmount;
  final double savedAmount;

  const MyPercentIndicatorGoal({
    Key? key,
    required this.goalAmount,
    required this.savedAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percent;

    if (savedAmount >= goalAmount) {
      percent = 1.0; // Если накоплена сумма больше или равна цели, устанавливаем 100%
    } else {
      percent = savedAmount / goalAmount;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: LinearPercentIndicator(
            width: constraints.maxWidth,
            lineHeight: 16,
            percent: percent,
            animation: true,
            animateFromLastPercent: true,
            backgroundColor: Color(0xFFD9D9D9)!,
            progressColor: const Color(0xFF3CB96A),
            barRadius: const Radius.circular(12),
          ),
        );
      },
    );
  }
}

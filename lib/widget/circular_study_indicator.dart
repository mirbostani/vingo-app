import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vingo/util/util.dart' as Vingo;

class CircularStudyIndicator extends StatelessWidget {
  final double width;
  final double height;
  final int totalCardsCount;
  final int newCardsCount;
  final int learningCardsCount;
  final int reviewCardsCount;

  const CircularStudyIndicator({
    Key? key,
    required this.width,
    required this.height,
    required this.totalCardsCount,
    required this.newCardsCount,
    required this.learningCardsCount,
    required this.reviewCardsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      child: Stack(
        children: [
          CircularProgressIndicator(
            strokeWidth: 3.0,
            backgroundColor:
                Vingo.ThemeUtil.of(context).statTotalColor.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(
              Vingo.ThemeUtil.of(context).statNewColor,
            ),
            value: totalCardsCount == 0
                ? 0
                : (newCardsCount / totalCardsCount) - 0.01,
          ),
          RotationTransition(
            turns: AlwaysStoppedAnimation(
                totalCardsCount == 0 ? 0 : newCardsCount / totalCardsCount),
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              backgroundColor:
                  Vingo.ThemeUtil.of(context).statTotalColor.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                Vingo.ThemeUtil.of(context).statLearningColor,
              ),
              value: totalCardsCount == 0
                  ? 0
                  : (learningCardsCount / totalCardsCount) - 0.01,
            ),
          ),
          RotationTransition(
            turns: AlwaysStoppedAnimation(totalCardsCount == 0
                ? 0
                : (newCardsCount / totalCardsCount) +
                    (learningCardsCount / totalCardsCount)),
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              backgroundColor:
                  Vingo.ThemeUtil.of(context).statTotalColor.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                Vingo.ThemeUtil.of(context).statReviewColor,
              ),
              value: totalCardsCount == 0
                  ? 0
                  : (reviewCardsCount / totalCardsCount) - 0.01,
            ),
          )
        ],
      ),
    );
  }
}

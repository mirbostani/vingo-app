import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:vingo/util/util.dart' as Vingo;

class MultipleFabButton extends StatefulWidget {
  final List<MultipleFabButtonChild> children;

  MultipleFabButton({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  _MultipleFabButtonState createState() => _MultipleFabButtonState();
}

class _MultipleFabButtonState extends State<MultipleFabButton>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  late AnimationController animationController;
  late Animation<double> translateButton;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });

    translateButton = Tween<double>(
      begin: Vingo.ThemeUtil.fabButtonHeight,
      end: -16.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: Curves.easeOut,
      ),
    ));

    opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: Curves.easeOut,
      ),
    ));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (!isOpened) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: ColorTween(
          begin: Vingo.ThemeUtil.of(context).fabBackgroundColor,
          end: Vingo.ThemeUtil.of(context).fabSecondaryBackgroundColor,
        )
            .animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval(
                  0.0,
                  1.0,
                  curve: Curves.linear,
                ),
              ),
            )
            .value,
        onPressed: animate,
        // tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          size: Vingo.ThemeUtil.fabIconSize,
          progress:
              Tween<double>(begin: 0.0, end: 1.0).animate(animationController),
          color: Vingo.ThemeUtil.of(context).fabSecondaryIconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...List<Widget>.generate(
          widget.children.length,
          (index) => Transform(
            transform: Matrix4.translationValues(
              0.0,
              translateButton.value * (widget.children.length - index),
              0.0,
            ),
            child: Opacity(
              opacity: opacity.value,
              child: widget.children[index],
            ),
          ),
        ),
        toggle(),
      ],
    );
  }
}

class MultipleFabButtonChild extends StatelessWidget {
  final IconData icon;
  final double scale;
  final String? title;
  final String? tooltip;
  final void Function() onPressed;

  const MultipleFabButtonChild({
    Key? key,
    required this.icon,
    required this.scale,
    this.title,
    this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            // There can't be multiple FAB on one route page. We have to set
            // different heroTag in order to achieve having multiple FABs.
            // heroTag: Uuid().v4(),
            heroTag: null, // or set null
            onPressed: onPressed,
            tooltip: tooltip,
            backgroundColor: Vingo.ThemeUtil.of(context).fabBackgroundColor,
            child: Icon(
              icon,
              color: Vingo.ThemeUtil.of(context).fabIconColor,
              size: Vingo.ThemeUtil.fabIconSizeSmall,
            ),
          ),
          if (title != null)
            Positioned(
              bottom: 0.5 *
                  (Vingo.ThemeUtil.fabButtonHeight -
                      Vingo.ThemeUtil.fabIconSize),
              right: Vingo.LocalizationsUtil.isLtr(context)
                  ? Vingo.ThemeUtil.fabButtonHeight + Vingo.ThemeUtil.padding
                  : null,
              left: Vingo.LocalizationsUtil.isLtr(context)
                  ? null
                  : Vingo.ThemeUtil.fabButtonHeight + Vingo.ThemeUtil.padding,
              child: Container(
                height: Vingo.ThemeUtil.fabIconSize,
                padding: EdgeInsets.only(
                  top: Vingo.ThemeUtil.paddingQuarter,
                  bottom: Vingo.ThemeUtil.paddingQuarter,
                  left: Vingo.ThemeUtil.paddingHalf,
                  right: Vingo.ThemeUtil.paddingHalf,
                ),
                decoration: BoxDecoration(
                  color: Vingo.ThemeUtil.of(context).formBackgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(Vingo.ThemeUtil.borderRadiusQuarter),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(title!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

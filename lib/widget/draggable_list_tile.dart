import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vingo/util/util.dart' as Vingo;

class DraggableListTile extends StatefulWidget {
  final Widget title;
  final Color? tileColor;
  final Color? moreButtonColor;
  final int? level;
  final Widget? leadingIcon;
  final bool? showDraggable;
  final bool? enableDraggable;
  final void Function(Key key)? onTap;
  final void Function(Key key)? onMorePressed;
  final void Function(Key key)? onDragStarted;
  final void Function(Key key)? onDragEnded;
  final void Function(Key key)? onDragCanceled;
  final void Function(Key key)? onDragTargetMoveUp;
  final void Function(Key key)? onDragTargetMoveDown;
  final void Function(Key draggableKey, Key dragTargetKey)?
      onDragTargetAcceptChild;

  DraggableListTile({
    required Key key,
    required this.title,
    this.leadingIcon,
    this.level = 0,
    this.tileColor,
    this.moreButtonColor,
    this.showDraggable = true,
    this.enableDraggable = true,
    this.onTap,
    this.onMorePressed,
    this.onDragStarted,
    this.onDragEnded,
    this.onDragCanceled,
    this.onDragTargetMoveUp,
    this.onDragTargetMoveDown,
    this.onDragTargetAcceptChild,
  }) : super(key: key);

  @override
  _DraggableListTileState createState() => _DraggableListTileState();
}

class _DraggableListTileState extends State<DraggableListTile> {
  bool _dragTargetHovered = false;
  double? _dragTargetInitialOffset;

  @override
  Widget build(BuildContext context) {
    double padding = 16.0;
    double height = 48.0;
    double dragDelta = 16.0;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget draggable = ListTile(
          contentPadding: EdgeInsets.only(
            right: padding,
            left: padding * (1 + widget.level!),
          ),
          tileColor: widget.tileColor,
          horizontalTitleGap: 0.0,
          leading: widget.leadingIcon,
          title: widget.title,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.more_horiz),
                iconSize: Vingo.ThemeUtil.iconSizeSmall,
                splashRadius: Vingo.ThemeUtil.iconSizeSmallSplashRadius,
                // tooltip: Vingo.LocalizationsUtil.of(context).more,
                color: widget.moreButtonColor,
                hoverColor: Colors.transparent,
                onPressed: () {
                  widget.onMorePressed?.call(widget.key!);
                },
              ),
            ],
          ),
          onTap: () {
            widget.onTap?.call(widget.key!);
          },
        );
        Widget draggableFeedback = ListTile(
          contentPadding: EdgeInsets.only(
            right: padding,
            left: padding * (1 + widget.level!),
          ),
          // tileColor: Colors.grey.shade300, // color
          horizontalTitleGap: 0.0,
          leading: widget.leadingIcon,
          title: widget.title,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.drag_indicator),
                iconSize: Vingo.ThemeUtil.iconSizeSmall,
                splashRadius: Vingo.ThemeUtil.iconSizeSmallSplashRadius,
                // tooltip: Vingo.LocalizationsUtil.of(context).more,
                color: widget.moreButtonColor,
                hoverColor: Colors.transparent,
                onPressed: () {
                  // widget.onMorePressed?.call(_key as Key);
                },
              ),
            ],
          ),
        );
        Widget childWhenDragging = Container(
          width: constraints.maxWidth,
          height: height,
          color: Colors.black.withAlpha(100), // color
        );
        return Stack(
          children: [
            //------------------------------------------------------------------
            // Item working as a draggable
            Positioned(
              child: Container(
                width: constraints.maxWidth,
                height: height,
                child: Draggable(
                  maxSimultaneousDrags: widget.enableDraggable == true ? 1 : 0,
                  axis: Axis.vertical,
                  affinity: Axis.vertical,
                  child: Container(
                    height: height,
                    child: widget.showDraggable == true
                        ? draggable
                        : childWhenDragging,
                  ),
                  feedback: SizedBox(
                    width: constraints.maxWidth,
                    // height: constraints.maxHeight,
                    child: Material(
                      child: Container(
                        height: height,
                        child: draggableFeedback,
                      ),
                    ),
                  ),
                  childWhenDragging: childWhenDragging,
                  onDragStarted: () {
                    widget.onDragStarted?.call(widget.key!);
                  },
                  onDragUpdate: (DragUpdateDetails details) {},
                  onDraggableCanceled: (velocity, offset) {
                    _dragTargetHovered = false;
                    _dragTargetInitialOffset = null;
                    widget.onDragCanceled?.call(widget.key!);
                  },
                  onDragEnd: (DraggableDetails details) {
                    _dragTargetHovered = false;
                    _dragTargetInitialOffset = null;
                    widget.onDragEnded?.call(widget.key!);
                  },
                  data: {
                    "key": widget.key,
                    "title": widget.title,
                  },
                ),
              ),
            ),
            //------------------------------------------------------------------
            // // Touch area excluding handlebar
            // Positioned(
            //   child: Listener(
            //     onPointerDown: (event) {},
            //     child: InkWell(
            //       onTap: () {
            //         widget.onTap?.call(_key as Key);
            //       },
            //       child: Container(
            //         width: constraints.maxWidth -
            //             3 * Vingo.ThemeUtil.paddingDouble,
            //         height: height,
            //         color: Colors.red.withAlpha(100),
            //       ),
            //     ),
            //   ),
            // ),
            //------------------------------------------------------------------
            // Item working as a drag target
            Positioned(
              child: Container(
                width: constraints.maxWidth,
                height: height,
                // color: Colors.red,
                child: DragTarget(
                  builder: (BuildContext context, List<Object?> candidateData,
                      List<dynamic> rejectedData) {
                    return Container();
                  },
                  onWillAccept: (data) {
                    _dragTargetHovered = true;
                    var target = {
                      "key": widget.key,
                      "title": widget.title,
                    };
                    return true;
                  },
                  onAcceptWithDetails: (DragTargetDetails<Object> details) {},
                  onAccept: (data) {
                    _dragTargetHovered = false;
                    _dragTargetInitialOffset = null;
                    var target = {
                      "key": widget.key,
                      "title": widget.title,
                    };
                    widget.onDragTargetAcceptChild?.call(
                      (data as Map<String, Object?>)["key"] as Key,
                      target["key"] as Key,
                    );
                  },
                  onMove: (details) {
                    _dragTargetHovered = true;
                    if (_dragTargetInitialOffset == null) {
                      _dragTargetInitialOffset = details.offset.dy;
                    }
                    double delta =
                        details.offset.dy - _dragTargetInitialOffset!;
                    // upward draggable, moving drag target down
                    if (delta < -(height - dragDelta)) {
                      _dragTargetHovered = false;
                      widget.onDragTargetMoveDown?.call(widget.key!);
                    }
                    // downward draggable, moving drag target up
                    else if (delta > (height - dragDelta)) {
                      _dragTargetHovered = false;
                      widget.onDragTargetMoveUp?.call(widget.key!);
                    }
                  },
                  onLeave: (data) {
                    _dragTargetHovered = false;
                    _dragTargetInitialOffset = null;
                  },
                ),
              ),
            ),
            //------------------------------------------------------------------
          ],
        );
      },
    );
  }
}

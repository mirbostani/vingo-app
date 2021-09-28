import 'dart:io' as IO;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:vingo/util/util.dart' as Vingo;

class ImageExtended extends StatefulWidget {
  final String url;
  final double? width;
  final bool isBlock;
  final bool invert;
  final double radius;
  final EdgeInsetsGeometry padding;

  const ImageExtended({
    Key? key,
    required this.url,
    this.width,
    this.isBlock = true,
    this.invert = false,
    this.radius = Vingo.ThemeUtil.borderRadiusHalf,
    this.padding = const EdgeInsets.all(0.0),
  }) : super(key: key);

  @override
  _ImageExtendedState createState() => _ImageExtendedState();
}

class _ImageExtendedState extends State<ImageExtended> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> parseUrl() async {
    return widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: parseUrl(), // returns `Future<String>` type
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          if (widget.isBlock) {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                // strokeWidth: 2.0,
                backgroundColor: Vingo.ThemeUtil.of(context)
                    .progressIndicatorBackgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Vingo.ThemeUtil.of(context).progressIndicatorValueColor,
                ),
                value: null,
              ),
            );
          } else {
            return SizedBox(
              height: Vingo.ThemeUtil.textFontSizeSmall,
              width: Vingo.ThemeUtil.textFontSizeSmall,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                backgroundColor: Vingo.ThemeUtil.of(context)
                    .progressIndicatorBackgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Vingo.ThemeUtil.of(context).progressIndicatorValueColor,
                ),
                value: null,
              ),
            );
          }
        }

        Vingo.PlatformUtil.log("Loading image: ${snapshot.data}");

        Widget image;
        try {
          image = Image.network(
            snapshot.data!,
            width: widget.width,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Vingo.ThemeUtil.of(context)
                        .progressIndicatorBackgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Vingo.ThemeUtil.of(context).progressIndicatorValueColor,
                    ),
                    value: loadingProgress.expectedTotalBytes != null
                        ? (loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!)
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Vingo.ThemeUtil.of(context).textMutedColor,
                  ),
                ),
              );
            },
          );

          // Widget image = Image.file(
          //   IO.File(snapshot.data!),
          //   width: widget.width,
          // );

          if (widget.invert) {
            image = ColorFiltered(
              colorFilter: ColorFilter.matrix([
                // R, G, B, A
                -1, 0, 0, 0, 255,
                0, -1, 0, 0, 255,
                0, 0, -1, 0, 255,
                0, 0, 0, 1, 0,
              ]),
              child: image,
            );
          }
        } catch (e) {
          Vingo.PlatformUtil.log("Loading image failed: ${snapshot.data}");
          image = Container(
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Vingo.ThemeUtil.of(context).textMutedColor,
              ),
            ),
          );
        }

        if (widget.isBlock) {
          return Container(
            padding: widget.padding,
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(widget.radius),
              child: image,
            ),
          );
        } else {
          return ClipRRect(
            borderRadius: new BorderRadius.circular(widget.radius),
            child: image,
          );
        }
      },
    );
  }
}

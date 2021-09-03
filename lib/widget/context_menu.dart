import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vingo/util/util.dart' as Vingo;

/// Create a context menu with items.
/// 
/// ```dart
/// var result = await Vingo.ContextMenu.show(
///   context: context,
///   title: "My Deck",
///   items: [
///     Vingo.ContextMenuItem(
///       key: Key("rename"),
///       title: "Rename",
///       onTap: () {
///         rename();
///       },
///     ),
///     Vingo.ContextMenuItem(
///       key: Key("delete"),
///       title: "Delete",
///       onTap: () {
///         delete();
///       },
///     ),
///   ]
/// );
/// switch (result) {
///   case "rename":
///     rename();
///     break;
///   case "delete":
///     delete();
///     break;
/// }
/// ```
class ContextMenu extends StatelessWidget {
  final String title;
  final List<ContextMenuItem> items;

  const ContextMenu({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(
        Vingo.ThemeUtil.borderRadius,
      ))),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Vingo.ThemeUtil.textFontSizeMedium,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: List<SimpleDialogOption>.generate(
        items.length,
        (index) => SimpleDialogOption(
          child: items[index], // ContextMenuItem
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  static Future<String?> show({
    Key? key,
    required BuildContext context,
    required String title,
    required List<ContextMenuItem> items,
  }) async {
    return await showDialog<String?>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ContextMenu(
            key: key,
            title: title,
            items: items,
          );
        });
  }
}

////////////////////////////////////////////////////////////////////////////////

class ContextMenuItem extends StatelessWidget {
  final String title;
  final Icon? icon;
  final VoidCallback? onTap;

  const ContextMenuItem({
    Key? key,
    required this.title,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title),
      contentPadding: EdgeInsets.only(
        left: Vingo.ThemeUtil.paddingDouble,
        right: Vingo.ThemeUtil.paddingDouble,
      ),
      onTap: () {
        Navigator.of(context).pop((key as ValueKey).value); // call before onTap
        onTap?.call();
      },
    );
  }
}

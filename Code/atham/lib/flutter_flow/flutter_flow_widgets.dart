// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:auto_size_text/auto_size_text.dart';

// class FFButtonOptions {
//   final TextStyle textStyle;
//   final double elevation;
//   final double height;
//   final double width;
//   final EdgeInsetsGeometry padding;
//   final Color color;
//   final Color disabledColor;
//   final Color disabledTextColor;
//   final Color splashColor;
//   final double iconSize;
//   final Color iconColor;
//   final EdgeInsetsGeometry iconPadding;
//   final double borderRadius;
//   final BorderSide borderSide;

//   const FFButtonOptions({
//     required this.textStyle,
//     required this.elevation,
//     required this.height,
//     required this.width,
//     required this.padding,
//     required this.color,
//     required this.disabledColor,
//     required this.disabledTextColor,
//     required this.splashColor,
//     required this.iconSize,
//     required this.iconColor,
//     required this.iconPadding,
//     required this.borderRadius,
//     required this.borderSide,
//   });
// }

// class FFButtonWidget extends StatefulWidget {

//   FFButtonWidget(
//     {
//     Key? key,
//     required this.text,
//     required this.onPressed,
//     required this.icon,
//     //required this.iconData,
//     //required this.options,
//     this.showLoadingIndicator = true,})
//      : super(key: key);

//   final String text;
//   Widget? icon;
//   IconData? iconData;
//   final Function() onPressed;
//   FFButtonOptions options;
//   final bool showLoadingIndicator;

//   @override
//   State<FFButtonWidget> createState() => _FFButtonWidgetState();
// }

// class _FFButtonWidgetState extends State<FFButtonWidget> {
//   bool loading = false;

//   @override
//   Widget build(BuildContext context) {
//     Widget textWidget = loading
//         ? Center(
//             child: Container(
//               width: 23,
//               height: 23,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   widget.options.textStyle.color ?? Colors.white,
//                 ),
//               ),
//             ),
//           )
//         : AutoSizeText(
//             widget.text,
//             style: widget.options.textStyle,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           );

//     final onPressed = widget.showLoadingIndicator
//         ? () async {
//             if (loading) {
//               return;
//             }
//             setState(() => loading = true);
//             try {
//               await widget.onPressed();
//             } finally {
//               if (mounted) {
//                 setState(() => loading = false);
//               }
//             }
//           }
//         : () => widget.onPressed();

//     ButtonStyle style = ButtonStyle(
//       shape: MaterialStateProperty.all<OutlinedBorder>(
//         RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(widget.options.borderRadius ?? 8.0),
//           side: widget.options.borderSide ?? BorderSide.none,
//         ),
//       ),
//       foregroundColor: MaterialStateProperty.resolveWith<Color>(
//         (states) {
//           if (states.contains(MaterialState.disabled)) {
//             return widget.options.disabledTextColor;
//           }
//           return widget.options.textStyle.color!;
//         },
//       ),
//       backgroundColor: MaterialStateProperty.resolveWith<Color>(
//         (states) {
//           if (states.contains(MaterialState.disabled)) {
//             return widget.options.disabledColor;
//           }
//           return widget.options.color;
//         },
//       ),
//       overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
//         if (states.contains(MaterialState.pressed)) {
//           return widget.options.splashColor;
//         }
//         return Colors.red;
//       }),
//       padding: MaterialStateProperty.all(widget.options.padding ??
//           const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)),
//       elevation:
//           MaterialStateProperty.all<double>(widget.options.elevation ?? 2.0),
//     );

//     if (widget.icon != null || widget.iconData != null) {
//       return Container(
//         height: widget.options.height,
//         width: widget.options.width,
//         child: ElevatedButton.icon(
//           icon: Padding(
//             padding: widget.options.iconPadding ?? EdgeInsets.zero,
//             child: widget.icon ??
//                 FaIcon(
//                   widget.iconData,
//                   size: widget.options.iconSize,
//                   color: widget.options.iconColor ??
//                       widget.options.textStyle.color,
//                 ),
//           ),
//           label: textWidget,
//           onPressed: onPressed,
//           style: style,
//         ),
//       );
//     }

//     return Container(
//       height: widget.options.height,
//       width: widget.options.width,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: style,
//         child: textWidget,
//       ),
//     );
//   }
// }

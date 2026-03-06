import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 2,
    this.expandLabel = 'selengkapnya',
    this.collapseLabel = 'ringkas',
    this.toggleStyle,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final String expandLabel;
  final String collapseLabel;
  final TextStyle? toggleStyle;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool hasOverflow = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: widget.style,
              maxLines: _expanded ? null : widget.maxLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (hasOverflow || _expanded)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _expanded ? widget.collapseLabel : widget.expandLabel,
                    style:
                        widget.toggleStyle ??
                        const TextStyle(
                          color: Color(0xFFFF6A2D),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

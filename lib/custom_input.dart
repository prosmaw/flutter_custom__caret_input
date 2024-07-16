import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({super.key});

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput>
    with TickerProviderStateMixin {
  TextEditingController inputController = TextEditingController();
  bool isDone = false;
  bool isMax = false;
  FocusNode focusNode = FocusNode();
  Offset _caretOffset = Offset.zero;
  GlobalKey caretkey = GlobalKey();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_updateCaretPosition);
    inputController.addListener(_updateCaretPosition);
  }

  @override
  void dispose() {
    super.dispose();
    inputController.dispose();
    focusNode.dispose();
  }

  void _updateCaretPosition() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (focusNode.hasFocus) {
        final textPosition = inputController.selection.baseOffset;
        if (textPosition == -1) return;
        //use of text painter to get the caret position
        final textPainter = TextPainter(
          text: TextSpan(
            text: inputController.text,
            style: const TextStyle(fontSize: 18),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final caretOffset = textPainter.getOffsetForCaret(
          TextPosition(offset: textPosition),
          Rect.zero,
        );

        setState(() {
          _caretOffset = caretOffset;
        });
        if (inputController.text.length == 10) {
          setState(() {
            isMax = true;
          });
          Future.delayed(
              const Duration(seconds: 1),
              () => setState(() {
                    isDone = true;
                  }));
        } else {
          setState(() {
            isMax = false;
            isDone = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, bottom: 5),
              child: const Text(
                "Username",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            Stack(
              children: [
                TextField(
                  controller: inputController,
                  showCursor: false,
                  focusNode: focusNode,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  maxLength: 10,
                  cursorHeight: 20,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (focusNode.hasFocus)
                  TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 1),
                      tween: Tween<double>(
                          begin: (_caretOffset.dx + 12),
                          end: isMax ? width - 82 : (_caretOffset.dx + 12)),
                      builder: (context, caretPos, child) {
                        return Positioned(
                          key: caretkey,
                          left: !isMax ? (_caretOffset.dx + 12) : caretPos,
                          top: _caretOffset.dy +
                              20, //caret pos + textfield content padding
                          child: TweenAnimationBuilder(
                              tween:
                                  Tween<double>(begin: 5, end: isMax ? 20 : 5),
                              duration: const Duration(seconds: 1),
                              builder: (context, caretWidth, child) {
                                return Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    height: 20,
                                    width: !isMax ? 5 : caretWidth,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                          height: (inputController.text.length *
                                                  20) /
                                              10,
                                          width: !isMax
                                              ? 5
                                              : caretWidth, //default width for the caret to come back quickly on change
                                          decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 33, 33, 243),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: TweenAnimationBuilder(
                                              tween: Tween<double>(
                                                  begin: 0,
                                                  end: isDone ? 1 : 0),
                                              duration:
                                                  const Duration(seconds: 1),
                                              builder: (context, iconOpacity,
                                                  child) {
                                                return Opacity(
                                                  opacity:
                                                      isDone ? iconOpacity : 0,
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              })),
                                    ));
                              }),
                        );
                      })
              ],
            ),
          ],
        ),
      ),
    );
  }
}

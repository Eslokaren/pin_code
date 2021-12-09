import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinCode extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final MainAxisAlignment mainAxisAlignment;
  final TextInputType keyboardType;
  final bool autoFocus;
  final dynamic pinTheme;

  const PinCode(
      {Key? key,
      required this.length,
      required this.onChanged,
      this.textStyle,
      this.backgroundColor,
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
      this.keyboardType = TextInputType.visiblePassword,
      this.autoFocus = false,
      this.pinTheme})
      : super(key: key);

  @override
  _PinCodeState createState() => _PinCodeState();
}

class _PinCodeState extends State<PinCode> with TickerProviderStateMixin {
  TextEditingController? _textEditingController;
  int _selectedIndex = 0;
  BorderRadius? borderRadius;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late List<String> _inputList;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(.1, 0.00),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    _inputList = List<String>.filled(widget.length, "");
  }

  @override
  Widget build(BuildContext context) {
    var textField = TextFormField(
      autofocus: widget.autoFocus,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(
          widget.length,
        )
      ],
      showCursor: false,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(0),
        border: InputBorder.none,
        fillColor: Colors.cyan,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      style: const TextStyle(
          color: Colors.transparent, height: .01, fontSize: kIsWeb ? 1 : 0.1),
    );

    List<Widget> _generateFields() {
      var result = <Widget>[];
      for (int i = 0; i < widget.length; i++) {
        result.add(Container(
          padding: const EdgeInsets.all(2),
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                // borderRadius:
                border: Border.all(color: Colors.green, width: 3)),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                _inputList[i],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ).merge(widget.textStyle),
              ),
            ),
          ),
        ));
      }
      return result;
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
          height: 75,
          // color: Colors.black,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              AbsorbPointer(
                absorbing: true,
                child: AutofillGroup(
                    onDisposeAction: AutofillContextAction.commit,
                    child: textField),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onDoubleTap: () => FocusNode().requestFocus(),
                  child: Row(
                    mainAxisAlignment: widget.mainAxisAlignment,
                    children: _generateFields(),
                  ),
                ),
              )
            ],
          )),
    );
  }

  void _setTextToInput(String data) async {
    var replaceInputList = List<String>.filled(widget.length, "");

    for (int i = 0; i < widget.length; i++) {
      replaceInputList[i] = data.length > i ? data[i] : "";
    }

    if (mounted) {
      setState(() {
        _selectedIndex = data.length;
        _inputList = replaceInputList;
      });
    }
  }
}

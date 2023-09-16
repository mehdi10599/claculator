import '../../constants.dart';
import 'package:flutter/material.dart';

class GetKeyboard extends StatelessWidget {
  final List keyboardList;
  final Size size;
  final Function onTap;
  const GetKeyboard({super.key, required this.keyboardList,required this.size,required this.onTap});

  @override
  Widget build(BuildContext context) {

    List<Widget> keyboardRows = [];
    for (int i = 0; i < keyboardList.length; i++) {
      keyboardRows.add(getKeyboardRow(keyboardList[i]));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keyboardRows
    );

  }

  Widget getKeyboardRow(List keyboardListRow) {
    List<Widget> keyboardButtons = [];
    for (int i = 0; i < keyboardListRow.length; i++) {
      keyboardButtons.add(getButtons(keyboardListRow[i]));
    }
    return Row(
        children:keyboardButtons
    );
  }

  Widget getButtons(String buttonText) {
    return Expanded(
      child: Container(
        height: size.height*0.06,
        margin: const EdgeInsets.symmetric(vertical: 1,horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: K_BTN_COLOR,
        ),
        child: TextButton(
          onPressed: () => onTap(buttonText: buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: K_BTN_TEXT_COLOR,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }


}

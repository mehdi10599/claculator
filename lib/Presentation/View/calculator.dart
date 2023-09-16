import 'package:calculator_ood/Presentation/Controller/controller.dart';
import 'package:calculator_ood/Presentation/Model/view_model.dart';
import 'package:calculator_ood/Presentation/Presenter/view_interface.dart';

import '../../constants.dart';
import 'keyboard.dart';
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> implements ViewInterface{
  late Size size;
  List allBtn = [];
  String showResult = '';
  String result = '';
  int openQuot = 0;
  bool hasResult = false;
  String prevResult = '';
  int historyCounter = 0;

  @override
  showExpressionResult(ViewModel viewModel) {
    result +=  viewModel.expression;
    setState(() {});
  }

  void onPressed({required String buttonText}) {
    if(hasResult){
      //      در صورتی که بعد از زدن مساوی دکمه های اوپراتور زده شود نتیجه خروجی به عنوان اولین عدد قرار میگیرد
      if( getBtnType(buttonText) == 'is_operator'){
        showResult = result;
        allBtn = result.split('');
        result = '';
        hasResult=false;
      }
      else{
        showResult = '';
        allBtn = [];
        result = '';
        hasResult=false;
      }
    }
    String lastBtn = showLastBtn();
    if (getBtnType(buttonText) == 'is_number') {
      //====================================================  دکمه های اعداد
      if (lastBtn == ')') {
        showResult += '×$buttonText';
        saveBtn('×');
        saveBtn(buttonText);
      } else if (!(getLastNumber() == ZERO && buttonText == ZERO)) {
        if (getLastNumber() == ZERO && buttonText != ZERO) {
          removeLastBtn();
          showResult = showResult.substring(
              0,
              showResult.length -
                  1); //remove last zero character from show result
        }
        showResult += buttonText;
        saveBtn(buttonText);
      }
    }
    else if (getBtnType(buttonText) == 'is_function') {
      // ====================================================  دکمه های توابع
      if (lastBtn == DECIMAL_POINT_SIGN) {
        removePointWithMultiplication();
      }
      if (lastBtn == ')') {
        showResult += '×$buttonText(';
        saveBtn('×');
        saveBtn(buttonText);
        saveBtn('(');
      } else if (getBtnType(lastBtn) == 'is_number') {
        showResult += '×$buttonText(';
        saveBtn('×');
        saveBtn(buttonText);
        saveBtn('(');
      } else {
        showResult += '$buttonText(';
        saveBtn(buttonText);
        saveBtn('(');
      }
      openQuot++;
    }
    else if (getBtnType(buttonText) == 'is_operator') {
      //====================================================  دکمه های اپراتور + - * / %
      if (getLastNumber().contains('_')) {
        showResult += ")";
        openQuot--;
        saveBtn(")");
      }
      if (lastBtn == DECIMAL_POINT_SIGN) {
        removeLastPoint();
      }
      if (getBtnType(lastBtn) == 'is_operator') {
        removeLastBtn();
        showResult = showResult.substring(0, showResult.length - 1);
        showResult += buttonText;
        saveBtn(buttonText);
      }
      else if (lastBtn != "(" && lastBtn != '') {
        showResult += buttonText;
        saveBtn(buttonText);
      }
    }
    else if (getBtnType(buttonText) == 'is_other') {
      if (buttonText == CLEAR_ALL_SIGN) {
        //==================================================== پاک کردن همه
        clearAll();
      }
      else if (buttonText == DEL_SIGN) {
        //====================================================  دکمه پاک کردن کاراکتر قبلی
        if (lastBtn == '(') {
          openQuot--;
        } else if (lastBtn == ')') {
          openQuot++;
        }
        int lastBtnLength = lastBtn.length;
        showResult = showResult.substring(0, showResult.length - lastBtnLength);
        removeLastBtn();
      }
      else if (buttonText == QUOTE_SIGN) {
        //====================================================  پرانتز

        if (getLastNumber().contains('_')) {
          if (getLastNumber() == '_') {
            showResult += "1";
            showResult += ")";
            openQuot--;
            saveBtn("1");
            saveBtn(")");
          } else {
            showResult += ")";
            openQuot--;
            saveBtn(")");
          }
        } else if (openQuot == 0 && getBtnType(lastBtn) == 'is_number') {
          showResult += "×(";
          openQuot++;
          saveBtn("×");
          saveBtn("(");
        } else if (getBtnType(lastBtn) == 'is_number' && openQuot > 0) {
          showResult += ")";
          openQuot--;
          saveBtn(")");
        }
        if (lastBtn == ")" && openQuot == 0) {
          showResult += "×(";
          openQuot++;
          saveBtn("×");
          saveBtn("(");
        } else if (lastBtn == ")" && openQuot > 0) {
          showResult += ")";
          openQuot--;
          saveBtn(")");
        }
        if (lastBtn == "(" && openQuot > 0 || lastBtn == '') {
          showResult += "(";
          openQuot++;
          saveBtn("(");
        }
        if (getBtnType(lastBtn) == 'is_operator') {
          showResult += "(";
          openQuot++;
          saveBtn("(");
        }
      }
      else if (buttonText == DECIMAL_POINT_SIGN) {
        //==================================================== نقطه
        String lastNumber = getLastNumber();
        if (lastNumber == '') {
          showResult += '0.';
          saveBtn("0");
          saveBtn(".");
        } else if (!(lastNumber.contains('.'))) {
          showResult += '.';
          saveBtn(".");
        }
      }
      else if (buttonText == PLUSMINUS_SIGN) {
        //==================================================== علامت مثبت منفی
        if (getLastNumber() == '') {
          showResult += '(';
          showResult += MINUS_SIGN;
          saveBtn('(');
          saveBtn('_');
          openQuot++;
        } else if (!(getLastNumber().contains('_'))) {
          makeNumberNegative();
        } else if ((getLastNumber()).contains('_')) {
          makeNumberPositive();
        }
      }
      else if (buttonText == EQUAL_SIGN) {
        //==================================================== علامت مساوی
        if (openQuot > 0) {
          while (openQuot > 0) {
            showResult += ')';
            saveBtn(')');
            openQuot--;
          }
        }
        Controller(showResult);
        hasResult = true;
        showResult += EQUAL_SIGN;
        saveBtn(EQUAL_SIGN);
        saveBtn(result);
      }
    }

    setState(() {});
  }

  void removePointWithMultiplication() {
    removeLastBtn();
    showResult = showResult.substring(0, showResult.length - 1);
    showResult += MULTIPLICATION_SIGN;
    saveBtn(MULTIPLICATION_SIGN);
  }

  void removeLastPoint() {
    removeLastBtn();
    showResult = showResult.substring(0, showResult.length - 1);
  }

  void makeNumberNegative() {
    String lastNumber = getLastNumber();
    int lastNumberLength = lastNumber.length;
    showResult = showResult.substring(0, showResult.length - lastNumberLength);
    showResult = '$showResult(-$lastNumber';
    allBtn.insert(allBtn.length - lastNumberLength, "(");
    allBtn.insert(allBtn.length - lastNumberLength, "_");
    openQuot++;
  }

  void makeNumberPositive() {
    int lastNumberLength = getLastNumber().length;
    showResult =
        showResult.substring(0, showResult.length - (lastNumberLength + 1));
    String positiveNum = getLastNumber().replaceAll('_', '');
    showResult += positiveNum;
    List reverseAllBtn = allBtn.reversed.toList();
    reverseAllBtn.removeAt(lastNumberLength - 1);
    reverseAllBtn.removeAt(lastNumberLength - 1);
    allBtn = reverseAllBtn.reversed.toList();
    openQuot--;
  }

  String getLastNumber() {
    List revAllBtn = allBtn.reversed.toList();
    String lastNum = '';
    List lastNumList = [];
    for (int i = 0; i < revAllBtn.length; i++) {
      if (getBtnType(revAllBtn[i]) == 'is_number' ||
          revAllBtn[i] == DECIMAL_POINT_SIGN ||
          revAllBtn[i] == '_') {
        lastNumList.add(revAllBtn[i]);
      } else {
        break;
      }
    }
    lastNumList = lastNumList.reversed.toList();
    lastNum = lastNumList.join();
    return lastNum;
  }

  void saveBtn(String btn) {
    allBtn.add(btn);
  }

  void removeLastBtn() {
    if (allBtn.isNotEmpty) {
      allBtn.removeLast();
    }
  }

  void clearAllBtn() {
    allBtn = [];
  }

  String showLastBtn() {
    if (allBtn.isNotEmpty) {
      return allBtn.last;
    } else {
      return '';
    }
  }

  String getBtnType(String btn) {
    if (btn == ZERO ||
        btn == ONE ||
        btn == TWO ||
        btn == THREE ||
        btn == FOUR ||
        btn == FIVE ||
        btn == SIX ||
        btn == SEVEN ||
        btn == EIGHT ||
        btn == NINE) {
      return 'is_number';
    } else if (btn == PLUS_SIGN ||
        btn == MINUS_SIGN ||
        btn == MULTIPLICATION_SIGN ||
        btn == DIVISION_SIGN ) {
      return 'is_operator';
    } else {
      return 'is_other';
    }
  }

  void clearAll() {
    showResult = '';
    result = '';
    openQuot = 0;
    allBtn = [];
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    String getAppBarQuotText(){
      if(openQuot>0){
        return ' ( $MULTIPLICATION_SIGN$openQuot';
      }else{
        return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getAppBarQuotText(),
              style: const TextStyle(color: K_BTN_TEXT_COLOR),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Column(
        children: [
          Container(
            height: size.height * .18,
            color: Colors.black,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              bottom: 10,
              top: 10
            ),
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showResult,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 17),
                  ),
                  Text(
                    result,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 23),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          GetKeyboard(
            keyboardList: keyboardCalculator,
            size: size,
            onTap: onPressed,
          ),
        ],
      ),
    );
  }

}

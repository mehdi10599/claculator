import 'dart:async';

import 'package:calculator_ood/Presentation/Controller/controller.dart';
import 'package:calculator_ood/Presentation/Model/view_model.dart';
import '../../constants.dart';
import 'keyboard.dart';
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  late Size size;
  List allBtn = [];
  String showExpression = '';
  String finalResult = '';
  int openQuot = 0;
  bool hasResult = false;
  String prevResult = '';
  int historyCounter = 0;
  static StreamController<ViewModel> streamController = StreamController<ViewModel>();
  late Stream<ViewModel> stream;
  @override
  void initState() {
    stream = streamController.stream;
    stream.listen((ViewModel event) {
      finalResult = event.expression;
    });
    super.initState();
  }

  void onPressed({required String buttonText}) {
    if(hasResult){
      //      در صورتی که بعد از زدن مساوی دکمه های اوپراتور زده شود نتیجه خروجی به عنوان اولین عدد قرار میگیرد
      if( getBtnType(buttonText) == 'is_operator'){
        showExpression = finalResult;
        allBtn = finalResult.split('');
        finalResult = '';
        hasResult=false;
      }
      else{
        showExpression = '';
        allBtn = [];
        finalResult = '';
        hasResult=false;
      }
    }
    String lastBtn = showLastBtn();
    if (getBtnType(buttonText) == 'is_number') {
      //====================================================  دکمه های اعداد
      if (lastBtn == ')') {
        showExpression += '×$buttonText';
        saveBtn('×');
        saveBtn(buttonText);
      } else if (!(getLastNumber() == ZERO && buttonText == ZERO)) {
        if (getLastNumber() == ZERO && buttonText != ZERO) {
          removeLastBtn();
          showExpression = showExpression.substring(
              0,
              showExpression.length -
                  1); //remove last zero character from show result
        }
        showExpression += buttonText;
        saveBtn(buttonText);
      }
    }
    else if (getBtnType(buttonText) == 'is_function') {
      // ====================================================  دکمه های توابع
      if (lastBtn == DECIMAL_POINT_SIGN) {
        removePointWithMultiplication();
      }
      if (lastBtn == ')') {
        showExpression += '×$buttonText(';
        saveBtn('×');
        saveBtn(buttonText);
        saveBtn('(');
      } else if (getBtnType(lastBtn) == 'is_number') {
        showExpression += '×$buttonText(';
        saveBtn('×');
        saveBtn(buttonText);
        saveBtn('(');
      } else {
        showExpression += '$buttonText(';
        saveBtn(buttonText);
        saveBtn('(');
      }
      openQuot++;
    }
    else if (getBtnType(buttonText) == 'is_operator') {
      //====================================================  دکمه های اپراتور + - * / %
      if (getLastNumber().contains('_')) {
        showExpression += ")";
        openQuot--;
        saveBtn(")");
      }
      if (lastBtn == DECIMAL_POINT_SIGN) {
        removeLastPoint();
      }
      if (getBtnType(lastBtn) == 'is_operator') {
        removeLastBtn();
        showExpression = showExpression.substring(0, showExpression.length - 1);
        showExpression += buttonText;
        saveBtn(buttonText);
      }
      else if (lastBtn != "(" && lastBtn != '') {
        showExpression += buttonText;
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
        showExpression = showExpression.substring(0, showExpression.length - lastBtnLength);
        removeLastBtn();
      }
      else if (buttonText == QUOTE_SIGN) {
        //====================================================  پرانتز

        if (getLastNumber().contains('_')) {
          if (getLastNumber() == '_') {
            showExpression += "1";
            showExpression += ")";
            openQuot--;
            saveBtn("1");
            saveBtn(")");
          } else {
            showExpression += ")";
            openQuot--;
            saveBtn(")");
          }
        } else if (openQuot == 0 && getBtnType(lastBtn) == 'is_number') {
          showExpression += "×(";
          openQuot++;
          saveBtn("×");
          saveBtn("(");
        } else if (getBtnType(lastBtn) == 'is_number' && openQuot > 0) {
          showExpression += ")";
          openQuot--;
          saveBtn(")");
        }
        if (lastBtn == ")" && openQuot == 0) {
          showExpression += "×(";
          openQuot++;
          saveBtn("×");
          saveBtn("(");
        } else if (lastBtn == ")" && openQuot > 0) {
          showExpression += ")";
          openQuot--;
          saveBtn(")");
        }
        if (lastBtn == "(" && openQuot > 0 || lastBtn == '') {
          showExpression += "(";
          openQuot++;
          saveBtn("(");
        }
        if (getBtnType(lastBtn) == 'is_operator') {
          showExpression += "(";
          openQuot++;
          saveBtn("(");
        }
      }
      else if (buttonText == DECIMAL_POINT_SIGN) {
        //==================================================== نقطه
        String lastNumber = getLastNumber();
        if (lastNumber == '') {
          showExpression += '0.';
          saveBtn("0");
          saveBtn(".");
        } else if (!(lastNumber.contains('.'))) {
          showExpression += '.';
          saveBtn(".");
        }
      }
      else if (buttonText == PLUSMINUS_SIGN) {
        //==================================================== علامت مثبت منفی
        if (getLastNumber() == '') {
          showExpression += '(';
          showExpression += MINUS_SIGN;
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
            showExpression += ')';
            saveBtn(')');
            openQuot--;
          }
        }
        hasResult = true;
        showExpression += EQUAL_SIGN;
        saveBtn(EQUAL_SIGN);
        saveBtn(finalResult);
        Controller(showExpression);
      }
    }

    setState(() {});
  }

  void removePointWithMultiplication() {
    removeLastBtn();
    showExpression = showExpression.substring(0, showExpression.length - 1);
    showExpression += MULTIPLICATION_SIGN;
    saveBtn(MULTIPLICATION_SIGN);
  }

  void removeLastPoint() {
    removeLastBtn();
    showExpression = showExpression.substring(0, showExpression.length - 1);
  }

  void makeNumberNegative() {
    String lastNumber = getLastNumber();
    int lastNumberLength = lastNumber.length;
    showExpression = showExpression.substring(0, showExpression.length - lastNumberLength);
    showExpression = '$showExpression(-$lastNumber';
    allBtn.insert(allBtn.length - lastNumberLength, "(");
    allBtn.insert(allBtn.length - lastNumberLength, "_");
    openQuot++;
  }

  void makeNumberPositive() {
    int lastNumberLength = getLastNumber().length;
    showExpression = showExpression.substring(0, showExpression.length - (lastNumberLength + 1));
    String positiveNum = getLastNumber().replaceAll('_', '');
    showExpression += positiveNum;
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
    showExpression = '';
    finalResult = '';
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
                    showExpression,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 17),
                  ),
                  Text(
                    finalResult,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 23),
                  )
                  // StreamBuilder(
                  //   stream: stream,
                  //   builder: (BuildContext ctx ,AsyncSnapshot<double> snapShot ){
                  //     return Text(
                  //       snapShot.data.toString(),
                  //       style: const TextStyle(color: Colors.greenAccent, fontSize: 23),
                  //     );
                  //   }
                  // ),
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

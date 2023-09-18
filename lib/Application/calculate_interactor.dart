import 'package:calculator_ood/Application/input_boundary.dart';
import 'package:calculator_ood/Application/input_data.dart';
import 'package:calculator_ood/Application/output_data.dart';
import 'package:calculator_ood/Presentation/Presenter/presenter.dart';

class CalculateInteractor implements InputBoundary{
  late InputData inputData;
  late OutputData outputData;

  @override
  void calculate(InputData inputData) {
    String convertedExpression = _convertOperators(inputData.expression);
    String result = convertedExpression;

    result = _calculateExpression(result);

    result = _removeExtraZeroAfterPoint(result);
    outputData = OutputData(result);
    Presenter().takeExpressionResult(outputData);
  }

  String _removeExtraZeroAfterPoint(String result){
    if (result.endsWith('.0')) {
      result = result.substring(0, result.length - 2);
    }
    return result;
  }

  String _convertOperators(String expression){
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');
    return expression;
  }

  String _calculateExpression(String expression) {

    String result = '';

    while(_expressionHasParentheses(expression)){
      String newExpression = _calculateInnerParentheses(expression);
      expression = newExpression;
    }

    result = _calculateSubExpression(expression).toString();

    return result;
  }

  bool _expressionHasParentheses(String expression){
    return expression.contains('(');
  }

  String _calculateInnerParentheses(String expression) {
    int indexOfFirstClosed = expression.indexOf(')');
    int indexOfOpenBefore = expression.substring(0,indexOfFirstClosed).lastIndexOf('(');
    String innerExpression = expression.substring(indexOfOpenBefore+1,indexOfFirstClosed);
    double subResult = _calculateSubExpression(innerExpression);
    String newExpression = expression.replaceFirst(expression.substring(indexOfOpenBefore,indexOfFirstClosed+1), subResult.toString());
    return newExpression;
  }

  double _calculateSubExpression(String subExp) {

    List<dynamic> splitExp = _splitOperatorAndOperands(subExp);

    while(splitExp.contains('*') || splitExp.contains('/')){
      for(int i = 1; i < splitExp.length-1 ; i++){
        if(splitExp[i] == '*' || splitExp[i] == '/'){
          double res;
          if(splitExp[i] == '*'){
            res = double.parse(splitExp[i-1].toString()) *  double.parse(splitExp[i+1].toString());
          }else{
            res = double.parse(splitExp[i-1].toString()) /  double.parse(splitExp[i+1].toString());
          }
          splitExp.replaceRange(i-1, i+2, [res.toString()]);
        }
        else{
          continue;
        }
      }
    }

    while(splitExp.contains('+') || splitExp.contains('-')){
      for(int i = 1; i < splitExp.length-1 ; i++){
        if(splitExp[i] == '+' || splitExp[i] == '-'){
          double res;
          if(splitExp[i] == '+'){
            res = double.parse(splitExp[i-1].toString()) +  double.parse(splitExp[i+1].toString());
          }else{
            res = double.parse(splitExp[i-1].toString()) -  double.parse(splitExp[i+1].toString());
          }
          splitExp.replaceRange(i-1, i+2, [res.toString()]);
        }
        else{
          continue;
        }
      }
    }

    return double.parse(splitExp[0].toString());
  }

  List<dynamic>  _splitOperatorAndOperands(String subExp){

    List<dynamic> splitExp = [];

    String current = '';
    int i = 0;
    if(subExp[0] == '-'){
      current += subExp[0];
      i++;
    }
    for( ; i < subExp.length ; i++){
      int? x = int.tryParse(subExp[i]);
      if(subExp[i] == '-' && int.tryParse(subExp[i-1]) == null ){
        current += subExp[i];
        continue;
      }
      if(x != null || subExp[i] == '.'){
        current += subExp[i];
        if(i == subExp.length-1){
          splitExp.add(double.parse(current));
        }
        continue;
      }
      splitExp.add(current);
      current = subExp[i];
      splitExp.add(current);
      current = '';
    }
    return splitExp;
  }




}
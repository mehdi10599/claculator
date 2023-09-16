import 'package:calculator_ood/Application/input_boundary.dart';
import 'package:calculator_ood/Application/input_data.dart';
import 'package:calculator_ood/Application/output_data.dart';
import 'package:calculator_ood/Presentation/Presenter/presenter.dart';

class CalculateInteractor implements InputBoundary{
  late InputData inputData;
  late OutputData outputData;

  @override
  void calculate(InputData inputData) {
    String convertedExpression = convertOperators(inputData.expression);
    print("convertedExpression = $convertedExpression");
    print("inputData = ${inputData.expression}");
    ///todo execute expression

    String result = convertedExpression;
    if (result.endsWith('.0')) {
      result = result.substring(0, result.length - 2);
    }
    outputData = OutputData(result);
    Presenter().takeExpressionResult(outputData);
  }


  String convertOperators(String expression){
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');
    return expression;
  }


}
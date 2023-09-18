

import 'package:calculator_ood/Application/calculate_interactor.dart';
import 'package:calculator_ood/Application/input_boundary.dart';

import '../../Application/input_data.dart';

class Controller{

  late InputData inputData;
  Controller(String expression){

    if(expression.contains("=")){
      expression = expression.replaceAll("=", "");
    }
    if(expression.isEmpty){
      expression = '0';
    }
    if(int.tryParse(expression[expression.length-1]) == null){
      expression = expression.substring(0,expression.length-1);
    }
    inputData = InputData(expression);
    InputBoundary inputBoundary = CalculateInteractor();
    inputBoundary.calculate(inputData);
  }



}
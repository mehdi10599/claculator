

import 'package:calculator_ood/Application/calculate_interactor.dart';
import 'package:calculator_ood/Application/input_boundary.dart';

import '../../Application/input_data.dart';

class Controller{

  late InputData inputData;
  Controller(String expression){
    inputData = InputData(expression);
    InputBoundary inputBoundary = CalculateInteractor();
    inputBoundary.calculate(inputData);
  }



}
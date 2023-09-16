import 'package:calculator_ood/Application/output_boundary.dart';
import 'package:calculator_ood/Application/output_data.dart';
import 'package:calculator_ood/Presentation/Model/view_model.dart';
import 'package:calculator_ood/Presentation/Presenter/view_interface.dart';
import 'package:calculator_ood/Presentation/View/calculator.dart';

class Presenter implements OutputBoundary{
  late ViewModel viewModel;
  late ViewInterface viewInterface;

  @override
  void takeExpressionResult(OutputData outputData) {
    viewModel = ViewModel(outputData.result);
    viewInterface = CalculatorState();
    viewInterface.showExpressionResult(viewModel);
  }

}
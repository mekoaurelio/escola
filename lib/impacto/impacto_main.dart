import 'package:flutter/material.dart';
import 'impacto_grid.dart';

class ImpactoMain extends StatefulWidget {
  const ImpactoMain({Key? key}) : super(key: key);

  @override
  State<ImpactoMain> createState() => _ImpactoMainState();
}

class _ImpactoMainState extends State<ImpactoMain> with TickerProviderStateMixin {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ImpactoGrid(
       // fundeb: fundebRaw,       // sua lista do Fundeb
       // infantil: infantilRaw,   // sua lista do Infantil
      ),
    );
  }
}

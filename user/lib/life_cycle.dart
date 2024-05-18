import 'package:flutter/material.dart';

class LifeCycle extends StatefulWidget {
  const LifeCycle({Key? key}) : super(key: key);

  @override
  State<LifeCycle> createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> with WidgetsBindingObserver{

  // didchange lifecycle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }


  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print(state);

  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

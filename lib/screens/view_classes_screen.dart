import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_awesome_app/bloc/sewclass_bloc.dart';
import 'package:my_awesome_app/model/sewclass.dart';
import 'package:my_awesome_app/screens/base_screen.dart';

class ViewClassesScreen extends BaseScreen {
  const ViewClassesScreen({
    super.key,
    super.title = 'Classes',
  });
  @override
  _ViewClassesScreenState createState() => _ViewClassesScreenState();
}

class _ViewClassesScreenState extends State<ViewClassesScreen> {
  late final StreamSubscription<List<Sewclass>> _sewClassesSubscription;
  List<Sewclass> _sewClasses = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }
  @override
  void dispose() {
    _sewClassesSubscription.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    _sewClassesSubscription = SewclassBloc().sewclassesStream.listen((sewClasses){
      setState(() {
        _sewClasses = sewClasses;
      });
    });
    await SewclassBloc().fetchSewclasses();
  }

  Widget _buildSewClasses() {
    return ListView.builder(
      itemCount: _sewClasses.length,
      itemBuilder: (context, index) {
        final sewClass = _sewClasses[index];
        return ListTile(
          title: Text(sewClass.name),
          subtitle: Text(sewClass.description
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Classes'),
      ),
      body: Center(
        child: _buildSewClasses(),
      ),
    );
  }
}
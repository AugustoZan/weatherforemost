import "../widgets/Button.dart";
import "../widgets/Card.dart";
import "../widgets/EstadoVacio.dart";
import "../widgets/Header.dart";
import "../widgets/Modal.dart";

import "../providers/ClimaProvider.dart";

import 'package:flutter/material.dart';



class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
    @override
    Widget build(BuildContext context) {
      return Container();
    }
}
/*
class _HomeScreenState extends State<HomeScreen> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: const Header(),
        body: Column (
          children: [

          ],
        )
      );
    }
}
*/
import 'package:flutter/material.dart';

//biblioteca http - permite fazer requisições
import 'package:http/http.dart' as http;

import 'dart:async'; // biblioteca de requisição assíncrona
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=e73a9514";

void main() async {

  runApp(MaterialApp(
     home: Home(),
    theme: ThemeData(
        hintColor: Colors.greenAccent,
        primaryColor: Colors.greenAccent,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
          hintStyle: TextStyle(color: Colors.greenAccent),
        )),
      ),
  );
}

//Furuto dos nossos dados
Future<Map> getData() async{ //retorna um mapa no futuro
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}



class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }


  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar!).toStringAsFixed(2);
    euroController.text = (real/euro!).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    dolarController.text = (euro * this.euro!).toStringAsFixed(2);
    realController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...",
                  style:TextStyle(
                    color: Colors.black,
                    fontSize: 25.0),
                textAlign: TextAlign.center,)
              );
            default:
              if(snapshot.hasError){
                return Center(
                    child: Text("Erro ao Carregar Dados :(",
                      style:TextStyle(
                          color: Colors.red,
                          fontSize: 25.0),
                      textAlign: TextAlign.center,),
                );
              } else{
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                        //centralizar | strech = ocupar o maior espaço possível
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                        size: 150.0, color: Colors.greenAccent,),

                      buildTextField("Reais", "R\$ ", realController, _realChanged),

                      Divider(),

                      buildTextField("Dólares", "US\$ ", dolarController, _dolarChanged),

                      Divider(),

                      buildTextField("Euros", "€ ", euroController, _euroChanged),

                    ],
                  ),
                );
              }
          }
        })
    );
  }
}


Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.greenAccent),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold
    ),
    onChanged: f as void Function(String)?,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
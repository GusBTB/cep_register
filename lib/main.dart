import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:register_cep/models/cep_return.dart';
import 'package:register_cep/pages/history.dart';
import 'package:register_cep/repositories/search_cep.dart';
import 'package:register_cep/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyApplicationId = 'r3rQkrSJlGfwn1uHsp9j3gPSGDO78wKVKmMzGU8K';
  const keyClientKey = 'Aa7nwx9znLTbno6uKjNbgRu3V3PXNghePZL93ytW';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Consulta de CEP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController cepController = TextEditingController(text: "");

  bool bottom = false;

  showBottom(context, cepReturnModel) {
    return Utils().showBottomSheet(context, cepReturnModel);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          drawer: Drawer(
              child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Column(children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const History()));
                },
                leading: const Icon(Icons.history),
                title: const Text("Histórico"),
              )
            ]),
          )),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 239, 0, 199),
            title: Text(widget.title),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  "Consulte todos os dados de um CEP",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CepInputFormatter()
                  ],
                  controller: cepController,
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 15),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 102, 0, 204))),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 102, 0, 204))),
                    hintText: "Digite o CEP",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (cepController.text.isEmpty ||
                        cepController.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cep inválido")));
                    } else {
                      String cepReplaced = cepController.text
                          .replaceAll(".", "")
                          .replaceAll("-", "");
                      var response = await http.get(Uri.parse(
                          'https://viacep.com.br/ws/$cepReplaced/json/'));
                      if (response.statusCode == 200 &&
                          !response.body.contains("erro")) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        cepController.text = "";
                        var decodedJson = jsonDecode(response.body);
                        CepReturnModel cepReturnModel =
                            CepReturnModel.fromJson(decodedJson);
                        SearchAndRetrieveCep().saveCep(cepReturnModel);
                        Utils().showBottomSheet(context, cepReturnModel);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Cep não encontrado")));
                      }
                    }
                    //Pesquisar Cep
                    //Se sucesso guardar em B4App
                  },
                  child: const Text("Consultar"),
                ),
                Expanded(child: Container())
              ],
            ),
          )),
    );
  }
}

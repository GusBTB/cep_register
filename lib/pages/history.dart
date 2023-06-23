import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:register_cep/models/cep_return.dart';
import 'package:register_cep/repositories/search_cep.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  TextEditingController cepController = TextEditingController();
  List<ParseObject> his = [];
  bool loading = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    loading = true;
    await Future.delayed(const Duration(seconds: 2), () async {
      his = await SearchAndRetrieveCep().getCeps();
    });
    setState(() {});
    debugPrint(his.toString());
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Histórico de buscas"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: his.length,
                  itemBuilder: (context, index) {
                    var item = his[index];
                    return ListTile(
                        title: Text("${item['logradouro']}"),
                        subtitle: Text("${item['localidade']}"),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Editar cep'),
                                      content: TextField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          CepInputFormatter()
                                        ],
                                        controller: cepController,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 15),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 102, 0, 204))),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 102, 0, 204))),
                                          hintText: "Digite o CEP",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .labelLarge,
                                          ),
                                          child: const Text('Salvar'),
                                          onPressed: () async {
                                            if (cepController.text.isEmpty ||
                                                cepController.text.length < 8) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Cep inválido")));
                                            } else {
                                              String cepReplaced = cepController
                                                  .text
                                                  .replaceAll(".", "")
                                                  .replaceAll("-", "");
                                              var response = await http.get(
                                                  Uri.parse(
                                                      'https://viacep.com.br/ws/$cepReplaced/json/'));
                                              if (response.statusCode == 200 &&
                                                  !response.body
                                                      .contains("erro")) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                cepController.text = "";
                                                var decodedJson =
                                                    jsonDecode(response.body);
                                                CepReturnModel cepReturnModel =
                                                    CepReturnModel.fromJson(
                                                        decodedJson);
                                                SearchAndRetrieveCep()
                                                    .updateCep(item['objectId'],
                                                        cepReturnModel);

                                                initData();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            "Cep não encontrado")));
                                              }
                                            }
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await SearchAndRetrieveCep()
                                    .deleteCep(item['objectId']);
                                initData();
                              },
                            )
                          ],
                        ));
                  },
                ),
        ),
      ),
    );
  }
}

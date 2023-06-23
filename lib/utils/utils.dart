import 'package:flutter/material.dart';

class Utils {
  showBottomSheet(context, cepObj) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          height: 200,
          child: ListView(
            children: [
              Text(
                'Para o CEP ${cepObj.cep}:',
                style: const TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flexible(child: Container()),
                  Text("Logradouro: ${cepObj.logradouro}"),
                  // Flexible(child: Container()),
                  Text("Localidade: ${cepObj.localidade}"),
                  // Flexible(child: Container()),
                  Text("UF: ${cepObj.uf}"),
                ],
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromARGB(255, 102, 0, 204))),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

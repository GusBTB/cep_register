import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:register_cep/models/cep_return.dart';

class SearchAndRetrieveCep {
  Future<void> saveCep(CepReturnModel cepObj) async {
    await Future.delayed(const Duration(seconds: 1), () async {
      final saved = ParseObject('cep')
        ..set('cep', cepObj.cep)
        ..set('logradouro', cepObj.logradouro)
        ..set('complemento', cepObj.complemento)
        ..set('bairro', cepObj.bairro)
        ..set('localidade', cepObj.localidade)
        ..set('uf', cepObj.uf)
        ..set('ibge', cepObj.ibge)
        ..set('gia', cepObj.gia)
        ..set('ddd', cepObj.ddd)
        ..set('siafi', cepObj.siafi);
      await saved.save();
    });
  }

  Future<List<ParseObject>> getCeps() async {
    QueryBuilder<ParseObject> queryCep =
        QueryBuilder<ParseObject>(ParseObject('cep'));
    final ParseResponse apiResponse = await queryCep.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateCep(String id, cepObj) async {
    var cep = ParseObject('cep')..objectId = id;
    await cep.delete();
    await Future.delayed(const Duration(seconds: 1), () async {
      final saved = ParseObject('cep')
        ..set('cep', cepObj.cep)
        ..set('logradouro', cepObj.logradouro)
        ..set('complemento', cepObj.complemento)
        ..set('bairro', cepObj.bairro)
        ..set('localidade', cepObj.localidade)
        ..set('uf', cepObj.uf)
        ..set('ibge', cepObj.ibge)
        ..set('gia', cepObj.gia)
        ..set('ddd', cepObj.ddd)
        ..set('siafi', cepObj.siafi);
      await saved.save();
    });
  }

  Future<void> deleteCep(String id) async {
    await Future.delayed(const Duration(seconds: 1), () async {
      var cep = ParseObject('cep')..objectId = id;
      await cep.delete();
    });
  }
}

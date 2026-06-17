import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicoService {
  static const String baseUrl = "http://192.168.1.7:8082/api/servicos";

  static Future<void> publicarServico({
    required Map<String, dynamic> dados,
    required String clienteId,
  }) async {
    final body = {
      "titulo": dados["titulo"],
      "especialidade": dados["especialidade"],
      "descricao": dados["descricao"],
      "cidade": dados["cidade"],
      "estado": dados["estado"],
      "clienteId": clienteId,
    };

    print(jsonEncode(body));

    print("CHAMANDO API...");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer SEU_TOKEN",
      },
      body: jsonEncode(body),
    );

    print("CHEGOU RESPOSTA");
    print(response.statusCode);
    print(response.body);

    print("STATUS:");
    print(response.statusCode);

    print("RESPOSTA:");
    print(response.body);

    if (response.statusCode != 201) {
      throw Exception("Erro ao publicar serviço: ${response.body}");
    }

    print("SERVIÇO PUBLICADO");
  }
}

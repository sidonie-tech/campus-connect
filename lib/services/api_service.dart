import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Utilisation d'une API de citations gratuite
  static const String _quoteUrl = 'https://api.quotable.io/random';

  Future<Map<String, dynamic>?> getRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_quoteUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de la citation: $e');
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuoteProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String _quote = "Chargement d'une citation...";
  String _author = "";
  bool _isLoading = false;

  String get quote => _quote;
  String get author => _author;
  bool get isLoading => _isLoading;

  QuoteProvider() {
    fetchNewQuote();
  }

  Future<void> fetchNewQuote() async {
    _isLoading = true;
    notifyListeners();

    final data = await _apiService.getRandomQuote();
    if (data != null) {
      _quote = data['content'] ?? "Pas de citation trouvée";
      _author = data['author'] ?? "Inconnu";
    } else {
      _quote = "Impossible de charger une citation.";
      _author = "";
    }

    _isLoading = false;
    notifyListeners();
  }
}

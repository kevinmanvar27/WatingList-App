import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionService {
  Future<List<dynamic>> getPlans() async {
    final url = Uri.parse("https://waitinglist.rektech.work/api/subscription-plans");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      return jsonData['data']; // List return thase
    } else {
      throw Exception("Failed to load subscription plans");
    }
  }
}

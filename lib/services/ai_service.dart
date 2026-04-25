import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY');
const String askAIEndpoint = "https://campusyncserver.onrender.com/ask";

Future<String> askAI(String message) async {
  try {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.post(
      Uri.parse(askAIEndpoint),
      headers: {
        "Content-Type": "application/json",
        if (idToken != null) "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({"message": message}),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return "Error: ${data["error"] ?? response.body}";
    }

    if (data["candidates"] != null &&
    data["candidates"].isNotEmpty) {
    return data["candidates"][0]["content"]["parts"][0]["text"];
    } else if (data["error"] != null) {
    return "Error: ${data["error"]}";
    } else {
    return "No response";
}

  } catch (e) {
    print(e);
    return "Connection failed 😢";
  }
}

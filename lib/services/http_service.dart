import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  // Base URL for your backend
  static const String baseUrl = 'YOUR_BACKEND_URL';

  // GET request example
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  // POST request example
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // PUT request example
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  // DELETE request example
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  // Handle response and check for errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
}

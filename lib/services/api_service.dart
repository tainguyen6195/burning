import 'dart:convert';

import 'package:bruning/models/product_response.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<ProductResponse> getProducts({
    required int skip,
    int limit = 20,
  }) async {
    print('ApiService: Fetching products. Skip: $skip, Limit: $limit');

    final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('ApiService: Products fetched successfully!');
        return ProductResponse.fromJson(jsonDecode(response.body));
      } else {
        print(
          'ApiService: Failed to load products. Status Code: ${response.statusCode}',
        );
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('ApiService: Exception occurred during getProducts: $e');
      rethrow;
    }
  }

  Future<ProductResponse> searchProducts({
    required String query,
    required int skip,
    int limit = 20,
  }) async {
    print('ApiService: Searching for "$query". Skip: $skip, Limit: $limit');

    final uri = Uri.parse(
      '$_baseUrl/products/search?q=$query&limit=$limit&skip=$skip',
    );
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('ApiService: Search for "$query" was successful!');
        return ProductResponse.fromJson(jsonDecode(response.body));
      } else {
        print(
          'ApiService: Failed to search for "$query". Status Code: ${response.statusCode}',
        );
        throw Exception('Failed to search products');
      }
    } catch (e) {
      print('ApiService: Exception occurred during searchProducts: $e');
      rethrow;
    }
  }
}

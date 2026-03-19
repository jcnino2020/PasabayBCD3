import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Base URL for the product API
  // In production, replace with your actual API endpoint
  static const String _baseUrl =
      'http://ov3.238.mytemp.website/pasabaybcd/api';

  /// Fetch all products from the server
  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body is List ? body : (body['data'] ?? []);
        return data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Add a new product to the server
  Future<Product?> addProduct(Product product) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/products.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(product.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['data'] != null) {
          return Product.fromJson(body['data'] as Map<String, dynamic>);
        }
        // Return the original product marked as synced if server doesn't return data
        return product.copyWith(isSynced: true);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing product on the server
  Future<Product?> updateProduct(Product product) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/products.php?id=${product.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(product.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['data'] != null) {
          return Product.fromJson(body['data'] as Map<String, dynamic>);
        }
        return product.copyWith(isSynced: true);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete a product from the server
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/products.php?id=$id'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Fetch a single product by ID (for conflict resolution)
  Future<Product?> getProductById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products.php?id=$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['data'] != null) {
          return Product.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

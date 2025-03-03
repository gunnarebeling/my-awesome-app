import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_awesome_app/api/api.dart';
import 'package:my_awesome_app/model/api_response.dart';
import 'package:my_awesome_app/model/api_error.dart';
import 'package:my_awesome_app/model/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class LoginApi extends Api {
  final storage = FlutterSecureStorage();
  
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      return client
          .post(
            Uri.parse('$apiUrl/api/Auth/login'),
            headers: await getDefaultHeaders(),
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .then((response) => _processLoginResponse(response));
    } catch (e) {
      return ApiResponse<User>(
        error: ApiError(
          500,
          'Network error during login: ${e.toString()}'
        )
      );
    }
  }
  
  ApiResponse<User> _processLoginResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        
        // Store the token securely
        String token = jsonResponse['token'];
        storeToken(token);
        
        // Return a successful response with no data
        return ApiResponse<User>(
          data: null,  // Initially null until we fetch user data
          headers: response.headers
        );
      } else {
        // Create an ApiError object
        final errorData = json.decode(response.body);
        final error = ApiError(
          response.statusCode,
          errorData['message'] ?? errorData['error'] ?? 'Login failed',
          details: errorData
        );
        
        // Return a response with an error
        return ApiResponse<User>(
          error: error,
          headers: response.headers
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        error: ApiError(
          500,
          'Error processing login response: ${e.toString()}'
        )
      );
    }
  }
  
  Future<void> storeToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }
  
  Future<User?> loginAndGetUserDetails(String email, String password) async {
    final loginResponse = await login(email, password);
    
    // Check if there's no error instead of checking success property
    if (loginResponse.error == null) {
      // Now fetch user details using the stored token
      final userResponse = await fetchCurrentUser();
      return userResponse.data;
    }
    
    return null;
  }
  
  Future<Map<String, String>> getDefaultHeaders() async {
    return {
      'Content-Type': 'application/json',
    };
  }
  
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<ApiResponse<User>> fetchCurrentUser() async {
    try {
      return client
          .get(
            Uri.parse('$apiUrl/api/Auth/me'),
            headers: await getAuthenticatedHeaders(),
          )
          .then((response) {
            if (response.statusCode == 200) {
              try {
                var userData = json.decode(response.body);
                
                // Get the user data - handle different API response formats
                var userObj = userData;
                if (userData['user'] != null) {
                  userObj = userData['user'];
                }
                
                // Parse the user data into your User model
                User user = User(
                  id: userObj['id'],
                  email: userObj['email'],
                  firstName: userObj['firstName'],
                  lastName: userObj['lastName'],
                  phoneNumber: userObj['phoneNumber'],
                  role: userObj['role'] ?? 'User',
                );
                
                return ApiResponse<User>(
                  data: user,
                  headers: response.headers
                );
              } catch (e) {
                return ApiResponse<User>(
                  error: ApiError(
                    500,
                    'Failed to parse user data: ${e.toString()}'
                  )
                );
              }
            } else {
              // Create an ApiError object
              try {
                final errorData = json.decode(response.body);
                final error = ApiError(
                  response.statusCode,
                  'Failed to fetch user',
                  details: errorData
                );
                
                return ApiResponse<User>(
                  error: error,
                  headers: response.headers
                );
              } catch (e) {
                return ApiResponse<User>(
                  error: ApiError(
                    response.statusCode,
                    'Error fetching user: ${response.body}'
                  )
                );
              }
            }
          });
    } catch (e) {
      return ApiResponse<User>(
        error: ApiError(
          500,
          'Network error during user fetch: ${e.toString()}'
        )
      );
    }
  }
  
  Future<bool> logout() async {
    try {
      await storage.delete(key: 'auth_token');
      return true;
    } catch (e) {
      print("Logout error: $e");
      return false;
    }
  }
}
import 'dart:io';

import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_endpoints.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // Getter to access the ApiClient
  ApiClient get client => _client;

  // Auth related APIs
  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.login, body: userData);
  }

  // Profile related APIs
  Future<Map<String, dynamic>> fetchProfile() async {
    return await _client.get(ApiEndpoints.profile);
  }

  // Schedule related APIs
  Future<Map<String, dynamic>> getSchedule() async {
    return await _client.get(ApiEndpoints.schedule);
  }

  // Job related APIs
  Future<Map<String, dynamic>> getJobAndAds() async {
    return await _client.get(ApiEndpoints.jobAndAds);
  }

  // Compliance related APIs
  Future<Map<String, dynamic>> getCompliance() async {
    return await _client.get(ApiEndpoints.compliance);
  }

  // Contact related APIs
  Future<Map<String, dynamic>> submitContactForm(Map<String, String> data) async {
    return await client.post(ApiEndpoints.contactUs, body: data);
  }

  // Add Request related APIs
  Future<Map<String, dynamic>> addDeductionWithSignature(
      Map<String, dynamic> deductionData,
      File signatureFile,
      String fileFieldName
      ) async {
    return await _client.postMultipart(
        ApiEndpoints.addDeduction,
        body: deductionData,
        file: signatureFile,
        fileField: fileFieldName
    );
  }
}

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
  Future<Map<String, dynamic>> getSchedule(Map<String, dynamic> body) async {
    return await _client.post(ApiEndpoints.schedule, body: body);
  }

  // Job related APIs
  Future<Map<String, dynamic>> getJobAndAds() async {
    return await _client.get(ApiEndpoints.jobAndAds);
  }

  //Job Share related APIs
  Future<Map<String, dynamic>> getJobShare(Map<String, dynamic> body) async {
    // Use form-data instead of JSON for this specific endpoint
    return await _client.post(ApiEndpoints.jobShare, body: body, useFormData: true);
  }

  // Compliance related APIs
  Future<Map<String, dynamic>> getCompliance() async {
    return await _client.get(ApiEndpoints.compliance);
  }

  // Assigned Training related APIs
  Future<Map<String, dynamic>> getTrainingAssigned() async {
    return await _client.get(ApiEndpoints.getTrainingAssigned);
  }

  // Completed Training related APIs
  Future<Map<String, dynamic>> getTrainingCompleted() async {
    return await _client.get(ApiEndpoints.getTrainingCompleted);
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

  // Weather related APIs
  Future<Map<String, dynamic>> getWeather() async {
    return await _client.get(ApiEndpoints.getWeather);
  }

  // // Add parameters to the getWeather method
  // Future<Map<String, dynamic>> getWeather({double? lat, double? long}) async {
  //   Map<String, dynamic>? queryParams;
  //
  //   if (lat != null && long != null) {
  //     queryParams = {
  //       'lat': lat.toString(),
  //       'long': long.toString(),
  //     };
  //   }
  //
  //   return await _client.get(ApiEndpoints.getWeather, queryParams: queryParams);
  // }

// Add method to get location data
  Future<Map<String, dynamic>> getWeatherLocation() async {
    return await _client.get(ApiEndpoints.getWeatherEpicode);
  }

  //Quote related APIs
  Future<Map<String, dynamic>> getQuote() async {
    return await _client.fetchQuote();
  }

  //Training Doc related APIs
  Future<Map<String, dynamic>> trainingDoc(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.trainingDoc, body: userData);
  }

  //Training Doc View related APIs
  Future<Map<String, dynamic>> trainingDocView(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.trainingView, body: userData);
  }

  // Show check in button related APIs
  Future<Map<String, dynamic>> getCheckInButton() async {
    return await _client.get(ApiEndpoints.showCheckIn);
  }

  //Test related APIs
  Future<Map<String, dynamic>> giveTest(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.giveTest, body: userData);
  }

  //Compliance Download related APIs
  Future<Map<String, dynamic>> complianceDownload(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.complianceDownload, body: userData);
  }

  //Check In related APIs
  Future<Map<String, dynamic>> checkIn(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.checkIn, body: userData);
  }

  //Check Out related APIs
  Future<Map<String, dynamic>> checkOut(Map<String, dynamic> userData) async {
    return await _client.post(ApiEndpoints.checkOut, body: userData);
  }

  //Submit Test related APIs
  Future<Map<String, dynamic>> submitTest(Map<String, dynamic> userData, {File? signatureFile}) async {
    if (signatureFile != null) {
      return await _client.postMultipart(
          ApiEndpoints.submitTest,
          body: userData,
          file: signatureFile,
          fileField: 'signature'
      );
    } else {
      return await _client.post(ApiEndpoints.submitTest, body: userData);
    }
  }
}
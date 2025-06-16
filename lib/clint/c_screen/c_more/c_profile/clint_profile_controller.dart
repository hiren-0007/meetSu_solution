import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/client/profile/client_profile_response_model.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

enum ProfileTab { contact, address, company }

class ClientProfileController extends ChangeNotifier {
  final ApiService _apiService;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  ProfileTab _selectedTab = ProfileTab.contact;

  // Data
  Client? _client;
  Company? _company;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  ProfileTab get selectedTab => _selectedTab;
  Client? get client => _client;
  Company? get company => _company;
  bool get hasData => _client != null && _company != null;

  // Constructor
  ClientProfileController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient());

  // Contact getters
  String get contactName => _client?.contactName ?? '';
  String get email => _client?.email ?? '';
  String get telephone => _client?.telephone ?? '';
  String get ext => _client?.ext?.toString() ?? '';
  String get alternateContactNo => _client?.alternateContactNo ?? '';
  String get username => _client?.username ?? '';
  String get fax => _client?.fax ?? '';

  // Address getters
  String get address => _company?.address ?? '';
  String get address2 => _company?.address2 ?? '';
  String get country => _company?.countryName ?? '';
  String get province => _company?.provinceName ?? '';
  String get city => _company?.cityName ?? '';
  String get postalCode => _company?.postalCode ?? '';

  // Company getters
  String get companyName => _company?.companyName ?? '';
  String get shortName => _company?.shortName ?? '';
  String get companyEmail => _company?.email ?? '';
  String get companyTelephone => _company?.telephone ?? '';
  String get companyContactName => _company?.contactPerson ?? '';
  String get companyFax => _company?.fax ?? '';
  String get companyLogo => _company?.logoFullPath ?? '';

  void setSelectedTab(ProfileTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> loadProfileData() async {
    _setLoading(true);
    clearMessages();

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token?.isEmpty ?? true) {
        throw Exception("Please log in to continue");
      }

      _apiService.client.addAuthToken(token!);
      final response = await _apiService.getClintProfile();

      final profileResponse = ClientProfileResponseModel.fromJson(response);

      if (profileResponse.success == true) {
        _client = profileResponse.client;
        _company = profileResponse.company;
        return true;
      } else {
        throw Exception("Failed to load profile data");
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfileData() async {
    _setLoading(true);
    clearMessages();

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token?.isEmpty ?? true) {
        throw Exception("Please log in to continue");
      }

      // Simulate save operation
      await Future.delayed(const Duration(milliseconds: 500));

      _successMessage = "Profile updated successfully!";
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains("401") || errorStr.contains("unauthorized")) {
      return "Session expired. Please log in again.";
    } else if (errorStr.contains("network") || errorStr.contains("connection")) {
      return "Network error. Please check your connection.";
    } else if (errorStr.contains("timeout")) {
      return "Request timed out. Please try again.";
    } else {
      return "Failed to load profile data. Please try again.";
    }
  }
}
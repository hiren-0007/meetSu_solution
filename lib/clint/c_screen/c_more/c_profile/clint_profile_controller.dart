import 'package:flutter/material.dart';

enum TabType {
  contact,
  address,
  company,
  password,
}

class ClientProfileController extends ChangeNotifier {
  // Selected tab
  TabType _selectedTab = TabType.contact;
  TabType get selectedTab => _selectedTab;

  // Password protection
  bool _isPasswordProtected = true;
  bool get isPasswordProtected => _isPasswordProtected;

  // Password controllers
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Contact Details Tab
  String _contactName = 'Hiren Panchal';
  String _email = 'hiren@gmail.com';
  String _telephone = '123 123 1213';
  String _ext = '';
  String _alternateContactNo = '';
  String _username = 'hiren';
  String _fax = '';

  // Address Details Tab
  String _address = '99A - Dundas Street East';
  String _address2 = '2nd Floor';
  String _country = 'Canada';
  String _province = 'Ontario';
  String _city = 'Mississauga';
  String _postalCode = 'L5A 1W7';

  // Company Details Tab
  String _companyName = 'MEETsu Solutions';
  String _shortName = 'MEETsu';
  String _companyEmail = 'reg@meetsusolutions.com';
  String _companyTelephone = '905 232 5200';
  String _companyContactName = 'Reg Christian';
  String _companyFax = '';
  String _companyLogo = 'https://example.com/logo.png'; // Replace with actual logo URL or asset path

  // Getters for Contact Details
  String get contactName => _contactName;
  String get email => _email;
  String get telephone => _telephone;
  String get ext => _ext;
  String get alternateContactNo => _alternateContactNo;
  String get username => _username;
  String get fax => _fax;

  // Getters for Address Details
  String get address => _address;
  String get address2 => _address2;
  String get country => _country;
  String get province => _province;
  String get city => _city;
  String get postalCode => _postalCode;

  // Getters for Company Details
  String get companyName => _companyName;
  String get shortName => _shortName;
  String get companyEmail => _companyEmail;
  String get companyTelephone => _companyTelephone;
  String get companyContactName => _companyContactName;
  String get companyFax => _companyFax;
  String get companyLogo => _companyLogo;

  // Methods to change tab
  void setSelectedTab(TabType tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // Methods to update Contact Details
  void setContactName(String value) {
    _contactName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setTelephone(String value) {
    _telephone = value;
    notifyListeners();
  }

  void setExt(String value) {
    _ext = value;
    notifyListeners();
  }

  void setAlternateContactNo(String value) {
    _alternateContactNo = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setFax(String value) {
    _fax = value;
    notifyListeners();
  }

  // Methods to update Address Details
  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setAddress2(String value) {
    _address2 = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }

  void setProvince(String value) {
    _province = value;
    notifyListeners();
  }

  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  void setPostalCode(String value) {
    _postalCode = value;
    notifyListeners();
  }

  // Methods to update Company Details
  void setCompanyName(String value) {
    _companyName = value;
    notifyListeners();
  }

  void setShortName(String value) {
    _shortName = value;
    notifyListeners();
  }

  void setCompanyEmail(String value) {
    _companyEmail = value;
    notifyListeners();
  }

  void setCompanyTelephone(String value) {
    _companyTelephone = value;
    notifyListeners();
  }

  void setCompanyContactName(String value) {
    _companyContactName = value;
    notifyListeners();
  }

  void setCompanyFax(String value) {
    _companyFax = value;
    notifyListeners();
  }

  // Method to update company logo
  void updateCompanyLogo() {
    // Implementation would use ImagePicker or similar to choose a new logo
    // For now we just simulate a change
    _companyLogo = 'https://example.com/updated_logo.png';
    notifyListeners();
  }

  // Method to update password
  void updatePassword() {
    if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      // Show error: fields cannot be empty
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      // Show error: passwords don't match
      return;
    }

    // Simulate password update success
    passwordController.clear();
    confirmPasswordController.clear();

    // Toggle password protection (for demonstration)
    _isPasswordProtected = !_isPasswordProtected;

    notifyListeners();
  }

  // Load profile data from API/database
  Future<void> loadProfileData() async {
    // Implementation would fetch data from API
    // This is just a placeholder for the actual implementation
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }

  // Save profile data to API/database
  Future<void> saveProfileData() async {
    // Implementation would save data to API
    // This is just a placeholder for the actual implementation
    await Future.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
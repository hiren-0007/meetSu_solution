import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_cantroller.dart';

class PersonalInfoScreen extends StatefulWidget {
  final ProfileController? controller;

  const PersonalInfoScreen({
    super.key,
    this.controller,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _homeNoController = TextEditingController();
  final TextEditingController _simNoController = TextEditingController();
  final TextEditingController _simExpiryController = TextEditingController();

  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _emergencyEmailController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  final TextEditingController _referredByController = TextEditingController();
  final TextEditingController _referredRelationshipController = TextEditingController();

  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    if (widget.controller != null) {
      // Initialize fields with profile data
      final personalInfo = widget.controller!.personalInfo.value;
      final profileData = widget.controller!.profileData.value;

      if (personalInfo.fullName.isNotEmpty) {
        final nameParts = personalInfo.fullName.split(" ");
        if (nameParts.isNotEmpty) {
          _firstNameController.text = nameParts.first;
          if (nameParts.length > 1) {
            _lastNameController.text = nameParts.sublist(1).join(" ");
          }
        }
      }

      _typeController.text = personalInfo.gender;
      _dobController.text = personalInfo.dateOfBirth;

      // Get profile photo URL
      if (profileData != null) {
        photoUrl = profileData.photoUrl;
      }

      // Get emergency contact info
      final data = profileData?.data;
      if (data != null) {
        _mobileController.text = data.mobileNumber;
        _homeNoController.text = data.homeNumber;
        _simNoController.text = data.sinNo;
        _simExpiryController.text = data.sinExpiry;

        _emergencyNameController.text = data.emergencyName;
        _emergencyPhoneController.text = data.emergencyPhone;
        _emergencyEmailController.text = data.emergencyEmail;
        _relationshipController.text = data.emergencyRelationship;
        _languageController.text = data.emergencyLanguage;

        _referredByController.text = data.referredBy;
        _referredRelationshipController.text = data.referredRelationship;
      }
    } else {
      // Default values if no controller is provided
      _firstNameController.text = "HIREN";
      _lastNameController.text = "PANCHAL";
      _typeController.text = "Male";
      _dobController.text = "Oct 19 1999";
      _mobileController.text = "909 232 5200";
      _emergencyNameController.text = "TEST";
      _emergencyPhoneController.text = "311 313 1313";
      _relationshipController.text = "FRIEND";
      _languageController.text = "TEST";
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _typeController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _homeNoController.dispose();
    _simNoController.dispose();
    _simExpiryController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyEmailController.dispose();
    _relationshipController.dispose();
    _languageController.dispose();
    _referredByController.dispose();
    _referredRelationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _buildProfileImage(),
              ),
              const SizedBox(height: 20),
              _buildTextField("First Name :", _firstNameController),
              _buildTextField("Last Name :", _lastNameController),
              _buildTextField("Type :", _typeController),
              _buildTextField("Date Of Birth :", _dobController),
              _buildTextField("Mobile :", _mobileController),
              _buildTextField("Home No. :", _homeNoController),
              _buildTextField("Sim No :", _simNoController),
              _buildTextField("Sim Expiry :", _simExpiryController),
              const SizedBox(height: 20),
              const Text(
                "Emergency Contact",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField("Name :", _emergencyNameController),
              _buildTextField("Phone No :", _emergencyPhoneController),
              _buildTextField("Email :", _emergencyEmailController),
              _buildTextField("Relationship :", _relationshipController),
              _buildTextField("Language :", _languageController),
              const SizedBox(height: 20),
              const Text(
                "References",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField("Referred By :", _referredByController),
              _buildTextField(
                  "Referred Relationship :", _referredRelationshipController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return ValueListenableBuilder(
      valueListenable: widget.controller?.profileData ?? ValueNotifier(null),
      builder: (context, profileData, _) {
        final photoUrl = profileData?.photoUrl ?? this.photoUrl;

        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(50),
          ),
          child: photoUrl != null && photoUrl.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              photoUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
          )
              : const Icon(
            Icons.person,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            isDense: true,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
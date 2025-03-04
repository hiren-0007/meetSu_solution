import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController(text: "HIREN");
  final TextEditingController _lastNameController = TextEditingController(text: "PANCHAL");
  final TextEditingController _typeController = TextEditingController(text: "Male");
  final TextEditingController _dobController = TextEditingController(text: "Oct 19 1999");
  final TextEditingController _mobileController = TextEditingController(text: "909 232 5200");
  final TextEditingController _homeNoController = TextEditingController();
  final TextEditingController _simNoController = TextEditingController();
  final TextEditingController _simExpiryController = TextEditingController();

  // Emergency contact controllers
  final TextEditingController _emergencyNameController = TextEditingController(text: "TEST");
  final TextEditingController _emergencyPhoneController = TextEditingController(text: "311 313 1313");
  final TextEditingController _emergencyEmailController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController(text: "FRIEND");
  final TextEditingController _languageController = TextEditingController(text: "TEST");

  // Reference controllers
  final TextEditingController _referredByController = TextEditingController();
  final TextEditingController _referredRelationshipController = TextEditingController();

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
      appBar: AppBar(
        title: const Text("Personal Information"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Container
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Personal Details
              _buildTextField("First Name :", _firstNameController),
              _buildTextField("Last Name :", _lastNameController),
              _buildTextField("Type :", _typeController),
              _buildTextField("Date Of Birth :", _dobController),
              _buildTextField("Mobile :", _mobileController),
              _buildTextField("Home No. :", _homeNoController),
              _buildTextField("Sim No :", _simNoController),
              _buildTextField("Sim Expiry :", _simExpiryController),

              const SizedBox(height: 20),

              // Emergency Contact Section
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

              // References Section
              const Text(
                "References",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              _buildTextField("Referred By :", _referredByController),
              _buildTextField("Referred Relationship :", _referredRelationshipController),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Save functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Information Saved")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
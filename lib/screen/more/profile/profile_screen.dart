import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/profile/personalinfo/personal_info_sreen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_cantroller.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  int _selectedTab = 0;

  final List<String> _tabTitles = [
    "Login Info",
    "Aptitude",
    "Personal",
    "Address",
    "Education",
    "Experience",
    "Credentials"
  ];

  @override
  void initState() {
    super.initState();

    // Set up API client with auth token
    final token = SharedPrefsService.instance.getAccessToken();
    final apiClient = ApiClient(headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (token != null && token.isNotEmpty) {
      apiClient.addAuthToken(token);
    }

    _controller = ProfileController(apiService: ApiService(apiClient));
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3), // Match blue background
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            return ValueListenableBuilder<String?>(
              valueListenable: _controller.errorMessage,
              builder: (context, errorMessage, child) {
                if (errorMessage != null && errorMessage.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Error loading profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _controller.initialize(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2196F3),
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return child!;
              },
              child: Column(
                children: [
                  // App bar with back button and title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white30,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Profile",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  // Profile photo or avatar
                  ValueListenableBuilder(
                    valueListenable: _controller.profileData,
                    builder: (context, profileData, _) {
                      // Check if there's a photo URL in the profileData
                      String? photoUrl = profileData?.photoUrl;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: photoUrl != null && photoUrl.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: photoUrl == null || photoUrl.isEmpty
                            ? const Icon(
                          Icons.person,
                          color: Color(0xFF2196F3),
                          size: 30,
                        )
                            : null,
                      );
                    },
                  ),

                  // Main content in white card
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title with dropdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Title - with flexible to prevent overflow
                              Flexible(
                                child: Text(
                                  _selectedTab == 5 ? "Work Experience" : _tabTitles[_selectedTab],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Dropdown for tab selection
                              DropdownButton<int>(
                                value: _selectedTab,
                                icon: const Icon(Icons.arrow_drop_down),
                                elevation: 16,
                                underline: Container(height: 0),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedTab = newValue;
                                    });
                                  }
                                },
                                items: List.generate(_tabTitles.length, (index) {
                                  return DropdownMenuItem<int>(
                                    value: index,
                                    child: Text(_tabTitles[index]),
                                  );
                                }),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "We'd like to know more about you",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Content based on selected tab
                          Expanded(
                            child: _buildSelectedTabContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildLoginTab();
      case 1:
        return _buildAptitudeTab();
      case 2:
        return const PersonalInfoScreen();
      case 3:
        return _buildAddressTab();
      case 4:
        return _buildEducationTab();
      case 5:
        return _buildExperienceTab();
      case 6:
        return _buildCredentialsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // Login Tab
  Widget _buildLoginTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.loginInfo,
      builder: (context, loginInfo, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoField("Username", loginInfo.username),
              _buildInfoField("Email", loginInfo.email),
              _buildInfoField("Phone", loginInfo.phone),
              _buildInfoField("Role", loginInfo.role),
              _buildInfoField("Last Login", loginInfo.lastLogin),

              const SizedBox(height: 24),
              _buildSubmitButton("Update Info", () async {
                final result = await _controller.submitProfile();
                if (result && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully")),
                  );
                }
              }),
            ],
          ),
        );
      },
    );
  }

  // Aptitude Tab
  Widget _buildAptitudeTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.aptitudeInfo,
      builder: (context, aptitudeInfo, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoField("Test Scores", aptitudeInfo.testScores),
              _buildInfoField("Skills", aptitudeInfo.skills),
              _buildInfoField("Certifications", aptitudeInfo.certifications),

              const SizedBox(height: 24),
              _buildSubmitButton("Update Skills", () async {
                final result = await _controller.submitProfile();
                if (result && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Skills updated successfully")),
                  );
                }
              }),
            ],
          ),
        );
      },
    );
  }

  // Address Tab
  Widget _buildAddressTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.addressInfo,
      builder: (context, addressInfo, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoField("Street", addressInfo.street),
              _buildInfoField("City", addressInfo.city),
              _buildInfoField("State/Province", addressInfo.state),
              _buildInfoField("Postal Code", addressInfo.postalCode),
              _buildInfoField("Country", addressInfo.country),

              const SizedBox(height: 24),
              _buildSubmitButton("Update Address", () async {
                final result = await _controller.submitProfile();
                if (result && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Address updated successfully")),
                  );
                }
              }),
            ],
          ),
        );
      },
    );
  }

  // Education Tab
  Widget _buildEducationTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.educationList,
      builder: (context, educationList, _) {
        return Column(
          children: [
            Expanded(
              child: educationList.isEmpty
                  ? Center(
                child: Text(
                  "No education information added yet",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
                  : ListView.builder(
                itemCount: educationList.length,
                itemBuilder: (context, index) {
                  final education = educationList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          education.degree,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          education.institution,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${education.startDate.isNotEmpty ? education.startDate : 'N/A'} - ${education.endDate.isNotEmpty ? education.endDate : 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (education.grade.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Grade: ${education.grade}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildSubmitButton("Add Education", () {
              _controller.addEducation(context);
            }),
          ],
        );
      },
    );
  }

  // Experience Tab
  Widget _buildExperienceTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.experienceList,
      builder: (context, experienceList, _) {
        return Column(
          children: [
            Expanded(
              child: experienceList.isEmpty
                  ? Center(
                child: Text(
                  "No experience information added yet",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
                  : ListView.builder(
                itemCount: experienceList.length,
                itemBuilder: (context, index) {
                  final experience = experienceList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Company Name: ${experience.company}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Position Name: ${experience.position}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Years of Experience: ${experience.yearsOfExperience}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start Date: ${experience.startDate}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "End Date: ${experience.endDate}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (experience.supervisor.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Name of Supervisor: ${experience.supervisor}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildSubmitButton("Add Experience", () {
              _controller.addExperience(context);
            }),
          ],
        );
      },
    );
  }

  // Credentials Tab
  Widget _buildCredentialsTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.credentialInfo,
      builder: (context, credentialInfo, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoField("ID Number", credentialInfo.idNumber),
              _buildInfoField("Passport", credentialInfo.passport),
              _buildInfoField("Driver's License", credentialInfo.driversLicense),
              _buildInfoField("Tax ID", credentialInfo.taxId),
              _buildInfoField("Social Security", credentialInfo.socialSecurity),

              const SizedBox(height: 24),
              _buildSubmitButton("Update Credentials", () async {
                final result = await _controller.submitProfile();
                if (result && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Credentials updated successfully")),
                  );
                }
              }),
            ],
          ),
        );
      },
    );
  }

  // Helper method for info fields
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.edit,
                color: Color(0xFF2196F3),
                size: 18,
              ),
              const SizedBox(width: 12),
              // Wrap the text with Flexible to prevent overflow
              Flexible(
                child: Text(
                  value.isEmpty ? "Not provided" : value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper method for submit button with callback
  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
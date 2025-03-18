import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/profile/personalinfo/personal_info_sreen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_cantroller.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

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
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: const Color(0xFF2196F3),
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
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),

                            const SizedBox(height: 16),

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
            ],
          ),
        );
      },
    );
  }

  // Aptitude Tab
  Widget _buildAptitudeTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.profileData,
      builder: (context, profileData, _) {
        if (profileData == null || profileData.aptitude.isEmpty) {
          return Center(
            child: Text(
              "No aptitude information available",
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        // Get aptitude test summary
        int totalQuestions = 0;
        int correctAnswers = 0;

        // Calculate from category_wise_answer
        profileData.categoryWiseAnswer.forEach((key, value) {
          totalQuestions += value.totalQuestion;
          correctAnswers += value.correctAnswer;
        });

        String testScore = totalQuestions > 0
            ? "$correctAnswers/$totalQuestions"
            : "0/0";

        double scorePercentage = totalQuestions > 0
            ? (correctAnswers / totalQuestions) * 100
            : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aptitude Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aptitude Test Results",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Score",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            testScore,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Percentage",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            "${scorePercentage.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Category-wise results section
            Text(
              "Category Breakdown",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),

            // Category list
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profileData.categoryWiseAnswer.length,
                itemBuilder: (context, index) {
                  final entry = profileData.categoryWiseAnswer.entries.elementAt(index);
                  final categoryKey = entry.key;
                  final category = entry.value;

                  double categoryPercentage = category.totalQuestion > 0
                      ? (category.correctAnswer / category.totalQuestion) * 100
                      : 0;

                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${category.correctAnswer}/${category.totalQuestion}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${categoryPercentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // Questions and Answers Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Questions & Answers",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "${profileData.aptitude.length} Questions",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions List
            Expanded(
              child: ListView.builder(
                itemCount: profileData.aptitude.length,
                itemBuilder: (context, index) {
                  final question = profileData.aptitude[index];

                  // Get the correct and given answer indices (convert from string to int)
                  int correctAnsIndex = int.tryParse(question.correctAnswer) ?? 1;
                  int givenAnsIndex = question.givenAnswer;

                  // Check if the answer was correct
                  bool isCorrect = correctAnsIndex == givenAnsIndex;

                  // Create a list of answer options
                  List<String> answerOptions = [
                    question.answer1,
                    question.answer2,
                    question.answer3,
                    question.answer4,
                  ];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.question,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Category: ${question.category}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Answer Options
                        ...List.generate(4, (i) {
                          // Option letter (A, B, C, D)
                          String optionLetter = String.fromCharCode(65 + i);

                          // Check if this is the correct answer or the given answer
                          bool isCorrectOption = correctAnsIndex == (i + 1);
                          bool isGivenOption = givenAnsIndex == (i + 1);

                          // Set color based on correctness and selection
                          Color optionColor = Colors.transparent;
                          Color textColor = Colors.black;

                          if (isGivenOption) {
                            if (isCorrect) {
                              // Given answer is correct
                              optionColor = Colors.green.shade100;
                              textColor = Colors.green.shade800;
                            } else {
                              // Given answer is wrong
                              optionColor = Colors.red.shade100;
                              textColor = Colors.red.shade800;
                            }
                          } else if (isCorrectOption && !isCorrect) {
                            // Show correct answer when user got it wrong
                            optionColor = Colors.green.shade50;
                            textColor = Colors.green.shade800;
                          }

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: optionColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isGivenOption || (isCorrectOption && !isCorrect)
                                    ? textColor.withOpacity(0.5)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isGivenOption || (isCorrectOption && !isCorrect)
                                          ? textColor
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    optionLetter,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isGivenOption || (isCorrectOption && !isCorrect)
                                          ? textColor
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    answerOptions[i],
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: isCorrectOption || isGivenOption
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isGivenOption)
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                    size: 18,
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
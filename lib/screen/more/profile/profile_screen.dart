import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:meetsu_solutions/screen/more/profile/personalinfo/personal_info_sreen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_cantroller.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../model/profile/profile_response_model.dart';
import '../../../utils/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  int _selectedTab = 0;
  String? username;
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
    username = SharedPrefsService.instance.getUsername();
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
        backgroundColor: AppTheme.primaryColor,
        body: SafeArea(
          child: ValueListenableBuilder<bool>(
            valueListenable: _controller.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.white,
                  ),
                );
              }

              return ValueListenableBuilder<String?>(
                valueListenable: _controller.errorMessage,
                builder: (context, errorMessage, child) {
                  if (errorMessage != null && errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppTheme.screenPadding),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Error loading profile",
                              style: AppTheme.errorStyle,
                            ),
                            const SizedBox(height: AppTheme.extraSmallSpacing),
                            Text(
                              errorMessage,
                              style: AppTheme.errorMessageStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.contentSpacing),
                            ElevatedButton(
                              onPressed: () => _controller.initialize(),
                              style: AppTheme.retryButtonStyle,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.screenPadding,
                        vertical: AppTheme.smallSpacing + 2,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(AppTheme.iconPadding),
                              decoration: AppTheme.backButtonDecoration,
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppTheme.iconColorPrimary,
                                size: AppTheme.mediumIconSize,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                "Profile",
                                style: AppTheme.titleStyle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 16.0, top: 8.0, bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    username ?? "User",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _controller.profileData,
                      builder: (context, profileData, _) {
                        String? photoUrl =
                            "https://meetsusolutions.com/${profileData?.photoUrl}";

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppTheme.contentSpacing),
                          width: AppTheme.tabIconHeight,
                          height: AppTheme.tabIconHeight,
                          decoration: photoUrl != null && photoUrl.isNotEmpty
                              ? AppTheme.avatarWithPhotoDecoration(photoUrl)
                              : AppTheme.avatarWithoutPhotoDecoration,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                  size: AppTheme.largeIconSize,
                                )
                              : null,
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.contentSpacing,
                          AppTheme.mediumSpacing,
                          AppTheme.contentSpacing,
                          0,
                        ),
                        decoration: AppTheme.profileContentDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _selectedTab == 5
                                        ? "Work Experience"
                                        : _tabTitles[_selectedTab],
                                    style: AppTheme.sectionTitleStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                                  items:
                                      List.generate(_tabTitles.length, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(_tabTitles[index]),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.extraSmallSpacing),
                            Text(
                              "We'd like to know more about you",
                              style: AppTheme.sectionSubtitleStyle,
                            ),
                            const SizedBox(height: AppTheme.contentSpacing),
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
        return _buildPersonalInfoTab();
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

  String buildCredentialUrl(String baseImagePath) {
    // If it's already a full URL, return it as is
    if (baseImagePath.startsWith('http')) {
      return baseImagePath;
    }

    // Use the base URL
    const String baseUrl = 'https://www.meetsusolutions.com';

    // Get credential path from profileData
    String credentialPath = '';
    if (_controller.profileData.value != null) {
      credentialPath = _controller.profileData.value!.credentialUrl;
    } else {
      // Default path
      credentialPath = '/applicant/web/uploads/applicant_credential/big/';
    }

    // Make sure credentialPath starts with / and doesn't end with /
    if (!credentialPath.startsWith('/')) {
      credentialPath = '/$credentialPath';
    }
    if (credentialPath.endsWith('/')) {
      credentialPath = credentialPath.substring(0, credentialPath.length - 1);
    }

    // Make sure baseImagePath doesn't start with /
    String imagePath = baseImagePath;
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    // Build the final URL correctly
    return '$baseUrl$credentialPath/$imagePath';
  }

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
              const SizedBox(height: AppTheme.mediumSpacing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAptitudeTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.profileData,
      builder: (context, profileData, _) {
        if (profileData == null || profileData.aptitude.isEmpty) {
          return Center(
            child: Text(
              "No aptitude information available",
              style: AppTheme.emptyStateStyle,
            ),
          );
        }

        // Calculate total scores from categoryWiseAnswer
        int totalQuestions = 0;
        int correctAnswers = 0;

        profileData.categoryWiseAnswer.forEach((key, value) {
          totalQuestions += value.totalQuestion;
          correctAnswers += value.correctAnswer;
        });

        String testScore =
            totalQuestions > 0 ? "$correctAnswers/$totalQuestions" : "0/0";
        double scorePercentage =
            totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.contentSpacing),
              decoration: AppTheme.aptitudeCardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aptitude Test Results",
                    style: AppTheme.aptitudeTitleStyle,
                  ),
                  const SizedBox(height: AppTheme.extraSmallSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Score",
                            style: AppTheme.aptitudeLabelStyle,
                          ),
                          Text(
                            testScore,
                            style: AppTheme.aptitudeValueStyle,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Percentage",
                            style: AppTheme.aptitudeLabelStyle,
                          ),
                          Text(
                            "${scorePercentage.toStringAsFixed(1)}%",
                            style: AppTheme.aptitudeValueStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.contentSpacing - 2),
            Text(
              "Category Breakdown",
              style: AppTheme.categoryTitleStyle,
            ),
            const SizedBox(height: AppTheme.smallSpacing),
            SizedBox(
              height: AppTheme.tabBarHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profileData.categoryWiseAnswer.length,
                itemBuilder: (context, index) {
                  final entry =
                      profileData.categoryWiseAnswer.entries.elementAt(index);
                  final categoryKey = entry.key;
                  final category = entry.value;

                  double categoryPercentage = category.totalQuestion > 0
                      ? (category.correctAnswer / category.totalQuestion) * 100
                      : 0;

                  return Container(
                    width: AppTheme.categoryCardWidth,
                    margin: const EdgeInsets.only(right: AppTheme.smallSpacing),
                    padding: const EdgeInsets.all(AppTheme.smallSpacing),
                    decoration: AppTheme.categoryCardDecoration,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.category,
                          textAlign: TextAlign.center,
                          style: AppTheme.tabTitleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.miniSpacing),
                        Text(
                          "${category.correctAnswer}/${category.totalQuestion}",
                          style: AppTheme.categoryScoreStyle,
                        ),
                        Text(
                          "${categoryPercentage.toStringAsFixed(1)}%",
                          style: AppTheme.categoryPercentStyle,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.contentSpacing - 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Questions & Answers",
                  style: AppTheme.categoryTitleStyle,
                ),
                Text(
                  "${profileData.aptitude.length} Questions",
                  style: AppTheme.categoryPercentStyle,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.smallSpacing),
            Expanded(
              child: ListView.builder(
                itemCount: profileData.aptitude.length,
                itemBuilder: (context, index) {
                  final question = profileData.aptitude[index];

                  int correctAnsIndex =
                      int.tryParse(question.correctAnswer) ?? 1;
                  int givenAnsIndex = question.givenAnswer;

                  bool isCorrect = correctAnsIndex == givenAnsIndex;

                  List<String> answerOptions = [
                    question.answer1,
                    question.answer2,
                    question.answer3,
                    question.answer4,
                  ];

                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: AppTheme.contentSpacing),
                    padding: const EdgeInsets.all(AppTheme.contentSpacing),
                    decoration: AppTheme.questionCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  AppTheme.miniSpacing + 1),
                              decoration: BoxDecoration(
                                color: AppTheme.aptitudeCardColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: AppTheme.aptitudeTitleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.smallSpacing),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.question,
                                    style: AppTheme.questionStyle,
                                  ),
                                  const SizedBox(height: AppTheme.microSpacing),
                                  Text(
                                    "Category: ${question.category}",
                                    style: AppTheme.questionCategoryStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.smallSpacing),
                        ...List.generate(4, (i) {
                          String optionLetter = String.fromCharCode(65 + i);

                          bool isCorrectOption = correctAnsIndex == (i + 1);
                          bool isGivenOption = givenAnsIndex == (i + 1);

                          Color optionColor = AppTheme.transparent;
                          Color textColor = AppTheme.textPrimaryColor;

                          if (isGivenOption) {
                            if (isCorrect) {
                              optionColor = AppTheme.correctAnswerBgColor;
                              textColor = AppTheme.correctAnswerTextColor;
                            } else {
                              optionColor = AppTheme.wrongAnswerBgColor;
                              textColor = AppTheme.wrongAnswerTextColor;
                            }
                          } else if (isCorrectOption && !isCorrect) {
                            optionColor = AppTheme.correctAnswerLightBgColor;
                            textColor = AppTheme.correctAnswerTextColor;
                          }

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                                bottom: AppTheme.extraSmallSpacing),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.smallSpacing + 2,
                              vertical: AppTheme.extraSmallSpacing,
                            ),
                            decoration: BoxDecoration(
                              color: optionColor,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.miniRadius),
                              border: Border.all(
                                color: isGivenOption ||
                                        (isCorrectOption && !isCorrect)
                                    ? textColor.withOpacity(0.5)
                                    : AppTheme.categoryCardBorderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: AppTheme.optionCircleSize,
                                  height: AppTheme.optionCircleSize,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isGivenOption ||
                                              (isCorrectOption && !isCorrect)
                                          ? textColor
                                          : AppTheme.categoryCardBorderColor,
                                      width: 1.5,
                                    ),
                                    color: isGivenOption ||
                                            (isCorrectOption && !isCorrect)
                                        ? Colors.transparent
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    optionLetter,
                                    style: TextStyle(
                                      fontSize: AppTheme.textSizeExtraSmall,
                                      fontWeight: FontWeight.bold,
                                      color: isGivenOption ||
                                              (isCorrectOption && !isCorrect)
                                          ? textColor
                                          : AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.smallSpacing),
                                Expanded(
                                  child: Text(
                                    answerOptions[i],
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight:
                                          isCorrectOption || isGivenOption
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isGivenOption)
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isCorrect
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                    size: AppTheme.smallIconSize,
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

  Widget _buildAddressTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.addressInfo,
      builder: (context, addressInfo, _) {
        return ValueListenableBuilder(
            valueListenable: _controller.profileData,
            builder: (context, profileData, _) {
              // If profile data is available, use it directly
              final street = profileData?.data.address ?? addressInfo.street;
              final city = profileData?.city ?? addressInfo.city;
              final state = profileData?.province ?? addressInfo.state;
              final postalCode =
                  profileData?.data.postalCode ?? addressInfo.postalCode;
              final country = profileData?.country ?? addressInfo.country;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField("Street", street),
                    _buildInfoField("City", city),
                    _buildInfoField("State/Province", state),
                    _buildInfoField("Postal Code", postalCode),
                    _buildInfoField("Country", country),
                    const SizedBox(height: AppTheme.mediumSpacing),
                  ],
                ),
              );
            });
      },
    );
  }

  Widget _buildEducationTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.profileData,
      builder: (context, profileData, _) {
        final educationList = profileData?.education ?? [];

        // Also use educationList ValueNotifier as a fallback
        return ValueListenableBuilder(
          valueListenable: _controller.educationList,
          builder: (context, controllerEducationList, _) {
            final displayList = educationList.isNotEmpty
                ? educationList
                : controllerEducationList;

            return Column(
              children: [
                Expanded(
                  child: displayList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: Colors.grey.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No education information added yet",
                                style: AppTheme.emptyStateStyle,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            // Handle both Education model from API and EducationInfo from controller
                            final education = displayList[index];

                            // Extract data based on which model we're dealing with
                            final String degree = education is Education
                                ? education.courseName
                                : (education as EducationInfo).degree;

                            final String institution = education is Education
                                ? education.collegeName
                                : (education as EducationInfo).institution;

                            final String startDate = education is Education
                                ? ""
                                : // API model doesn't have startDate
                                (education as EducationInfo).startDate;

                            final String endDate = education is Education
                                ? education.graduateYear
                                : (education as EducationInfo).endDate;

                            final String grade = education is Education
                                ? ""
                                : // API model doesn't have grade
                                (education as EducationInfo).grade;

                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(
                                  bottom: AppTheme.contentSpacing,
                                  left: 2,
                                  right: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(
                                    AppTheme.contentSpacing),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.blue.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabeledField(
                                      label: education is Education
                                          ? "Course Name"
                                          : "Degree",
                                      value: degree,
                                      icon: Icons.school,
                                    ),
                                    const SizedBox(height: 12),

                                    _buildLabeledField(
                                      label: "Institution",
                                      value: institution,
                                      icon: Icons.account_balance,
                                    ),
                                    const SizedBox(height: 12),

                                    _buildLabeledField(
                                      label: "Duration",
                                      value:
                                          "${startDate.isNotEmpty ? startDate : 'N/A'} - ${endDate.isNotEmpty ? endDate : 'N/A'}",
                                      icon: Icons.calendar_today,
                                    ),

                                    // Grade field with label (if available)
                                    if (grade.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _buildLabeledField(
                                        label: "Grade",
                                        value: grade,
                                        icon: Icons.grade,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExperienceTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.profileData,
      builder: (context, profileData, _) {
        final experienceList = profileData?.experience ?? [];

        // Also use experienceList ValueNotifier as a fallback
        return ValueListenableBuilder(
            valueListenable: _controller.experienceList,
            builder: (context, controllerExperienceList, _) {
              final displayList = experienceList.isNotEmpty
                  ? experienceList
                  : controllerExperienceList;

              return Column(
                children: [
                  Expanded(
                    child: displayList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 48,
                                  color: Colors.grey.withOpacity(0.6),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No experience information added yet",
                                  style: AppTheme.emptyStateStyle,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              // Handle both Experience model from API and ExperienceInfo from controller
                              final experience = displayList[index];

                              // Extract data based on which model we're dealing with
                              final String company = experience is Experience
                                  ? experience.companyName
                                  : (experience as ExperienceInfo).company;

                              final String position = experience is Experience
                                  ? experience.positionName
                                  : (experience as ExperienceInfo).position;

                              final String startDate = experience is Experience
                                  ? experience.startDate
                                  : (experience as ExperienceInfo).startDate;

                              final String endDate = experience is Experience
                                  ? experience.endDate
                                  : (experience as ExperienceInfo).endDate;

                              final String supervisor = experience is Experience
                                  ? experience.nameSupervisor
                                  : (experience as ExperienceInfo).supervisor;

                              final String responsibilities =
                                  experience is Experience
                                      ? experience.reasonForLeaving
                                      : (experience as ExperienceInfo)
                                          .responsibilities;

                              final String yearsOfExperience =
                                  experience is Experience
                                      ? experience.noExperience.toString()
                                      : (experience as ExperienceInfo)
                                          .yearsOfExperience;

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(
                                    bottom: AppTheme.contentSpacing,
                                    left: 2,
                                    right: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      AppTheme.contentSpacing),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Colors.blue.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Company and Position at the top
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.business,
                                              color: AppTheme.primaryColor,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Company Name",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  company,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // Position
                                      _buildLabeledField(
                                        icon: Icons.work,
                                        label: "Position Name",
                                        value: position,
                                      ),
                                      const SizedBox(height: 12),

                                      // Years of Experience
                                      _buildLabeledField(
                                        icon: Icons.timer,
                                        label: "Years of Experience",
                                        value: yearsOfExperience,
                                      ),
                                      const SizedBox(height: 12),

                                      // Employment Duration
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildLabeledField(
                                              icon: Icons.calendar_today,
                                              label: "Start Date",
                                              value: startDate,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildLabeledField(
                                              icon: Icons.event,
                                              label: "End Date",
                                              value: endDate,
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (supervisor.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildLabeledField(
                                          icon: Icons.supervisor_account,
                                          label: "Name of Supervisor",
                                          value: supervisor,
                                        ),
                                      ],

                                      if (responsibilities.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildLabeledField(
                                          icon: Icons.description,
                                          label:
                                              "Responsibilities/Reason for Leaving",
                                          value: responsibilities,
                                          isMultiLine: true,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            });
      },
    );
  }

  Widget _buildCredentialsTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.profileData,
      builder: (context, profileData, _) {
        return ValueListenableBuilder(
          valueListenable: _controller.credentialInfo,
          builder: (context, credentialInfo, _) {
            // Extract credential information from both sources
            String idNumber = "";
            String passport = "";
            String driversLicense = "";
            String taxId = credentialInfo.taxId;
            String socialSecurity = "";
            String whmisCredential = "";

            // First try to get data from the profileData
            if (profileData != null) {
              idNumber = profileData.data.employeeId.toString();
              socialSecurity = profileData.data.sinNo;

              // Find credentials by type from the credentials list
              if (profileData.credentials.isNotEmpty) {
                for (var credential in profileData.credentials) {
                  if (credential.document.contains("Passport")) {
                    passport = credential.image;
                  } else if (credential.document.contains("Driver License")) {
                    driversLicense = credential.image;
                  } else if (credential.document.contains("WHMIS 2025")) {
                    whmisCredential = credential.image;
                  }
                }
              }
            } else {
              // Fallback to credentialInfo if profileData is null
              idNumber = credentialInfo.idNumber;
              passport = credentialInfo.passport;
              driversLicense = credentialInfo.driversLicense;
              socialSecurity = credentialInfo.socialSecurity;
              if (profileData != null) {
                // Find credentials by type from the credentials list
                if (profileData.credentials.isNotEmpty) {
                  for (var credential in profileData.credentials) {
                    if (credential.document.contains("WHMIS 2025")) {
                      whmisCredential = credential.image;
                      break;
                    }
                  }
                }
              } else {
                whmisCredential = _controller.aptitudeInfo.value.certifications;
              }
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoField("ID Number", idNumber),

                  // Replace the simple info field with a view button for Passport
                  _buildCredentialWithViewButton(context, "Passport", passport),

                  // You could do the same for Driver's License if needed
                  _buildCredentialWithViewButton(
                      context, "Driver's License", driversLicense),

                  _buildInfoField("Tax ID", taxId),
                  _buildInfoField("Social Security", socialSecurity),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WHMIS 2025 Certificate",
                        style: AppTheme.infoFieldLabelStyle,
                      ),
                      const SizedBox(height: AppTheme.extraSmallSpacing),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.contentSpacing,
                          vertical: AppTheme.smallSpacing + 2,
                        ),
                        decoration: AppTheme.infoFieldDecoration,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                whmisCredential.isEmpty
                                    ? "Not provided"
                                    : "Certificate Available",
                                style: AppTheme.infoFieldValueStyle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (whmisCredential.isNotEmpty)
                              ElevatedButton(
                                onPressed: () => _viewPdfCredential(
                                    context,
                                    buildCredentialUrl(whmisCredential),
                                    "WHMIS 2025 Certificate"),
                                child: Text("View"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.contentSpacing),
                    ],
                  ),

                  // Display other credentials if available
                  if (profileData?.credentials != null &&
                      profileData!.credentials.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.contentSpacing),
                    Text(
                      "Other Credentials",
                      style: AppTheme.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    ...profileData.credentials
                        .where((c) =>
                            !c.document.contains("Passport") &&
                            !c.document.contains("Driver License") &&
                            !c.document.contains("WHMIS 2025"))
                        .map((credential) => _buildCredentialWithViewButton(
                              context,
                              credential.document,
                              credential.image,
                            )),
                  ],
                  const SizedBox(height: AppTheme.mediumSpacing),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCredentialWithViewButton(
      BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.infoFieldLabelStyle,
        ),
        const SizedBox(height: AppTheme.extraSmallSpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.contentSpacing,
            vertical: AppTheme.smallSpacing + 2,
          ),
          decoration: AppTheme.infoFieldDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  value.isEmpty ? "Not provided" : "Document Available",
                  style: AppTheme.infoFieldValueStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (value.isNotEmpty)
                ElevatedButton(
                  onPressed: () => _viewPdfCredential(
                      context, buildCredentialUrl(value), label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("View"),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.contentSpacing),
      ],
    );
  }

  void _viewPdfCredential(BuildContext context, String url, String title) {
    print('Opening PDF URL: $url');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppTheme.primaryColor,
          ),
          body: SfPdfViewer.network(url),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return ValueListenableBuilder(
      valueListenable: _controller.profileData,
      builder: (context, profileData, _) {
        return ValueListenableBuilder(
          valueListenable: _controller.personalInfo,
          builder: (context, personalInfo, _) {
            // Get data from API response if available, otherwise use controller values
            final fullName = profileData != null
                ? "${profileData.data.firstName} ${profileData.data.lastName}"
                : personalInfo.fullName;

            final firstName = profileData?.data.firstName ??
                (personalInfo.fullName.isNotEmpty
                    ? personalInfo.fullName.split(' ').first
                    : "");

            final lastName = profileData?.data.lastName ??
                (personalInfo.fullName.isNotEmpty &&
                        personalInfo.fullName.split(' ').length > 1
                    ? personalInfo.fullName.split(' ').sublist(1).join(' ')
                    : "");

            final gender = profileData?.data.gender ?? personalInfo.gender;
            final dateOfBirth =
                profileData?.data.dob ?? personalInfo.dateOfBirth;
            final maritalStatus =
                profileData?.data.maritalStatus ?? personalInfo.maritalStatus;
            final nationality =
                profileData?.country ?? personalInfo.nationality;

            // Get contact and emergency information
            final mobileNumber = profileData?.data.mobileNumber ?? "";
            final homeNumber = profileData?.data.homeNumber ?? "";
            final sinNumber = profileData?.data.sinNo ?? "";
            final sinExpiry = profileData?.data.sinExpiry ?? "";

            final emergencyName = profileData?.data.emergencyName ?? "";
            final emergencyPhone = profileData?.data.emergencyPhone ?? "";
            final emergencyEmail = profileData?.data.emergencyEmail ?? "";
            final emergencyRelationship =
                profileData?.data.emergencyRelationship ?? "";
            final emergencyLanguage = profileData?.data.emergencyLanguage ?? "";

            final referredBy = profileData?.data.referredBy ?? "";
            final referredRelationship =
                profileData?.data.referredRelationship ?? "";

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.smallSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Personal Info Section
                    Text(
                      "Basic Information",
                      style: AppTheme.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    _buildInfoField("First Name", firstName),
                    _buildInfoField("Last Name", lastName),
                    _buildInfoField("Gender", gender),
                    _buildInfoField("Date of Birth", dateOfBirth),
                    _buildInfoField("Marital Status", maritalStatus),
                    _buildInfoField("Nationality", nationality),

                    const SizedBox(height: AppTheme.contentSpacing),

                    // Contact Information Section
                    Text(
                      "Contact Information",
                      style: AppTheme.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    _buildInfoField("Mobile Number", mobileNumber),
                    _buildInfoField("Home Number", homeNumber),
                    _buildInfoField("SIN Number", sinNumber),
                    _buildInfoField("SIN Expiry", sinExpiry),

                    const SizedBox(height: AppTheme.contentSpacing),

                    // Emergency Contact Section
                    Text(
                      "Emergency Contact",
                      style: AppTheme.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    _buildInfoField("Name", emergencyName),
                    _buildInfoField("Phone", emergencyPhone),
                    _buildInfoField("Email", emergencyEmail),
                    _buildInfoField("Relationship", emergencyRelationship),
                    _buildInfoField("Language", emergencyLanguage),

                    const SizedBox(height: AppTheme.contentSpacing),

                    // References Section
                    Text(
                      "References",
                      style: AppTheme.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    _buildInfoField("Referred By", referredBy),
                    _buildInfoField(
                        "Referred Relationship", referredRelationship),

                    const SizedBox(height: AppTheme.contentSpacing),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.infoFieldLabelStyle,
        ),
        const SizedBox(height: AppTheme.extraSmallSpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.contentSpacing,
            vertical: AppTheme.smallSpacing + 2,
          ),
          decoration: AppTheme.infoFieldDecoration,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  value.isEmpty ? "Not provided" : value,
                  style: AppTheme.infoFieldValueStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.contentSpacing),
      ],
    );
  }

  Widget _buildLabeledField({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not specified' : value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: isMultiLine ? 1.3 : 1.0,
                ),
                maxLines: isMultiLine ? 3 : 1,
                overflow:
                    isMultiLine ? TextOverflow.ellipsis : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

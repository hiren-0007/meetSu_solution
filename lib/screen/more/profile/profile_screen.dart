import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/profile/personalinfo/personal_info_sreen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_cantroller.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

import '../../../utils/theme/app_theme.dart';

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
                          const SizedBox(
                              width: AppTheme.appBarBackButtonMargin),
                        ],
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _controller.profileData,
                      builder: (context, profileData, _) {
                        String? photoUrl = profileData?.photoUrl;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppTheme.contentSpacing),
                          width: AppTheme.avatarSizeMedium,
                          height: AppTheme.avatarSizeMedium,
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
                                    ? textColor.withValues(alpha: 0.5)
                                    : AppTheme.categoryCardBorderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: AppTheme.optionCircleSize,
                                  height: AppTheme.optionCircleSize,
                                  alignment: Alignment.center,
                                  decoration: AppTheme.optionCircleDecoration(
                                    isGivenOption ||
                                        (isCorrectOption && !isCorrect),
                                    isGivenOption ||
                                            (isCorrectOption && !isCorrect)
                                        ? textColor
                                        : AppTheme.categoryCardBorderColor,
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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoField("Street", addressInfo.street),
              _buildInfoField("City", addressInfo.city),
              _buildInfoField("State/Province", addressInfo.state),
              _buildInfoField("Postal Code", addressInfo.postalCode),
              _buildInfoField("Country", addressInfo.country),
              const SizedBox(height: AppTheme.mediumSpacing),
            ],
          ),
        );
      },
    );
  }

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
                        style: AppTheme.emptyStateStyle,
                      ),
                    )
                  : ListView.builder(
                      itemCount: educationList.length,
                      itemBuilder: (context, index) {
                        final education = educationList[index];
                        return Container(
                          margin: const EdgeInsets.only(
                              bottom: AppTheme.contentSpacing),
                          padding:
                              const EdgeInsets.all(AppTheme.contentSpacing),
                          decoration: AppTheme.educationCardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                education.degree,
                                style: AppTheme.educationDegreeStyle,
                              ),
                              const SizedBox(height: AppTheme.microSpacing),
                              Text(
                                education.institution,
                                style: AppTheme.educationInstitutionStyle,
                              ),
                              const SizedBox(height: AppTheme.microSpacing),
                              Text(
                                "${education.startDate.isNotEmpty ? education.startDate : 'N/A'} - ${education.endDate.isNotEmpty ? education.endDate : 'N/A'}",
                                style: AppTheme.educationDateStyle,
                              ),
                              if (education.grade.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppTheme.microSpacing),
                                  child: Text(
                                    "Grade: ${education.grade}",
                                    style: AppTheme.educationDateStyle,
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
                        style: AppTheme.emptyStateStyle,
                      ),
                    )
                  : ListView.builder(
                      itemCount: experienceList.length,
                      itemBuilder: (context, index) {
                        final experience = experienceList[index];
                        return Container(
                          margin: const EdgeInsets.only(
                              bottom: AppTheme.contentSpacing),
                          padding:
                              const EdgeInsets.all(AppTheme.contentSpacing),
                          decoration: AppTheme.experienceCardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Company Name: ${experience.company}",
                                style: AppTheme.experienceItemStyle,
                              ),
                              const SizedBox(
                                  height: AppTheme.extraSmallSpacing),
                              Text(
                                "Position Name: ${experience.position}",
                                style: AppTheme.experienceItemStyle,
                              ),
                              const SizedBox(
                                  height: AppTheme.extraSmallSpacing),
                              Text(
                                "Years of Experience: ${experience.yearsOfExperience}",
                                style: AppTheme.experienceItemStyle,
                              ),
                              const SizedBox(
                                  height: AppTheme.extraSmallSpacing),
                              Text(
                                "Start Date: ${experience.startDate}",
                                style: AppTheme.experienceItemStyle,
                              ),
                              const SizedBox(
                                  height: AppTheme.extraSmallSpacing),
                              Text(
                                "End Date: ${experience.endDate}",
                                style: AppTheme.experienceItemStyle,
                              ),
                              if (experience.supervisor.isNotEmpty) ...[
                                const SizedBox(
                                    height: AppTheme.extraSmallSpacing),
                                Text(
                                  "Name of Supervisor: ${experience.supervisor}",
                                  style: AppTheme.experienceItemStyle,
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
              _buildInfoField(
                  "Driver's License", credentialInfo.driversLicense),
              _buildInfoField("Tax ID", credentialInfo.taxId),
              _buildInfoField("Social Security", credentialInfo.socialSecurity),
              const SizedBox(height: AppTheme.mediumSpacing),
            ],
          ),
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
}

import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/profile/profile_response_model.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ProfileController {
  final ApiService _apiService;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final ValueNotifier<ProfileResponseModel?> profileData =
  ValueNotifier<ProfileResponseModel?>(null);

  final ValueNotifier<LoginInfo> loginInfo =
  ValueNotifier<LoginInfo>(LoginInfo());
  final ValueNotifier<AptitudeInfo> aptitudeInfo =
  ValueNotifier<AptitudeInfo>(AptitudeInfo());
  final ValueNotifier<PersonalInfo> personalInfo =
  ValueNotifier<PersonalInfo>(PersonalInfo());
  final ValueNotifier<AddressInfo> addressInfo =
  ValueNotifier<AddressInfo>(AddressInfo());
  final ValueNotifier<List<EducationInfo>> educationList =
  ValueNotifier<List<EducationInfo>>([]);
  final ValueNotifier<List<ExperienceInfo>> experienceList =
  ValueNotifier<List<ExperienceInfo>>([]);
  final ValueNotifier<CredentialInfo> credentialInfo =
  ValueNotifier<CredentialInfo>(CredentialInfo());

  ProfileController({ApiService? apiService})
      : _apiService = apiService ??
      ApiService(ApiClient(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }));

  void initialize() {
    isLoading.value = true;

    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final response = await _apiService.fetchProfile();

      final profile = ProfileResponseModel.fromJson(response);
      profileData.value = profile;

      _updateSectionDataFromProfile(profile);

      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = "Failed to load profile data: ${e.toString()}";
      _fetchMockUserData();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateSectionDataFromProfile(ProfileResponseModel profile) {
    loginInfo.value = LoginInfo(
      username: profile.data.username,
      email: profile.data.email ?? "",
      phone: profile.data.mobileNumber ?? "",
      role: "Employee",
      lastLogin: profile.data.lastLoginAt != 0
          ? DateTime.fromMillisecondsSinceEpoch(profile.data.lastLoginAt * 1000)
          .toString()
          : "",
    );

    personalInfo.value = PersonalInfo(
      fullName: "${profile.data.firstName} ${profile.data.lastName}",
      dateOfBirth: profile.data.dob ?? "",
      gender: profile.data.gender ?? "",
      maritalStatus: profile.data.maritalStatus ?? "",
      nationality: profile.country ?? "",
    );

    addressInfo.value = AddressInfo(
      street: profile.data.address ?? "",
      city: profile.city ?? "",
      state: profile.province ?? "",
      postalCode: profile.data.postalCode ?? "",
      country: profile.country ?? "",
    );

    int totalQuestions = 0;
    int correctAnswers = 0;

    profile.categoryWiseAnswer.forEach((key, value) {
      totalQuestions += value.totalQuestion;
      correctAnswers += value.correctAnswer;
    });

    String testScore =
    totalQuestions > 0 ? "${correctAnswers}/${totalQuestions}" : "0/0";

    aptitudeInfo.value = AptitudeInfo(
      testScores: testScore,
      skills: profile.data.language ?? "",
      certifications: _findCredentialByType(profile.credentials, "WHMIS 2025"),
    );

    final educationItems = profile.education
        .map((edu) => EducationInfo(
      degree: edu.courseName ?? "",
      institution: edu.collegeName ?? "",
      startDate: "",
      endDate: edu.graduateYear ?? "",
      grade: "",
    ))
        .toList();

    educationList.value = educationItems;

    final experienceItems = profile.experience
        .map((exp) => ExperienceInfo(
      company: exp.companyName ?? "",
      position: exp.positionName ?? "",
      startDate: exp.startDate ?? "",
      endDate: exp.endDate ?? "",
      supervisor: exp.nameSupervisor ?? "",
      responsibilities: exp.reasonForLeaving ?? "",
      yearsOfExperience: exp.noExperience?.toString() ?? "",
    ))
        .toList();

    experienceList.value = experienceItems;

    credentialInfo.value = CredentialInfo(
      idNumber: profile.data.employeeId.toString(),
      passport: _findCredentialByType(profile.credentials, "Passport"),
      driversLicense:
      _findCredentialByType(profile.credentials, "Driver License"),
      taxId: "",
      socialSecurity: profile.data.sinNo ?? "",
    );
  }

  String _findCredentialByType(List<Credential> credentials, String type) {
    for (var credential in credentials) {
      if (credential.document?.contains(type) == true) {
        return credential.image ?? "";
      }
    }
    return "";
  }

  void _fetchMockUserData() {
    loginInfo.value = LoginInfo(
      username: "john_doe",
      email: "john.doe@example.com",
      phone: "+1-555-123-4567",
      role: "Employee",
      lastLogin: "2023-05-15 14:30:22",
    );

    aptitudeInfo.value = AptitudeInfo(
      testScores: "85/100",
      skills: "Flutter, Dart, Firebase, UI/UX Design",
      certifications: "Google Flutter Developer, AWS Cloud Practitioner",
    );

    personalInfo.value = PersonalInfo(
      fullName: "John Doe",
      dateOfBirth: "1992-04-18",
      gender: "Male",
      maritalStatus: "Married",
      nationality: "United States",
    );

    addressInfo.value = AddressInfo(
      street: "123 Main Street, Apt 4B",
      city: "New York",
      state: "NY",
      postalCode: "10001",
      country: "United States",
    );

    educationList.value = [
      EducationInfo(
        degree: "Bachelor of Science in Computer Science",
        institution: "MIT",
        startDate: "2010-09",
        endDate: "2014-05",
        grade: "3.8 GPA",
      ),
      EducationInfo(
        degree: "Master of Computer Applications",
        institution: "Stanford University",
        startDate: "2014-09",
        endDate: "2016-05",
        grade: "3.9 GPA",
      ),
    ];

    experienceList.value = [
      ExperienceInfo(
        company: "Tech Solutions Inc.",
        position: "Junior Software Developer",
        startDate: "2016-07",
        endDate: "2018-05",
        supervisor: "John Smith",
        responsibilities: "Mobile app development, API integration",
        yearsOfExperience: "2",
      ),
      ExperienceInfo(
        company: "Google LLC",
        position: "Senior Software Engineer",
        startDate: "2018-06",
        endDate: "Present",
        supervisor: "Jane Smith",
        responsibilities:
        "Lead development of Flutter applications, mentor junior developers",
        yearsOfExperience: "5",
      ),
    ];

    credentialInfo.value = CredentialInfo(
      idNumber: "ID-123456789",
      passport: "P12345678",
      driversLicense: "DL-9876543210",
      taxId: "TAX-1234567890",
      socialSecurity: "SSN-XXX-XX-1234",
    );
  }

  void editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content:
        const Text("This function will allow editing profile information."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void addEducation(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final degreeController = TextEditingController();
    final institutionController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Education"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: degreeController,
                  decoration:
                  const InputDecoration(labelText: "Degree/Certificate *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: institutionController,
                  decoration: const InputDecoration(labelText: "Institution *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                      labelText: "Start Date (YYYY-MM) *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                      labelText: "End Date (YYYY-MM or 'Present') *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: gradeController,
                  decoration:
                  const InputDecoration(labelText: "Grade/GPA (optional)"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final education = EducationInfo(
                  degree: degreeController.text,
                  institution: institutionController.text,
                  startDate: startDateController.text,
                  endDate: endDateController.text,
                  grade: gradeController.text,
                );

                educationList.value = [...educationList.value, education];
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void addExperience(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final companyController = TextEditingController();
    final positionController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final supervisorController = TextEditingController();
    final responsibilitiesController = TextEditingController();
    final yearsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Experience"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: companyController,
                  decoration:
                  const InputDecoration(labelText: "Company Name *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: positionController,
                  decoration:
                  const InputDecoration(labelText: "Position/Title *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                      labelText: "Start Date (YYYY-MM-DD) *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                      labelText: "End Date (YYYY-MM-DD or 'Present') *"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: supervisorController,
                  decoration:
                  const InputDecoration(labelText: "Supervisor Name"),
                ),
                TextFormField(
                  controller: yearsController,
                  decoration:
                  const InputDecoration(labelText: "Years of Experience"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: responsibilitiesController,
                  decoration:
                  const InputDecoration(labelText: "Responsibilities"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final experience = ExperienceInfo(
                  company: companyController.text,
                  position: positionController.text,
                  startDate: startDateController.text,
                  endDate: endDateController.text,
                  supervisor: supervisorController.text,
                  responsibilities: responsibilitiesController.text,
                  yearsOfExperience: yearsController.text,
                );

                experienceList.value = [...experienceList.value, experience];
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<bool> submitProfile() async {
    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 1));

      isLoading.value = false;
      return true;
    } catch (e) {
      errorMessage.value = "Failed to update profile: ${e.toString()}";
      isLoading.value = false;
      return false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    profileData.dispose();
    loginInfo.dispose();
    aptitudeInfo.dispose();
    personalInfo.dispose();
    addressInfo.dispose();
    educationList.dispose();
    experienceList.dispose();
    credentialInfo.dispose();
  }
}

class LoginInfo {
  final String username;
  final String email;
  final String phone;
  final String role;
  final String lastLogin;

  LoginInfo({
    this.username = "",
    this.email = "",
    this.phone = "",
    this.role = "",
    this.lastLogin = "",
  });
}

class AptitudeInfo {
  final String testScores;
  final String skills;
  final String certifications;

  AptitudeInfo({
    this.testScores = "",
    this.skills = "",
    this.certifications = "",
  });
}

class PersonalInfo {
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String maritalStatus;
  final String nationality;

  PersonalInfo({
    this.fullName = "",
    this.dateOfBirth = "",
    this.gender = "",
    this.maritalStatus = "",
    this.nationality = "",
  });
}

class AddressInfo {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  AddressInfo({
    this.street = "",
    this.city = "",
    this.state = "",
    this.postalCode = "",
    this.country = "",
  });
}

class EducationInfo {
  final String degree;
  final String institution;
  final String startDate;
  final String endDate;
  final String grade;

  EducationInfo({
    this.degree = "",
    this.institution = "",
    this.startDate = "",
    this.endDate = "",
    this.grade = "",
  });
}

class ExperienceInfo {
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String supervisor;
  final String responsibilities;
  final String yearsOfExperience;

  ExperienceInfo({
    this.company = "",
    this.position = "",
    this.startDate = "",
    this.endDate = "",
    this.supervisor = "",
    this.responsibilities = "",
    this.yearsOfExperience = "",
  });
}

class CredentialInfo {
  final String idNumber;
  final String passport;
  final String driversLicense;
  final String taxId;
  final String socialSecurity;

  CredentialInfo({
    this.idNumber = "",
    this.passport = "",
    this.driversLicense = "",
    this.taxId = "",
    this.socialSecurity = "",
  });
}
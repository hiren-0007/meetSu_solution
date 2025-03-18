class ProfileResponseModel {
  final ProfileData data;
  final String city;
  final String province;
  final String country;
  final String resumeUrl;
  final List<Education> education;
  final List<Experience> experience;
  final String credentialUrl;
  final List<Credential> credentials;
  final Map<String, CategoryWiseAnswer> categoryWiseAnswer;
  final List<AptitudeQuestion> aptitude;
  final String photoUrl;
  final String googleMapKey;

  ProfileResponseModel({
    required this.data,
    required this.city,
    required this.province,
    required this.country,
    required this.resumeUrl,
    required this.education,
    required this.experience,
    required this.credentialUrl,
    required this.credentials,
    required this.categoryWiseAnswer,
    required this.aptitude,
    required this.photoUrl,
    required this.googleMapKey,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse education list
    List<Education> educationList = [];
    if (json['education'] != null) {
      educationList = List<Education>.from(
        json['education'].map((e) => Education.fromJson(e)),
      );
    }

    // Parse experience list
    List<Experience> experienceList = [];
    if (json['experience'] != null) {
      experienceList = List<Experience>.from(
        json['experience'].map((e) => Experience.fromJson(e)),
      );
    }

    // Parse credentials list
    List<Credential> credentialsList = [];
    if (json['credentials'] != null) {
      credentialsList = List<Credential>.from(
        json['credentials'].map((e) => Credential.fromJson(e)),
      );
    }

    // Parse aptitude questions list
    List<AptitudeQuestion> aptitudeList = [];
    if (json['aptitude'] != null) {
      aptitudeList = List<AptitudeQuestion>.from(
        json['aptitude'].map((e) => AptitudeQuestion.fromJson(e)),
      );
    }

    // Parse category wise answers
    Map<String, CategoryWiseAnswer> categoryAnswers = {};
    if (json['category_wise_answer'] != null) {
      json['category_wise_answer'].forEach((key, value) {
        categoryAnswers[key] = CategoryWiseAnswer.fromJson(value);
      });
    }

    return ProfileResponseModel(
      data: ProfileData.fromJson(json['data']),
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      country: json['country'] ?? '',
      resumeUrl: json['resume_url'] ?? '',
      education: educationList,
      experience: experienceList,
      credentialUrl: json['credential_url'] ?? '',
      credentials: credentialsList,
      categoryWiseAnswer: categoryAnswers,
      aptitude: aptitudeList,
      photoUrl: json['photo_url'] ?? '',
      googleMapKey: json['google_map_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'city': city,
      'province': province,
      'country': country,
      'resume_url': resumeUrl,
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'credential_url': credentialUrl,
      'credentials': credentials.map((e) => e.toJson()).toList(),
      'category_wise_answer': categoryWiseAnswer.map((key, value) => MapEntry(key, value.toJson())),
      'aptitude': aptitude.map((e) => e.toJson()).toList(),
      'photo_url': photoUrl,
      'google_map_key': googleMapKey,
    };
  }
}

class ProfileData {
  final int id;
  final int logId;
  final int employeeId;
  final String username;
  final String firstName;
  final String lastName;
  final String? photo;
  final String homeNumber;
  final String mobileNumber;
  final String email;
  final String passwordHash;
  final String authKey;
  final String accessToken;
  final String pushToken;
  final int tokenDeviceType;
  final String address;
  final String address2;
  final String postalCode;
  final int city;
  final int province;
  final int country;
  final String resume;
  final String? authorize;
  final String dob;
  final String gender;
  final String maritalStatus;
  final String language;
  final String sinExpiry;
  final String? sinStatus;
  final String sinNo;
  final int defaultPosition;
  final String? applicantStatus;
  final String applyDate;
  final String? acceptedDate;
  final int applyPosition;
  final String availableDate;
  final String startDate;
  final String? endDate;
  final int origin;
  final String emergencyName;
  final String emergencyPhone;
  final String emergencyEmail;
  final String emergencyRelationship;
  final String emergencyLanguage;
  final String referredBy;
  final String referredRelationship;
  final String workInCanada;
  final String? note;
  final int mailSent;
  final String? confirmedAt;
  final String? unconfirmedEmail;
  final int blockedAt;
  final String? registrationIp;
  final int flags;
  final int registerType;
  final int testPercentage;
  final String createdAt;
  final String updatedAt;
  final int lastLoginAt;
  final String status;
  final String isOnDuty;
  final int score;
  final String scheduleType;
  final String? overrideHours;
  final String? overrideStartTime;

  ProfileData({
    required this.id,
    required this.logId,
    required this.employeeId,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.photo,
    required this.homeNumber,
    required this.mobileNumber,
    required this.email,
    required this.passwordHash,
    required this.authKey,
    required this.accessToken,
    required this.pushToken,
    required this.tokenDeviceType,
    required this.address,
    required this.address2,
    required this.postalCode,
    required this.city,
    required this.province,
    required this.country,
    required this.resume,
    this.authorize,
    required this.dob,
    required this.gender,
    required this.maritalStatus,
    required this.language,
    required this.sinExpiry,
    this.sinStatus,
    required this.sinNo,
    required this.defaultPosition,
    this.applicantStatus,
    required this.applyDate,
    this.acceptedDate,
    required this.applyPosition,
    required this.availableDate,
    required this.startDate,
    this.endDate,
    required this.origin,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.emergencyEmail,
    required this.emergencyRelationship,
    required this.emergencyLanguage,
    required this.referredBy,
    required this.referredRelationship,
    required this.workInCanada,
    this.note,
    required this.mailSent,
    this.confirmedAt,
    this.unconfirmedEmail,
    required this.blockedAt,
    this.registrationIp,
    required this.flags,
    required this.registerType,
    required this.testPercentage,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    required this.status,
    required this.isOnDuty,
    required this.score,
    required this.scheduleType,
    this.overrideHours,
    this.overrideStartTime,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      logId: json['log_id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      photo: json['photo'],
      homeNumber: json['home_number'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['password_hash'] ?? '',
      authKey: json['auth_key'] ?? '',
      accessToken: json['access_token'] ?? '',
      pushToken: json['push_token'] ?? '',
      tokenDeviceType: json['token_device_type'] ?? 0,
      address: json['address'] ?? '',
      address2: json['address_2'] ?? '',
      postalCode: json['postal_code'] ?? '',
      city: json['city'] ?? 0,
      province: json['province'] ?? 0,
      country: json['country'] ?? 0,
      resume: json['resume'] ?? '',
      authorize: json['authorize'],
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      language: json['language'] ?? '',
      sinExpiry: json['sin_expiry'] ?? '',
      sinStatus: json['sin_status'],
      sinNo: json['sin_no'] ?? '',
      defaultPosition: json['default_position'] ?? 0,
      applicantStatus: json['applicant_status'],
      applyDate: json['apply_date'] ?? '',
      acceptedDate: json['accepted_date'],
      applyPosition: json['apply_position'] ?? 0,
      availableDate: json['available_date'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      origin: json['origin'] ?? 0,
      emergencyName: json['emergency_name'] ?? '',
      emergencyPhone: json['emergency_phone'] ?? '',
      emergencyEmail: json['emergency_email'] ?? '',
      emergencyRelationship: json['emergency_relationship'] ?? '',
      emergencyLanguage: json['emergency_language'] ?? '',
      referredBy: json['referred_by'] ?? '',
      referredRelationship: json['referred_relationship'] ?? '',
      workInCanada: json['work_in_canada'] ?? '',
      note: json['note'],
      mailSent: json['mail_sent'] ?? 0,
      confirmedAt: json['confirmed_at'],
      unconfirmedEmail: json['unconfirmed_email'],
      blockedAt: json['blocked_at'] ?? 0,
      registrationIp: json['registration_ip'],
      flags: json['flags'] ?? 0,
      registerType: json['register_type'] ?? 0,
      testPercentage: json['test_percentage'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      lastLoginAt: json['last_login_at'] ?? 0,
      status: json['status'] ?? '',
      isOnDuty: json['is_on_duty'] ?? '',
      score: json['score'] ?? 0,
      scheduleType: json['schedule_type'] ?? '',
      overrideHours: json['override_hours'],
      overrideStartTime: json['override_start_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'log_id': logId,
      'employee_id': employeeId,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'photo': photo,
      'home_number': homeNumber,
      'mobile_number': mobileNumber,
      'email': email,
      'password_hash': passwordHash,
      'auth_key': authKey,
      'access_token': accessToken,
      'push_token': pushToken,
      'token_device_type': tokenDeviceType,
      'address': address,
      'address_2': address2,
      'postal_code': postalCode,
      'city': city,
      'province': province,
      'country': country,
      'resume': resume,
      'authorize': authorize,
      'dob': dob,
      'gender': gender,
      'marital_status': maritalStatus,
      'language': language,
      'sin_expiry': sinExpiry,
      'sin_status': sinStatus,
      'sin_no': sinNo,
      'default_position': defaultPosition,
      'applicant_status': applicantStatus,
      'apply_date': applyDate,
      'accepted_date': acceptedDate,
      'apply_position': applyPosition,
      'available_date': availableDate,
      'start_date': startDate,
      'end_date': endDate,
      'origin': origin,
      'emergency_name': emergencyName,
      'emergency_phone': emergencyPhone,
      'emergency_email': emergencyEmail,
      'emergency_relationship': emergencyRelationship,
      'emergency_language': emergencyLanguage,
      'referred_by': referredBy,
      'referred_relationship': referredRelationship,
      'work_in_canada': workInCanada,
      'note': note,
      'mail_sent': mailSent,
      'confirmed_at': confirmedAt,
      'unconfirmed_email': unconfirmedEmail,
      'blocked_at': blockedAt,
      'registration_ip': registrationIp,
      'flags': flags,
      'register_type': registerType,
      'test_percentage': testPercentage,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_login_at': lastLoginAt,
      'status': status,
      'is_on_duty': isOnDuty,
      'score': score,
      'schedule_type': scheduleType,
      'override_hours': overrideHours,
      'override_start_time': overrideStartTime,
    };
  }
}

class Education {
  final int id;
  final int applicantId;
  final String collegeName;
  final String courseName;
  final String graduateYear;

  Education({
    required this.id,
    required this.applicantId,
    required this.collegeName,
    required this.courseName,
    required this.graduateYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] ?? 0,
      applicantId: json['applicant_id'] ?? 0,
      collegeName: json['college_name'] ?? '',
      courseName: json['course_name'] ?? '',
      graduateYear: json['graduate_year'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicant_id': applicantId,
      'college_name': collegeName,
      'course_name': courseName,
      'graduate_year': graduateYear,
    };
  }
}

class Experience {
  final int id;
  final int applicantId;
  final String companyName;
  final String positionName;
  final String? expiryDate;
  final int noExperience;
  final String startDate;
  final String endDate;
  final String nameSupervisor;
  final String reasonForLeaving;
  final int authorize;
  final String referanceEmail;
  final String? referanceRemark;

  Experience({
    required this.id,
    required this.applicantId,
    required this.companyName,
    required this.positionName,
    this.expiryDate,
    required this.noExperience,
    required this.startDate,
    required this.endDate,
    required this.nameSupervisor,
    required this.reasonForLeaving,
    required this.authorize,
    required this.referanceEmail,
    this.referanceRemark,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? 0,
      applicantId: json['applicant_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      positionName: json['position_name'] ?? '',
      expiryDate: json['expiry_date'],
      noExperience: json['no_experience'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      nameSupervisor: json['name_supervisor'] ?? '',
      reasonForLeaving: json['reason_for_leaving'] ?? '',
      authorize: json['authorize'] ?? 0,
      referanceEmail: json['referance_email'] ?? '',
      referanceRemark: json['referance_remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicant_id': applicantId,
      'company_name': companyName,
      'position_name': positionName,
      'expiry_date': expiryDate,
      'no_experience': noExperience,
      'start_date': startDate,
      'end_date': endDate,
      'name_supervisor': nameSupervisor,
      'reason_for_leaving': reasonForLeaving,
      'authorize': authorize,
      'referance_email': referanceEmail,
      'referance_remark': referanceRemark,
    };
  }
}

class Credential {
  final String image;
  final String document;

  Credential({
    required this.image,
    required this.document,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      image: json['image'] ?? '',
      document: json['document'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'document': document,
    };
  }
}

class CategoryWiseAnswer {
  final String category;
  final int totalQuestion;
  final int correctAnswer;

  CategoryWiseAnswer({
    required this.category,
    required this.totalQuestion,
    required this.correctAnswer,
  });

  factory CategoryWiseAnswer.fromJson(Map<String, dynamic> json) {
    return CategoryWiseAnswer(
      category: json['category'] ?? '',
      totalQuestion: json['total_question'] ?? 0,
      correctAnswer: json['correct_answer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'total_question': totalQuestion,
      'correct_answer': correctAnswer,
    };
  }
}

class AptitudeQuestion {
  final String id;
  final String category;
  final String question;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;
  final String correctAnswer;
  final int givenAnswer;

  AptitudeQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
    required this.correctAnswer,
    required this.givenAnswer,
  });

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) {
    return AptitudeQuestion(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      question: json['question'] ?? '',
      answer1: json['answer1'] ?? '',
      answer2: json['answer2'] ?? '',
      answer3: json['answer3'] ?? '',
      answer4: json['answer4'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      givenAnswer: json['given_answer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer1': answer1,
      'answer2': answer2,
      'answer3': answer3,
      'answer4': answer4,
      'correct_answer': correctAnswer,
      'given_answer': givenAnswer,
    };
  }
}
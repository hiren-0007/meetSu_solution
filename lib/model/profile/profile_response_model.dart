class ProfileResponseModel {
  final ProfileData data;
  final String? city;
  final String? province;
  final String? country;
  final String? resumeUrl;
  final List<Education> education;
  final List<Experience> experience;
  final String? credentialUrl;
  final List<Credential> credentials;
  final Map<String, CategoryWiseAnswer> categoryWiseAnswer;
  final List<AptitudeQuestion> aptitude;
  final String? photoUrl;
  final String? googleMapKey;

  ProfileResponseModel({
    required this.data,
    this.city,
    this.province,
    this.country,
    this.resumeUrl,
    required this.education,
    required this.experience,
    this.credentialUrl,
    required this.credentials,
    required this.categoryWiseAnswer,
    required this.aptitude,
    this.photoUrl,
    this.googleMapKey,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse education list
    List<Education> educationList = [];
    if (json['education'] != null) {
      educationList = List<Education>.from(
        (json['education'] as List).map((e) => Education.fromJson(e)),
      );
    }

    // Parse experience list
    List<Experience> experienceList = [];
    if (json['experience'] != null) {
      experienceList = List<Experience>.from(
        (json['experience'] as List).map((e) => Experience.fromJson(e)),
      );
    }

    // Parse credentials list
    List<Credential> credentialsList = [];
    if (json['credentials'] != null) {
      credentialsList = List<Credential>.from(
        (json['credentials'] as List).map((e) => Credential.fromJson(e)),
      );
    }

    // Parse aptitude questions list
    List<AptitudeQuestion> aptitudeList = [];
    if (json['aptitude'] != null) {
      aptitudeList = List<AptitudeQuestion>.from(
        (json['aptitude'] as List).map((e) => AptitudeQuestion.fromJson(e)),
      );
    }

    // Parse category wise answers
    Map<String, CategoryWiseAnswer> categoryAnswers = {};
    if (json['category_wise_answer'] != null && json['category_wise_answer'] is Map) {
      (json['category_wise_answer'] as Map).forEach((key, value) {
        if (value != null) {
          categoryAnswers[key.toString()] = CategoryWiseAnswer.fromJson({
            ...value as Map<String, dynamic>,
            'category': key.toString(), // Add the category key
          });
        }
      });
    }

    return ProfileResponseModel(
      data: ProfileData.fromJson(json['data']),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      country: json['country']?.toString(),
      resumeUrl: json['resume_url']?.toString(),
      education: educationList,
      experience: experienceList,
      credentialUrl: json['credential_url']?.toString(),
      credentials: credentialsList,
      categoryWiseAnswer: categoryAnswers,
      aptitude: aptitudeList,
      photoUrl: json['photo_url']?.toString(),
      googleMapKey: json['google_map_key']?.toString(),
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
  final String? homeNumber;
  final String? mobileNumber;
  final String? email;
  final String? passwordHash;
  final String? authKey;
  final String? accessToken;
  final String? pushToken;
  final int tokenDeviceType;
  final String? address;
  final String? address2;
  final String? postalCode;
  final dynamic city; // Keep as dynamic
  final dynamic province; // Keep as dynamic
  final dynamic country; // Keep as dynamic
  final String? resume;
  final String? authorize;
  final String? dob;
  final String? gender;
  final String? maritalStatus;
  final String? language;
  final String? sinExpiry;
  final dynamic sinStatus;
  final String? sinNo;
  final int defaultPosition;
  final dynamic applicantStatus;
  final String? applyDate;
  final String? acceptedDate;
  final int applyPosition;
  final String? availableDate;
  final String? startDate;
  final String? endDate;
  final int origin;
  final String? emergencyName;
  final String? emergencyPhone;
  final String? emergencyEmail;
  final String? emergencyRelationship;
  final String? emergencyLanguage;
  final String? referredBy;
  final String? referredRelationship;
  final String? workInCanada;
  final dynamic note;
  final int mailSent;
  final dynamic confirmedAt;
  final dynamic unconfirmedEmail;
  final int blockedAt;
  final dynamic registrationIp;
  final int flags;
  final int registerType;
  final int testPercentage;
  final String? createdAt;
  final String? updatedAt;
  final int lastLoginAt;
  final String? status;
  final String? isOnDuty;
  final int score;
  final String? scheduleType;
  final dynamic overrideHours;
  final dynamic overrideStartTime;

  ProfileData({
    required this.id,
    required this.logId,
    required this.employeeId,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.homeNumber,
    this.mobileNumber,
    this.email,
    this.passwordHash,
    this.authKey,
    this.accessToken,
    this.pushToken,
    required this.tokenDeviceType,
    this.address,
    this.address2,
    this.postalCode,
    required this.city,
    required this.province,
    required this.country,
    this.resume,
    this.authorize,
    this.dob,
    this.gender,
    this.maritalStatus,
    this.language,
    this.sinExpiry,
    this.sinStatus,
    this.sinNo,
    required this.defaultPosition,
    this.applicantStatus,
    this.applyDate,
    this.acceptedDate,
    required this.applyPosition,
    this.availableDate,
    this.startDate,
    this.endDate,
    required this.origin,
    this.emergencyName,
    this.emergencyPhone,
    this.emergencyEmail,
    this.emergencyRelationship,
    this.emergencyLanguage,
    this.referredBy,
    this.referredRelationship,
    this.workInCanada,
    this.note,
    required this.mailSent,
    this.confirmedAt,
    this.unconfirmedEmail,
    required this.blockedAt,
    this.registrationIp,
    required this.flags,
    required this.registerType,
    required this.testPercentage,
    this.createdAt,
    this.updatedAt,
    required this.lastLoginAt,
    this.status,
    this.isOnDuty,
    required this.score,
    this.scheduleType,
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
      homeNumber: json['home_number']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      email: json['email']?.toString(),
      passwordHash: json['password_hash']?.toString(),
      authKey: json['auth_key']?.toString(),
      accessToken: json['access_token']?.toString(),
      pushToken: json['push_token']?.toString(),
      tokenDeviceType: json['token_device_type'] ?? 0,
      address: json['address']?.toString(),
      address2: json['address_2']?.toString(),
      postalCode: json['postal_code']?.toString(),
      city: json['city'], // Keep as dynamic
      province: json['province'] ?? 0,
      country: json['country'] ?? 0,
      resume: json['resume']?.toString(),
      authorize: json['authorize']?.toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      language: json['language']?.toString(),
      sinExpiry: json['sin_expiry']?.toString(),
      sinStatus: json['sin_status'],
      sinNo: json['sin_no']?.toString(),
      defaultPosition: json['default_position'] ?? 0,
      applicantStatus: json['applicant_status'],
      applyDate: json['apply_date']?.toString(),
      acceptedDate: json['accepted_date']?.toString(),
      applyPosition: json['apply_position'] ?? 0,
      availableDate: json['available_date']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      origin: json['origin'] ?? 0,
      emergencyName: json['emergency_name']?.toString(),
      emergencyPhone: json['emergency_phone']?.toString(),
      emergencyEmail: json['emergency_email']?.toString(),
      emergencyRelationship: json['emergency_relationship']?.toString(),
      emergencyLanguage: json['emergency_language']?.toString(),
      referredBy: json['referred_by']?.toString(),
      referredRelationship: json['referred_relationship']?.toString(),
      workInCanada: json['work_in_canada']?.toString(),
      note: json['note'],
      mailSent: json['mail_sent'] ?? 0,
      confirmedAt: json['confirmed_at']?.toString(),
      unconfirmedEmail: json['unconfirmed_email']?.toString(),
      blockedAt: json['blocked_at'] ?? 0,
      registrationIp: json['registration_ip'],
      flags: json['flags'] ?? 0,
      registerType: json['register_type'] ?? 0,
      testPercentage: json['test_percentage'] ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      lastLoginAt: json['last_login_at'] ?? 0,
      status: json['status']?.toString(),
      isOnDuty: json['is_on_duty']?.toString(),
      score: json['score'] ?? 0,
      scheduleType: json['schedule_type']?.toString(),
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
  final String? collegeName;
  final String? courseName;
  final String? graduateYear;

  Education({
    required this.id,
    required this.applicantId,
    this.collegeName,
    this.courseName,
    this.graduateYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] ?? 0,
      applicantId: json['applicant_id'] ?? 0,
      collegeName: json['college_name']?.toString(),
      courseName: json['course_name']?.toString(),
      graduateYear: json['graduate_year']?.toString(),
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
  final String? companyName;
  final String? positionName;
  final dynamic expiryDate;
  final dynamic noExperience; // Keep as dynamic to handle double values
  final String? startDate;
  final String? endDate;
  final String? nameSupervisor;
  final String? reasonForLeaving;
  final int authorize;
  final String? referanceEmail;
  final dynamic referanceRemark;

  Experience({
    required this.id,
    required this.applicantId,
    this.companyName,
    this.positionName,
    this.expiryDate,
    required this.noExperience,
    this.startDate,
    this.endDate,
    this.nameSupervisor,
    this.reasonForLeaving,
    required this.authorize,
    this.referanceEmail,
    this.referanceRemark,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? 0,
      applicantId: json['applicant_id'] ?? 0,
      companyName: json['company_name']?.toString(),
      positionName: json['position_name']?.toString(),
      expiryDate: json['expiry_date'],
      noExperience: json['no_experience'], // Keep as dynamic
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      nameSupervisor: json['name_supervisor']?.toString(),
      reasonForLeaving: json['reason_for_leaving']?.toString(),
      authorize: json['authorize'] ?? 0,
      referanceEmail: json['referance_email']?.toString(),
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
  final String? image;
  final String? document;

  Credential({
    this.image,
    this.document,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      image: json['image']?.toString(),
      document: json['document']?.toString(),
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
  final int wrongAnswer;
  final int totalPoints;

  CategoryWiseAnswer({
    required this.category,
    required this.totalQuestion,
    required this.correctAnswer,
    this.wrongAnswer = 0,
    this.totalPoints = 0,
  });

  factory CategoryWiseAnswer.fromJson(Map<String, dynamic> json) {
    return CategoryWiseAnswer(
      category: json['category']?.toString() ?? '',
      totalQuestion: json['total_question'] ?? 0,
      correctAnswer: json['correct_answer'] ?? 0,
      wrongAnswer: json['wrong_answer'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'total_question': totalQuestion,
      'correct_answer': correctAnswer,
      'wrong_answer': wrongAnswer,
      'total_points': totalPoints,
    };
  }
}

class AptitudeQuestion {
  final String id;
  final String? category;
  final String? question;
  final String? answer1;
  final String? answer2;
  final String? answer3;
  final String? answer4;
  final String? correctAnswer;
  final int givenAnswer;

  AptitudeQuestion({
    required this.id,
    this.category,
    this.question,
    this.answer1,
    this.answer2,
    this.answer3,
    this.answer4,
    this.correctAnswer,
    required this.givenAnswer,
  });

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) {
    return AptitudeQuestion(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString(),
      question: json['question']?.toString(),
      answer1: json['answer1']?.toString(),
      answer2: json['answer2']?.toString(),
      answer3: json['answer3']?.toString(),
      answer4: json['answer4']?.toString(),
      correctAnswer: json['correct_answer']?.toString(),
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
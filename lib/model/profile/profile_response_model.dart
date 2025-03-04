class ProfileResponseModel {
  Data? data;
  String? city;
  String? province;
  String? country;
  String? resumeUrl;
  List<Education>? education;
  List<Experience>? experience;
  String? credentialUrl;
  List<Credentials>? credentials;
  // CategoryWiseAnswer? categoryWiseAnswer;
  List<Aptitude>? aptitude;
  String? photoUrl;
  String? googleMapKey;

  ProfileResponseModel(
      {this.data,
      this.city,
      this.province,
      this.country,
      this.resumeUrl,
      this.education,
      this.experience,
      this.credentialUrl,
      this.credentials,
      // this.categoryWiseAnswer,
      this.aptitude,
      this.photoUrl,
      this.googleMapKey});

  ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    city = json['city'];
    province = json['province'];
    country = json['country'];
    resumeUrl = json['resume_url'];
    if (json['education'] != null) {
      education = <Education>[];
      json['education'].forEach((v) {
        education!.add(new Education.fromJson(v));
      });
    }
    if (json['experience'] != null) {
      experience = <Experience>[];
      json['experience'].forEach((v) {
        experience!.add(new Experience.fromJson(v));
      });
    }
    credentialUrl = json['credential_url'];
    if (json['credentials'] != null) {
      credentials = <Credentials>[];
      json['credentials'].forEach((v) {
        credentials!.add(new Credentials.fromJson(v));
      });
    }
    // categoryWiseAnswer = json['category_wise_answer'] != null
    //     ? new CategoryWiseAnswer.fromJson(json['category_wise_answer'])
    //     : null;
    if (json['aptitude'] != null) {
      aptitude = <Aptitude>[];
      json['aptitude'].forEach((v) {
        aptitude!.add(new Aptitude.fromJson(v));
      });
    }
    photoUrl = json['photo_url'];
    googleMapKey = json['google_map_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['city'] = this.city;
    data['province'] = this.province;
    data['country'] = this.country;
    data['resume_url'] = this.resumeUrl;
    if (this.education != null) {
      data['education'] = this.education!.map((v) => v.toJson()).toList();
    }
    if (this.experience != null) {
      data['experience'] = this.experience!.map((v) => v.toJson()).toList();
    }
    data['credential_url'] = this.credentialUrl;
    if (this.credentials != null) {
      data['credentials'] = this.credentials!.map((v) => v.toJson()).toList();
    }
    // if (this.categoryWiseAnswer != null) {
    //   data['category_wise_answer'] = this.categoryWiseAnswer!.toJson();
    // }
    if (this.aptitude != null) {
      data['aptitude'] = this.aptitude!.map((v) => v.toJson()).toList();
    }
    data['photo_url'] = this.photoUrl;
    data['google_map_key'] = this.googleMapKey;
    return data;
  }
}

class Data {
  int? id;
  int? logId;
  int? employeeId;
  String? username;
  String? firstName;
  String? lastName;
  Null? photo;
  String? homeNumber;
  String? mobileNumber;
  String? email;
  String? passwordHash;
  String? authKey;
  String? accessToken;
  String? pushToken;
  int? tokenDeviceType;
  String? address;
  String? address2;
  String? postalCode;
  int? city;
  int? province;
  int? country;
  String? resume;
  Null? authorize;
  String? dob;
  String? gender;
  String? maritalStatus;
  String? language;
  String? sinExpiry;
  Null? sinStatus;
  String? sinNo;
  int? defaultPosition;
  Null? applicantStatus;
  String? applyDate;
  Null? acceptedDate;
  int? applyPosition;
  String? availableDate;
  String? startDate;
  String? endDate;
  int? origin;
  String? emergencyName;
  String? emergencyPhone;
  String? emergencyEmail;
  String? emergencyRelationship;
  String? emergencyLanguage;
  String? referredBy;
  String? referredRelationship;
  String? workInCanada;
  Null? note;
  int? mailSent;
  Null? confirmedAt;
  Null? unconfirmedEmail;
  int? blockedAt;
  Null? registrationIp;
  int? flags;
  int? registerType;
  int? testPercentage;
  String? createdAt;
  String? updatedAt;
  int? lastLoginAt;
  String? status;
  String? isOnDuty;
  int? score;
  String? scheduleType;
  Null? overrideHours;
  Null? overrideStartTime;

  Data(
      {this.id,
      this.logId,
      this.employeeId,
      this.username,
      this.firstName,
      this.lastName,
      this.photo,
      this.homeNumber,
      this.mobileNumber,
      this.email,
      this.passwordHash,
      this.authKey,
      this.accessToken,
      this.pushToken,
      this.tokenDeviceType,
      this.address,
      this.address2,
      this.postalCode,
      this.city,
      this.province,
      this.country,
      this.resume,
      this.authorize,
      this.dob,
      this.gender,
      this.maritalStatus,
      this.language,
      this.sinExpiry,
      this.sinStatus,
      this.sinNo,
      this.defaultPosition,
      this.applicantStatus,
      this.applyDate,
      this.acceptedDate,
      this.applyPosition,
      this.availableDate,
      this.startDate,
      this.endDate,
      this.origin,
      this.emergencyName,
      this.emergencyPhone,
      this.emergencyEmail,
      this.emergencyRelationship,
      this.emergencyLanguage,
      this.referredBy,
      this.referredRelationship,
      this.workInCanada,
      this.note,
      this.mailSent,
      this.confirmedAt,
      this.unconfirmedEmail,
      this.blockedAt,
      this.registrationIp,
      this.flags,
      this.registerType,
      this.testPercentage,
      this.createdAt,
      this.updatedAt,
      this.lastLoginAt,
      this.status,
      this.isOnDuty,
      this.score,
      this.scheduleType,
      this.overrideHours,
      this.overrideStartTime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logId = json['log_id'];
    employeeId = json['employee_id'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    photo = json['photo'];
    homeNumber = json['home_number'];
    mobileNumber = json['mobile_number'];
    email = json['email'];
    passwordHash = json['password_hash'];
    authKey = json['auth_key'];
    accessToken = json['access_token'];
    pushToken = json['push_token'];
    tokenDeviceType = json['token_device_type'];
    address = json['address'];
    address2 = json['address_2'];
    postalCode = json['postal_code'];
    city = json['city'];
    province = json['province'];
    country = json['country'];
    resume = json['resume'];
    authorize = json['authorize'];
    dob = json['dob'];
    gender = json['gender'];
    maritalStatus = json['marital_status'];
    language = json['language'];
    sinExpiry = json['sin_expiry'];
    sinStatus = json['sin_status'];
    sinNo = json['sin_no'];
    defaultPosition = json['default_position'];
    applicantStatus = json['applicant_status'];
    applyDate = json['apply_date'];
    acceptedDate = json['accepted_date'];
    applyPosition = json['apply_position'];
    availableDate = json['available_date'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    origin = json['origin'];
    emergencyName = json['emergency_name'];
    emergencyPhone = json['emergency_phone'];
    emergencyEmail = json['emergency_email'];
    emergencyRelationship = json['emergency_relationship'];
    emergencyLanguage = json['emergency_language'];
    referredBy = json['referred_by'];
    referredRelationship = json['referred_relationship'];
    workInCanada = json['work_in_canada'];
    note = json['note'];
    mailSent = json['mail_sent'];
    confirmedAt = json['confirmed_at'];
    unconfirmedEmail = json['unconfirmed_email'];
    blockedAt = json['blocked_at'];
    registrationIp = json['registration_ip'];
    flags = json['flags'];
    registerType = json['register_type'];
    testPercentage = json['test_percentage'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastLoginAt = json['last_login_at'];
    status = json['status'];
    isOnDuty = json['is_on_duty'];
    score = json['score'];
    scheduleType = json['schedule_type'];
    overrideHours = json['override_hours'];
    overrideStartTime = json['override_start_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['log_id'] = this.logId;
    data['employee_id'] = this.employeeId;
    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['photo'] = this.photo;
    data['home_number'] = this.homeNumber;
    data['mobile_number'] = this.mobileNumber;
    data['email'] = this.email;
    data['password_hash'] = this.passwordHash;
    data['auth_key'] = this.authKey;
    data['access_token'] = this.accessToken;
    data['push_token'] = this.pushToken;
    data['token_device_type'] = this.tokenDeviceType;
    data['address'] = this.address;
    data['address_2'] = this.address2;
    data['postal_code'] = this.postalCode;
    data['city'] = this.city;
    data['province'] = this.province;
    data['country'] = this.country;
    data['resume'] = this.resume;
    data['authorize'] = this.authorize;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['marital_status'] = this.maritalStatus;
    data['language'] = this.language;
    data['sin_expiry'] = this.sinExpiry;
    data['sin_status'] = this.sinStatus;
    data['sin_no'] = this.sinNo;
    data['default_position'] = this.defaultPosition;
    data['applicant_status'] = this.applicantStatus;
    data['apply_date'] = this.applyDate;
    data['accepted_date'] = this.acceptedDate;
    data['apply_position'] = this.applyPosition;
    data['available_date'] = this.availableDate;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['origin'] = this.origin;
    data['emergency_name'] = this.emergencyName;
    data['emergency_phone'] = this.emergencyPhone;
    data['emergency_email'] = this.emergencyEmail;
    data['emergency_relationship'] = this.emergencyRelationship;
    data['emergency_language'] = this.emergencyLanguage;
    data['referred_by'] = this.referredBy;
    data['referred_relationship'] = this.referredRelationship;
    data['work_in_canada'] = this.workInCanada;
    data['note'] = this.note;
    data['mail_sent'] = this.mailSent;
    data['confirmed_at'] = this.confirmedAt;
    data['unconfirmed_email'] = this.unconfirmedEmail;
    data['blocked_at'] = this.blockedAt;
    data['registration_ip'] = this.registrationIp;
    data['flags'] = this.flags;
    data['register_type'] = this.registerType;
    data['test_percentage'] = this.testPercentage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['last_login_at'] = this.lastLoginAt;
    data['status'] = this.status;
    data['is_on_duty'] = this.isOnDuty;
    data['score'] = this.score;
    data['schedule_type'] = this.scheduleType;
    data['override_hours'] = this.overrideHours;
    data['override_start_time'] = this.overrideStartTime;
    return data;
  }
}

class Education {
  int? id;
  int? applicantId;
  String? collegeName;
  String? courseName;
  String? graduateYear;

  Education(
      {this.id,
      this.applicantId,
      this.collegeName,
      this.courseName,
      this.graduateYear});

  Education.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    applicantId = json['applicant_id'];
    collegeName = json['college_name'];
    courseName = json['course_name'];
    graduateYear = json['graduate_year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['applicant_id'] = this.applicantId;
    data['college_name'] = this.collegeName;
    data['course_name'] = this.courseName;
    data['graduate_year'] = this.graduateYear;
    return data;
  }
}

class Experience {
  int? id;
  int? applicantId;
  String? companyName;
  String? positionName;
  Null? expiryDate;
  int? noExperience;
  String? startDate;
  String? endDate;
  String? nameSupervisor;
  String? reasonForLeaving;
  int? authorize;
  String? referanceEmail;
  Null? referanceRemark;

  Experience(
      {this.id,
      this.applicantId,
      this.companyName,
      this.positionName,
      this.expiryDate,
      this.noExperience,
      this.startDate,
      this.endDate,
      this.nameSupervisor,
      this.reasonForLeaving,
      this.authorize,
      this.referanceEmail,
      this.referanceRemark});

  Experience.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    applicantId = json['applicant_id'];
    companyName = json['company_name'];
    positionName = json['position_name'];
    expiryDate = json['expiry_date'];
    noExperience = json['no_experience'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    nameSupervisor = json['name_supervisor'];
    reasonForLeaving = json['reason_for_leaving'];
    authorize = json['authorize'];
    referanceEmail = json['referance_email'];
    referanceRemark = json['referance_remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['applicant_id'] = this.applicantId;
    data['company_name'] = this.companyName;
    data['position_name'] = this.positionName;
    data['expiry_date'] = this.expiryDate;
    data['no_experience'] = this.noExperience;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['name_supervisor'] = this.nameSupervisor;
    data['reason_for_leaving'] = this.reasonForLeaving;
    data['authorize'] = this.authorize;
    data['referance_email'] = this.referanceEmail;
    data['referance_remark'] = this.referanceRemark;
    return data;
  }
}

class Credentials {
  String? image;
  String? document;

  Credentials({this.image, this.document});

  Credentials.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    document = json['document'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['document'] = this.document;
    return data;
  }
}

class Aptitude {
  String? id;
  String? category;
  String? question;
  String? answer1;
  String? answer2;
  String? answer3;
  String? answer4;
  String? correctAnswer;
  int? givenAnswer;

  Aptitude(
      {this.id,
      this.category,
      this.question,
      this.answer1,
      this.answer2,
      this.answer3,
      this.answer4,
      this.correctAnswer,
      this.givenAnswer});

  Aptitude.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    question = json['question'];
    answer1 = json['answer1'];
    answer2 = json['answer2'];
    answer3 = json['answer3'];
    answer4 = json['answer4'];
    correctAnswer = json['correct_answer'];
    givenAnswer = json['given_answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category'] = this.category;
    data['question'] = this.question;
    data['answer1'] = this.answer1;
    data['answer2'] = this.answer2;
    data['answer3'] = this.answer3;
    data['answer4'] = this.answer4;
    data['correct_answer'] = this.correctAnswer;
    data['given_answer'] = this.givenAnswer;
    return data;
  }
}

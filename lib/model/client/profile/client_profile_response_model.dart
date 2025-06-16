class ClientProfileResponseModel {
  bool? success;
  Client? client;
  Company? company;

  ClientProfileResponseModel({this.success, this.client, this.company});

  ClientProfileResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    client =
    json['client'] != null ? new Client.fromJson(json['client']) : null;
    company =
    json['company'] != null ? new Company.fromJson(json['company']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.client != null) {
      data['client'] = this.client!.toJson();
    }
    if (this.company != null) {
      data['company'] = this.company!.toJson();
    }
    return data;
  }
}

class Client {
  int? id;
  int? companyId;
  String? username;
  String? email;
  String? passwordHash;
  String? authKey;
  String? accessToken;
  String? telephone;
  dynamic ext;
  String? fax;
  String? contactName;
  String? alternateContactNo;
  int? getTimesheet;
  dynamic confirmedAt;
  dynamic unconfirmedEmail;
  dynamic blockedAt;
  String? registrationIp;
  int? flags;
  String? createdAt;
  String? updatedAt;
  int? lastLoginAt;
  String? status;
  String? role;

  Client(
      {this.id,
        this.companyId,
        this.username,
        this.email,
        this.passwordHash,
        this.authKey,
        this.accessToken,
        this.telephone,
        this.ext,
        this.fax,
        this.contactName,
        this.alternateContactNo,
        this.getTimesheet,
        this.confirmedAt,
        this.unconfirmedEmail,
        this.blockedAt,
        this.registrationIp,
        this.flags,
        this.createdAt,
        this.updatedAt,
        this.lastLoginAt,
        this.status,
        this.role});

  Client.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    username = json['username'];
    email = json['email'];
    passwordHash = json['password_hash'];
    authKey = json['auth_key'];
    accessToken = json['access_token'];
    telephone = json['telephone'];
    ext = json['ext'];
    fax = json['fax'];
    contactName = json['contact_name'];
    alternateContactNo = json['alternate_contact_no'];
    getTimesheet = json['get_timesheet'];
    confirmedAt = json['confirmed_at'];
    unconfirmedEmail = json['unconfirmed_email'];
    blockedAt = json['blocked_at'];
    registrationIp = json['registration_ip'];
    flags = json['flags'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastLoginAt = json['last_login_at'];
    status = json['status'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['password_hash'] = this.passwordHash;
    data['auth_key'] = this.authKey;
    data['access_token'] = this.accessToken;
    data['telephone'] = this.telephone;
    data['ext'] = this.ext;
    data['fax'] = this.fax;
    data['contact_name'] = this.contactName;
    data['alternate_contact_no'] = this.alternateContactNo;
    data['get_timesheet'] = this.getTimesheet;
    data['confirmed_at'] = this.confirmedAt;
    data['unconfirmed_email'] = this.unconfirmedEmail;
    data['blocked_at'] = this.blockedAt;
    data['registration_ip'] = this.registrationIp;
    data['flags'] = this.flags;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['last_login_at'] = this.lastLoginAt;
    data['status'] = this.status;
    data['role'] = this.role;
    return data;
  }
}

class Company {
  int? id;
  int? parentId;
  String? companyName;
  String? shortName;
  String? code;
  String? contactPerson;
  String? billingContactPerson;
  String? email;
  String? replaceEmail;
  String? billingEmail;
  String? toBillEmail;
  String? performanceEmail;
  dynamic billingAddress;
  String? billingCompany;
  String? hstNo;
  String? salutation;
  String? telephone;
  dynamic ext;
  String? fax;
  String? logo;
  String? overtimeHours;
  int? weeklyNotification;
  String? address;
  String? address2;
  int? country;
  int? province;
  int? city;
  String? postalCode;
  double? longitude;
  double? latitude;
  int? radius;
  String? scheduleType;
  int? showTraining;
  String? createdAt;
  String? updatedAt;
  String? status;
  dynamic contract;
  String? logoFullPath;
  String? countryName;
  String? provinceName;
  String? cityName;

  Company(
      {this.id,
        this.parentId,
        this.companyName,
        this.shortName,
        this.code,
        this.contactPerson,
        this.billingContactPerson,
        this.email,
        this.replaceEmail,
        this.billingEmail,
        this.toBillEmail,
        this.performanceEmail,
        this.billingAddress,
        this.billingCompany,
        this.hstNo,
        this.salutation,
        this.telephone,
        this.ext,
        this.fax,
        this.logo,
        this.overtimeHours,
        this.weeklyNotification,
        this.address,
        this.address2,
        this.country,
        this.province,
        this.city,
        this.postalCode,
        this.longitude,
        this.latitude,
        this.radius,
        this.scheduleType,
        this.showTraining,
        this.createdAt,
        this.updatedAt,
        this.status,
        this.contract,
        this.logoFullPath,
        this.countryName,
        this.provinceName,
        this.cityName});

  Company.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    companyName = json['company_name'];
    shortName = json['short_name'];
    code = json['code'];
    contactPerson = json['contact_person'];
    billingContactPerson = json['billing_contact_person'];
    email = json['email'];
    replaceEmail = json['replace_email'];
    billingEmail = json['billing_email'];
    toBillEmail = json['to_bill_email'];
    performanceEmail = json['performance_email'];
    billingAddress = json['billing_address'];
    billingCompany = json['billing_company'];
    hstNo = json['hst_no'];
    salutation = json['salutation'];
    telephone = json['telephone'];
    ext = json['ext'];
    fax = json['fax'];
    logo = json['logo'];
    overtimeHours = json['overtime_hours'];
    weeklyNotification = json['weekly_notification'];
    address = json['address'];
    address2 = json['address_2'];
    country = json['country'];
    province = json['province'];
    city = json['city'];
    postalCode = json['postal_code'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    radius = json['radius'];
    scheduleType = json['schedule_type'];
    showTraining = json['show_training'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    contract = json['contract'];
    logoFullPath = json['logo_full_path'];
    countryName = json['country_name'];
    provinceName = json['province_name'];
    cityName = json['city_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['company_name'] = this.companyName;
    data['short_name'] = this.shortName;
    data['code'] = this.code;
    data['contact_person'] = this.contactPerson;
    data['billing_contact_person'] = this.billingContactPerson;
    data['email'] = this.email;
    data['replace_email'] = this.replaceEmail;
    data['billing_email'] = this.billingEmail;
    data['to_bill_email'] = this.toBillEmail;
    data['performance_email'] = this.performanceEmail;
    data['billing_address'] = this.billingAddress;
    data['billing_company'] = this.billingCompany;
    data['hst_no'] = this.hstNo;
    data['salutation'] = this.salutation;
    data['telephone'] = this.telephone;
    data['ext'] = this.ext;
    data['fax'] = this.fax;
    data['logo'] = this.logo;
    data['overtime_hours'] = this.overtimeHours;
    data['weekly_notification'] = this.weeklyNotification;
    data['address'] = this.address;
    data['address_2'] = this.address2;
    data['country'] = this.country;
    data['province'] = this.province;
    data['city'] = this.city;
    data['postal_code'] = this.postalCode;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['radius'] = this.radius;
    data['schedule_type'] = this.scheduleType;
    data['show_training'] = this.showTraining;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['status'] = this.status;
    data['contract'] = this.contract;
    data['logo_full_path'] = this.logoFullPath;
    data['country_name'] = this.countryName;
    data['province_name'] = this.provinceName;
    data['city_name'] = this.cityName;
    return data;
  }
}

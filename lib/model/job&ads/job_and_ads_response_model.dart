class JobAndAdsResponseModel {
  bool? success;
  String? message;
  Response? response;

  JobAndAdsResponseModel({this.success, this.message, this.response});

  JobAndAdsResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    response = json['response'] != null
        ? Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (response != null) {
      data['response'] = response!.toJson();
    }
    return data;
  }
}

class Response {
  List<Jobs>? jobs;
  List<Ads>? ads;

  Response({this.jobs, this.ads});

  Response.fromJson(Map<String, dynamic> json) {
    if (json['jobs'] != null) {
      jobs = <Jobs>[];
      json['jobs'].forEach((v) {
        jobs!.add(Jobs.fromJson(v));
      });
    }
    if (json['ads'] != null) {
      ads = <Ads>[];
      json['ads'].forEach((v) {
        ads!.add(Ads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (jobs != null) {
      data['jobs'] = jobs!.map((v) => v.toJson()).toList();
    }
    if (ads != null) {
      data['ads'] = ads!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Jobs {
  int? jobId;
  String? jobPosition;
  String? positionDescription;
  String? shareDescription;
  String? positionDate;
  String? location;
  int? noOfPositions;
  String? salary;
  String? image;
  String? imageUrl;
  String? onlyImage;

  Jobs(
      {this.jobId,
        this.jobPosition,
        this.positionDescription,
        this.shareDescription,
        this.positionDate,
        this.location,
        this.noOfPositions,
        this.salary,
        this.image,
        this.imageUrl,
        this.onlyImage});

  Jobs.fromJson(Map<String, dynamic> json) {
    jobId = json['job_id'];
    jobPosition = json['job_position'];
    positionDescription = json['position_description'];
    shareDescription = json['share_description'];
    positionDate = json['position_date'];
    location = json['location'];
    noOfPositions = json['no_of_positions'];
    salary = json['salary'];
    image = json['image'];
    imageUrl = json['image_url'];
    onlyImage = json['only_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['job_id'] = jobId;
    data['job_position'] = jobPosition;
    data['position_description'] = positionDescription;
    data['share_description'] = shareDescription;
    data['position_date'] = positionDate;
    data['location'] = location;
    data['no_of_positions'] = noOfPositions;
    data['salary'] = salary;
    data['image'] = image;
    data['image_url'] = imageUrl;
    data['only_image'] = onlyImage;
    return data;
  }
}

class Ads {
  int? adsId;
  String? subjectLine;
  String? description;
  String? shareDescription;
  String? date;
  String? place;
  String? amount;
  String? image;
  String? imageUrl;
  String? status;
  String? onlyImage;

  Ads(
      {this.adsId,
        this.subjectLine,
        this.description,
        this.shareDescription,
        this.date,
        this.place,
        this.amount,
        this.image,
        this.imageUrl,
        this.status,
        this.onlyImage});

  Ads.fromJson(Map<String, dynamic> json) {
    adsId = json['ads_id'];
    subjectLine = json['subject_line'];
    description = json['description'];
    shareDescription = json['share_description'];
    date = json['date'];
    place = json['place'];
    amount = json['amount'];
    image = json['image'];
    imageUrl = json['image_url'];
    status = json['status'];
    onlyImage = json['only_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ads_id'] = adsId;
    data['subject_line'] = subjectLine;
    data['description'] = description;
    data['share_description'] = shareDescription;
    data['date'] = date;
    data['place'] = place;
    data['amount'] = amount;
    data['image'] = image;
    data['image_url'] = imageUrl;
    data['status'] = status;
    data['only_image'] = onlyImage;
    return data;
  }
}

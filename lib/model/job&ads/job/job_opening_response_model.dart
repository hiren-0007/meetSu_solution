class JobOpeningResponseModel {
  bool? success;
  String? message;
  Response? response;

  JobOpeningResponseModel({this.success, this.message, this.response});

  JobOpeningResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    response = json['response'] != null
        ? new Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.response != null) {
      data['response'] = this.response!.toJson();
    }
    return data;
  }
}

class Response {
  List<Jobs>? jobs;

  Response({this.jobs});

  Response.fromJson(Map<String, dynamic> json) {
    if (json['jobs'] != null) {
      jobs = <Jobs>[];
      json['jobs'].forEach((v) {
        jobs!.add(new Jobs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.jobs != null) {
      data['jobs'] = this.jobs!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['job_id'] = this.jobId;
    data['job_position'] = this.jobPosition;
    data['position_description'] = this.positionDescription;
    data['share_description'] = this.shareDescription;
    data['position_date'] = this.positionDate;
    data['location'] = this.location;
    data['no_of_positions'] = this.noOfPositions;
    data['salary'] = this.salary;
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    data['only_image'] = this.onlyImage;
    return data;
  }
}

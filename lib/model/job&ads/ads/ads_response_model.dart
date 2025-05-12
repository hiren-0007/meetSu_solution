class AdsResponseModel {
  bool? success;
  String? message;
  Response? response;

  AdsResponseModel({this.success, this.message, this.response});

  AdsResponseModel.fromJson(Map<String, dynamic> json) {
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
  List<Ads>? ads;

  Response({this.ads});

  Response.fromJson(Map<String, dynamic> json) {
    if (json['ads'] != null) {
      ads = <Ads>[];
      json['ads'].forEach((v) {
        ads!.add(new Ads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ads != null) {
      data['ads'] = this.ads!.map((v) => v.toJson()).toList();
    }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ads_id'] = this.adsId;
    data['subject_line'] = this.subjectLine;
    data['description'] = this.description;
    data['share_description'] = this.shareDescription;
    data['date'] = this.date;
    data['place'] = this.place;
    data['amount'] = this.amount;
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    data['status'] = this.status;
    data['only_image'] = this.onlyImage;
    return data;
  }
}

class AdsResponseModel {
  final bool? success;
  final String? message;
  final AdsResponseData? response;

  AdsResponseModel({
    this.success,
    this.message,
    this.response,
  });

  factory AdsResponseModel.fromJson(Map<String, dynamic> json) {
    return AdsResponseModel(
      success: json['success'],
      message: json['message'],
      response: json['response'] != null
          ? AdsResponseData.fromJson(json['response'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (response != null) 'response': response!.toJson(),
    };
  }
}

class AdsResponseData {
  final List<Ads>? ads;

  AdsResponseData({this.ads});

  factory AdsResponseData.fromJson(Map<String, dynamic> json) {
    return AdsResponseData(
      ads: json['ads'] != null
          ? List<Ads>.from(json['ads'].map((v) => Ads.fromJson(v)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ads != null) 'ads': ads!.map((v) => v.toJson()).toList(),
    };
  }
}

class Ads {
  final int? adsId;
  final String? subjectLine;
  final String? description;
  final String? shareDescription;
  final String? date;
  final String? place;
  final String? amount;
  final String? image;
  final String? imageUrl;
  final String? status;
  final String? onlyImage;

  Ads({
    this.adsId,
    this.subjectLine,
    this.description,
    this.shareDescription,
    this.date,
    this.place,
    this.amount,
    this.image,
    this.imageUrl,
    this.status,
    this.onlyImage,
  });

  factory Ads.fromJson(Map<String, dynamic> json) {
    return Ads(
      adsId: json['ads_id'],
      subjectLine: json['subject_line'],
      description: json['description'],
      shareDescription: json['share_description'],
      date: json['date'],
      place: json['place'],
      amount: json['amount'],
      image: json['image'],
      imageUrl: json['image_url'],
      status: json['status'],
      onlyImage: json['only_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ads_id': adsId,
      'subject_line': subjectLine,
      'description': description,
      'share_description': shareDescription,
      'date': date,
      'place': place,
      'amount': amount,
      'image': image,
      'image_url': imageUrl,
      'status': status,
      'only_image': onlyImage,
    };
  }
}

class WeatherResponseModel {
  String? temperature;

  WeatherResponseModel({this.temperature});

  WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['temperature'] != null) {
      if (json['temperature'] is int || json['temperature'] is double) {
        temperature = json['temperature'].toString();
      } else {
        temperature = json['temperature'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['temperature'] = this.temperature;
    return data;
  }
}
class WeatherResponseModel {
  String? temperature;
  String? date;
  String? icon;

  WeatherResponseModel({
    this.temperature,
    this.date,
    this.icon,
  });

  WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    temperature = json['temperature'];
    date = json['date'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['temperature'] = temperature;
    data['date'] = date;
    data['icon'] = icon;
    return data;
  }
}
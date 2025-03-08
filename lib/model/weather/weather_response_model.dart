class GetWeatherResponse {
  String? temperature;
   String? date;
   String? icon;

  GetWeatherResponse({this.temperature,this.date,this.icon});

  GetWeatherResponse.fromJson(Map<String, dynamic> json) {
    temperature = json['temperature'];
    date = json['date'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temperature'] = this.temperature;
    data['date'] = this.date;
    data['icon'] = this.icon;
    return data;
  }
}

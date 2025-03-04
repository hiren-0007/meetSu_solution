class LoginResponseModel {
  String? accessToken;
  int? isTempLogin;

  LoginResponseModel({this.accessToken, this.isTempLogin});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    isTempLogin = json['is_temp_login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['is_temp_login'] = isTempLogin;
    return data;
  }
}

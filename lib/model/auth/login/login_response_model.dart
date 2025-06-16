class LoginResponseModel {
  String? accessToken;
  int? isTempLogin;
  String? login;

  LoginResponseModel({this.accessToken, this.isTempLogin, this.login});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    isTempLogin = json['is_temp_login'];
    login = json['login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['is_temp_login'] = this.isTempLogin;
    data['login'] = this.login;
    return data;
  }
}

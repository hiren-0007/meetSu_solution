class ScheduleResponseModel {
  List<Data>? data;
  String? payCheck;
  ScheduleDate? date;

  ScheduleResponseModel({this.data, this.payCheck, this.date});

  ScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    payCheck = json['pay_check'];
    date = json['date'] != null ? ScheduleDate.fromJson(json['date']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['pay_check'] = this.payCheck;
    if (this.date != null) {
      data['date'] = this.date!.toJson();
    }
    return data;
  }
}

class Data {
  String? company;
  String? position;
  String? shift;
  String? startTime;
  String? endTime;
  String? hours;
  String? date;
  String? rate;
  String? totalPay;

  Data({
    this.company,
    this.position,
    this.shift,
    this.startTime,
    this.endTime,
    this.hours,
    this.date,
    this.rate,
    this.totalPay,
  });

  Data.fromJson(Map<String, dynamic> json) {
    company = json['company'];
    position = json['position'];
    shift = json['shift'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    hours = json['hours'];
    date = json['date'];
    rate = json['rate'];
    totalPay = json['total_pay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company'] = company;
    data['position'] = position;
    data['shift'] = shift;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['hours'] = hours;
    data['date'] = date;
    data['rate'] = rate;
    data['total_pay'] = totalPay;
    return data;
  }
}

class ScheduleDate {
  String? prevSd;
  String? prevEd;
  String? nextSd;
  String? nextEd;

  ScheduleDate({this.prevSd, this.prevEd, this.nextSd, this.nextEd});

  ScheduleDate.fromJson(Map<String, dynamic> json) {
    prevSd = json['prev_sd'];
    prevEd = json['prev_ed'];
    nextSd = json['next_sd'];
    nextEd = json['next_ed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prev_sd'] = prevSd;
    data['prev_ed'] = prevEd;
    data['next_sd'] = nextSd;
    data['next_ed'] = nextEd;
    return data;
  }
}

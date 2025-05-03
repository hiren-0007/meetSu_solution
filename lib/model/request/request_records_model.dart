class RequestRecordsModel {
  List<RequestRecord>? data;

  RequestRecordsModel({this.data});

  RequestRecordsModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <RequestRecord>[];
      json['data'].forEach((v) {
        data!.add(new RequestRecord.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RequestRecord {
  String? id;
  String? applicantId;
  String? amount;
  String? date;
  String? reason;
  String? filename;
  Null? signName;
  String? createdDate;
  String? modifiedDate;
  String? filepath;

  RequestRecord(
      {this.id,
        this.applicantId,
        this.amount,
        this.date,
        this.reason,
        this.filename,
        this.signName,
        this.createdDate,
        this.modifiedDate,
        this.filepath});

  RequestRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    applicantId = json['applicant_id'];
    amount = json['amount'];
    date = json['date'];
    reason = json['reason'];
    filename = json['filename'];
    signName = json['sign_name'];
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    filepath = json['filepath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['applicant_id'] = this.applicantId;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['reason'] = this.reason;
    data['filename'] = this.filename;
    data['sign_name'] = this.signName;
    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['filepath'] = this.filepath;
    return data;
  }
}


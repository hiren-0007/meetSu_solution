class CompletedTrainingResponseModel {
  List<Data>? data;

  CompletedTrainingResponseModel({this.data});

  CompletedTrainingResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? clientName;
  String? trainingName;
  int? trainingId;
  int? score;
  String? document;

  Data(
      {this.clientName,
        this.trainingName,
        this.trainingId,
        this.score,
        this.document});

  Data.fromJson(Map<String, dynamic> json) {
    clientName = json['client_name'];
    trainingName = json['training_name'];
    trainingId = json['training_id'];
    score = json['score'];
    document = json['document'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_name'] = clientName;
    data['training_name'] = trainingName;
    data['training_id'] = trainingId;
    data['score'] = score;
    data['document'] = document;
    return data;
  }
}

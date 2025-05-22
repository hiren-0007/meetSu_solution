class CompletedTrainingResponseModel {
  List<CompletedTrainingData>? data;

  CompletedTrainingResponseModel({this.data});

  CompletedTrainingResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CompletedTrainingData>[];
      json['data'].forEach((v) {
        data!.add(CompletedTrainingData.fromJson(v));
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

class CompletedTrainingData {
  String? clientName;
  String? trainingName;
  int? trainingId;
  int? score;
  String? document;

  CompletedTrainingData({
    this.clientName,
    this.trainingName,
    this.trainingId,
    this.score,
    this.document
  });

  CompletedTrainingData.fromJson(Map<String, dynamic> json) {
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
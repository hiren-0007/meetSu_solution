class AssignedTrainingResponseModel {
  List<AssignedTrainingData>? data;

  AssignedTrainingResponseModel({this.data});

  AssignedTrainingResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <AssignedTrainingData>[];
      json['data'].forEach((v) {
        data!.add(AssignedTrainingData.fromJson(v));
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

class AssignedTrainingData {
  String? clientName;
  String? trainingName;
  int? trainingId;
  int? docRead;

  AssignedTrainingData({
    this.clientName,
    this.trainingName,
    this.trainingId,
    this.docRead
  });

  AssignedTrainingData.fromJson(Map<String, dynamic> json) {
    clientName = json['client_name'];
    trainingName = json['training_name'];
    trainingId = json['training_id'];
    docRead = json['doc_read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_name'] = clientName;
    data['training_name'] = trainingName;
    data['training_id'] = trainingId;
    data['doc_read'] = docRead;
    return data;
  }
}
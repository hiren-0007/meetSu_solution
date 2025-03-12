class TrainingDocResponseModel {
  int? showTest;
  List<Data>? data;

  TrainingDocResponseModel({this.showTest, this.data});

  TrainingDocResponseModel.fromJson(Map<String, dynamic> json) {
    showTest = json['show_test'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['show_test'] = showTest;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? name;
  int? trainingId;
  int? documentId;
  String? document;
  Null youtube;

  Data(
      {this.name,
        this.trainingId,
        this.documentId,
        this.document,
        this.youtube});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    trainingId = json['training_id'];
    documentId = json['document_id'];
    document = json['document'];
    youtube = json['youtube'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['training_id'] = trainingId;
    data['document_id'] = documentId;
    data['document'] = document;
    data['youtube'] = youtube;
    return data;
  }
}

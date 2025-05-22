class TrainingDocViewResponseModel {
  int? trainingId;
  String? documentName;
  String? documentPath;
  String? youtube;
  String? vimeo;
  int? documentViewed;
  int? giveTest;
  String? nextDocument;
  String? content;

  TrainingDocViewResponseModel({
    this.trainingId,
    this.documentName,
    this.documentPath,
    this.youtube,
    this.vimeo,
    this.documentViewed,
    this.giveTest,
    this.nextDocument,
    this.content
  });

  TrainingDocViewResponseModel.fromJson(Map<String, dynamic> json) {
    trainingId = json['training_id'];
    documentName = json['document_name'];
    documentPath = json['document_path'];
    youtube = json['youtube'];
    vimeo = json['vimeo'];
    documentViewed = json['document_viewed'];
    giveTest = json['give_test'];
    nextDocument = json['next_document'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['training_id'] = trainingId;
    data['document_name'] = documentName;
    data['document_path'] = documentPath;
    data['youtube'] = youtube;
    data['vimeo'] = vimeo;
    data['document_viewed'] = documentViewed;
    data['give_test'] = giveTest;
    data['next_document'] = nextDocument;
    data['content'] = content;
    return data;
  }
}
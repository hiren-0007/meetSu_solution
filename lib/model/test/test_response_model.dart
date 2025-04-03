class TestResponseModel {
  List<Data>? data;

  TestResponseModel({this.data});

  TestResponseModel.fromJson(Map<String, dynamic> json) {
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
  QuestionData? questionData;
  List<Answer>? answer;
  String? imageUrl;

  Data({this.questionData, this.answer, this.imageUrl});

  Data.fromJson(Map<String, dynamic> json) {
    questionData = json['question_data'] != null
        ? QuestionData.fromJson(json['question_data'])
        : null;
    if (json['answer'] != null) {
      answer = <Answer>[];
      json['answer'].forEach((v) {
        answer!.add(Answer.fromJson(v));
      });
    }
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (questionData != null) {
      data['question_data'] = questionData!.toJson();
    }
    if (answer != null) {
      data['answer'] = answer!.map((v) => v.toJson()).toList();
    }
    data['image_url'] = imageUrl;
    return data;
  }
}

class QuestionData {
  int? id;
  int? trainingId;
  String? image;
  String? question;
  String? createdDate;
  int? createdBy;
  String? modifiedDate;
  int? modifiedBy;

  QuestionData(
      {this.id,
        this.trainingId,
        this.image,
        this.question,
        this.createdDate,
        this.createdBy,
        this.modifiedDate,
        this.modifiedBy});

  QuestionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trainingId = json['training_id'];
    image = json['image'];
    question = json['question'];
    createdDate = json['created_date'];
    createdBy = json['created_by'];
    modifiedDate = json['modified_date'];
    modifiedBy = json['modified_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['training_id'] = trainingId;
    data['image'] = image;
    data['question'] = question;
    data['created_date'] = createdDate;
    data['created_by'] = createdBy;
    data['modified_date'] = modifiedDate;
    data['modified_by'] = modifiedBy;
    return data;
  }
}

class Answer {
  int? id;
  int? questionId;
  String? answer;
  int? isCorrect;
  int? sortOrder;
  String? createdDate;
  int? createdBy;
  String? modifiedDate;
  int? modifiedBy;

  Answer(
      {this.id,
        this.questionId,
        this.answer,
        this.isCorrect,
        this.sortOrder,
        this.createdDate,
        this.createdBy,
        this.modifiedDate,
        this.modifiedBy});

  Answer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionId = json['question_id'];
    answer = json['answer'];
    isCorrect = json['is_correct'];
    sortOrder = json['sort_order'];
    createdDate = json['created_date'];
    createdBy = json['created_by'];
    modifiedDate = json['modified_date'];
    modifiedBy = json['modified_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question_id'] = questionId;
    data['answer'] = answer;
    data['is_correct'] = isCorrect;
    data['sort_order'] = sortOrder;
    data['created_date'] = createdDate;
    data['created_by'] = createdBy;
    data['modified_date'] = modifiedDate;
    data['modified_by'] = modifiedBy;
    return data;
  }
}

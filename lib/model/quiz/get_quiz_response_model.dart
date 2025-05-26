class GetQuizResponseModel {
  Quiz? quiz;
  int? show;
  int? duration;

  GetQuizResponseModel({this.quiz, this.show, this.duration});

  GetQuizResponseModel.fromJson(Map<String, dynamic> json) {
    quiz = json['quiz'] != null ? new Quiz.fromJson(json['quiz']) : null;
    show = json['show'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.quiz != null) {
      data['quiz'] = this.quiz!.toJson();
    }
    data['show'] = this.show;
    data['duration'] = this.duration;
    return data;
  }
}

class Quiz {
  int? id;
  String? question;
  String? answer;
  String? status;
  int? taken;
  String? createdDate;
  int? createdBy;
  int? modifiedBy;
  String? modifiedDate;

  Quiz(
      {this.id,
        this.question,
        this.answer,
        this.status,
        this.taken,
        this.createdDate,
        this.createdBy,
        this.modifiedBy,
        this.modifiedDate});

  Quiz.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    status = json['status'];
    taken = json['taken'];
    createdDate = json['created_date'];
    createdBy = json['created_by'];
    modifiedBy = json['modified_by'];
    modifiedDate = json['modified_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['answer'] = this.answer;
    data['status'] = this.status;
    data['taken'] = this.taken;
    data['created_date'] = this.createdDate;
    data['created_by'] = this.createdBy;
    data['modified_by'] = this.modifiedBy;
    data['modified_date'] = this.modifiedDate;
    return data;
  }
}

class ApiEndpoints {

  static const String login = 'login/login';

  static const String profile = 'flutter/profile';

  static const String schedule = 'flutter/schedule';

  static const String getAdsOnly = 'job/get-jobopenings-ads?page=0&limit=100&job_or_ads=2&webmob=0';

  static const String getJobsOnly = 'job/get-jobopenings-ads?page=0&limit=100&job_or_ads=1&webmob=0';

  static const String jobShare = 'flutter/share-link';

  static const String compliance = 'flutter/compliance';

  static const String contactUs  = 'flutter/contact';

  static const String addDeduction = 'flutter/add-deduction';

  static const String getRequestData = 'flutter/show-deduction';

  static const String getWeather = 'flutter/weather';

  static const String getTrainingAssigned = 'flutter/training-assigned';

  static const String getTrainingCompleted = 'flutter/training-finished';

  static const String trainingDoc = 'flutter/training-documents';

  static const String trainingView = 'flutter/training-view';

  static const String showCheckIn = 'flutter/show-checkin';

  static const String giveTest = 'flutter/test';

  static const String submitTest = 'flutter/test-submit';

  static const String complianceDownload = 'flutter/download-compliance';

  static const String checkIn = 'flutter/checkin';

  static const String checkOut = 'flutter/checkout';

  static const String fcmToken = 'flutter/user-token';

  static const String userLogout = 'flutter/logout';

  static const String getShowQuiz = 'flutter/show-quiz';

  static const String getQuiz = 'flutter/quiz';

  static const String quizAnswer = 'flutter/quiz-answer';


  //////////////////////////////////////////////////////////////////////

  static const String clintLogout = 'client/logout';
  static const String getClintProfile = 'client/profile';
  static const String getClintShift = 'client/shifts';
  static const String getClintPositions = 'client/positions';
  static const String createJobRequest = 'client/create-job-request';
  static const String weeklyReport = 'client/weekly-report';
  static const String clintSchedule = 'client/schedule';
  static const String showAssignedApplicants = 'client/show-assigned-applicants';
  static const String showClientWeather = 'client/weather';
}
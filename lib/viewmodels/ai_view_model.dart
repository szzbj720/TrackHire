import 'package:flutter/material.dart';

import '../models/ai_job_analysis.dart';
import '../services/ai_service.dart';

class AIViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();

  bool _isLoading = false;
  bool _isTailoringResume = false;

  String _errorMessage = '';
  String _resumeTailorError = '';

  AIJobAnalysis? _analysis;
  List<String> _tailoredResumeBullets = [];

  bool get isLoading => _isLoading;
  bool get isTailoringResume => _isTailoringResume;

  String get errorMessage => _errorMessage;
  String get resumeTailorError => _resumeTailorError;

  AIJobAnalysis? get analysis => _analysis;
  List<String> get tailoredResumeBullets => _tailoredResumeBullets;

  Future<void> analyzeJobDescription(String jobDescription) async {
    if (jobDescription.trim().isEmpty) {
      _errorMessage = 'Please paste a job description first.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    _analysis = null;
    notifyListeners();

    try {
      _analysis = await _aiService.analyzeJobDescription(jobDescription);
    } catch (error) {
      _errorMessage =
      'Something went wrong while analyzing the job description.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> tailorResume(String jobDescription) async {
    if (jobDescription.trim().isEmpty) {
      _resumeTailorError = 'Please paste a job description first.';
      notifyListeners();
      return;
    }

    _isTailoringResume = true;
    _resumeTailorError = '';
    _tailoredResumeBullets = [];
    notifyListeners();

    try {
      _tailoredResumeBullets = await _aiService.tailorResume(jobDescription);
    } catch (error) {
      _resumeTailorError =
      'Something went wrong while tailoring your resume.';
    }

    _isTailoringResume = false;
    notifyListeners();
  }

  void clearAnalysis() {
    _analysis = null;
    _errorMessage = '';
    _resumeTailorError = '';
    _tailoredResumeBullets = [];
    notifyListeners();
  }
}
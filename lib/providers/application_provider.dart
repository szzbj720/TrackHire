import 'package:flutter/material.dart';

import '../models/job_application.dart';
import '../services/api_service.dart';

class ApplicationProvider extends ChangeNotifier {
  List<JobApplication> applications = [];
  bool isLoading = true;
  String? errorMessage;

  int selectedPageIndex = 0;

  String searchQuery = '';
  String selectedFilter = 'All';
  String selectedChecklistFilter = 'All Docs';

  final List<String> filters = [
    'All',
    'Applied',
    'Interviewing',
    'Offer',
    'Rejected',
  ];

  final List<String> checklistFilters = [
    'All Docs',
    'Complete',
    'Incomplete',
    'Needs Resume',
    'Needs Portfolio',
    'Needs Cover Letter',
    'Needs Questions',
    'Needs Other',
  ];

  ApplicationProvider() {
    loadApplications();
  }

  List<JobApplication> get savedApplications {
    return applications.where((application) => application.isSaved).toList();
  }

  List<JobApplication> get filteredApplications {
    List<JobApplication> sourceApplications = selectedPageIndex == 0
        ? applications
        : savedApplications;

    return sourceApplications.where((application) {
      final String query = searchQuery.toLowerCase();

      final bool matchesSearch =
          application.company.toLowerCase().contains(query) ||
          application.role.toLowerCase().contains(query) ||
          application.location.toLowerCase().contains(query) ||
          application.salaryRange.toLowerCase().contains(query) ||
          application.notes.toLowerCase().contains(query);

      final bool matchesStatusFilter =
          selectedFilter == 'All' || application.status == selectedFilter;

      bool matchesChecklistFilter = true;

      if (selectedChecklistFilter == 'Complete') {
        matchesChecklistFilter = application.isChecklistComplete;
      } else if (selectedChecklistFilter == 'Incomplete') {
        matchesChecklistFilter = !application.isChecklistComplete;
      } else if (selectedChecklistFilter == 'Needs Resume') {
        matchesChecklistFilter = !application.hasResume;
      } else if (selectedChecklistFilter == 'Needs Portfolio') {
        matchesChecklistFilter = !application.hasPortfolio;
      } else if (selectedChecklistFilter == 'Needs Cover Letter') {
        matchesChecklistFilter = !application.hasCoverLetter;
      } else if (selectedChecklistFilter == 'Needs Questions') {
        matchesChecklistFilter = !application.hasApplicationQuestions;
      } else if (selectedChecklistFilter == 'Needs Other') {
        matchesChecklistFilter = !application.hasOther;
      }

      return matchesSearch && matchesStatusFilter && matchesChecklistFilter;
    }).toList();
  }

  int get totalApplications {
    return applications.length;
  }

  int get savedCount {
    return savedApplications.length;
  }

  int get interviewingCount {
    return applications
        .where((application) => application.status == 'Interviewing')
        .length;
  }

  int get offerCount {
    return applications
        .where((application) => application.status == 'Offer')
        .length;
  }

  int get rejectedCount {
    return applications
        .where((application) => application.status == 'Rejected')
        .length;
  }

  Future<void> loadApplications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      applications = await ApiService.fetchApplications();
    } catch (error) {
      errorMessage = error.toString();
      applications = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addApplication(JobApplication newApplication) async {
    try {
      final JobApplication createdApplication =
          await ApiService.createApplication(newApplication);

      applications.insert(0, createdApplication);
      errorMessage = null;
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> updateApplication(
    int index,
    JobApplication updatedApplication,
  ) async {
    if (index < 0 || index >= applications.length) {
      return;
    }

    final int? id = applications[index].id;

    if (id == null) {
      return;
    }

    try {
      final JobApplication savedApplication =
          await ApiService.updateApplication(id, updatedApplication);

      applications[index] = savedApplication;
      errorMessage = null;
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteApplication(int index) async {
    if (index < 0 || index >= applications.length) {
      return;
    }

    final int? id = applications[index].id;

    if (id == null) {
      return;
    }

    try {
      await ApiService.deleteApplication(id);

      applications.removeAt(index);
      errorMessage = null;
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleSaved(JobApplication selectedApplication) async {
    final int originalIndex = applications.indexOf(selectedApplication);

    if (originalIndex == -1) {
      return;
    }

    final int? id = selectedApplication.id;

    if (id == null) {
      return;
    }

    try {
      final JobApplication updatedApplication = await ApiService.toggleSaved(
        id,
      );

      applications[originalIndex] = updatedApplication;
      errorMessage = null;
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  void setStatusFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  void setChecklistFilter(String value) {
    selectedChecklistFilter = value;
    notifyListeners();
  }

  void clearSearchAndFilters() {
    searchQuery = '';
    selectedFilter = 'All';
    selectedChecklistFilter = 'All Docs';
    notifyListeners();
  }

  void changePage(int index) {
    selectedPageIndex = index;
    searchQuery = '';
    selectedFilter = 'All';
    selectedChecklistFilter = 'All Docs';
    notifyListeners();
  }
}

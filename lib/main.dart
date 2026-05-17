import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TrackHireApp());
}

class TrackHireApp extends StatelessWidget {
  const TrackHireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackHire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class JobApplication {
  final String company;
  final String role;
  final String status;
  final String dateApplied;
  final String location;
  final String salaryRange;
  final String notes;
  final bool hasResume;
  final bool hasPortfolio;
  final bool hasCoverLetter;
  final bool hasApplicationQuestions;
  final bool hasOther;
  final bool isSaved;

  const JobApplication({
    required this.company,
    required this.role,
    required this.status,
    required this.dateApplied,
    required this.location,
    required this.salaryRange,
    required this.notes,
    required this.hasResume,
    required this.hasPortfolio,
    required this.hasCoverLetter,
    required this.hasApplicationQuestions,
    required this.hasOther,
    required this.isSaved,
  });

  JobApplication copyWith({
    String? company,
    String? role,
    String? status,
    String? dateApplied,
    String? location,
    String? salaryRange,
    String? notes,
    bool? hasResume,
    bool? hasPortfolio,
    bool? hasCoverLetter,
    bool? hasApplicationQuestions,
    bool? hasOther,
    bool? isSaved,
  }) {
    return JobApplication(
      company: company ?? this.company,
      role: role ?? this.role,
      status: status ?? this.status,
      dateApplied: dateApplied ?? this.dateApplied,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      notes: notes ?? this.notes,
      hasResume: hasResume ?? this.hasResume,
      hasPortfolio: hasPortfolio ?? this.hasPortfolio,
      hasCoverLetter: hasCoverLetter ?? this.hasCoverLetter,
      hasApplicationQuestions:
      hasApplicationQuestions ?? this.hasApplicationQuestions,
      hasOther: hasOther ?? this.hasOther,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'role': role,
      'status': status,
      'dateApplied': dateApplied,
      'location': location,
      'salaryRange': salaryRange,
      'notes': notes,
      'hasResume': hasResume,
      'hasPortfolio': hasPortfolio,
      'hasCoverLetter': hasCoverLetter,
      'hasApplicationQuestions': hasApplicationQuestions,
      'hasOther': hasOther,
      'isSaved': isSaved,
    };
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? 'Applied',
      dateApplied: json['dateApplied'] ?? 'No date added',
      location: json['location'] ?? 'No location added',
      salaryRange: json['salaryRange'] ?? 'No salary added',
      notes: json['notes'] ?? 'No notes added.',
      hasResume: json['hasResume'] ?? false,
      hasPortfolio: json['hasPortfolio'] ?? false,
      hasCoverLetter: json['hasCoverLetter'] ?? false,
      hasApplicationQuestions: json['hasApplicationQuestions'] ?? false,
      hasOther: json['hasOther'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }

  int get checklistCompletedCount {
    int count = 0;

    if (hasResume) {
      count++;
    }
    if (hasPortfolio) {
      count++;
    }
    if (hasCoverLetter) {
      count++;
    }
    if (hasApplicationQuestions) {
      count++;
    }
    if (hasOther) {
      count++;
    }

    return count;
  }

  bool get isChecklistComplete {
    return checklistCompletedCount == 5;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String storageKey = 'job_applications';

  List<JobApplication> applications = [];
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  List<JobApplication> get savedApplications {
    return applications.where((application) => application.isSaved).toList();
  }

  List<JobApplication> get filteredApplications {
    List<JobApplication> sourceApplications =
    selectedPageIndex == 0 ? applications : savedApplications;

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

  Future<void> loadApplications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(storageKey);

    if (savedData == null) {
      setState(() {
        applications = [
          const JobApplication(
            company: 'Apple',
            role: 'iOS Developer',
            status: 'Applied',
            dateApplied: 'May 17, 2026',
            location: 'Cupertino, CA',
            salaryRange: '\$120k - \$160k',
            notes: 'Applied through LinkedIn.',
            hasResume: true,
            hasPortfolio: true,
            hasCoverLetter: false,
            hasApplicationQuestions: true,
            hasOther: false,
            isSaved: true,
          ),
          const JobApplication(
            company: 'Robinhood',
            role: 'Mobile Engineer',
            status: 'Interviewing',
            dateApplied: 'May 15, 2026',
            location: 'Remote',
            salaryRange: '\$130k - \$170k',
            notes: 'Need to follow up with recruiter.',
            hasResume: true,
            hasPortfolio: true,
            hasCoverLetter: true,
            hasApplicationQuestions: true,
            hasOther: false,
            isSaved: false,
          ),
          const JobApplication(
            company: 'Duolingo',
            role: 'Software Engineer',
            status: 'Rejected',
            dateApplied: 'May 10, 2026',
            location: 'Pittsburgh, PA',
            salaryRange: 'Not listed',
            notes: 'Keep improving mobile portfolio.',
            hasResume: true,
            hasPortfolio: false,
            hasCoverLetter: false,
            hasApplicationQuestions: true,
            hasOther: false,
            isSaved: false,
          ),
        ];
        isLoading = false;
      });

      await saveApplications();
      return;
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    setState(() {
      applications =
          decodedData.map((item) => JobApplication.fromJson(item)).toList();
      isLoading = false;
    });
  }

  Future<void> saveApplications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> encodedApplications =
    applications.map((application) => application.toJson()).toList();

    await prefs.setString(storageKey, jsonEncode(encodedApplications));
  }

  Future<void> addApplication(JobApplication newApplication) async {
    setState(() {
      applications.add(newApplication);
    });

    await saveApplications();
  }

  Future<void> updateApplication(
      int index,
      JobApplication updatedApplication,
      ) async {
    setState(() {
      applications[index] = updatedApplication;
    });

    await saveApplications();
  }

  Future<void> deleteApplication(int index) async {
    setState(() {
      applications.removeAt(index);
    });

    await saveApplications();
  }

  Future<void> toggleSaved(JobApplication selectedApplication) async {
    final int originalIndex = applications.indexOf(selectedApplication);

    if (originalIndex == -1) {
      return;
    }

    final JobApplication updatedApplication = selectedApplication.copyWith(
      isSaved: !selectedApplication.isSaved,
    );

    await updateApplication(originalIndex, updatedApplication);
  }

  Future<void> openAddJobScreen() async {
    final newApplication = await Navigator.push<JobApplication>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditJobScreen(),
      ),
    );

    if (newApplication != null) {
      await addApplication(newApplication);
    }
  }

  Future<void> openDetailScreen(JobApplication selectedApplication) async {
    final int originalIndex = applications.indexOf(selectedApplication);

    if (originalIndex == -1) {
      return;
    }

    final result = await Navigator.push<JobDetailResult>(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(
          application: selectedApplication,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    if (result.shouldDelete) {
      await deleteApplication(originalIndex);
      return;
    }

    if (result.updatedApplication != null) {
      await updateApplication(originalIndex, result.updatedApplication!);
    }
  }

  void clearSearchAndFilters() {
    setState(() {
      searchQuery = '';
      selectedFilter = 'All';
      selectedChecklistFilter = 'All Docs';
    });
  }

  void changePage(int index) {
    setState(() {
      selectedPageIndex = index;
      searchQuery = '';
      selectedFilter = 'All';
      selectedChecklistFilter = 'All Docs';
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalApplications = applications.length;
    int savedCount = savedApplications.length;
    int interviewingCount = applications
        .where((application) => application.status == 'Interviewing')
        .length;
    int offerCount =
        applications.where((application) => application.status == 'Offer').length;
    int rejectedCount = applications
        .where((application) => application.status == 'Rejected')
        .length;

    final List<JobApplication> visibleApplications = filteredApplications;

    String pageTitle =
    selectedPageIndex == 0 ? 'Recent Applications' : 'Saved Applications';

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackHire'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            selectedPageIndex == 0
                ? 'Job Application Tracker'
                : 'Saved Applications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedPageIndex == 0
                ? 'Track applications, interviews, documents, and application progress in one place.'
                : 'Quickly revisit the jobs you care about most.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total',
                  value: totalApplications.toString(),
                  icon: Icons.work_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Saved',
                  value: savedCount.toString(),
                  icon: Icons.favorite_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Offers',
                  value: offerCount.toString(),
                  icon: Icons.star_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Interviewing',
                  value: interviewingCount.toString(),
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Rejected',
                  value: rejectedCount.toString(),
                  icon: Icons.close,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          TextField(
            decoration: InputDecoration(
              labelText: 'Search applications',
              hintText:
              'Search by company, role, location, salary, or notes',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          Text(
            'Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (String filter in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Materials',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (String filter in checklistFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: selectedChecklistFilter == filter,
                      onSelected: (_) {
                        setState(() {
                          selectedChecklistFilter = filter;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pageTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${visibleApplications.length} shown',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (selectedPageIndex == 0 && applications.isEmpty)
            const EmptyApplicationMessage()
          else if (selectedPageIndex == 1 && savedApplications.isEmpty)
            const EmptySavedMessage()
          else if (visibleApplications.isEmpty)
              EmptySearchMessage(
                onClear: clearSearchAndFilters,
              )
            else
              for (JobApplication application in visibleApplications)
                JobCard(
                  application: application,
                  onTap: () {
                    openDetailScreen(application);
                  },
                  onSavedTap: () {
                    toggleSaved(application);
                  },
                ),
        ],
      ),
      floatingActionButton: selectedPageIndex == 0
          ? FloatingActionButton.extended(
        onPressed: openAddJobScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Job'),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPageIndex,
        onDestinationSelected: changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'All',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}

class AddEditJobScreen extends StatefulWidget {
  final JobApplication? existingApplication;

  const AddEditJobScreen({
    super.key,
    this.existingApplication,
  });

  @override
  State<AddEditJobScreen> createState() => _AddEditJobScreenState();
}

class _AddEditJobScreenState extends State<AddEditJobScreen> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryRangeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedStatus = 'Applied';

  bool hasResume = false;
  bool hasPortfolio = false;
  bool hasCoverLetter = false;
  bool hasApplicationQuestions = false;
  bool hasOther = false;
  bool isSaved = false;

  final List<String> statuses = [
    'Applied',
    'Interviewing',
    'Offer',
    'Rejected',
  ];

  bool get isEditing {
    return widget.existingApplication != null;
  }

  @override
  void initState() {
    super.initState();

    final existingApplication = widget.existingApplication;

    if (existingApplication != null) {
      companyController.text = existingApplication.company;
      roleController.text = existingApplication.role;
      dateController.text = existingApplication.dateApplied;
      locationController.text = existingApplication.location;
      salaryRangeController.text = existingApplication.salaryRange;
      notesController.text = existingApplication.notes;
      selectedStatus = existingApplication.status;
      hasResume = existingApplication.hasResume;
      hasPortfolio = existingApplication.hasPortfolio;
      hasCoverLetter = existingApplication.hasCoverLetter;
      hasApplicationQuestions = existingApplication.hasApplicationQuestions;
      hasOther = existingApplication.hasOther;
      isSaved = existingApplication.isSaved;
    }
  }

  @override
  void dispose() {
    companyController.dispose();
    roleController.dispose();
    dateController.dispose();
    locationController.dispose();
    salaryRangeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void saveApplication() {
    if (companyController.text.isEmpty || roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a company and role.'),
        ),
      );
      return;
    }

    final savedApplication = JobApplication(
      company: companyController.text,
      role: roleController.text,
      status: selectedStatus,
      dateApplied:
      dateController.text.isEmpty ? 'No date added' : dateController.text,
      location: locationController.text.isEmpty
          ? 'No location added'
          : locationController.text,
      salaryRange: salaryRangeController.text.isEmpty
          ? 'No salary added'
          : salaryRangeController.text,
      notes: notesController.text.isEmpty
          ? 'No notes added.'
          : notesController.text,
      hasResume: hasResume,
      hasPortfolio: hasPortfolio,
      hasCoverLetter: hasCoverLetter,
      hasApplicationQuestions: hasApplicationQuestions,
      hasOther: hasOther,
      isSaved: isSaved,
    );

    Navigator.pop(context, savedApplication);
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = isEditing ? 'Edit Application' : 'Add Application';
    String heading = isEditing ? 'Update Job Application' : 'New Job Application';
    String buttonText = isEditing ? 'Save Changes' : 'Save Application';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            heading,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEditing
                ? 'Edit the details for this application.'
                : 'Add the key details for a job you applied to.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: companyController,
            decoration: const InputDecoration(
              labelText: 'Company',
              hintText: 'Example: Apple',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: roleController,
            decoration: const InputDecoration(
              labelText: 'Role',
              hintText: 'Example: Mobile Developer',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedStatus = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: 'Date Applied',
              hintText: 'Example: May 17, 2026',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Example: Remote, New York, NY',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: salaryRangeController,
            decoration: const InputDecoration(
              labelText: 'Salary Range',
              hintText: 'Example: \$90k - \$120k',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Application Materials',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ChecklistCheckbox(
            title: 'Resume',
            value: hasResume,
            onChanged: (value) {
              setState(() {
                hasResume = value;
              });
            },
          ),
          ChecklistCheckbox(
            title: 'Portfolio',
            value: hasPortfolio,
            onChanged: (value) {
              setState(() {
                hasPortfolio = value;
              });
            },
          ),
          ChecklistCheckbox(
            title: 'Cover Letter',
            value: hasCoverLetter,
            onChanged: (value) {
              setState(() {
                hasCoverLetter = value;
              });
            },
          ),
          ChecklistCheckbox(
            title: 'Application Questions',
            value: hasApplicationQuestions,
            onChanged: (value) {
              setState(() {
                hasApplicationQuestions = value;
              });
            },
          ),
          ChecklistCheckbox(
            title: 'Other',
            value: hasOther,
            onChanged: (value) {
              setState(() {
                hasOther = value;
              });
            },
          ),

          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Save to favorites'),
            subtitle: const Text('Show this application on the Saved page'),
            value: isSaved,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                isSaved = value;
              });
            },
          ),

          const SizedBox(height: 16),

          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Example: Follow up with recruiter next week.',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: saveApplication,
            icon: const Icon(Icons.save),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

class ChecklistCheckbox extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ChecklistCheckbox({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      contentPadding: EdgeInsets.zero,
      onChanged: (newValue) {
        onChanged(newValue ?? false);
      },
    );
  }
}

class JobDetailResult {
  final JobApplication? updatedApplication;
  final bool shouldDelete;

  const JobDetailResult({
    this.updatedApplication,
    this.shouldDelete = false,
  });
}

class JobDetailScreen extends StatefulWidget {
  final JobApplication application;

  const JobDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late JobApplication currentApplication;

  @override
  void initState() {
    super.initState();
    currentApplication = widget.application;
  }

  Color getStatusColor(String status) {
    if (status == 'Applied') {
      return Colors.blue;
    } else if (status == 'Interviewing') {
      return Colors.orange;
    } else if (status == 'Offer') {
      return Colors.green;
    } else if (status == 'Rejected') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Future<void> editApplication() async {
    final updatedApplication = await Navigator.push<JobApplication>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditJobScreen(
          existingApplication: currentApplication,
        ),
      ),
    );

    if (updatedApplication != null) {
      setState(() {
        currentApplication = updatedApplication;
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        JobDetailResult(updatedApplication: updatedApplication),
      );
    }
  }

  void toggleSavedOnDetail() {
    setState(() {
      currentApplication = currentApplication.copyWith(
        isSaved: !currentApplication.isSaved,
      );
    });
  }

  Future<void> confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete application?'),
          content: Text(
            'Are you sure you want to delete ${currentApplication.company}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        const JobDetailResult(shouldDelete: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(currentApplication.status);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        Navigator.pop(
          context,
          JobDetailResult(updatedApplication: currentApplication),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Application Details'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: toggleSavedOnDetail,
              icon: Icon(
                currentApplication.isSaved
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: currentApplication.isSaved ? Colors.red : null,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              currentApplication.company,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentApplication.role,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentApplication.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            DetailSection(
              title: 'Company',
              content: currentApplication.company,
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 12),

            DetailSection(
              title: 'Role',
              content: currentApplication.role,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),

            DetailSection(
              title: 'Date Applied',
              content: currentApplication.dateApplied,
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 12),

            DetailSection(
              title: 'Location',
              content: currentApplication.location,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),

            DetailSection(
              title: 'Salary Range',
              content: currentApplication.salaryRange,
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 12),

            MaterialsSection(application: currentApplication),
            const SizedBox(height: 12),

            DetailSection(
              title: 'Notes',
              content: currentApplication.notes,
              icon: Icons.notes_outlined,
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: editApplication,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Application'),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Application'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const DetailSection({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaterialsSection extends StatelessWidget {
  final JobApplication application;

  const MaterialsSection({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    double checklistProgress = application.checklistCompletedCount / 5;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_outlined),
                const SizedBox(width: 12),
                Text(
                  'Application Materials',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('${application.checklistCompletedCount}/5'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: checklistProgress,
            ),
            const SizedBox(height: 12),
            ChecklistItem(
              title: 'Resume',
              isChecked: application.hasResume,
            ),
            ChecklistItem(
              title: 'Portfolio',
              isChecked: application.hasPortfolio,
            ),
            ChecklistItem(
              title: 'Cover Letter',
              isChecked: application.hasCoverLetter,
            ),
            ChecklistItem(
              title: 'Application Questions',
              isChecked: application.hasApplicationQuestions,
            ),
            ChecklistItem(
              title: 'Other',
              isChecked: application.hasOther,
            ),
          ],
        ),
      ),
    );
  }
}

class ChecklistItem extends StatelessWidget {
  final String title;
  final bool isChecked;

  const ChecklistItem({
    super.key,
    required this.title,
    required this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isChecked ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}

class EmptyApplicationMessage extends StatelessWidget {
  const EmptyApplicationMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.work_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No applications yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap Add Job to start tracking your applications.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptySavedMessage extends StatelessWidget {
  const EmptySavedMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.favorite_border,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No saved applications yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the heart on an application to save it here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptySearchMessage extends StatelessWidget {
  final VoidCallback onClear;

  const EmptySearchMessage({
    super.key,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No matching applications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing your search or filter.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Clear search and filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final VoidCallback onSavedTap;

  const JobCard({
    super.key,
    required this.application,
    required this.onTap,
    required this.onSavedTap,
  });

  Color getStatusColor(String status) {
    if (status == 'Applied') {
      return Colors.blue;
    } else if (status == 'Interviewing') {
      return Colors.orange;
    } else if (status == 'Offer') {
      return Colors.green;
    } else if (status == 'Rejected') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(application.status);
    double checklistProgress = application.checklistCompletedCount / 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                application.company,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onSavedTap,
              icon: Icon(
                application.isSaved ? Icons.favorite : Icons.favorite_border,
                color: application.isSaved ? Colors.red : null,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(application.role),
              const SizedBox(height: 6),
              Text('Location: ${application.location}'),
              const SizedBox(height: 6),
              Text('Salary: ${application.salaryRange}'),
              const SizedBox(height: 6),
              Text('Materials Ready: ${application.checklistCompletedCount}/5'),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: checklistProgress,
              ),
              const SizedBox(height: 6),
              Text('Applied: ${application.dateApplied}'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
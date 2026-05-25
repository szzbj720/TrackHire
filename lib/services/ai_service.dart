import '../models/ai_job_analysis.dart';

class AIService {
  Future<AIJobAnalysis> analyzeJobDescription(String jobDescription) async {
    await Future.delayed(const Duration(seconds: 1));

    return AIJobAnalysis(
      company: 'Company Not Detected',
      role: 'Mobile Developer',
      location: 'Not specified',
      salaryRange: 'Not specified',
      summary:
      'This role focuses on mobile development, APIs, and scalable application design.',
      requiredSkills: [
        'Mobile Development',
        'Flutter',
        'REST APIs',
        'Git',
      ],
      preferredSkills: [
        'Firebase',
        'SQLite',
        'CI/CD',
        'Agile',
      ],
      recommendedMaterials: [
        'Resume',
        'GitHub',
        'Portfolio',
      ],
      interviewQuestions: [
        'Describe a mobile app you built.',
        'How do you manage state?',
        'How do you connect APIs?',
      ],
    );
  }

  Future<List<String>> tailorResume(String jobDescription) async {
    await Future.delayed(const Duration(seconds: 1));

    final String lowerText = jobDescription.toLowerCase();

    if (lowerText.contains('ios') || lowerText.contains('swift')) {
      return [
        'Developed iOS application features using Swift, SwiftUI, Firebase, and production-ready mobile development practices.',
        'Resolved Xcode, dependency, deployment target, and third-party SDK integration issues to improve mobile app stability.',
        'Implemented reliable app functionality with clean UI components, structured state management, and reusable Swift-based architecture.',
        'Integrated analytics, crash reporting, authentication, and deep-linking tools to support production monitoring and user engagement.',
        'Tested iOS features through simulator and TestFlight workflows to improve app readiness before release.',
      ];
    }

    if (lowerText.contains('android') || lowerText.contains('kotlin')) {
      return [
        'Built Android-focused mobile features using Kotlin, modern UI patterns, backend API integration, and persistent local data storage.',
        'Implemented job tracking workflows with structured models, reusable screens, and reliable state management for a polished user experience.',
        'Integrated REST API communication, JSON serialization, and database persistence to support full-stack mobile functionality.',
        'Debugged Android emulator, Gradle, SDK, dependency, and backend connectivity issues to maintain a stable development workflow.',
        'Improved app readiness through testing, error handling, and production-style build workflows.',
      ];
    }

    if (lowerText.contains('react native')) {
      return [
        'Developed cross-platform mobile features using React Native, TypeScript, Expo, reusable components, and persistent state management.',
        'Built editable mobile workflows with dynamic routing, CRUD operations, confirmation modals, and offline persistence.',
        'Implemented flexible business logic for user-driven data management, real-time recalculation, and optimized recommendations.',
        'Designed and tested polished mobile UI across iOS Simulator and Android Emulator to ensure consistent cross-platform behavior.',
        'Maintained scalable project structure using TypeScript, modular components, and clean state management practices.',
      ];
    }

    if (lowerText.contains('flutter') || lowerText.contains('dart')) {
      return [
        'Built a full-stack Flutter mobile application using Dart, Provider, Node.js, Express, SQLite, and REST APIs to manage job applications.',
        'Implemented AI-inspired job description analysis features that extract required skills, recommended materials, role summaries, and interview preparation insights.',
        'Designed a scalable MVVM-inspired architecture with dedicated models, views, view models, services, and reusable widgets.',
        'Integrated local persistence, JSON serialization, CSV export, and saved-role management to support practical career tracking workflows.',
        'Automated development quality checks using GitHub Actions CI/CD, Flutter analyze, test automation, Android APK builds, and artifact upload.',
      ];
    }

    return [
      'Built a full-stack mobile application using Flutter, Provider, Node.js, Express, SQLite, and REST APIs to support organized job application tracking.',
      'Implemented AI-inspired job description analysis features that extract required skills, recommended materials, summaries, and interview preparation insights.',
      'Designed a scalable MVVM-inspired architecture with dedicated models, views, view models, services, and reusable widgets.',
      'Integrated local persistence, JSON serialization, CSV export, and saved-role management to support practical career tracking workflows.',
      'Automated development quality checks using GitHub Actions CI/CD, Flutter analyze, test automation, Android APK builds, and artifact upload.',
    ];
  }
}
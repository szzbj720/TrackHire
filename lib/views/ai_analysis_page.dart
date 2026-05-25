import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/job_application.dart';
import '../providers/application_provider.dart';
import '../viewmodels/ai_view_model.dart';
import '../widgets/ai_result_card.dart';

class AIAnalysisPage extends StatefulWidget {
  const AIAnalysisPage({super.key});

  @override
  State<AIAnalysisPage> createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  final TextEditingController _controller = TextEditingController();
  final AIViewModel _vm = AIViewModel();

  @override
  void dispose() {
    _controller.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _analyze() {
    _vm.analyzeJobDescription(_controller.text);
  }

  void _tailor() {
    _vm.tailorResume(_controller.text);
  }

  void _clear() {
    _controller.clear();
    _vm.clearAnalysis();
  }

  void _copyBullet(String bullet) {
    Clipboard.setData(ClipboardData(text: bullet));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied resume bullet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveToTrackHire() async {
    final analysis = _vm.analysis;

    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analyze the job first before saving.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<ApplicationProvider>();

    final now = DateTime.now();

    final notes =
        '''
AI Summary:
${analysis.summary}

Required Skills:
${analysis.requiredSkills.join(', ')}

Preferred Skills:
${analysis.preferredSkills.join(', ')}

Recommended Materials:
${analysis.recommendedMaterials.join(', ')}

Interview Questions:
${analysis.interviewQuestions.map((q) => '- $q').join('\n')}

Tailored Resume Bullets:
${_vm.tailoredResumeBullets.map((b) => '- $b').join('\n')}
''';

    final newApplication = JobApplication(
      company: analysis.company,
      role: analysis.role,
      status: 'Applied',
      dateApplied: '${now.month}/${now.day}/${now.year}',
      location: analysis.location,
      salaryRange: analysis.salaryRange,
      notes: notes,
      hasResume: analysis.recommendedMaterials.contains('Resume'),
      hasPortfolio:
          analysis.recommendedMaterials.contains('Portfolio') ||
          analysis.recommendedMaterials.contains('GitHub'),
      hasCoverLetter: analysis.recommendedMaterials.contains('Cover Letter'),
      hasApplicationQuestions: false,
      hasOther: _vm.tailoredResumeBullets.isNotEmpty,
      isSaved: false,
    );

    await provider.addApplication(newApplication);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${analysis.role} saved to TrackHire.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _clear();
    provider.changePage(0);
  }

  Widget _buildResumeBulletCard(String bullet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                bullet,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'Copy',
              onPressed: () => _copyBullet(bullet),
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Job Analyzer',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste a job description below to analyze the role and generate tailored resume bullets.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _controller,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Job Description',
                        hintText: 'Paste job description here...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _vm.isLoading ? null : _analyze,
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(
                              _vm.isLoading ? 'Analyzing...' : 'Analyze',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _vm.isTailoringResume ? null : _tailor,
                            icon: const Icon(Icons.description),
                            label: Text(
                              _vm.isTailoringResume
                                  ? 'Generating...'
                                  : 'Resume AI',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_controller.text.isNotEmpty ||
                        _vm.analysis != null ||
                        _vm.tailoredResumeBullets.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _clear,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ),

                    if (_vm.isLoading || _vm.isTailoringResume)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    if (_vm.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _vm.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    if (_vm.resumeTailorError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _vm.resumeTailorError,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    if (_vm.analysis != null) ...[
                      const SizedBox(height: 20),
                      AIResultCard(analysis: _vm.analysis!),
                    ],

                    if (_vm.tailoredResumeBullets.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Tailored Resume Bullets',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._vm.tailoredResumeBullets.map(_buildResumeBulletCard),
                    ],
                  ],
                ),
              ),
            ),

            if (_vm.analysis != null || _vm.tailoredResumeBullets.isNotEmpty)
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFBF7),
                    border: Border(top: BorderSide(color: Color(0xFFE8E3F5))),
                  ),
                  child: FilledButton.icon(
                    onPressed: _saveToTrackHire,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save to TrackHire'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

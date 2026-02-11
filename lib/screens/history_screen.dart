import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../utils/constants.dart';
import '../utils/image_from_path.dart';
import 'uploaded_images_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  String _statusLabel(SubmissionStatus status, AppLocalizations l10n) {
    switch (status) {
      case SubmissionStatus.saved:
        return l10n.statusSaved;
      case SubmissionStatus.uploading:
        return l10n.statusUploading;
      case SubmissionStatus.submitted:
        return l10n.uploaded;
      case SubmissionStatus.failed:
        return l10n.failed;
      case SubmissionStatus.diagnosed:
        return l10n.diagnosed;
    }
  }

  Color _statusColor(BuildContext context, SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.saved:
        return Colors.orange;
      case SubmissionStatus.uploading:
        return Theme.of(context).colorScheme.primary;
      case SubmissionStatus.submitted:
        return Colors.blue;
      case SubmissionStatus.failed:
        return Theme.of(context).colorScheme.error;
      case SubmissionStatus.diagnosed:
        return Colors.green;
    }
  }

  Widget _thumb(String path) {
    final borderRadius = BorderRadius.circular(12);

    final img = imageFromPath(path, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: 56,
        height: 56,
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: img,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubmissionProvider>(context);
    final submissions = provider.submissions;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadedImagesScreen()),
              );
            },
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: l10n.uploadedImages,
          ),
          IconButton(
            onPressed:
                provider.isLoading ? null : () => provider.loadSubmissions(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('${l10n.error}: ${provider.error}'))
              : submissions.isEmpty
                  ? Center(child: Text(l10n.noHistoryYet))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: submissions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final s = submissions[index];
                        final statusColor = _statusColor(context, s.status);

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeResults,
                                arguments: s.id,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  _thumb(s.mediaPath),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDateTime(s.createdAt),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _statusLabel(s.status, l10n),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

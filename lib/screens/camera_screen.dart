import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../providers/connectivity_provider.dart';
import '../l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Open camera immediately on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePhoto();
    });
  }

  Future<void> _takePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        await _handleCapturedMedia(photo);
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${l10n.error}: ${kIsWeb ? "Camera not available on web. Please use gallery." : e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _handleCapturedMedia(XFile media) async {
    final submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);
    final connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      // Create submission
      final submission = Submission(
        id: const Uuid().v4(),
        mediaPath: media.path,
        mediaType: MediaType.image,
        createdAt: DateTime.now(),
        status: SubmissionStatus.saved,
      );

      // Save to local storage
      await submissionProvider.addSubmission(submission);

      if (mounted) {
        // Show appropriate message
        final message = connectivityProvider.isOnline
            ? l10n.submittedOnline
            : l10n.savedOffline;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                connectivityProvider.isOnline ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              _isCapturing ? 'Opening camera...' : 'Loading...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

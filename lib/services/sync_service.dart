import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'dart:convert'; // Will be needed for real API implementation
// import 'package:http/http.dart' as http; // Will be needed for real API implementation
import '../models/submission.dart';
import '../models/diagnosis_result.dart';
import '../models/treatment_step.dart';
import 'storage_service.dart';

class SyncService {
  final StorageService _storageService;
  final String baseUrl;

  final _uploadProgressController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get uploadProgressStream =>
      _uploadProgressController.stream;

  bool _isSyncing = false;
  Timer? _syncTimer;

  SyncService({
    required StorageService storageService,
    this.baseUrl = 'https://api.example.com', // Replace with actual API URL
  }) : _storageService = storageService;

  // Start automatic sync service
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (timer) {
      syncPendingSubmissions();
    });
  }

  // Stop automatic sync
  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  // Sync all pending submissions
  Future<void> syncPendingSubmissions() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Sync already in progress, skipping');
      }
      return;
    }

    _isSyncing = true;

    try {
      final pendingSubmissions = await _storageService.getPendingSubmissions();

      if (kDebugMode) {
        print('Syncing ${pendingSubmissions.length} pending submissions');
      }

      for (var submission in pendingSubmissions) {
        await uploadSubmission(submission);
        // Add small delay between uploads to avoid overwhelming server
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sync: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Upload a single submission
  Future<bool> uploadSubmission(Submission submission) async {
    try {
      // Update status to uploading
      submission = submission.copyWith(status: SubmissionStatus.uploading);
      await _storageService.updateSubmission(submission);
      _uploadProgressController.add({
        'id': submission.id,
        'status': SubmissionStatus.uploading,
        'progress': 0.0,
      });

      // Simulate file upload (replace with actual upload logic)
      // In a real implementation, you would:
      // 1. Read the file from submission.mediaPath
      // 2. Create a multipart request
      // 3. Upload to backend API
      // 4. Get response with diagnosis_id

      final response = await _mockUpload(submission);

      if (response['success']) {
        submission = submission.copyWith(
          status: SubmissionStatus.submitted,
          uploadedAt: DateTime.now(),
          diagnosisId: response['diagnosis_id'],
        );
        await _storageService.updateSubmission(submission);

        _uploadProgressController.add({
          'id': submission.id,
          'status': SubmissionStatus.submitted,
          'progress': 1.0,
        });

        if (kDebugMode) {
          print('Upload successful: ${submission.id}');
        }

        return true;
      } else {
        throw Exception(response['error'] ?? 'Upload failed');
      }
    } catch (e) {
      // Mark as failed
      submission = submission.copyWith(status: SubmissionStatus.failed);
      await _storageService.updateSubmission(submission);

      _uploadProgressController.add({
        'id': submission.id,
        'status': SubmissionStatus.failed,
        'progress': 0.0,
      });

      if (kDebugMode) {
        print('Upload failed: ${submission.id}, error: $e');
      }

      return false;
    }
  }

  // Mock upload for development (replace with real API call)
  Future<Map<String, dynamic>> _mockUpload(Submission submission) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // For now, return a mock success response
    return {
      'success': true,
      'diagnosis_id': 'diag_${submission.id}',
      'message': 'Upload successful',
    };

    /* Real implementation would look like:
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/submissions'));
      request.files.add(await http.MultipartFile.fromPath('media', submission.mediaPath));
      request.fields['submission_id'] = submission.id;
      request.fields['media_type'] = submission.mediaType.name;
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        return {'success': false, 'error': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
    */
  }

  // Fetch diagnosis result from backend
  Future<DiagnosisResult?> fetchDiagnosisResult(String submissionId) async {
    try {
      // Mock response for development
      await Future.delayed(const Duration(seconds: 1));

      // Return a mock diagnosis result
      final mockResult = DiagnosisResult(
        id: 'diag_$submissionId',
        submissionId: submissionId,
        diseaseName: 'Late Blight',
        severity: DiseaseSeverity.high,
        confidence: 0.87,
        description:
            'A serious fungal disease affecting tomato and potato plants',
        diagnosedAt: DateTime.now(),
        isUnknown: false,
      );

      await _storageService.saveDiagnosisResult(mockResult);
      return mockResult;

      /* Real implementation:
      final response = await http.get(
        Uri.parse('$baseUrl/api/diagnosis/$submissionId'),
      );
      
      if (response.statusCode == 200) {
        final result = DiagnosisResult.fromJson(json.decode(response.body));
        await _storageService.saveDiagnosisResult(result);
        return result;
      }
      return null;
      */
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching diagnosis: $e');
      }
      return null;
    }
  }

  // Fetch treatment steps from backend
  Future<Treatment?> fetchTreatment(String diseaseId) async {
    try {
      // Mock response for development
      await Future.delayed(const Duration(seconds: 1));

      // Return mock treatment data
      return Treatment(
        diseaseId: diseaseId,
        diseaseName: 'Late Blight',
        organicSteps: [
          TreatmentStep(
            stepNumber: 1,
            title: 'Remove Infected Leaves',
            description:
                'Carefully remove and destroy all infected plant parts to prevent spread',
            type: TreatmentType.organic,
            safetyLevel: SafetyLevel.safe,
            timing: 'Immediately',
            ppeRequired: ['Gloves'],
          ),
          TreatmentStep(
            stepNumber: 2,
            title: 'Apply Copper-Based Fungicide',
            description:
                'Spray copper-based organic fungicide on affected plants',
            type: TreatmentType.organic,
            safetyLevel: SafetyLevel.caution,
            dosage: '50ml per liter of water',
            timing: 'Every 7-10 days',
            ppeRequired: ['Gloves', 'Mask'],
            weatherDependent: true,
          ),
        ],
        chemicalSteps: [
          TreatmentStep(
            stepNumber: 1,
            title: 'Apply Mancozeb Fungicide',
            description: 'Use Mancozeb fungicide as directed',
            type: TreatmentType.chemical,
            safetyLevel: SafetyLevel.warning,
            dosage: '2g per liter of water',
            timing: 'Every 5-7 days',
            safetyWarnings: ['Toxic if ingested', 'Avoid contact with skin'],
            ppeRequired: ['Gloves', 'Mask', 'Protective clothing'],
            weatherDependent: true,
          ),
        ],
        generalAdvice:
            'Ensure good air circulation and avoid overhead watering',
        rainWarning: true,
        weatherCondition: 'Rain expected in 24 hours',
      );

      /* Real implementation:
      final response = await http.get(
        Uri.parse('$baseUrl/api/treatments/$diseaseId'),
      );
      
      if (response.statusCode == 200) {
        return Treatment.fromJson(json.decode(response.body));
      }
      return null;
      */
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching treatment: $e');
      }
      return null;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _uploadProgressController.close();
  }
}

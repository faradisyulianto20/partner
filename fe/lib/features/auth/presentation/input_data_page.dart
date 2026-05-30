import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/features/auth/presentation/widgets/client_profile_form_step.dart';
import 'package:hackathon/features/auth/presentation/widgets/psychologist_profile1_form_step.dart';
import 'package:hackathon/features/auth/presentation/widgets/psychologist_profile_form_step.dart';
import 'package:hackathon/features/auth/presentation/widgets/verification_documents_step.dart';
import 'package:hackathon/features/auth/presentation/widgets/verification_pending_step.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class InputDataPage extends StatefulWidget {
  final bool isPsychologist;

  const InputDataPage({super.key, this.isPsychologist = false});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  static final String _baseUrl = AppConstants.baseUrl;
  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl, autoLoadToken: true);

  int _stepIndex = 0;
  bool _isSaving = false;

  final Map<String, dynamic> _step1Data = {};
  final Map<String, dynamic> _step2Data = {};
  final Map<String, dynamic> _step3Data = {};

  void _onClientSubmit(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);

    try {
      final response = await _apiClient.post('/profile/client', body: data);
      debugPrint('📥 POST /profile/client — status: ${response.statusCode} | data: ${response.data}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan profil.')));
        }
        setState(() => _isSaving = false);
        return;
      }

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('❌ POST /profile/client error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan.')));
      }
      setState(() => _isSaving = false);
    }
  }

  void _onPsychologistStep1(Map<String, dynamic> data) {
    _step1Data.addAll(data);
    setState(() => _stepIndex = 1);
  }

  void _onPsychologistStep2(Map<String, dynamic> data) {
    _step2Data.addAll(data);
    setState(() => _stepIndex = 2);
  }

  void _onPsychologistStep3(Map<String, dynamic> data) async {
    _step3Data.addAll(data);
    setState(() => _isSaving = true);

    try {
      // POST /profile/psychologist
      final profileBody = <String, dynamic>{
        ..._step1Data,
        ..._step2Data,
      };
      profileBody['isAcceptingSessions'] = true;

      final profileResp = await _apiClient.post('/profile/psychologist', body: profileBody);
      debugPrint('📥 POST /profile/psychologist — status: ${profileResp.statusCode}');

      if (profileResp.statusCode != 201 && profileResp.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan profil psikolog.')));
        }
        setState(() => _isSaving = false);
        return;
      }

      // POST /profile/psychologist/documents
      final docBody = <String, dynamic>{
        'ktpUrl': _step3Data['ktpUrl'] ?? '',
        'faceWithKtpUrl': _step3Data['faceWithKtpUrl'] ?? '',
        'strLicenseUrl': _step3Data['strLicenseUrl'] ?? '',
      };

      final docResp = await _apiClient.post('/profile/psychologist/documents', body: docBody);
      debugPrint('📥 POST /profile/psychologist/documents — status: ${docResp.statusCode}');

      if (!mounted) return;
      setState(() => _stepIndex = 3);
    } catch (e) {
      debugPrint('❌ Psychologist save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan.')));
      }
    }
    setState(() => _isSaving = false);
  }

  void _backToLogin() {
    context.go('/login');
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showPending = widget.isPsychologist && _stepIndex == 3;
    final LinearGradient activeHorizontalGradient = widget.isPsychologist
        ? AppGradients.horizontalPsychologist
        : AppGradients.horizontal;

    if (showPending) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: activeHorizontalGradient),
          child: SafeArea(
            child: VerificationPendingStep(onBackToLogin: _backToLogin),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(gradient: activeHorizontalGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 124),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: SingleChildScrollView(
                  child: widget.isPsychologist
                      ? IndexedStack(
                          index: _stepIndex,
                          children: [
                            Psychologist1Profile1FormStep(onNext: _onPsychologistStep1),
                            PsychologistProfileFormStep(onNext: _onPsychologistStep2),
                            VerificationDocumentsStep(onNext: _onPsychologistStep3),
                          ],
                        )
                      : ClientProfileFormStep(
                          onSubmit: _onClientSubmit,
                          isSaving: _isSaving,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

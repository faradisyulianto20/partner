import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  int _stepIndex = 0;

  void _nextStep() {
    if (!widget.isPsychologist) {
      context.go('/home');
      return;
    }

    if (_stepIndex < 3) {
      setState(() => _stepIndex += 1);
      return;
    } else {
      context.go('/login');
    }
  }

  void _backToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool showPending = widget.isPsychologist && _stepIndex == 3;

    if (showPending) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          child: SafeArea(
            child: VerificationPendingStep(onBackToLogin: _backToLogin),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.horizontal),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: SingleChildScrollView(
                  child: widget.isPsychologist
                      ? IndexedStack(
                          index: _stepIndex,
                          children: [
                            Psychologist1Profile1FormStep(onNext: _nextStep),
                            PsychologistProfileFormStep(onNext: _nextStep),
                            VerificationDocumentsStep(onNext: _nextStep),
                          ],
                        )
                      : ClientProfileFormStep(onSubmit: _nextStep),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

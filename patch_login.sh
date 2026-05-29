#!/bin/bash
git checkout fe/lib/features/auth/presentation/login_page.dart
git checkout fe/lib/features/auth/presentation/register_page.dart

# Patch login_page.dart
sed -i '' '/if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {/,/}/s/^/\/\/ /' fe/lib/features/auth/presentation/login_page.dart

# Patch register_page.dart
sed -i '' '/if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {/,/}/s/^/\/\/ /' fe/lib/features/auth/presentation/register_page.dart


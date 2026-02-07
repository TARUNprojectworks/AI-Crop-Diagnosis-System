import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/submission_provider.dart';
import '../widgets/voice_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final submissionProvider = Provider.of<SubmissionProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, AppConstants.routeSettings),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              themeProvider.isDarkMode
                  ? AppConstants.assetBgDark
                  : AppConstants.assetBgLight,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    l10n.welcomeMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.camera_alt,
                        label: l10n.camera,
                        onTap: () => Navigator.pushNamed(
                            context, AppConstants.routeCamera),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.photo_library,
                        label: l10n.gallery,
                        onTap: () => Navigator.pushNamed(
                            context, AppConstants.routeGallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Voice Instructions
                  VoiceButton(
                    text: l10n.voiceInstructionHome,
                    languageCode: languageProvider.currentLocale.languageCode,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.tapToSpeak,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Connectivity & Queue Status Indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      connectivityProvider.isOnline
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: connectivityProvider.isOnline
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectivityProvider.isOnline
                          ? l10n.online
                          : l10n.offline,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    if (!connectivityProvider.isOnline &&
                        submissionProvider.pendingCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${submissionProvider.pendingCount} pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

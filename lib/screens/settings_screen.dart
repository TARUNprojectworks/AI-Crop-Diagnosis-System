import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/font_size_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(l10n.language),
          _buildLanguageSelector(context, languageProvider),
          const Divider(height: 40),
          _buildSectionTitle(l10n.theme),
          SwitchListTile(
            title:
                Text(themeProvider.isDarkMode ? l10n.darkMode : l10n.lightMode),
            secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          const Divider(height: 40),
          _buildSectionTitle(l10n.fontSize),
          _buildFontSizeSelector(context, fontSizeProvider, l10n),
          const Divider(height: 40),
          ListTile(
            title: Text(l10n.about),
            subtitle: Text(l10n.appVersion),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context, LanguageProvider provider) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppConstants.supportedLanguages.entries.map((entry) {
        final isSelected = provider.currentLocale.languageCode == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) provider.setLanguage(entry.key);
          },
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: FontWeight.bold,
          ),
          selectedColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSelector(
      BuildContext context, FontSizeProvider provider, AppLocalizations l10n) {
    return RadioGroup<FontSize>(
      groupValue: provider.currentFontSize,
      onChanged: (value) {
        if (value != null) provider.setFontSize(value);
      },
      child: Column(
        children: [
          RadioListTile<FontSize>(
            title: Text(l10n.small, style: const TextStyle(fontSize: 12)),
            value: FontSize.small,
          ),
          RadioListTile<FontSize>(
            title: Text(l10n.medium, style: const TextStyle(fontSize: 16)),
            value: FontSize.medium,
          ),
          RadioListTile<FontSize>(
            title: Text(l10n.large, style: const TextStyle(fontSize: 20)),
            value: FontSize.large,
          ),
        ],
      ),
    );
  }
}

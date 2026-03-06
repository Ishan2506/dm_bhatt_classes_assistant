import 'package:dm_bhatt_classes_new/cubit/theme/theme_cubit.dart';
import 'package:dm_bhatt_classes_new/screen/admin/update_password_screen.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dm_bhatt_classes_new/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: l10n.settings,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            String themeModeText;
            if (state.themeMode == ThemeMode.light) themeModeText = l10n.themeLight;
            else if (state.themeMode == ThemeMode.dark) themeModeText = l10n.themeDark;
            else themeModeText = l10n.themeSystem;

            String langText;
            if (state.locale.languageCode == 'gu') langText = "ગુજરાતી";
            else if (state.locale.languageCode == 'hi') langText = "हिन्दी";
            else langText = "English";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(l10n.appearance),
                _buildSettingsItem(
                  context,
                  title: l10n.themeMode,
                  value: themeModeText,
                  icon: Icons.dark_mode_outlined,
                  onTap: () => _showThemeModeSelector(context),
                ),
                _buildSettingsItem(
                  context,
                  title: "Theme Style",
                  value: _capitalize(state.selectedStyle.name),
                  icon: Icons.palette_outlined,
                  onTap: () => _showThemeStyleSelector(context),
                ),
                const SizedBox(height: 16),
                _buildSectionHeader(l10n.language),
                _buildSettingsItem(
                  context,
                  title: l10n.language,
                  value: langText,
                  icon: Icons.language,
                  onTap: () => _showLanguageSelector(context),
                ),
                const SizedBox(height: 16),
                _buildSectionHeader("Account"),
                _buildSettingsItem(
                  context,
                  title: l10n.updatePassword,
                  value: "",
                  icon: Icons.lock_reset,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showThemeModeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.themeMode, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildThemeModeOption(context, l10n.themeLight, ThemeMode.light),
              _buildThemeModeOption(context, l10n.themeDark, ThemeMode.dark),
              _buildThemeModeOption(context, l10n.themeSystem, ThemeMode.system),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeOption(BuildContext context, String label, ThemeMode mode) {
    final currentMode = context.read<ThemeCubit>().state.themeMode;
    return RadioListTile<ThemeMode>(
      title: Text(label, style: GoogleFonts.poppins()),
      value: mode,
      groupValue: currentMode,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (val) {
        if (val != null) {
          context.read<ThemeCubit>().changeTheme(val);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showThemeStyleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Theme Style", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...AppThemeStyle.values.map((style) => _buildStyleOption(context, style)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStyleOption(BuildContext context, AppThemeStyle style) {
    final currentStyle = context.read<ThemeCubit>().state.selectedStyle;
    return RadioListTile<AppThemeStyle>(
      title: Text(_capitalize(style.name), style: GoogleFonts.poppins()),
      value: style,
      groupValue: currentStyle,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (val) {
        if (val != null) {
          context.read<ThemeCubit>().changeStyle(val);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.language, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildLangOption(context, "English", const Locale('en')),
              _buildLangOption(context, "हिन्दी", const Locale('hi')),
              _buildLangOption(context, "ગુજરાતી", const Locale('gu')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(BuildContext context, String label, Locale locale) {
    final currentLocale = context.read<ThemeCubit>().state.locale;
    return RadioListTile<Locale>(
      title: Text(label, style: GoogleFonts.poppins()),
      value: locale,
      groupValue: currentLocale,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (val) {
        if (val != null) {
          context.read<ThemeCubit>().changeLocale(val);
          Navigator.pop(context);
        }
      },
    );
  }
}

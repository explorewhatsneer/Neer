import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart';

import '../services/supabase_service.dart';
import '../services/storage_service.dart';

import '../widgets/profile/edit_profile_widgets.dart';
import '../widgets/common/glass_button.dart';

import '../widgets/common/animated_press.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _service = SupabaseService();
  final StorageService _storageService = StorageService();
  late String _uid;

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  bool _isLoading = false;
  String? _currentPhotoUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _uid = _service.client.auth.currentUser?.id ?? "";

    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();

    if (_uid.isNotEmpty) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final result = await _service.getUser(_uid);
    if (result.isSuccess) {
      final user = result.data;
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          _usernameController.text = user.username;
          _bioController.text = user.bio;
          _currentPhotoUrl = user.profileImage;
          _isLoading = false;
        });
      }
    } else {
      debugPrint("Kullanıcı verisi çekilemedi: ${result.error.message}");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _showImageSourcePicker() {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? NeerColors.darkSurface.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.90),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.60),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppStrings.changePhoto, style: NeerTypography.h3),
                    const SizedBox(height: 20),
                    _SheetOption(
                      icon: Icons.photo_library_rounded,
                      label: AppStrings.pickFromGallery,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(height: 10),
                    _SheetOption(
                      icon: Icons.camera_alt_rounded,
                      label: AppStrings.takePhoto,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      AppSnackBar.error(context, AppStrings.emptyFieldsError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalPhotoUrl = _currentPhotoUrl ?? "";

      if (_selectedImage != null) {
        String? uploadedUrl = await _storageService.uploadProfileImage(_selectedImage!, _uid);
        if (uploadedUrl != null) {
          finalPhotoUrl = uploadedUrl;
        }
      }

      final updateResult = await _service.updateProfile(_uid, {
        'full_name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar_url': finalPhotoUrl,
      });

      if (updateResult.isFailure) {
        if (mounted) {
          AppSnackBar.error(context, "${AppStrings.error}: ${updateResult.error.message}");
        }
      } else if (mounted) {
        AppSnackBar.success(context, AppStrings.profileUpdated);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, "${AppStrings.error}: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(
      body: _isLoading && _nameController.text.isEmpty
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header with avatar
                SliverAppBar(
                  expandedHeight: 235.0,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Center(
                    child: GlassButton.appBar(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GlassButton.appBar(
                          icon: Icons.check_rounded,
                          onTap: _isLoading ? () {} : _saveProfile,
                        ),
                      ),
                    ),
                  ],
                  title: Text(
                    AppStrings.editProfileTitle,
                    style: NeerTypography.h3.copyWith(
                      color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.87),
                    ),
                  ),
                  centerTitle: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: EditAvatarArea(
                      selectedImage: _selectedImage,
                      currentUrl: _currentPhotoUrl,
                      onEditTap: _showImageSourcePicker,
                    ),
                  ),
                ),

                // Form
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal info section
                        EditSectionTitle(
                          title: AppStrings.personalInfo,
                          icon: Icons.person_outline_rounded,
                        ),
                        NeerTextField(
                          label: AppStrings.fullName,
                          icon: Icons.badge_outlined,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 14),
                        NeerTextField(
                          label: AppStrings.username,
                          icon: Icons.alternate_email_rounded,
                          controller: _usernameController,
                        ),

                        const SizedBox(height: 28),

                        // Bio section
                        EditSectionTitle(
                          title: AppStrings.about,
                          icon: Icons.edit_note_rounded,
                        ),
                        NeerTextField(
                          label: AppStrings.bio,
                          icon: Icons.short_text_rounded,
                          controller: _bioController,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 36),

                        // Save button
                        AnimatedPress(
                          onTap: _isLoading ? () {} : _saveProfile,
                          useHeavyHaptic: true,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  NeerColors.primary,
                                  NeerColors.primaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: NeerColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      AppStrings.saveChanges,
                                      style: NeerTypography.button.copyWith(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SHEET OPTION — glass bottom sheet item
// ═══════════════════════════════════════════════════════

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedPress(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:image_picker/image_picker.dart';

// CORE & MODELLER
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart';

// SERVİSLER
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

// WIDGETLAR
import '../widgets/profile/edit_profile_widgets.dart'; 

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

  // --- 1. VERİLERİ ÇEK ---
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

  // --- 2. RESİM SEÇME ---
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImageSourcePicker() {
    HapticFeedback.lightImpact(); 
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library_rounded, color: theme.primaryColor),
                  title: Text(
                    AppStrings.pickFromGallery, 
                    style: NeerTypography.bodyLarge
                  ),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: theme.primaryColor),
                  title: Text(
                    AppStrings.takePhoto, 
                    style: NeerTypography.bodyLarge
                  ),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 3. KAYDETME ---
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

      // Yeni resim varsa yükle (Storage Service zaten Supabase uyumlu)
      if (_selectedImage != null) {
        String? uploadedUrl = await _storageService.uploadProfileImage(_selectedImage!, _uid);
        if (uploadedUrl != null) {
          finalPhotoUrl = uploadedUrl;
        }
      }

      // Veritabanını güncelle
      final updateResult = await _service.updateProfile(_uid, {
        'full_name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar_url': finalPhotoUrl,
      });

      if (updateResult.isFailure) {
        if (mounted) {
          AppSnackBar.error(context, "Hata: ${updateResult.error.message}");
        }
      } else if (mounted) {
        AppSnackBar.success(context, AppStrings.profileUpdated);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, "Hata: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: _isLoading && _nameController.text.isEmpty
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. HEADER (Resim ve Blur)
                SliverAppBar(
                  expandedHeight: 280.0,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  
                  // Geri Butonu (Yuvarlak)
                  leading: Center(
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3), 
                        shape: BoxShape.circle
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  
                  title: Text(
                    AppStrings.editProfileTitle,
                    style: NeerTypography.h3.copyWith(
                      color: theme.textTheme.bodyLarge?.color,
                    )
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

                // 2. FORM ALANI
                SliverToBoxAdapter(
                  child: Container(
                    transform: Matrix4.translationValues(0, -20, 0), // Hafif yukarı taşıma
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditSectionTitle(title: AppStrings.personalInfo),
                          const SizedBox(height: 20),
                          
                          NeerTextField(
                            label: AppStrings.fullName, 
                            icon: Icons.person_outline_rounded, 
                            controller: _nameController,
                          ),
                          const SizedBox(height: 20),
                          
                          NeerTextField(
                            label: AppStrings.username, 
                            icon: Icons.alternate_email_rounded, 
                            controller: _usernameController,
                          ),
                          const SizedBox(height: 30),
                          
                          EditSectionTitle(title: AppStrings.about),
                          const SizedBox(height: 20),
                          
                          NeerTextField(
                            label: AppStrings.bio, 
                            icon: Icons.edit_note_rounded, 
                            controller: _bioController, 
                            maxLines: 4,
                          ),

                          const SizedBox(height: 50),

                          // KAYDET BUTONU
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(borderRadius: NeerRadius.cardRadius),
                              ),
                              onPressed: _isLoading ? null : _saveProfile,
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : Text(
                                      AppStrings.saveChanges, 
                                      style: NeerTypography.button.copyWith(fontSize: 18)
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
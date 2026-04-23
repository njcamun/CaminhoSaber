// lib/ui/screens/dependentes_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DependentesScreen extends StatelessWidget {
  const DependentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerir Perfis'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                  itemCount: profileProvider.allProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = profileProvider.allProfiles[index];
                    return _buildProfileListItem(context, profile);
                  },
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditDependentDialog(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text('Novo Perfil'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildProfileListItem(BuildContext context, Profile profile) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final bool isActive = profile.uid == profileProvider.activeProfile?.uid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        color: isActive ? AppColors.primary.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? AppColors.primary : Colors.blueGrey.withValues(alpha: 0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: ClipOval(
                child: _buildAvatarDisplay(profile.avatarAssetPath),
              ),
            ),
          ),
          title: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              profile.nome.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isActive ? AppColors.primary : Colors.black87),
            ),
          ),
          subtitle: Text(
            profile.isMainProfile ? 'Perfil Principal' : 'Perfil Dependente',
            style: TextStyle(color: Colors.blueGrey.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'edit') {
                _showAddOrEditDependentDialog(context, profileToEdit: profile);
              } else if (value == 'delete') {
                _showConfirmRemoveDialog(context, profile);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar'), contentPadding: EdgeInsets.zero)),
              if (!profile.isMainProfile)
                PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: Text('Remover', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)), contentPadding: EdgeInsets.zero)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarDisplay(String path) {
    if (path.startsWith('assets/') || path.startsWith('http')) {
      return SafeAssetImage(path: path, fit: BoxFit.cover, width: 56, height: 56);
    } else {
      if (kIsWeb) return const Icon(Icons.person);
      return Image.file(File(path), fit: BoxFit.cover, width: 56, height: 56);
    }
  }

  void _showAddOrEditDependentDialog(BuildContext context, {Profile? profileToEdit}) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final isEditing = profileToEdit != null;
    final nameController = TextEditingController(text: isEditing ? profileToEdit.nome : '');
    final ImagePicker picker = ImagePicker();
    final size = MediaQuery.of(context).size;

    final List<String> assetAvatars = [
      'assets/images/foto_p.png',
      'assets/avatars/avatar1.png',
      'assets/avatars/avatar2.png',
      'assets/avatars/avatar3.png',
      'assets/avatars/avatar4.png',
      'assets/avatars/mergulho.png',
    ];
    
    String selectedAvatar = isEditing ? profileToEdit.avatarAssetPath : assetAvatars.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_attributes_rounded : Icons.person_add_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(child: Text((isEditing ? 'Editar Perfil' : 'Novo Perfil').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                ],
              ),
              content: Container(
                width: size.width * 0.85 > 500 ? 500 : size.width * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Nome do Explorador'.toUpperCase(),
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                          prefixIcon: const Icon(Icons.face_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Personaliza o teu Avatar:'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      
                      if (!kIsWeb)
                      InkWell(
                        onTap: () async {
                          final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                          if (photo != null) {
                            setState(() => selectedAvatar = photo.path);
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: !selectedAvatar.startsWith('assets/') ? AppColors.primary : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: !selectedAvatar.startsWith('assets/') 
                                ? ClipOval(child: Image.file(File(selectedAvatar), fit: BoxFit.cover))
                                : const Icon(Icons.camera_alt_rounded, size: 40, color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text('Tirar Foto'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(thickness: 1)),
                      Text('Ou escolhe um boneco:'.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: assetAvatars.map((avatar) {
                          final bool isSel = selectedAvatar == avatar;
                          return GestureDetector(
                            onTap: () => setState(() => selectedAvatar = avatar),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSel ? AppColors.primary : Colors.transparent, width: 3),
                              ),
                              child: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: ClipOval(child: SafeAssetImage(path: avatar, fit: BoxFit.cover)),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      if (isEditing) {
                        profileProvider.editDependent(profileUid: profileToEdit.uid, newName: nameController.text.trim(), newAvatarPath: selectedAvatar);
                      } else {
                        profileProvider.addDependent(nome: nameController.text.trim(), avatarAssetPath: selectedAvatar);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Guardar'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmRemoveDialog(BuildContext context, Profile profile) {
    if (profile.isMainProfile) return;

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final progressoService = Provider.of<ProgressoService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 28),
              const SizedBox(width: 10),
              Text('Remover Perfil?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Text('Tem a certeza que quer remover o perfil de "${profile.nome}"? Todo o seu progresso será apagado permanentemente.'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              onPressed: () async {
                await progressoService.removeProgressForProfile(profile.uid);
                await profileProvider.removeDependent(profile.uid);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text('Remover'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

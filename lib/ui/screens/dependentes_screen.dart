// lib/ui/screens/dependentes_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';

class DependentesScreen extends StatelessWidget {
  const DependentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Perfis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditDependentDialog(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
        color: isActive ? Colors.blue.shade50.withOpacity(0.95) : Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade50,
              child: ClipOval(
                child: _buildAvatarDisplay(profile.avatarAssetPath),
              ),
            ),
          ),
          title: Text(
            profile.nome,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isActive ? Colors.blue.shade900 : Colors.black87),
          ),
          subtitle: Text(
            profile.isMainProfile ? 'Perfil Principal (Nelson)' : 'Perfil Dependente',
            style: TextStyle(color: Colors.grey.shade600),
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
              if (!profile.isMainProfile) // Apenas permite remover se NÃO for o principal
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Remover', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarDisplay(String path) {
    if (path.startsWith('assets/')) {
      return SafeAssetImage(path: path, fit: BoxFit.cover, width: 56, height: 56);
    } else {
      return Image.file(File(path), fit: BoxFit.cover, width: 56, height: 56);
    }
  }

  void _showAddOrEditDependentDialog(BuildContext context, {Profile? profileToEdit}) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final isEditing = profileToEdit != null;
    final nameController = TextEditingController(text: isEditing ? profileToEdit.nome : '');
    final ImagePicker picker = ImagePicker();

    final List<String> assetAvatars = [
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
                  Icon(isEditing ? Icons.edit_attributes_rounded : Icons.person_add_rounded, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(isEditing ? 'Editar Perfil' : 'Novo Perfil', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Explorador',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.face_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Personaliza o teu Avatar:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 16),
                    
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
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: !selectedAvatar.startsWith('assets/') ? Colors.blue : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: !selectedAvatar.startsWith('assets/') 
                              ? ClipOval(child: Image.file(File(selectedAvatar), fit: BoxFit.cover))
                              : const Icon(Icons.camera_alt_rounded, size: 40, color: Colors.blue),
                          ),
                          const SizedBox(height: 4),
                          const Text('Tirar Foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(thickness: 1)),
                    const Text('Ou escolhe um boneco:', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                              border: Border.all(color: isSel ? Colors.blue : Colors.transparent, width: 3),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: ClipOval(child: SafeAssetImage(path: avatar, fit: BoxFit.cover)),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                  child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmRemoveDialog(BuildContext context, Profile profile) {
    if (profile.isMainProfile) return; // Segurança extra

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final progressoService = Provider.of<ProgressoService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text('Remover Perfil?'),
          content: Text('Tem a certeza que quer remover o perfil de "${profile.nome}"? Todo o seu progresso será apagado permanentemente.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                await progressoService.removeProgressForProfile(profile.uid);
                await profileProvider.removeDependent(profile.uid);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }
}

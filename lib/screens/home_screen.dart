import 'package:flutter/material.dart';
import '../services/mimesita_repository.dart';
import '../services/location_service.dart';
import '../services/mock_data.dart';
import '../constants/app_colors.dart';
import '../models/review.dart';
import 'map_screen.dart';
import 'explore_list_screen.dart';
import 'seller_submit_screen.dart';
import 'admin_moderation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MimesitaRepository _repository = MimesitaRepository();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Attempt GPS detection in background
    LocationService.determinePosition().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showSupabaseConfigDialog() {
    final urlCtrl = TextEditingController();
    final keyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Conexión con Supabase'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa las credenciales de tu proyecto Supabase para sincronizar en tiempo real:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(
                labelText: 'Project URL',
                hintText: 'https://xxx.supabase.co',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyCtrl,
              decoration: InputDecoration(
                labelText: 'Anon Public Key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _repository.isSupabaseConfigured
                  ? '🟢 Supabase actualmente conectado.'
                  : '🟡 Funcionando con datos precargados de Mesa de los Santos.',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (urlCtrl.text.isNotEmpty && keyCtrl.text.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                final success = await _repository.initializeSupabase(
                  url: urlCtrl.text.trim(),
                  anonKey: keyCtrl.text.trim(),
                );
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '¡Conectado exitosamente a Supabase!'
                          : 'No se pudo conectar a Supabase. Verifica la URL.',
                    ),
                    backgroundColor: success ? AppColors.primary : AppColors.rejected,
                  ),
                );
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  void _showRoleSelectorDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Rol (Modo Prototipo)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Prueba la experiencia de la app desde los diferentes tipos de cuenta:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Text('🎒'),
              ),
              title: const Text('Viajero / Usuario'),
              subtitle: const Text('Explora el mapa, filtra por categorías y califica lugares'),
              trailing: _repository.currentRole == UserRole.traveler
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                _repository.setRole(UserRole.traveler);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Text('🏪'),
              ),
              title: const Text('Comerciante / Vendedor'),
              subtitle: const Text('Registra negocios y publica eventos de fin de semana'),
              trailing: _repository.currentRole == UserRole.seller
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                _repository.setRole(UserRole.seller);
                Navigator.pop(ctx);
                setState(() => _currentIndex = 2); // Switch to publish
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE7F6),
                child: Text('🛡️'),
              ),
              title: const Text('Administrador'),
              subtitle: const Text('Revisa el buzón de seguridad y aprueba o rechaza contenido'),
              trailing: _repository.currentRole == UserRole.admin
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                _repository.setRole(UserRole.admin);
                Navigator.pop(ctx);
                setState(() => _currentIndex = 3); // Switch to moderation
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final pendingCount = _repository.totalPendingCount;

        final screens = [
          MapScreen(repository: _repository),
          ExploreListScreen(repository: _repository),
          SellerSubmitScreen(repository: _repository),
          AdminModerationScreen(repository: _repository),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🍽️', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mimesita',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 11, color: AppColors.accent),
                        const SizedBox(width: 2),
                        Text(
                          MockData.defaultLocationName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Supabase Config Button
              IconButton(
                icon: Icon(
                  Icons.cloud_sync,
                  color: _repository.isSupabaseConfigured ? AppColors.primary : Colors.grey.shade600,
                ),
                tooltip: 'Configurar Supabase',
                onPressed: _showSupabaseConfigDialog,
              ),

              // Role Switcher Button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  icon: Text(
                    _repository.currentRole == UserRole.traveler
                        ? '🎒'
                        : (_repository.currentRole == UserRole.seller ? '🏪' : '🛡️'),
                  ),
                  label: Text(
                    _repository.currentRole == UserRole.traveler
                        ? 'Viajero'
                        : (_repository.currentRole == UserRole.seller ? 'Comercio' : 'Admin'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: _showRoleSelectorDialog,
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map, color: AppColors.primary),
                label: 'Mapa',
              ),
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore, color: AppColors.primary),
                label: 'Explorar',
              ),
              const NavigationDestination(
                icon: Icon(Icons.add_business_outlined),
                selectedIcon: Icon(Icons.add_business, color: AppColors.primary),
                label: 'Publicar',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.shield_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.shield, color: AppColors.primary),
                ),
                label: 'Moderación',
              ),
            ],
          ),
        );
      },
    );
  }
}

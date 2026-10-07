import 'package:flutter/material.dart';
import '../models/place.dart';
import '../models/event.dart';
import '../constants/app_colors.dart';
import '../constants/categories.dart';
import '../services/mimesita_repository.dart';

class AdminModerationScreen extends StatefulWidget {
  final MimesitaRepository repository;

  const AdminModerationScreen({super.key, required this.repository});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  void _promptRejectDialog({
    required String title,
    required Function(String reason) onReject,
  }) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rechazar: $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indica el motivo del rechazo para notificar al comerciante (ej. contenido inapropiado, spam, imágenes violentas o datos incorrectos):',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Motivo del rechazo...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejected,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final reason = reasonCtrl.text.trim().isNotEmpty
                  ? reasonCtrl.text.trim()
                  : 'Incumple las políticas de seguridad de la comunidad.';
              onReject(reason);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Publicación rechazada.'),
                  backgroundColor: AppColors.rejected,
                ),
              );
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final pendingPlaces = widget.repository.pendingPlaces;
        final pendingEvents = widget.repository.pendingEvents;
        final totalCount = pendingPlaces.length + pendingEvents.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.shield, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Panel de Moderación'),
                const SizedBox(width: 8),
                if (totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalCount',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            backgroundColor: const Color(0xFF1C2833), // Slate dark for admin
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: totalCount == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Todo al día!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No hay solicitudes pendientes de aprobación.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Revisa que las fotos, títulos y descripciones sean aptos para todo público y representen lugares reales.',
                              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Places
                    if (pendingPlaces.isNotEmpty) ...[
                      const Text(
                        'Lugares / Negocios Pendientes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...pendingPlaces.map((p) => _buildPlaceItem(p)),
                      const SizedBox(height: 20),
                    ],

                    // Events
                    if (pendingEvents.isNotEmpty) ...[
                      const Text(
                        'Eventos Pendientes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...pendingEvents.map((e) => _buildEventItem(e)),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPlaceItem(Place place) {
    final catInfo = CategoryHelper.getInfo(place.category);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(catInfo.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  catInfo.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: catInfo.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PENDIENTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pending,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              place.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              place.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${place.address} (Mesa de los Santos)',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (place.whatsapp != null)
              Text(
                '💬 WhatsApp: ${place.whatsapp}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rejected,
                    side: const BorderSide(color: AppColors.rejected),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Rechazar'),
                  onPressed: () => _promptRejectDialog(
                    title: place.name,
                    onReject: (reason) => widget.repository.rejectPlace(place.id, reason),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.approved,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Aprobar'),
                  onPressed: () {
                    widget.repository.approvePlace(place.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${place.name}" aprobado y publicado en el mapa.'),
                        backgroundColor: AppColors.approved,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(WeekendEvent event) {
    final catInfo = CategoryHelper.getInfo(event.category);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(catInfo.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  catInfo.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: catInfo.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'EVENTO PENDIENTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pending,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              event.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '🎟️ Precio: ${event.ticketPrice}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rejected,
                    side: const BorderSide(color: AppColors.rejected),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Rechazar'),
                  onPressed: () => _promptRejectDialog(
                    title: event.title,
                    onReject: (reason) => widget.repository.rejectEvent(event.id, reason),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.approved,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Aprobar'),
                  onPressed: () {
                    widget.repository.approveEvent(event.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${event.title}" aprobado y publicado en el feed.'),
                        backgroundColor: AppColors.approved,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

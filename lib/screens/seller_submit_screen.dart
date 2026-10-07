import 'package:flutter/material.dart';
import '../models/place.dart';
import '../models/event.dart';
import '../constants/app_colors.dart';
import '../constants/categories.dart';
import '../services/mimesita_repository.dart';
import '../services/mock_data.dart';

class SellerSubmitScreen extends StatefulWidget {
  final MimesitaRepository repository;

  const SellerSubmitScreen({super.key, required this.repository});

  @override
  State<SellerSubmitScreen> createState() => _SellerSubmitScreenState();
}

class _SellerSubmitScreenState extends State<SellerSubmitScreen> {
  int _submitType = 0; // 0: Place / Business, 1: Weekend Event

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController(text: 'Mesa de los Santos, Santander');
  final _whatsappCtrl = TextEditingController(text: '+57 3');
  final _photoUrlCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '\$\$');

  PlaceCategory _selectedCategory = PlaceCategory.food;
  double _lat = MockData.defaultLat;
  double _lng = MockData.defaultLng;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _whatsappCtrl.dispose();
    _photoUrlCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (_submitType == 0) {
        // Place
        final newPlace = Place(
          id: 'place-${DateTime.now().millisecondsSinceEpoch}',
          sellerId: 'current-seller',
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory,
          latitude: _lat,
          longitude: _lng,
          address: _addressCtrl.text.trim(),
          town: 'Mesa de los Santos',
          whatsapp: _whatsappCtrl.text.trim().isNotEmpty ? _whatsappCtrl.text.trim() : null,
          priceLevel: _priceCtrl.text.trim(),
          photos: _photoUrlCtrl.text.trim().isNotEmpty
              ? [_photoUrlCtrl.text.trim()]
              : [
                  'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
                ],
          status: ItemStatus.pending,
        );

        await widget.repository.submitNewPlace(newPlace);
      } else {
        // Event
        final now = DateTime.now();
        final saturday = now.add(Duration(days: (6 - now.weekday) % 7));

        final newEvent = WeekendEvent(
          id: 'event-${DateTime.now().millisecondsSinceEpoch}',
          sellerId: 'current-seller',
          title: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory,
          latitude: _lat,
          longitude: _lng,
          startTime: DateTime(saturday.year, saturday.month, saturday.day, 15, 0),
          endTime: DateTime(saturday.year, saturday.month, saturday.day, 22, 0),
          ticketPrice: _priceCtrl.text.trim().isNotEmpty ? _priceCtrl.text.trim() : 'Entrada Libre',
          whatsapp: _whatsappCtrl.text.trim(),
          bannerUrl: _photoUrlCtrl.text.trim().isNotEmpty
              ? _photoUrlCtrl.text.trim()
              : 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80',
          status: ItemStatus.pending,
        );

        await widget.repository.submitNewEvent(newEvent);
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.accent, size: 28),
            SizedBox(width: 8),
            Text('¡Enviado a Moderación!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu ${_submitType == 0 ? 'lugar' : 'evento'} ha sido recibido exitosamente.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para proteger a la comunidad contra contenido inadecuado, violencia o spam, nuestro equipo revisará la información antes de publicarla en el mapa.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estado actual: Pendiente de aprobación',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _nameCtrl.clear();
    _descCtrl.clear();
    _photoUrlCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = CategoryHelper.allCategories
        .where((c) => c.category != PlaceCategory.all)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portal para Negocios y Eventos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storefront, color: AppColors.primary, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Tienes un negocio o evento en La Mesa?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Publica gratis para que los viajeros de fin de semana te encuentren fácilmente.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Type Switcher (Lugar vs Evento)
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.place),
                    label: Text('Negocio o Lugar'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.event),
                    label: Text('Evento Fin de Semana'),
                  ),
                ],
                selected: {_submitType},
                onSelectionChanged: (set) {
                  setState(() {
                    _submitType = set.first;
                    _priceCtrl.text = _submitType == 0 ? '\$\$' : 'Entrada Libre';
                  });
                },
              ),

              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: _submitType == 0 ? 'Nombre del Negocio o Lugar *' : 'Título del Evento *',
                  hintText: _submitType == 0
                      ? 'Ej. Café Mirador Las Nubes'
                      : 'Ej. Noche de Fogata & Cerveza Artesanal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(_submitType == 0 ? Icons.store : Icons.title),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
              ),

              const SizedBox(height: 14),

              // Category Selector
              DropdownButtonFormField<PlaceCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: filteredCategories.map((c) {
                  return DropdownMenuItem(
                    value: c.category,
                    child: Row(
                      children: [
                        Text(c.emoji),
                        const SizedBox(width: 8),
                        Text(c.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (cat) {
                  if (cat != null) setState(() => _selectedCategory = cat);
                },
              ),

              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción detallada *',
                  hintText: 'Cuéntale a los viajeros qué hace especial este lugar, especialidades, etc.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) =>
                    val == null || val.trim().length < 10 ? 'Describe en al menos 10 caracteres' : null,
              ),

              const SizedBox(height: 14),

              // Address & Price in Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _addressCtrl,
                      decoration: InputDecoration(
                        labelText: 'Dirección o Vereda',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: InputDecoration(
                        labelText: _submitType == 0 ? 'Precio (\$, \$\$)' : 'Costo Boleta',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // WhatsApp
              TextFormField(
                controller: _whatsappCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número de WhatsApp (con indicativo)',
                  hintText: '+57 312 345 6789',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.chat_bubble, color: Color(0xFF25D366)),
                ),
              ),

              const SizedBox(height: 14),

              // Photo URL
              TextFormField(
                controller: _photoUrlCtrl,
                decoration: InputDecoration(
                  labelText: 'URL de Foto / Flyer (Opcional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.photo_camera),
                ),
              ),

              const SizedBox(height: 14),

              // Location Coordinates Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicación en el Mapa',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Lat: ${_lat.toStringAsFixed(4)}, Lng: ${_lng.toStringAsFixed(4)} (Mesa de los Santos)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          // Allow resetting to default or fine-tuning
                          _lat = MockData.defaultLat;
                          _lng = MockData.defaultLng;
                        });
                      },
                      child: const Text('Centrar'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSubmitting ? 'Enviando...' : 'Enviar para Aprobación',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  '🔒 El contenido pasa por filtro de seguridad y moderación antes de publicarse.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

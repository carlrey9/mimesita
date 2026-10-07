import '../constants/categories.dart';
import '../models/place.dart';
import '../models/event.dart';
import '../models/review.dart';

class MockData {
  // Center of Mesa de los Santos, Santander, Colombia
  static const double defaultLat = 6.8145;
  static const double defaultLng = -73.1190;
  static const String defaultLocationName = "Mesa de los Santos, Santander";

  static List<Place> getInitialPlaces() {
    return [
      Place(
        id: 'place-1',
        sellerId: 'seller-1',
        name: 'Mercado Campesino de la Mesa de los Santos',
        description:
            'El corazón gastronómico y cultural del fin de semana. Prueba las auténticas arepas de chócolo recién asadas con queso campesino, obleas con arequipe y mora artesanal, mute santandereano, artesanías de fique y frutas frescas de la región.',
        category: PlaceCategory.food,
        latitude: 6.8145,
        longitude: -73.1190,
        address: 'Vía Principal km 14, Los Santos',
        town: 'Mesa de los Santos',
        phone: '+57 315 220 8900',
        whatsapp: '+573152208900',
        instagram: '@mercadocampesinomesa',
        priceLevel: '\$',
        photos: [
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: true,
        isImperdible: true,
        status: ItemStatus.approved,
        ratingAvg: 4.8,
        ratingCount: 342,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Place(
        id: 'place-2',
        sellerId: 'seller-2',
        name: 'Hacienda El Roble (Café Mesa de los Santos)',
        description:
            'Hacienda cafetera histórica de café orgánico bajo sombra de árboles centenarios. Uno de los cafés más codiciados del mundo. Ofrece tour guiado del café, cata sensorial barista y senderismo de avistamiento de aves exóticas.',
        category: PlaceCategory.coffee,
        latitude: 6.8580,
        longitude: -73.1320,
        address: 'Vereda El Roble, Mesa de los Santos',
        town: 'Mesa de los Santos',
        phone: '+57 317 640 1234',
        whatsapp: '+573176401234',
        instagram: '@cafemesadelossantos',
        priceLevel: '\$\$\$',
        photos: [
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: true,
        isImperdible: true,
        status: ItemStatus.approved,
        ratingAvg: 4.9,
        ratingCount: 215,
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      Place(
        id: 'place-3',
        sellerId: 'seller-3',
        name: 'Parque de Escalada en Roca La Mojarra',
        description:
            'Mecca internacional de la escalada deportiva en arenisca roja, con más de 250 vías abiertas y una vista imponente sobre el Cañón del Chicamocha. Cursos para principiantes, alquiler de equipo profesional y zona de camping.',
        category: PlaceCategory.extremeSports,
        latitude: 6.7950,
        longitude: -73.0890,
        address: 'Sector Refugio La Roca, La Mojarra',
        town: 'Mesa de los Santos',
        phone: '+57 316 789 4433',
        whatsapp: '+573167894433',
        priceLevel: '\$\$',
        photos: [
          'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: true,
        isImperdible: true,
        status: ItemStatus.approved,
        ratingAvg: 5.0,
        ratingCount: 184,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Place(
        id: 'place-4',
        sellerId: 'seller-4',
        name: 'Estación Teleférico Panachi - Estación Mesa',
        description:
            'Una de las estaciones de teleférico más largas del planeta (6.3 km cruzando el abismo del Cañón del Chicamocha). Punto panorámico obligado para tomar fotos impresionantes del cañón y disfrutar de la brisa de la tarde.',
        category: PlaceCategory.photoSpot,
        latitude: 6.7915,
        longitude: -73.0760,
        address: 'Borde del Cañón, Entrada Teleférico',
        town: 'Mesa de los Santos',
        phone: '+57 607 639 4444',
        priceLevel: '\$\$',
        photos: [
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: false,
        isImperdible: true,
        status: ItemStatus.approved,
        ratingAvg: 4.9,
        ratingCount: 420,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      Place(
        id: 'place-5',
        sellerId: 'seller-5',
        name: 'Parapente Vuelo Térmico Chicamocha',
        description:
            'Experimenta la adrenalina pura volando como un cóndor sobre el cañón con instructores certificados por la FAI. Vuelo en tándem de 15 a 20 minutos con fotos y video en Go-Pro incluidos.',
        category: PlaceCategory.extremeSports,
        latitude: 6.7880,
        longitude: -73.0810,
        address: 'Pista de Despegue El Picacho',
        town: 'Mesa de los Santos',
        whatsapp: '+573105559876',
        priceLevel: '\$\$\$',
        photos: [
          'https://images.unsplash.com/photo-1508672019048-805c876b67e2?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: true,
        isImperdible: false,
        status: ItemStatus.approved,
        ratingAvg: 4.9,
        ratingCount: 96,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Place(
        id: 'place-6',
        sellerId: 'seller-6',
        name: 'Mirador Cascada El Salto del Duende',
        description:
            'Majestuosa caída de agua que se precipita al vacío del cañón. Cuenta con un puente mirador ideal para sesiones de fotos, senderos ecológicos y leyendas tradicionales de los indígenas Guane.',
        category: PlaceCategory.photoSpot,
        latitude: 6.8110,
        longitude: -73.1250,
        address: 'Sector El Salto',
        town: 'Mesa de los Santos',
        priceLevel: 'Gratis',
        photos: [
          'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: false,
        isImperdible: true,
        status: ItemStatus.approved,
        ratingAvg: 4.6,
        ratingCount: 112,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Place(
        id: 'place-7',
        sellerId: 'seller-7',
        name: 'Fogón Santandereano & Asador Las Brisas',
        description:
            'Especialidad en cabrito asado, carne oreada, sopa de mute tradicional en leña y arepa santandereana. Ambiente campestre con música de cuerda en vivo los domingos.',
        category: PlaceCategory.food,
        latitude: 6.8200,
        longitude: -73.1150,
        address: 'Vía Acapulco km 8',
        town: 'Mesa de los Santos',
        whatsapp: '+573187654321',
        priceLevel: '\$\$',
        photos: [
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: false,
        isImperdible: false,
        status: ItemStatus.approved,
        ratingAvg: 4.7,
        ratingCount: 153,
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      Place(
        id: 'place-8',
        sellerId: 'seller-8',
        name: 'Santos Studio: Barbería & Café Boutique',
        description:
            'Nuevo concepto en La Mesa: corte de cabello clásico, arreglo de barba con toalla caliente y café de especialidad mientras esperas tu turno. Vista panorámica a los pinares.',
        category: PlaceCategory.business,
        latitude: 6.8140,
        longitude: -73.1175,
        address: 'Plaza Central de la Mesa, Local 3',
        town: 'Mesa de los Santos',
        phone: '+57 301 234 5678',
        whatsapp: '+573012345678',
        priceLevel: '\$',
        photos: [
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
        ],
        isFeatured: false,
        isImperdible: false,
        status: ItemStatus.approved,
        ratingAvg: 5.0,
        ratingCount: 19,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  static List<WeekendEvent> getInitialEvents() {
    final now = DateTime.now();
    // This coming Saturday and Sunday
    final thisSaturday = now.add(Duration(days: (6 - now.weekday) % 7));
    final thisSunday = thisSaturday.add(const Duration(days: 1));

    return [
      WeekendEvent(
        id: 'event-1',
        sellerId: 'seller-sports',
        title: 'Copa de la Niebla: Torneo Relámpago de Fútbol 8',
        description:
            'Gran torneo de fútbol aficionado entre veredas y visitantes. Premiación en efectivo, asado comunitario, cerveza artesanal y animación en vivo.',
        category: PlaceCategory.sports,
        latitude: 6.8130,
        longitude: -73.1160,
        startTime: DateTime(thisSaturday.year, thisSaturday.month, thisSaturday.day, 14, 0),
        endTime: DateTime(thisSunday.year, thisSunday.month, thisSunday.day, 19, 0),
        ticketPrice: 'Entrada Libre',
        whatsapp: '+573123456789',
        isFeatured: true,
        bannerUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=800&q=80',
        status: ItemStatus.approved,
      ),
      WeekendEvent(
        id: 'event-2',
        sellerId: 'seller-glamping',
        title: 'Noche de Fogata & Música Acústica Bajo las Estrellas',
        description:
            'Reúnete alrededor de una fogata gigante con malvaviscos, canelazo santandereano, guitarreada acústica en vivo y telescopio para observar las estrellas.',
        category: PlaceCategory.nightlife,
        latitude: 6.8020,
        longitude: -73.0950,
        startTime: DateTime(thisSaturday.year, thisSaturday.month, thisSaturday.day, 19, 30),
        endTime: DateTime(thisSunday.year, thisSunday.month, thisSunday.day, 1, 0),
        ticketPrice: '\$25.000 COP (Incluye Canelazo)',
        whatsapp: '+573159988776',
        isFeatured: true,
        bannerUrl: 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?auto=format&fit=crop&w=800&q=80',
        status: ItemStatus.approved,
      ),
      WeekendEvent(
        id: 'event-3',
        sellerId: 'seller-2',
        title: 'Festival del Café de Origen & Cata Guiada',
        description:
            'Aprende a diferenciar notas de cacao, frutos rojos y jazmín en los granos premiados de la región. Incluye demostración de métodos de filtrado (V60, Chemex y Aeropress).',
        category: PlaceCategory.coffee,
        latitude: 6.8580,
        longitude: -73.1320,
        startTime: DateTime(thisSunday.year, thisSunday.month, thisSunday.day, 10, 0),
        endTime: DateTime(thisSunday.year, thisSunday.month, thisSunday.day, 16, 0),
        ticketPrice: '\$35.000 COP',
        whatsapp: '+573176401234',
        isFeatured: false,
        bannerUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
        status: ItemStatus.approved,
      ),
      WeekendEvent(
        id: 'event-4-pending',
        sellerId: 'seller-party',
        title: 'Fiesta Electrónica Open Air en el Cañón (Pendiente Moderación)',
        description:
            'DJ sets locales y luces láser en el mirador. Evento en proceso de revisión de permisos de ruido y seguridad por el administrador.',
        category: PlaceCategory.nightlife,
        latitude: 6.7900,
        longitude: -73.0800,
        startTime: DateTime(thisSaturday.year, thisSaturday.month, thisSaturday.day, 21, 0),
        endTime: DateTime(thisSunday.year, thisSunday.month, thisSunday.day, 4, 0),
        ticketPrice: '\$50.000 COP',
        status: ItemStatus.pending,
      ),
    ];
  }

  static List<Review> getInitialReviews() {
    return [
      Review(
        id: 'rev-1',
        placeId: 'place-1',
        userId: 'u1',
        userName: 'Carolina Méndez',
        rating: 5,
        comment: '¡Las mejores arepas de chócolo de toda Colombia! El queso campesino se derrite completamente. Recomiendo ir antes del mediodía porque se llena bastante.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'rev-2',
        placeId: 'place-1',
        userId: 'u2',
        userName: 'Andrés Gómez',
        rating: 5,
        comment: 'Un ambiente súper familiar. Compramos moras, guanábanas y miel pura directamente a los campesinos. Muy buen parqueadero.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'rev-3',
        placeId: 'place-3',
        userId: 'u3',
        userName: 'Mateo Restrepo (Escalador)',
        rating: 5,
        comment: 'La roca en La Mojarra es de nivel mundial. La vista hacia el abismo del Chicamocha mientras estás colgado a 30 metros te deja sin aliento.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
}

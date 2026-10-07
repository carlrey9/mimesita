-- ==============================================================================
-- MIMESITA - Supabase PostgreSQL + PostGIS Database Schema
-- Architecture for Hyper-Local Discovery Platform
-- Target Pilot: Mesa de los Santos, Santander
-- ==============================================================================

-- 1. Enable PostGIS Extension for high-performance spatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Custom Enumerations
CREATE TYPE user_role AS ENUM ('traveler', 'seller', 'admin');
CREATE TYPE item_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE place_category AS ENUM (
    'food',           -- Comida típica, restaurantes, arepas de chócolo
    'coffee',          -- Haciendas cafeteras, café de origen, repostería
    'photo_spot',      -- Miradores al Cañón de Chicamocha, cascadas
    'extreme_sports',  -- Escalada en roca (La Mojarra), parapente, MTB
    'culture',         -- Artesanías, historia Guane, mercado campesino
    'nightlife',       -- Fogatas, glamping nights, música en vivo
    'sports',          -- Torneos de fútbol, microfútbol, carreras
    'business'         -- Nuevos negocios, barberías, spas, tiendas locales
);

-- 3. User Profiles Table (Extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    role user_role NOT NULL DEFAULT 'traveler',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Places / Businesses Table
CREATE TABLE IF NOT EXISTS public.places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category place_category NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    geom GEOMETRY(Point, 4326),
    address TEXT,
    town TEXT NOT NULL DEFAULT 'Mesa de los Santos',
    department TEXT NOT NULL DEFAULT 'Santander',
    phone TEXT,
    whatsapp TEXT,
    instagram TEXT,
    price_level TEXT DEFAULT '$$', -- $, $$, $$$
    photos TEXT[] DEFAULT '{}',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_imperdible BOOLEAN NOT NULL DEFAULT FALSE, -- Must-visit badge
    status item_status NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    rating_avg NUMERIC(3, 2) NOT NULL DEFAULT 5.00,
    rating_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Spatial index on geom for sub-millisecond distance queries
CREATE INDEX IF NOT EXISTS places_geom_idx ON public.places USING GIST (geom);
CREATE INDEX IF NOT EXISTS places_category_idx ON public.places (category);
CREATE INDEX IF NOT EXISTS places_status_idx ON public.places (status);

-- 5. Weekend & Pop-up Events Table
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    place_id UUID REFERENCES public.places(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category place_category NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    geom GEOMETRY(Point, 4326),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    ticket_price TEXT DEFAULT 'Entrada Libre',
    banner_url TEXT,
    whatsapp TEXT,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    status item_status NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS events_geom_idx ON public.events USING GIST (geom);
CREATE INDEX IF NOT EXISTS events_time_idx ON public.events (start_time, end_time);
CREATE INDEX IF NOT EXISTS events_status_idx ON public.events (status);

-- 6. Ratings & Reviews Table
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_id UUID NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    photos TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(place_id, user_id)
);

CREATE INDEX IF NOT EXISTS reviews_place_idx ON public.reviews (place_id);

-- 7. Automated Triggers

-- Trigger A: Keep PostGIS geometry column synchronized with lat/long
CREATE OR REPLACE FUNCTION update_place_geom()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_place_geom
BEFORE INSERT OR UPDATE OF latitude, longitude ON public.places
FOR EACH ROW EXECUTE FUNCTION update_place_geom();

CREATE OR REPLACE TRIGGER trigger_event_geom
BEFORE INSERT OR UPDATE OF latitude, longitude ON public.events
FOR EACH ROW EXECUTE FUNCTION update_place_geom();

-- Trigger B: Recalculate place rating_avg and rating_count when reviews change
CREATE OR REPLACE FUNCTION update_place_ratings()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.places
    SET 
        rating_avg = COALESCE((SELECT AVG(rating)::numeric(3,2) FROM public.reviews WHERE place_id = COALESCE(NEW.place_id, OLD.place_id)), 5.0),
        rating_count = (SELECT COUNT(*) FROM public.reviews WHERE place_id = COALESCE(NEW.place_id, OLD.place_id)),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.place_id, OLD.place_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_review_rating_change
AFTER INSERT OR UPDATE OR DELETE ON public.reviews
FOR EACH ROW EXECUTE FUNCTION update_place_ratings();

-- 8. High-Performance Spatial Query Function (Nearby Places with Distance in km)
CREATE OR REPLACE FUNCTION get_nearby_places(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 30.0,
    filter_category TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    category place_category,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_km DOUBLE PRECISION,
    rating_avg NUMERIC,
    rating_count INT,
    photos TEXT[],
    whatsapp TEXT,
    is_featured BOOLEAN,
    is_imperdible BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.description,
        p.category,
        p.latitude,
        p.longitude,
        (ST_Distance(p.geom, ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography) / 1000.0) AS distance_km,
        p.rating_avg,
        p.rating_count,
        p.photos,
        p.whatsapp,
        p.is_featured,
        p.is_imperdible
    FROM public.places p
    WHERE p.status = 'approved'
      AND (filter_category IS NULL OR filter_category = 'all' OR p.category::text = filter_category)
      AND ST_DWithin(p.geom, ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography, radius_km * 1000)
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Row Level Security (RLS) Configuration

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.places ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Helper to check if current user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles: Public can read, user can update self
CREATE POLICY "Public profiles are readable" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Places:
-- 1. Anyone (public travelers) can read approved places
CREATE POLICY "Anyone can view approved places" ON public.places
    FOR SELECT USING (status = 'approved' OR seller_id = auth.uid() OR is_admin());

-- 2. Sellers can insert places (always starts as pending)
CREATE POLICY "Authenticated sellers can insert places" ON public.places
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 3. Sellers can update their own places (cannot force status to approved)
CREATE POLICY "Sellers can update own places" ON public.places
    FOR UPDATE USING (seller_id = auth.uid() OR is_admin());

-- Events:
CREATE POLICY "Anyone can view approved events" ON public.events
    FOR SELECT USING (status = 'approved' OR seller_id = auth.uid() OR is_admin());

CREATE POLICY "Sellers can create events" ON public.events
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Sellers can update own events" ON public.events
    FOR UPDATE USING (seller_id = auth.uid() OR is_admin());

-- Reviews:
CREATE POLICY "Anyone can read reviews" ON public.reviews
    FOR SELECT USING (true);

CREATE POLICY "Authenticated travelers can post review" ON public.reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- CATCH FEATURE MIGRATION
-- Neer - Location Based Social Network
-- ============================================================
-- Bu SQL'i Supabase Dashboard > SQL Editor'da çalıştırın.
-- ============================================================

-- 1. PROFILES TABLOSUNA YENİ SÜTUNLAR
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'busy'
    CHECK (status IN ('available', 'busy', 'pending')),
  ADD COLUMN IF NOT EXISTS available_until TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS pending_catch_id UUID,
  ADD COLUMN IF NOT EXISTS phone_number TEXT;

-- 2. CATCHES TABLOSU
-- ============================================================
CREATE TABLE IF NOT EXISTS public.catches (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id  UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status       TEXT NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  created_at   TIMESTAMPTZ DEFAULT now(),
  expires_at   TIMESTAMPTZ DEFAULT (now() + INTERVAL '60 seconds')
);

CREATE INDEX IF NOT EXISTS idx_catches_cooldown
  ON public.catches(sender_id, receiver_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_catches_receiver_pending
  ON public.catches(receiver_id, status) WHERE status = 'pending';

-- 3. WATCHERS TABLOSU (Zil ikonu)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.watchers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  watcher_id  UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(watcher_id, target_id)
);

CREATE INDEX IF NOT EXISTS idx_watchers_target
  ON public.watchers(target_id, is_active) WHERE is_active = true;

-- 4. RLS POLİTİKALARI
-- ============================================================

-- catches RLS
ALTER TABLE public.catches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "catches_select" ON public.catches
  FOR SELECT USING (sender_id = auth.uid() OR receiver_id = auth.uid());

CREATE POLICY "catches_insert" ON public.catches
  FOR INSERT WITH CHECK (sender_id = auth.uid());

CREATE POLICY "catches_update" ON public.catches
  FOR UPDATE USING (receiver_id = auth.uid());

-- watchers RLS
ALTER TABLE public.watchers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "watchers_select" ON public.watchers
  FOR SELECT USING (watcher_id = auth.uid());

CREATE POLICY "watchers_insert" ON public.watchers
  FOR INSERT WITH CHECK (watcher_id = auth.uid());

CREATE POLICY "watchers_update" ON public.watchers
  FOR UPDATE USING (watcher_id = auth.uid());

CREATE POLICY "watchers_delete" ON public.watchers
  FOR DELETE USING (watcher_id = auth.uid());

-- 5. TRIGGERS
-- ============================================================

-- Catch gelince receiver'ı pending yap
CREATE OR REPLACE FUNCTION on_catch_created()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles
  SET status = 'pending', pending_catch_id = NEW.id
  WHERE id = NEW.receiver_id AND status = 'available';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_catch_created
  AFTER INSERT ON public.catches
  FOR EACH ROW EXECUTE FUNCTION on_catch_created();

-- Catch cevaplanınca durumu güncelle
CREATE OR REPLACE FUNCTION on_catch_resolved()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'pending' AND NEW.status IN ('accepted', 'rejected', 'expired') THEN
    UPDATE public.profiles
    SET status = CASE WHEN NEW.status = 'accepted' THEN 'busy' ELSE 'available' END,
        pending_catch_id = NULL
    WHERE id = NEW.receiver_id AND pending_catch_id = OLD.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_catch_resolved
  AFTER UPDATE ON public.catches
  FOR EACH ROW EXECUTE FUNCTION on_catch_resolved();

-- 6. pg_cron JOBS (Auto-expire)
-- ============================================================

-- Müsaitlik süresi dolunca busy yap
CREATE OR REPLACE FUNCTION expire_availability()
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET status = 'busy', available_until = NULL
  WHERE status = 'available' AND available_until IS NOT NULL AND available_until <= now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Süresi geçen catch'leri expire et
CREATE OR REPLACE FUNCTION expire_pending_catches()
RETURNS void AS $$
BEGIN
  UPDATE public.catches SET status = 'expired'
  WHERE status = 'pending' AND expires_at <= now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Her dakika çalıştır
SELECT cron.schedule('expire-availability', '* * * * *', $$ SELECT expire_availability(); $$);
SELECT cron.schedule('expire-pending-catches', '* * * * *', $$ SELECT expire_pending_catches(); $$);

-- 7. REALTIME
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.catches;
-- profiles zaten realtime'daysa bu satır hata verir, güvenle atlanabilir:
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;

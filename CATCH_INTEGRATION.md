# CATCH ENTEGRASYON SPECİ — neer Projesi İçin

> Bu dosya, "Catch" özelliğini neer'e entegre etmek için Claude Code'un referans dökümanıdır.

---

## Catch Nedir?
Arkadaşların anlık müsaitlik durumunu gösteren ve müsait olanlara bildirim atma / doğrudan arama yapma özelliği. Mevcut arkadaşlar sayfasının yerini alacak.

## Entegrasyon Stratejisi
- Navbar'daki mevcut "Arkadaşlar" sayfası **kaldırılacak**
- Yerine **Catch ekranı** gelecek (aynı tab, aynı ikon pozisyonu)
- neer'in mevcut auth ve kullanıcı sistemi korunacak
- Catch için gereken yeni tablolar neer'in **mevcut Supabase projesine** eklenecek

---

## 1. Supabase'e Eklenecek Yeni Tablolar

profiles tablosu zaten varsa, sadece şu sütunları EKLE (ALTER TABLE):

```sql
-- profiles tablosuna yeni sütunlar (MEVCUT tabloya ekleniyor)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'busy'
    CHECK (status IN ('available', 'busy', 'pending')),
  ADD COLUMN IF NOT EXISTS available_until TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS pending_catch_id UUID,
  ADD COLUMN IF NOT EXISTS phone_number TEXT;
-- phone_number zaten varsa bu satırı atla
```

Eğer profiles tablosu YOKSA veya farklı bir isimle (users vb.) kullanılıyorsa, mevcut tablo adına göre adapte et.

### Yeni tablo: catches
```sql
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
```

### Yeni tablo: watchers (Zil ikonu)
```sql
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
```

### RLS (catches & watchers)
```sql
ALTER TABLE public.catches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "catches_select" ON public.catches
  FOR SELECT USING (sender_id = auth.uid() OR receiver_id = auth.uid());
CREATE POLICY "catches_insert" ON public.catches
  FOR INSERT WITH CHECK (sender_id = auth.uid());
CREATE POLICY "catches_update" ON public.catches
  FOR UPDATE USING (receiver_id = auth.uid());

ALTER TABLE public.watchers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "watchers_select" ON public.watchers
  FOR SELECT USING (watcher_id = auth.uid());
CREATE POLICY "watchers_insert" ON public.watchers
  FOR INSERT WITH CHECK (watcher_id = auth.uid());
CREATE POLICY "watchers_update" ON public.watchers
  FOR UPDATE USING (watcher_id = auth.uid());
CREATE POLICY "watchers_delete" ON public.watchers
  FOR DELETE USING (watcher_id = auth.uid());
```

### Triggers
```sql
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
```

### pg_cron (auto-expire)
```sql
CREATE OR REPLACE FUNCTION expire_availability()
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET status = 'busy', available_until = NULL
  WHERE status = 'available' AND available_until IS NOT NULL AND available_until <= now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION expire_pending_catches()
RETURNS void AS $$
BEGIN
  UPDATE public.catches SET status = 'expired'
  WHERE status = 'pending' AND expires_at <= now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT cron.schedule('expire-availability', '* * * * *', $$ SELECT expire_availability(); $$);
SELECT cron.schedule('expire-pending-catches', '* * * * *', $$ SELECT expire_pending_catches(); $$);
```

### Realtime
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE public.catches;
-- profiles zaten realtime'daysa tekrar ekleme
```

---

## 2. Durum Makinesi (Status Machine)

```
busy (kırmızı) ← süre doldu (pg_cron) ← available (yeşil)
                                              ↓ catch geldi
                                         pending (sarı)
                                           ↙        ↘
                                  reddetti/timeout  onayladı
                                   → available      → busy
```

Renk kodları: available=#22C55E, busy=#EF4444, pending=#FBBF24

---

## 3. Flutter Tarafında Eklenecek Dosyalar

### Models
- `catch_request.dart` — CatchRequest model (id, senderId, receiverId, status, createdAt, expiresAt)
- `watcher.dart` — Watcher model (id, watcherId, targetId, isActive)

### Services
- `catch_service.dart` — sendCatch(), acceptCatch(), rejectCatch(), getCooldownRemaining()
- `availability_service.dart` — setAvailable(duration), setBusy(), getCurrentStatus()
- `watcher_service.dart` — toggleWatch(), getWatchedFriends()

### Widgets (Catch ekranında kullanılacak)
- `friend_catch_tile.dart` — Tek arkadaş satırı: durum dot + isim + catch butonu + zil + telefon
- `status_indicator.dart` — Yeşil/kırmızı/sarı yuvarlak dot
- `catch_button.dart` — "Catch" butonu (cooldown timer gösterir, 3dk kilit)
- `bell_toggle.dart` — Zil ikonu (watcher toggle)
- `phone_button.dart` — Telefon ikonu (url_launcher tel: ile doğrudan arama)
- `availability_picker.dart` — Süre seçici bottom sheet (30dk, 1sa, 2sa, 4sa)
- `incoming_catch_sheet.dart` — Gelen catch bildirimi bottom sheet (✅ onayla / ✖ reddet)

### Ana Ekran Değişikliği
- Mevcut arkadaşlar sayfası kaldırılacak
- Yerine Catch sayfası gelecek: üstte kendi durumunu toggle eden bir buton, altında arkadaş listesi
- Her arkadaş satırında: durum göstergesi + isim + catch butonu (sadece yeşillere) + zil + telefon (sadece yeşillere)
- Realtime subscription ile anlık güncelleme

---

## 4. Özellik Detayları

### Catch Mekanizması
- Sadece status='available' olan arkadaşlara Catch atılabilir
- Catch atınca → push notification + receiver otomatik 'pending' olur (DB trigger)
- Receiver onaylarsa → sender'ın ekranında ✅ belirir (Realtime)
- Receiver reddederse veya 60sn geçerse → receiver tekrar 'available' olur

### Anti-Spam Cooldown
- Bir kişiye Catch attıktan sonra aynı kişiye 3 dakika boyunca tekrar atılamaz
- UI'da geri sayım timer gösterilir

### Zil İkonu (Opt-in Radar)
- Arkadaşın yanındaki zili aktif edersen, o kişi müsait olduğunda sana push notification gelir
- watchers tablosunda is_active ile toggle

### Doğrudan Arama
- Sadece müsait (yeşil) kişilerin yanında telefon ikonu görünür
- Tıklayınca url_launcher ile tel: scheme açılır

### Kapasite Kilidi
- Müsait kişiye catch gelince otomatik 'pending' (sarı) olur
- Diğer herkes o kişiyi sarı görür, catch atamaz
- Accept → kırmızı, Reject/timeout → tekrar yeşil

---

## 5. Bağımlılıklar (pubspec.yaml'a eklenecek, yoksa)
- url_launcher (doğrudan arama için)
- Supabase Realtime zaten mevcut olmalı
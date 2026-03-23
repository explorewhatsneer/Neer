// Supabase Edge Function: Push Notification Webhook
//
// notifications tablosuna INSERT olduğunda bu fonksiyon tetiklenir.
// İlgili kullanıcının FCM token'ını çeker ve Firebase HTTP v1 API
// üzerinden gerçek push notification gönderir.
//
// Kurulum:
// 1. Supabase Dashboard → Database → Webhooks → notifications INSERT → bu fonksiyon
// 2. Edge Function Secrets: FIREBASE_PROJECT_ID, FIREBASE_SERVICE_ACCOUNT_KEY (JSON)
//
// Deploy: supabase functions deploy push-webhook

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── Firebase HTTP v1 Access Token ────────────────────────────

interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri: string;
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = btoa(
    JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: sa.token_uri,
      iat: now,
      exp: now + 3600,
    })
  );

  // JWT imzalama (Deno crypto)
  const encoder = new TextEncoder();
  const keyData = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\n/g, "");

  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    encoder.encode(`${header}.${payload}`)
  );

  const sig = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const jwt = `${header}.${payload}.${sig}`;

  // Token al
  const res = await fetch(sa.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const data = await res.json();
  return data.access_token;
}

// ─── Ana Handler ──────────────────────────────────────────────

serve(async (req) => {
  try {
    const body = await req.json();

    // Webhook payload: { type: "INSERT", table: "notifications", record: {...} }
    const record = body.record;
    if (!record || !record.user_id) {
      return new Response(JSON.stringify({ error: "Geçersiz payload" }), {
        status: 400,
      });
    }

    const userId: string = record.user_id;
    const title: string = record.title ?? "Neer";
    const message: string = record.body ?? record.message ?? "Yeni bir bildirim var";
    const notifType: string = record.type ?? "general";

    // 1. Supabase'den kullanıcının FCM token'ını çek
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { data: profile, error } = await supabase
      .from("profiles")
      .select("fcm_token, full_name")
      .eq("id", userId)
      .single();

    if (error || !profile?.fcm_token) {
      console.log(`FCM token bulunamadı: userId=${userId}`);
      return new Response(
        JSON.stringify({ skipped: true, reason: "no_fcm_token" }),
        { status: 200 }
      );
    }

    const fcmToken: string = profile.fcm_token;

    // 2. Firebase Service Account bilgilerini al
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
    const saKeyJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_KEY");

    if (!projectId || !saKeyJson) {
      console.error("Firebase env vars eksik");
      return new Response(
        JSON.stringify({ error: "Firebase yapılandırması eksik" }),
        { status: 500 }
      );
    }

    const serviceAccount: ServiceAccount = JSON.parse(saKeyJson);

    // 3. Firebase access token al
    const accessToken = await getAccessToken(serviceAccount);

    // 4. FCM HTTP v1 ile push gönder
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const fcmResponse = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: {
            title: title,
            body: message,
          },
          data: {
            type: notifType,
            notification_id: String(record.id ?? ""),
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          apns: {
            payload: {
              aps: {
                badge: 1,
                sound: "default",
                "content-available": 1,
              },
            },
          },
        },
      }),
    });

    const fcmResult = await fcmResponse.json();

    if (!fcmResponse.ok) {
      console.error("FCM hatası:", JSON.stringify(fcmResult));
      return new Response(JSON.stringify({ error: "FCM gönderim hatası", details: fcmResult }), {
        status: 502,
      });
    }

    console.log(`Push gönderildi: userId=${userId}, type=${notifType}`);
    return new Response(JSON.stringify({ success: true, messageId: fcmResult.name }), {
      status: 200,
    });
  } catch (err) {
    console.error("Edge Function hatası:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});

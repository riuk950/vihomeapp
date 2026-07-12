import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

// ─────────────────────────────────────────────────────────────────────────────
// CORS headers
// ─────────────────────────────────────────────────────────────────────────────
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ─────────────────────────────────────────────────────────────────────────────
// Genera un access_token de Google autenticando con Service Account (JWT RS256)
// Equivalente al paquete googleapis de Dart pero ejecutado en Deno/Edge.
// ─────────────────────────────────────────────────────────────────────────────
async function getGoogleAccessToken(serviceAccountJson: string): Promise<string> {
  let sa;
  try {
    sa = JSON.parse(serviceAccountJson);
  } catch (e) {
    throw new Error("El secreto GOOGLE_SERVICE_ACCOUNT_JSON no es un JSON válido.");
  }

  if (!sa || typeof sa !== "object") {
    throw new Error("El secreto GOOGLE_SERVICE_ACCOUNT_JSON no contiene un objeto JSON.");
  }

  if (!sa.private_key) {
    throw new Error(`El JSON de la Service Account no tiene el campo 'private_key'. Campos encontrados: ${Object.keys(sa).join(", ")}`);
  }

  if (!sa.client_email) {
    throw new Error(`El JSON de la Service Account no tiene el campo 'client_email'. Campos encontrados: ${Object.keys(sa).join(", ")}`);
  }

  const now = Math.floor(Date.now() / 1000);

  const jwtPayload = {
    iss: sa.client_email,
    sub: sa.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encodeBase64Url = (obj: object): string =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

  const encodedHeader = encodeBase64Url({ alg: "RS256", typ: "JWT" });
  const encodedPayload = encodeBase64Url(jwtPayload);
  const signingInput = `${encodedHeader}.${encodedPayload}`;

  // Limpiar PEM de la clave privada
  const pemKey = sa.private_key.replace(/\\n/g, "\n");
  const pemContents = pemKey
    .replace("-----BEGIN RSA PRIVATE KEY-----", "")
    .replace("-----END RSA PRIVATE KEY-----", "")
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  // Importar clave con WebCrypto API de Deno
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const encodedSignature = btoa(
    String.fromCharCode(...new Uint8Array(signatureBuffer)),
  )
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const signedJwt = `${signingInput}.${encodedSignature}`;

  // Intercambiar JWT firmado por access_token de Google OAuth2
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: signedJwt,
    }),
  });

  const tokenData = await tokenResponse.json();
  if (!tokenResponse.ok) {
    throw new Error(`Error obteniendo token de Google: ${JSON.stringify(tokenData)}`);
  }

  return tokenData.access_token as string;
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN HANDLER
// ─────────────────────────────────────────────────────────────────────────────
serve(async (req) => {
  // Preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. Verificar autenticación del usuario con su JWT de Supabase ──
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "No autorizado: falta el header Authorization" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseUserClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: { user }, error: authError } = await supabaseUserClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Token inválido o expirado" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    console.log(`[verify-subscription] Usuario autenticado: ${user.id}`);

    // ── 2. Parsear body ──
    const body = await req.json();
    const { purchaseToken, productId, packageName } = body as {
      purchaseToken: string;
      productId: string;
      packageName?: string;
    };

    if (!purchaseToken || !productId) {
      return new Response(
        JSON.stringify({ error: "Parámetros requeridos: purchaseToken y productId" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const resolvedPackage =
      packageName ??
      Deno.env.get("GOOGLE_PLAY_PACKAGE_NAME") ??
      "com.vihomeapp.vihomeapp";

    console.log(`[verify-subscription] Verificando: productId=${productId}, package=${resolvedPackage}`);

    // ── 3. Autenticarse con Google Play API via Service Account ──
    const serviceAccountJson = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON");
    if (!serviceAccountJson) {
      throw new Error("Secreto GOOGLE_SERVICE_ACCOUNT_JSON no configurado en Supabase");
    }

    const googleToken = await getGoogleAccessToken(serviceAccountJson);

    // ── 4. Consultar Google Play Developer API ──
    // GET /androidpublisher/v3/applications/{pkg}/purchases/subscriptions/{subId}/tokens/{token}
    const googleApiUrl = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${resolvedPackage}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`;

    const googleResponse = await fetch(googleApiUrl, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${googleToken}`,
        "Content-Type": "application/json",
      },
    });

    if (!googleResponse.ok) {
      const errorText = await googleResponse.text();
      console.error("[verify-subscription] Google API error:", errorText);
      return new Response(
        JSON.stringify({ error: "Error al verificar con Google Play Developer API", details: errorText }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const purchaseData = await googleResponse.json();
    console.log(`[verify-subscription] paymentState=${purchaseData.paymentState}, expiryTimeMillis=${purchaseData.expiryTimeMillis}`);

    // ── 5. Evaluar si la suscripción está activa ──
    // paymentState: 0=pendiente, 1=activo/recibido, 2=período de gracia
    // cancelReason existe si fue cancelada por el usuario (0), por el sistema, etc.
    // IMPORTANTE: Si el usuario cancela, conserva el acceso hasta la fecha de expiración.
    const paymentState: number = purchaseData.paymentState ?? -1;
    const expiryTimeMillis: number = Number(purchaseData.expiryTimeMillis ?? 0);
    const isExpired = expiryTimeMillis > 0 && expiryTimeMillis < Date.now();

    const isActive =
      (paymentState === 1 || paymentState === 2) && !isExpired;

    console.log(`[verify-subscription] isActive=${isActive} (paymentState=${paymentState}, cancelReason=${purchaseData.cancelReason}, isExpired=${isExpired})`);

    // ── 6. Actualizar Supabase con service_role_key (omite RLS del cliente) ──
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // Intentamos actualizar con columnas extendidas primero
    const { error: updateError } = await supabaseAdmin
      .from("profiles")
      .update({
        is_premium: isActive,
        premium_expires_at: isActive ? new Date(expiryTimeMillis).toISOString() : null,
        premium_product_id: isActive ? productId : null,
      })
      .eq("id", user.id);

    if (updateError) {
      // Fallback: solo is_premium si las columnas premium_* no existen aún
      console.warn(`[verify-subscription] Fallback a is_premium básico: ${updateError.message}`);
      const { error: fallbackError } = await supabaseAdmin
        .from("profiles")
        .update({ is_premium: isActive })
        .eq("id", user.id);

      if (fallbackError) {
        throw new Error(`Error crítico actualizando Supabase: ${fallbackError.message}`);
      }
    }

    console.log(`[verify-subscription] ✅ profiles actualizado: userId=${user.id}, is_premium=${isActive}`);

    // ── 7. Respuesta al cliente Flutter ──
    return new Response(
      JSON.stringify({
        success: true,
        isActive,
        paymentState,
        expiryTimeMillis,
        message: isActive
          ? "Suscripción verificada y activada correctamente"
          : "Suscripción no activa o expirada",
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );

  } catch (error) {
    console.error("[verify-subscription] Error inesperado:", error.message);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

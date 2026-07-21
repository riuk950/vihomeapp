import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"
import { JWT } from "https://esm.sh/google-auth-library@9.4.1"

serve(async (req) => {
  try {
    const payload = await req.json()
    console.log('Payload recibido:', JSON.stringify(payload, null, 2))

    if (payload.name === 'Functions') {
      return new Response(JSON.stringify({ message: 'Función activa' }), { status: 200 })
    }

    const record = payload.record || payload.data || payload;
    const oldRecord = payload.old_record;

    if (oldRecord && record.estado === oldRecord.estado) {
      return new Response(JSON.stringify({ message: 'El estado no ha cambiado' }), { status: 200 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    let { arrendatario_id, propiedad_id, estado, id: solicitud_id } = record;
    
    // Si faltan datos (común en UPDATE webhooks), los buscamos en la DB
    if (!arrendatario_id || !propiedad_id || !estado) {
      const { data: fullRecord } = await supabase
        .from('solicitudes')
        .select('arrendatario_id, propiedad_id, estado')
        .eq('id', solicitud_id)
        .single();
      
      if (fullRecord) {
        arrendatario_id = fullRecord.arrendatario_id;
        propiedad_id = fullRecord.propiedad_id;
        estado = fullRecord.estado;
      }
    }

    // Solo notificar si la solicitud ha sido aceptada o rechazada
    if (estado !== 'aceptada' && estado !== 'rechazada') {
      return new Response(JSON.stringify({ message: `El estado es "${estado}", no se envía notificación al arrendatario` }), { status: 200 })
    }

    const [{ data: profileTenant }, { data: propiedad }] = await Promise.all([
      supabase.from('profiles').select('fcm_token').eq('id', arrendatario_id).single(),
      supabase.from('propiedades').select('titulo').eq('id', propiedad_id).single(),
    ])

    if (!profileTenant?.fcm_token) {
      return new Response(JSON.stringify({ message: 'Arrendatario sin token FCM' }), { status: 200 })
    }

    const tituloPropiedad = propiedad?.titulo || 'la propiedad'
    const statusText = estado === 'aceptada' ? 'ACEPTADA' : 'RECHAZADA';
    const bodyText = estado === 'aceptada' 
      ? `¡Buenas noticias! Tu solicitud para "${tituloPropiedad}" ha sido ACEPTADA.`
      : `Tu solicitud para "${tituloPropiedad}" ha sido rechazada.`;

    const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}')
    const jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    })
    const accessToken = await jwtClient.getAccessToken()

    const fcmMessage = {
      message: {
        token: profileTenant.fcm_token,
        notification: {
          title: `Actualización de Solicitud: ${statusText}`,
          body: bodyText,
        },
        data: {
          type: 'tenant_notification', // MATCH con Flutter PushNotificationService
          solicitud_id: String(solicitud_id),
          estado: estado,
        },
        android: {
          priority: 'high',
          notification: { click_action: 'FLUTTER_NOTIFICATION_CLICK', sound: 'default' },
        },
        apns: { payload: { aps: { sound: 'default', badge: 1 } } },
      },
    }

    const fcmResponse = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${accessToken.token}` },
      body: JSON.stringify(fcmMessage),
    })

    return new Response(await fcmResponse.text(), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})

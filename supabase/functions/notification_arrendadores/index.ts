import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"
import { JWT } from "https://esm.sh/google-auth-library@9.4.1"

serve(async (req) => {
  try {
    const payload = await req.json()
    console.log('Payload completo recibido:', JSON.stringify(payload, null, 2))

    // Manejar el payload de prueba por defecto de Supabase
    if (payload.name === 'Functions') {
      return new Response(
        JSON.stringify({ message: '¡Función alcanzada con éxito! Para probar el envío real, envía un JSON con la estructura de {record: {...}}' }), 
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const record = payload.record || payload.data || payload;
    const requiredFields = ['arrendatario_id', 'arrendador_id', 'propiedad_id'];
    const missingFields = requiredFields.filter(field => !record[field]);

    if (missingFields.length > 0) {
      return new Response(
        JSON.stringify({ error: 'Invalid payload structure', missingFields }), 
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const { arrendatario_id, arrendador_id, propiedad_id, id: solicitud_id } = record;

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 1. Obtener token y nombres
    const [{ data: profileArrendador }, { data: profileArrendatario }, { data: propiedad }] = await Promise.all([
      supabase.from('profiles').select('fcm_token').eq('id', arrendador_id).single(),
      supabase.from('profiles').select('full_name').eq('id', arrendatario_id).single(),
      supabase.from('propiedades').select('titulo').eq('id', propiedad_id).single(),
    ])

    if (!profileArrendador?.fcm_token) {
      return new Response(JSON.stringify({ message: 'Arrendador sin token FCM' }), { status: 200 })
    }

    const nombreArrendatario = profileArrendatario?.full_name || 'Un interesado'
    const tituloPropiedad = propiedad?.titulo || 'tu propiedad'

    // 2. Obtener Token de Acceso de Google (OAuth2)
    const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}')
    
    if (!serviceAccount.project_id) {
      console.error('FIREBASE_SERVICE_ACCOUNT no configurada')
      return new Response(JSON.stringify({ error: 'Config error' }), { status: 500 })
    }

    const client = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    })

    const accessToken = await client.getAccessToken()

    // 3. Enviar a FCM v1
    const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`
    
    const fcmMessage = {
      message: {
        token: profileArrendador.fcm_token,
        notification: {
          title: '¡Nueva Solicitud!',
          body: `${nombreArrendatario} ha enviado una solicitud para ${tituloPropiedad}.`,
        },
        data: {
          type: 'new_application',
          solicitud_id: String(solicitud_id),
        },
        android: {
          priority: 'high',
          notification: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      },
    }

    const fcmResponse = await fetch(fcmEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken.token}`,
      },
      body: JSON.stringify(fcmMessage),
    })

    const fcmResult = await fcmResponse.json()
    console.log('Resultado FCM v1:', fcmResult)

    return new Response(JSON.stringify(fcmResult), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('Error general:', error)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"

const FCM_URL = 'https://fcm.googleapis.com/fcm/send'

serve(async (req) => {
  try {
    const { record } = await req.json()
    
    // El 'record' viene del trigger de Supabase (INSERT en solicitudes)
    const arrendador_id = record.arrendador_id
    const solicitud_id = record.id
    const propiedad_id = record.propiedad_id

    // 1. Inicializar cliente Supabase
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Obtener el fcm_token del arrendador
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', arrendador_id)
      .single()

    if (profileError || !profile?.fcm_token) {
      console.log(`No se encontró fcm_token para el arrendador ${arrendador_id}`)
      return new Response(JSON.stringify({ message: 'No token found' }), { status: 200 })
    }

    // 3. Obtener info de la propiedad para el mensaje
    const { data: propiedad } = await supabase
      .from('propiedades')
      .select('titulo')
      .eq('id', propiedad_id)
      .single()

    const tituloPropiedad = propiedad?.titulo || 'tu propiedad'

    // 4. Enviar notificación via FCM
    // Se recomienda usar la API v1 de FCM con OAuth2 en producción, 
    // pero para simplicidad usaremos la Server Key si está configurada.
    const serverKey = Deno.env.get('FIREBASE_SERVER_KEY')
    
    if (!serverKey) {
      console.error('FIREBASE_SERVER_KEY no está configurada en las variables de entorno')
      return new Response(JSON.stringify({ error: 'Server configuration error' }), { status: 500 })
    }

    const fcmPayload = {
      to: profile.fcm_token,
      notification: {
        title: '¡Nueva Solicitud de Arriendo!',
        body: `Has recibido una nueva solicitud para ${tituloPropiedad}.`,
        sound: 'default',
      },
      data: {
        type: 'new_application',
        solicitud_id: solicitud_id,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    }

    const response = await fetch(FCM_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${serverKey}`,
      },
      body: JSON.stringify(fcmPayload),
    })

    const result = await response.json()
    console.log('Resultado envío FCM:', result)

    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('Error en la función:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type GoogleTokenResponse = {
  access_token: string;
  expires_in: number;
  scope: string;
  token_type: string;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const googleClientId = Deno.env.get("GOOGLE_CLIENT_ID") ?? "";
    const googleClientSecret = Deno.env.get("GOOGLE_CLIENT_SECRET") ?? "";
    const googleRefreshToken = Deno.env.get("GOOGLE_REFRESH_TOKEN") ?? "";

    if (!googleClientId || !googleClientSecret || !googleRefreshToken) {
      throw new Error(
        "Google Meet belum dikonfigurasi. Set GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, dan GOOGLE_REFRESH_TOKEN di Supabase secrets.",
      );
    }

    const body = await req.json().catch(() => ({}));
    const title = typeof body?.title === "string" && body.title.trim()
      ? body.title.trim()
      : "Meeting UNO";

    const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        client_id: googleClientId,
        client_secret: googleClientSecret,
        refresh_token: googleRefreshToken,
        grant_type: "refresh_token",
      }),
    });

    if (!tokenResponse.ok) {
      const detail = await tokenResponse.text();
      throw new Error(`Gagal mengambil access token Google: ${detail}`);
    }

    const tokenData = await tokenResponse.json() as GoogleTokenResponse;
    const accessToken = tokenData.access_token;
    if (!accessToken) {
      throw new Error("Access token Google kosong.");
    }

    const meetResponse = await fetch("https://meet.googleapis.com/v2/spaces", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    });

    if (!meetResponse.ok) {
      const detail = await meetResponse.text();
      throw new Error(`Gagal membuat Google Meet space: ${detail}`);
    }

    const meetData = await meetResponse.json();
    return Response.json(
      {
        title,
        spaceName: meetData.name ?? null,
        meetingUri: meetData.meetingUri ?? null,
      },
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  } catch (error) {
    return Response.json(
      {
        error: error instanceof Error ? error.message : "Unknown error",
      },
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
});

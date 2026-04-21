# create-google-meet

Supabase Edge Function untuk membuat link Google Meet via Google Meet REST API.

## Secrets yang wajib

Set di project Supabase kamu:

```bash
supabase secrets set GOOGLE_CLIENT_ID="..."
supabase secrets set GOOGLE_CLIENT_SECRET="..."
supabase secrets set GOOGLE_REFRESH_TOKEN="..."
```

## Deploy

```bash
supabase functions deploy create-google-meet
```

## Cara dapat refresh token

Paling cepat pakai OAuth Playground atau backend OAuth flow milikmu sendiri, lalu ambil refresh token dari akun Google yang akan jadi organizer meeting.

Scope yang dibutuhkan:

```text
https://www.googleapis.com/auth/meetings.space.created
```

## Invoke dari Flutter

Function name:

```text
create-google-meet
```

Payload:

```json
{
  "title": "Interview Online"
}
```

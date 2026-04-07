# uno

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# UNO + Supabase Quick Setup

1. Run SQL setup on Supabase:
   - Open SQL Editor
   - Execute [supabase/schema.sql](supabase/schema.sql)

2. Install dependencies:
```bash
flutter pub get
```

3. Run app with Supabase keys:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

4. What is connected:
   - Register/login with Supabase Auth (email + password)
   - Feed reads from `public.posts`
   - Create post writes to `public.posts`
   - Images upload to Storage bucket `post-images` with generated unique file names

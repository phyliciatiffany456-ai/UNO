-- Run this script in Supabase SQL Editor.
-- It creates:
-- 1) posts table
-- 2) RLS policies for authenticated users
-- 3) post-images storage bucket + policies

create extension if not exists "pgcrypto";

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  author_role text not null default 'UNO Member',
  content text not null,
  category text not null check (category in ('insight', 'short', 'job')),
  accessibility text not null default 'public' check (accessibility in ('public', 'private')),
  image_urls text[] not null default '{}',
  can_apply boolean not null default false,
  hide_like_view_count boolean not null default true,
  turn_off_commenting boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.posts enable row level security;

drop policy if exists "Anyone can read public posts" on public.posts;
create policy "Anyone can read public posts"
on public.posts
for select
to authenticated
using (accessibility = 'public' or auth.uid() = author_id);

drop policy if exists "Authenticated users can insert own posts" on public.posts;
create policy "Authenticated users can insert own posts"
on public.posts
for insert
to authenticated
with check (auth.uid() = author_id);

drop policy if exists "Users can update own posts" on public.posts;
create policy "Users can update own posts"
on public.posts
for update
to authenticated
using (auth.uid() = author_id)
with check (auth.uid() = author_id);

drop policy if exists "Users can delete own posts" on public.posts;
create policy "Users can delete own posts"
on public.posts
for delete
to authenticated
using (auth.uid() = author_id);

insert into storage.buckets (id, name, public)
values ('post-images', 'post-images', true)
on conflict (id) do nothing;

drop policy if exists "Post images are viewable by authenticated users" on storage.objects;
create policy "Post images are viewable by authenticated users"
on storage.objects
for select
to authenticated
using (bucket_id = 'post-images');

drop policy if exists "Authenticated users can upload post images" on storage.objects;
create policy "Authenticated users can upload post images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[2]
);

drop policy if exists "Users can update own post images" on storage.objects;
create policy "Users can update own post images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[2]
)
with check (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[2]
);

drop policy if exists "Users can delete own post images" on storage.objects;
create policy "Users can delete own post images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[2]
);

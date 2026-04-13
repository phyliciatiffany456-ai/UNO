-- Run this script in Supabase SQL Editor.
-- Re-run safely: most statements use IF NOT EXISTS or CREATE OR REPLACE.

create extension if not exists "pgcrypto";

-- =========================
-- Profiles
-- =========================
create table if not exists public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default 'User',
  role text not null default 'UNO Member',
  avatar_url text,
  bio text not null default 'Belum ada bio.',
  pronoun text not null default 'Ms.',
  gender text not null default 'Perempuan',
  education text not null default '-',
  work_experience text not null default '-',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles add column if not exists avatar_url text;

alter table public.profiles enable row level security;

drop policy if exists "Profiles are readable by authenticated users" on public.profiles;
create policy "Profiles are readable by authenticated users"
on public.profiles
for select
to authenticated
using (true);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
on public.profiles
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "Avatar images viewable by authenticated users" on storage.objects;
create policy "Avatar images viewable by authenticated users"
on storage.objects
for select
to authenticated
using (bucket_id = 'avatars');

drop policy if exists "Users can upload own avatar images" on storage.objects;
create policy "Users can upload own avatar images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can update own avatar images" on storage.objects;
create policy "Users can update own avatar images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- =========================
-- Follow / friendship
-- =========================
create table if not exists public.user_follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid not null references auth.users (id) on delete cascade,
  following_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (follower_id, following_id),
  check (follower_id <> following_id)
);

alter table public.user_follows enable row level security;

drop policy if exists "Users can read follows" on public.user_follows;
create policy "Users can read follows"
on public.user_follows
for select
to authenticated
using (true);

drop policy if exists "Users can follow from own account" on public.user_follows;
create policy "Users can follow from own account"
on public.user_follows
for insert
to authenticated
with check (auth.uid() = follower_id);

drop policy if exists "Users can unfollow from own account" on public.user_follows;
create policy "Users can unfollow from own account"
on public.user_follows
for delete
to authenticated
using (auth.uid() = follower_id);

create or replace function public.are_friends(user_a uuid, user_b uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.user_follows f1
    join public.user_follows f2
      on f2.follower_id = f1.following_id
     and f2.following_id = f1.follower_id
    where f1.follower_id = user_a
      and f1.following_id = user_b
  );
$$;

-- =========================
-- Posts
-- =========================
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
  job_title text,
  job_location text,
  job_domicile text,
  job_requirements text,
  job_deadline date,
  created_at timestamptz not null default now()
);
alter table public.posts add column if not exists job_title text;
alter table public.posts add column if not exists job_location text;
alter table public.posts add column if not exists job_domicile text;
alter table public.posts add column if not exists job_requirements text;
alter table public.posts add column if not exists job_deadline date;

alter table public.posts enable row level security;

drop policy if exists "Anyone can read accessible posts" on public.posts;
create policy "Anyone can read accessible posts"
on public.posts
for select
to authenticated
using (
  accessibility = 'public'
  or auth.uid() = author_id
  or (accessibility = 'private' and public.are_friends(auth.uid(), author_id))
);

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

-- =========================
-- Engagement (like/comment/share)
-- =========================
create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

alter table public.post_likes enable row level security;

drop policy if exists "Post likes readable" on public.post_likes;
create policy "Post likes readable"
on public.post_likes
for select
to authenticated
using (true);

drop policy if exists "Users can like as themselves" on public.post_likes;
create policy "Users can like as themselves"
on public.post_likes
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can unlike own likes" on public.post_likes;
create policy "Users can unlike own likes"
on public.post_likes
for delete
to authenticated
using (auth.uid() = user_id);

create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

alter table public.post_comments enable row level security;

drop policy if exists "Post comments readable" on public.post_comments;
create policy "Post comments readable"
on public.post_comments
for select
to authenticated
using (true);

drop policy if exists "Users can comment as themselves" on public.post_comments;
create policy "Users can comment as themselves"
on public.post_comments
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can edit own comments" on public.post_comments;
create policy "Users can edit own comments"
on public.post_comments
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own comments" on public.post_comments;
create policy "Users can delete own comments"
on public.post_comments
for delete
to authenticated
using (auth.uid() = user_id);

create table if not exists public.post_shares (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

alter table public.post_shares enable row level security;

drop policy if exists "Post shares readable" on public.post_shares;
create policy "Post shares readable"
on public.post_shares
for select
to authenticated
using (true);

drop policy if exists "Users can share as themselves" on public.post_shares;
create policy "Users can share as themselves"
on public.post_shares
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can unshare own shares" on public.post_shares;
create policy "Users can unshare own shares"
on public.post_shares
for delete
to authenticated
using (auth.uid() = user_id);

-- =========================
-- Storage: Post images
-- =========================
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
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can update own post images" on storage.objects;
create policy "Users can update own post images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can delete own post images" on storage.objects;
create policy "Users can delete own post images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'post-images'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- =========================
-- Job applications
-- =========================
create table if not exists public.job_applications (
  id uuid primary key default gen_random_uuid(),
  job_post_id uuid not null references public.posts (id) on delete cascade,
  applicant_id uuid not null references auth.users (id) on delete cascade,
  cv_file_name text not null,
  cv_storage_path text not null,
  cv_public_url text not null,
  status text not null default 'waiting_review' check (
    status in ('waiting_review', 'under_review', 'accepted', 'rejected')
  ),
  reviewer_id uuid references auth.users (id) on delete set null,
  reviewer_note text,
  reviewed_at timestamptz,
  interview_type text check (interview_type in ('onsite', 'online')),
  interview_location text,
  interview_link text,
  interview_at timestamptz,
  created_at timestamptz not null default now(),
  unique (job_post_id, applicant_id)
);
alter table public.job_applications
  add column if not exists reviewer_id uuid references auth.users (id) on delete set null;
alter table public.job_applications
  add column if not exists reviewer_note text;
alter table public.job_applications
  add column if not exists reviewed_at timestamptz;
alter table public.job_applications
  add column if not exists interview_type text;
alter table public.job_applications
  add column if not exists interview_location text;
alter table public.job_applications
  add column if not exists interview_link text;
alter table public.job_applications
  add column if not exists interview_at timestamptz;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'job_applications_interview_type_check'
      and conrelid = 'public.job_applications'::regclass
  ) then
    alter table public.job_applications
      add constraint job_applications_interview_type_check
      check (interview_type in ('onsite', 'online') or interview_type is null);
  end if;
end
$$;

alter table public.job_applications enable row level security;

drop policy if exists "Users can read visible applications" on public.job_applications;
create policy "Users can read visible applications"
on public.job_applications
for select
to authenticated
using (
  auth.uid() = applicant_id
  or exists (
    select 1
    from public.posts p
    where p.id = job_post_id and p.author_id = auth.uid()
  )
);

drop policy if exists "Users can insert own applications" on public.job_applications;
create policy "Users can insert own applications"
on public.job_applications
for insert
to authenticated
with check (
  auth.uid() = applicant_id
  and not exists (
    select 1
    from public.posts p
    where p.id = job_post_id
      and p.author_id = applicant_id
  )
);

drop policy if exists "Applicants can update own application file" on public.job_applications;
create policy "Applicants can update own application file"
on public.job_applications
for update
to authenticated
using (auth.uid() = applicant_id)
with check (
  auth.uid() = applicant_id
  and status in ('waiting_review', 'under_review')
);

drop policy if exists "Job owners can review applications" on public.job_applications;
create policy "Job owners can review applications"
on public.job_applications
for update
to authenticated
using (
  exists (
    select 1
    from public.posts p
    where p.id = job_post_id and p.author_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.posts p
    where p.id = job_post_id and p.author_id = auth.uid()
  )
);

create or replace function public.owner_update_application_status(
  target_application_id uuid,
  new_status text,
  new_note text default null
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid;
  target_job_post_id uuid;
  target_owner_id uuid;
begin
  current_uid := auth.uid();
  if current_uid is null then
    raise exception 'not_authenticated';
  end if;

  if new_status not in ('waiting_review', 'under_review', 'accepted', 'rejected') then
    raise exception 'invalid_status';
  end if;

  select ja.job_post_id
  into target_job_post_id
  from public.job_applications ja
  where ja.id = target_application_id
  limit 1;

  if target_job_post_id is null then
    raise exception 'application_not_found';
  end if;

  select p.author_id
  into target_owner_id
  from public.posts p
  where p.id = target_job_post_id
  limit 1;

  if target_owner_id is null or target_owner_id <> current_uid then
    raise exception 'not_job_owner';
  end if;

  update public.job_applications
  set
    status = new_status,
    reviewer_id = current_uid,
    reviewer_note = new_note,
    reviewed_at = now()
  where id = target_application_id;

  return true;
end;
$$;

revoke all on function public.owner_update_application_status(uuid, text, text) from public;
grant execute on function public.owner_update_application_status(uuid, text, text) to authenticated;

insert into storage.buckets (id, name, public)
values ('job-cvs', 'job-cvs', true)
on conflict (id) do nothing;

drop policy if exists "Authenticated users can view cvs" on storage.objects;
create policy "Authenticated users can view cvs"
on storage.objects
for select
to authenticated
using (bucket_id = 'job-cvs');

drop policy if exists "Authenticated users can upload own cvs" on storage.objects;
create policy "Authenticated users can upload own cvs"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'job-cvs'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Authenticated users can update own cvs" on storage.objects;
create policy "Authenticated users can update own cvs"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'job-cvs'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'job-cvs'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Authenticated users can delete own cvs" on storage.objects;
create policy "Authenticated users can delete own cvs"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'job-cvs'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- =========================
-- Community chat (group and private rooms)
-- =========================
create table if not exists public.chat_rooms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  is_group boolean not null default false,
  created_by uuid references auth.users (id) on delete set null,
  room_code text,
  created_at timestamptz not null default now()
);
alter table public.chat_rooms
  add column if not exists is_group boolean not null default false;
alter table public.chat_rooms
  add column if not exists created_by uuid references auth.users (id) on delete set null;
alter table public.chat_rooms
  add column if not exists room_code text;
alter table public.chat_rooms
  add column if not exists created_at timestamptz not null default now();

create table if not exists public.chat_room_members (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.chat_rooms (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (room_id, user_id)
);
alter table public.chat_room_members
  add column if not exists created_at timestamptz not null default now();

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.chat_rooms (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);
alter table public.chat_messages
  add column if not exists created_at timestamptz not null default now();

update public.chat_rooms
set room_code = upper(substr(replace(id::text, '-', ''), 1, 8))
where room_code is null or btrim(room_code) = '';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'chat_rooms_room_code_key'
      and conrelid = 'public.chat_rooms'::regclass
  ) then
    alter table public.chat_rooms
      add constraint chat_rooms_room_code_key unique (room_code);
  end if;
end
$$;

alter table public.chat_rooms enable row level security;
alter table public.chat_room_members enable row level security;
alter table public.chat_messages enable row level security;

create or replace function public.is_chat_room_member(
  target_room_id uuid,
  target_user_id uuid default auth.uid()
)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.chat_room_members m
    where m.room_id = target_room_id
      and m.user_id = target_user_id
  );
$$;

revoke all on function public.is_chat_room_member(uuid, uuid) from public;
grant execute on function public.is_chat_room_member(uuid, uuid) to authenticated;

drop policy if exists "Members can read rooms" on public.chat_rooms;
create policy "Members can read rooms"
on public.chat_rooms
for select
to authenticated
using (
  public.is_chat_room_member(id, auth.uid())
);

drop policy if exists "Authenticated can create rooms" on public.chat_rooms;
create policy "Authenticated can create rooms"
on public.chat_rooms
for insert
to authenticated
with check (auth.uid() = created_by or created_by is null);

drop policy if exists "Members can read memberships" on public.chat_room_members;
create policy "Members can read memberships"
on public.chat_room_members
for select
to authenticated
using (
  user_id = auth.uid()
  or public.is_chat_room_member(room_id, auth.uid())
);

drop policy if exists "Users can join self to room" on public.chat_room_members;
create policy "Users can join self to room"
on public.chat_room_members
for insert
to authenticated
with check (user_id = auth.uid());

create or replace function public.create_group_room(
  target_room_name text,
  member_ids uuid[] default '{}'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid;
  created_room_id uuid;
  target_member_id uuid;
  clean_room_name text;
begin
  current_uid := auth.uid();
  if current_uid is null then
    raise exception 'not_authenticated';
  end if;

  clean_room_name := coalesce(nullif(trim(target_room_name), ''), 'Grup Baru');

  insert into public.chat_rooms(name, is_group, created_by)
  values (clean_room_name, true, current_uid)
  returning id into created_room_id;

  insert into public.chat_room_members(room_id, user_id)
  values (created_room_id, current_uid)
  on conflict (room_id, user_id) do nothing;

  foreach target_member_id in array coalesce(member_ids, '{}') loop
    if target_member_id is not null and target_member_id <> current_uid then
      insert into public.chat_room_members(room_id, user_id)
      values (created_room_id, target_member_id)
      on conflict (room_id, user_id) do nothing;
    end if;
  end loop;

  return created_room_id;
end;
$$;

revoke all on function public.create_group_room(text, uuid[]) from public;
grant execute on function public.create_group_room(text, uuid[]) to authenticated;

create or replace function public.create_group_room(
  target_room_name text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid;
  created_room_id uuid;
  generated_room_code text;
  clean_room_name text;
begin
  current_uid := auth.uid();
  if current_uid is null then
    raise exception 'not_authenticated';
  end if;

  clean_room_name := coalesce(nullif(trim(target_room_name), ''), 'Grup Baru');
  generated_room_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));

  insert into public.chat_rooms(name, is_group, created_by, room_code)
  values (clean_room_name, true, current_uid, generated_room_code)
  returning id into created_room_id;

  insert into public.chat_room_members(room_id, user_id)
  values (created_room_id, current_uid)
  on conflict (room_id, user_id) do nothing;

  return created_room_id;
end;
$$;

revoke all on function public.create_group_room(text) from public;
grant execute on function public.create_group_room(text) to authenticated;

create or replace function public.invite_users_to_group(
  target_room_id uuid,
  member_ids uuid[]
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid;
  target_member_id uuid;
  room_owner_id uuid;
  room_is_group boolean;
begin
  current_uid := auth.uid();
  if current_uid is null then
    raise exception 'not_authenticated';
  end if;

  select created_by, is_group
  into room_owner_id, room_is_group
  from public.chat_rooms
  where id = target_room_id
  limit 1;

  if room_owner_id is null then
    raise exception 'room_not_found';
  end if;

  if room_is_group is distinct from true then
    raise exception 'room_is_not_group';
  end if;

  if room_owner_id <> current_uid then
    raise exception 'not_group_owner';
  end if;

  foreach target_member_id in array coalesce(member_ids, '{}') loop
    if target_member_id is not null then
      insert into public.chat_room_members(room_id, user_id)
      values (target_room_id, target_member_id)
      on conflict (room_id, user_id) do nothing;
    end if;
  end loop;

  return true;
end;
$$;

revoke all on function public.invite_users_to_group(uuid, uuid[]) from public;
grant execute on function public.invite_users_to_group(uuid, uuid[]) to authenticated;

create or replace function public.join_group_by_code(
  target_room_code text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid;
  found_room_id uuid;
begin
  current_uid := auth.uid();
  if current_uid is null then
    raise exception 'not_authenticated';
  end if;

  select id
  into found_room_id
  from public.chat_rooms
  where room_code = upper(trim(target_room_code))
    and is_group = true
  limit 1;

  if found_room_id is null then
    raise exception 'group_not_found';
  end if;

  insert into public.chat_room_members(room_id, user_id)
  values (found_room_id, current_uid)
  on conflict (room_id, user_id) do nothing;

  return found_room_id;
end;
$$;

revoke all on function public.join_group_by_code(text) from public;
grant execute on function public.join_group_by_code(text) to authenticated;

create or replace function public.ensure_direct_room(
  target_user_id uuid,
  target_room_name text default 'Direct Chat'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid;
  found_room_id uuid;
  final_name text;
begin
  current_uid := auth.uid();
  if current_uid is null then
    raise exception 'not_authenticated';
  end if;

  if target_user_id is null or target_user_id = current_uid then
    raise exception 'invalid_target_user';
  end if;

  select r.id
  into found_room_id
  from public.chat_rooms r
  where r.is_group = false
    and exists (
      select 1 from public.chat_room_members m
      where m.room_id = r.id and m.user_id = current_uid
    )
    and exists (
      select 1 from public.chat_room_members m
      where m.room_id = r.id and m.user_id = target_user_id
    )
    and not exists (
      select 1 from public.chat_room_members m
      where m.room_id = r.id
        and m.user_id not in (current_uid, target_user_id)
    )
  limit 1;

  if found_room_id is not null then
    return found_room_id;
  end if;

  final_name := coalesce(nullif(trim(target_room_name), ''), 'Direct Chat');

  insert into public.chat_rooms(name, is_group, created_by)
  values (final_name, false, current_uid)
  returning id into found_room_id;

  insert into public.chat_room_members(room_id, user_id)
  values (found_room_id, current_uid)
  on conflict (room_id, user_id) do nothing;

  insert into public.chat_room_members(room_id, user_id)
  values (found_room_id, target_user_id)
  on conflict (room_id, user_id) do nothing;

  return found_room_id;
end;
$$;

revoke all on function public.ensure_direct_room(uuid, text) from public;
grant execute on function public.ensure_direct_room(uuid, text) to authenticated;

drop policy if exists "Members can read room messages" on public.chat_messages;
create policy "Members can read room messages"
on public.chat_messages
for select
to authenticated
using (
  public.is_chat_room_member(chat_messages.room_id, auth.uid())
);

drop policy if exists "Members can send messages" on public.chat_messages;
create policy "Members can send messages"
on public.chat_messages
for insert
to authenticated
with check (
  sender_id = auth.uid()
  and public.is_chat_room_member(chat_messages.room_id, auth.uid())
);

-- =========================
-- Prototype reset password (no SMTP)
-- =========================
create or replace function public.prototype_reset_password_by_email(
  target_email text,
  new_password text
)
returns boolean
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  target_user_id uuid;
begin
  if target_email is null or new_password is null then
    return false;
  end if;

  if length(trim(new_password)) < 6 then
    return false;
  end if;

  select id
  into target_user_id
  from auth.users
  where email = lower(trim(target_email))
  limit 1;

  if target_user_id is null then
    return false;
  end if;

  update auth.users
  set
    encrypted_password = crypt(new_password, gen_salt('bf')),
    updated_at = now()
  where id = target_user_id;

  return true;
end;
$$;

revoke all on function public.prototype_reset_password_by_email(text, text) from public;
grant execute on function public.prototype_reset_password_by_email(text, text) to anon, authenticated;

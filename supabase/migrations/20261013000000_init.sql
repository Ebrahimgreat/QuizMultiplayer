-- Initial schema for Quiz Multiplayer.

-- Profiles: one per auth user. Created automatically on signup (see trigger below).
create table public.profiles (
  id bigint generated always as identity primary key,
  user_id uuid not null unique references auth.users (id) on delete cascade,
  name text,
  role text check (role in ('player', 'content Creater')),
  created_at timestamptz not null default now()
);

-- Stats: points / games played per profile, used by home and leaderboard.
create table public.stats (
  id bigint generated always as identity primary key,
  user_profile_id bigint not null unique references public.profiles (id) on delete cascade,
  points integer not null default 0,
  games_played integer not null default 0
);

create table public.quiz (
  id bigint generated always as identity primary key,
  name text not null,
  quiz_category integer,
  users_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table public.quiz_question (
  id bigint generated always as identity primary key,
  quiz_id bigint not null references public.quiz (id) on delete cascade,
  question text not null
);

create table public.quiz_answer (
  id bigint generated always as identity primary key,
  question_id bigint not null references public.quiz_question (id) on delete cascade,
  answer text
);

create table public.quiz_options (
  id bigint generated always as identity primary key,
  quiz_questions bigint not null references public.quiz_question (id) on delete cascade,
  "A" text,
  "B" text,
  "C" text,
  "D" text
);

create table public.challenge (
  id bigint generated always as identity primary key,
  quiz_id bigint references public.quiz (id) on delete cascade,
  challenger_id bigint references public.profiles (id) on delete cascade,
  reciever_id bigint references public.profiles (id) on delete cascade,
  challenger_score numeric,
  reciever_score numeric,
  winner bigint references public.profiles (id),
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table public.lobby (
  id bigint generated always as identity primary key,
  user_profile_id bigint not null references public.profiles (id) on delete cascade,
  lobby_name text not null,
  created_at timestamptz not null default now()
);

-- Create profile + stats row whenever someone signs up.
-- name/role come from the metadata passed to supabase.auth.signUp in register.vue.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  new_profile_id bigint;
begin
  insert into public.profiles (user_id, name, role)
  values (new.id, new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'role')
  returning id into new_profile_id;

  insert into public.stats (user_profile_id) values (new_profile_id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Called from lobby.vue and quizTaking.vue to add points after a game.
create function public.update_stats(profile_id bigint, points_to_add integer, games_to_add integer)
returns void
language sql
security definer set search_path = public
as $$
  update public.stats
  set points = points + points_to_add,
      games_played = games_played + games_to_add
  where user_profile_id = profile_id;
$$;

-- Row level security: signed-in users can read everything; writes are limited
-- to what the client code actually does.
alter table public.profiles enable row level security;
alter table public.stats enable row level security;
alter table public.quiz enable row level security;
alter table public.quiz_question enable row level security;
alter table public.quiz_answer enable row level security;
alter table public.quiz_options enable row level security;
alter table public.challenge enable row level security;
alter table public.lobby enable row level security;

create policy "read profiles" on public.profiles for select to authenticated using (true);
create policy "update own profile" on public.profiles for update to authenticated using (user_id = auth.uid());

create policy "read stats" on public.stats for select to authenticated using (true);

create policy "read quizzes" on public.quiz for select to authenticated using (true);
create policy "create own quiz" on public.quiz for insert to authenticated with check (users_id = auth.uid());
create policy "update own quiz" on public.quiz for update to authenticated using (users_id = auth.uid());

create policy "read questions" on public.quiz_question for select to authenticated using (true);
create policy "add questions to own quiz" on public.quiz_question for insert to authenticated
  with check (exists (select 1 from public.quiz q where q.id = quiz_id and q.users_id = auth.uid()));

create policy "read answers" on public.quiz_answer for select to authenticated using (true);
create policy "add answers to own quiz" on public.quiz_answer for insert to authenticated
  with check (exists (
    select 1 from public.quiz_question qq join public.quiz q on q.id = qq.quiz_id
    where qq.id = question_id and q.users_id = auth.uid()
  ));

create policy "read options" on public.quiz_options for select to authenticated using (true);
create policy "add options to own quiz" on public.quiz_options for insert to authenticated
  with check (exists (
    select 1 from public.quiz_question qq join public.quiz q on q.id = qq.quiz_id
    where qq.id = quiz_questions and q.users_id = auth.uid()
  ));

create policy "read challenges" on public.challenge for select to authenticated using (true);
create policy "create challenges" on public.challenge for insert to authenticated with check (true);
create policy "update challenges" on public.challenge for update to authenticated using (true);

create policy "read lobby" on public.lobby for select to authenticated using (true);
create policy "join lobby" on public.lobby for insert to authenticated
  with check (exists (select 1 from public.profiles p where p.id = user_profile_id and p.user_id = auth.uid()));

-- lobby.vue listens for INSERTs on this table.
alter publication supabase_realtime add table public.lobby;

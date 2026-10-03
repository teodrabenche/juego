-- Applied to the Supabase project "juego" (zcpjjwrbowxsgfefgovf)
create table public.players (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 30),
  team int,
  created_at timestamptz not null default now()
);
create unique index players_name_key on public.players (lower(name));

create table public.scores (
  player_id uuid not null references public.players(id) on delete cascade,
  round int not null check (round between 1 and 6),
  points int not null default 0,
  primary key (player_id, round)
);

create table public.game (
  id int primary key default 1 check (id = 1),
  phase text not null default 'lobby',
  round int not null default 0,
  round_title text,
  captains uuid[] not null default '{}',
  pick_turn int not null default 0,
  team_game int not null default 0,
  team_results jsonb not null default '{}',
  updated_at timestamptz not null default now()
);
insert into public.game default values;

alter table public.players enable row level security;
alter table public.scores enable row level security;
alter table public.game enable row level security;

create policy "players all" on public.players for all to anon, authenticated using (true) with check (true);
create policy "scores all" on public.scores for all to anon, authenticated using (true) with check (true);
create policy "game read" on public.game for select to anon, authenticated using (true);
create policy "game update" on public.game for update to anon, authenticated using (true) with check (true);

create or replace function public.pick_player(p_captain uuid, p_player uuid)
returns void language plpgsql security definer set search_path = public as $$
declare g public.game;
begin
  select * into g from public.game where id = 1 for update;
  if g.phase <> 'draft' then raise exception 'Ahora no se está eligiendo'; end if;
  if g.captains[g.pick_turn + 1] is distinct from p_captain then raise exception 'No es tu turno'; end if;
  update public.players set team = g.pick_turn + 1 where id = p_player and team is null;
  if not found then raise exception 'Ese jugador ya está elegido'; end if;
  if exists (select 1 from public.players where team is null) then
    update public.game set pick_turn = 1 - g.pick_turn, updated_at = now() where id = 1;
  else
    update public.game set phase = 'teams', updated_at = now() where id = 1;
  end if;
end $$;
grant execute on function public.pick_player(uuid, uuid) to anon, authenticated;

alter publication supabase_realtime add table public.players, public.scores, public.game;

-- v2: 6 rondas con juegos fijos, textos (Exposed / Confesión) y votos
alter table public.game add column if not exists stage text not null default 'play';
alter table public.game add column if not exists step int not null default 0;
alter table public.game add column if not exists reveal boolean not null default false;
alter table public.game add column if not exists awarded text[] not null default '{}';

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  round int not null,
  player_id uuid not null references public.players(id) on delete cascade,
  slot int not null default 0,
  text text not null check (char_length(text) between 1 and 300),
  sort_key double precision not null default random(),
  created_at timestamptz not null default now(),
  unique (round, player_id, slot)
);

create table public.guesses (
  submission_id uuid not null references public.submissions(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  guess uuid not null references public.players(id) on delete cascade,
  primary key (submission_id, player_id)
);

alter table public.submissions enable row level security;
alter table public.guesses enable row level security;
create policy "submissions all" on public.submissions for all to anon, authenticated using (true) with check (true);
create policy "guesses all" on public.guesses for all to anon, authenticated using (true) with check (true);

create or replace function public.add_points(p_player uuid, p_round int, p_delta int)
returns void language sql security definer set search_path = public as $$
  insert into public.scores (player_id, round, points) values (p_player, p_round, p_delta)
  on conflict (player_id, round) do update set points = public.scores.points + excluded.points;
$$;
grant execute on function public.add_points(uuid, int, int) to anon, authenticated;

alter publication supabase_realtime add table public.submissions, public.guesses;

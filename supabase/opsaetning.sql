-- Månedens Verdensoverblik – live-afstemning
-- Kør én gang i Supabase → SQL Editor → New query → Run

create table if not exists public.votes (
  id         bigserial primary key,
  poll       text not null check (char_length(poll) between 1 and 20),
  story      text not null check (char_length(story) between 1 and 40),
  device     text not null check (char_length(device) between 8 and 64),
  created_at timestamptz not null default now(),
  unique (poll, device)              -- én stemme pr. telefon pr. måned
);

alter table public.votes enable row level security;

-- Alle må se resultaterne
drop policy if exists "laes stemmer" on public.votes;
create policy "laes stemmer" on public.votes for select to anon, authenticated using (true);

-- Alle må afgive en stemme – men ikke ændre eller slette
drop policy if exists "afgiv stemme" on public.votes;
create policy "afgiv stemme" on public.votes for insert to anon, authenticated with check (true);

-- Live-opdatering på storskærmen
alter publication supabase_realtime add table public.votes;

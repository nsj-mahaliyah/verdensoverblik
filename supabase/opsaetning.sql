-- Månedens Verdensoverblik – live-afstemning
-- ALLEREDE KØRT i projektet NSJMahaliyah (15.11.2026) – gemt her som dokumentation.

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
create policy "afgiv stemme" on public.votes for insert to anon, authenticated
  with check (poll ~ '^[0-9]{4}-[0-9]{2}$' and story ~ '^[a-z0-9-]+$');

-- Live-opdatering på storskærmen
alter publication supabase_realtime add table public.votes;

-- ── Tilføjet 15.11.2026: start/stop/nulstil med kode ──
-- Tabel vo_state (poll, open, round) styrer om afstemningen er åben.
-- votes har kolonnen round; unik pr. (poll, round, device). Stemmer kun tilladt når vo_state.open og round passer.
-- RPC: vo_start(p_poll) · vo_stop(p_poll, p_code) · vo_reset(p_poll, p_code)  (nulstil sletter alle stemmer og hæver round)
-- Koden ligger kun som bcrypt-hash i skemaet vo_private (ikke tilgængeligt via API). Skift kode:
--   update vo_private.admin set code_hash = extensions.crypt('NY_KODE', extensions.gen_salt('bf')) where id = 1;

-- ── Tilføjet 15.11.2026: skift stemme ──
-- Stemmer afgives via RPC vo_vote(p_poll, p_round, p_story, p_device) – opretter eller ændrer telefonens stemme (kun når åben).
-- anon kan kun læse kolonnerne id, poll, round, story, created_at (ikke telefon-id) og kan ikke skrive direkte i votes.

-- ── Tilføjet 15.11.2026: anonyme spørgsmål med godkendelse ──
-- Tabel vo_questions (poll, text, device, status afventer/godkendt/afvist). Publikum kan kun læse godkendte (uden telefon-id).
-- vo_state.shown_q = spørgsmålet der vises på storskærmen.
-- RPC: vo_ask(p_poll, p_text, p_device)  (maks 3 pr. telefon pr. 10 min)
--      vo_q_list(p_poll, p_code) · vo_q_decide(p_id, p_status, p_code) · vo_q_show(p_poll, p_id|null, p_code)
-- vo_q_reset(p_poll, p_code): sletter alle spørgsmål for måneden og fjerner spørgsmålet fra skærmen. vo_reset rydder nu også shown_q.

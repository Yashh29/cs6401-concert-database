-- ============================================================
-- CS6401 Database Systems Project
-- File: tests.sql
-- Target DBMS: MySQL
-- Run after modified_concerts_schema.sql, data.sql, and code.sql.
-- These tests are designed for the expanded dataset as well as
-- the original seed data. Test fixture IDs use high values.
-- ============================================================

USE cs6401_concerts;

-- IMPORTANT:
-- Some statements below intentionally raise errors. Execute each
-- marked "RUN SEPARATELY" statement individually in DBeaver so one
-- expected error does not stop the remaining tests.
-- Run TEST CLEANUP at the end. If a fixture transaction is interrupted,
-- run cleanup before rerunning the file. Expected-error statements must be
-- run individually; do not select/run the entire file as one batch.

-- ============================================================
-- TEST V1: View returns qualifying concerts.
-- The view should include concerts with at least two reserved seats
-- and should report distinct artists and distinct reserved fans.
-- Result values depend on which dataset (seed or expanded) is loaded.
-- ============================================================

SELECT *
FROM vw_concert_summary
ORDER BY concert_id
LIMIT 20;

-- TEST V1b: Explicitly inspect a qualifying concert.
-- Expected: concert 1 appears if it has at least two reserved seats.
SELECT *
FROM vw_concert_summary
WHERE concert_id = 1;

-- ============================================================
-- TEST V2: HAVING condition excludes a concert with no seats.
-- Concert 301 is deliberately created by data_expanded.sql without
-- tickets; in the small seed data, use concert 3 if it has no seats.
-- Expected: zero rows for the selected no-seat concert.
-- ============================================================

SELECT *
FROM vw_concert_summary
WHERE concert_id = 301;

-- ============================================================
-- TEST F1: Existing concert with no tickets/seats returns zero.
-- Expected: 0 for concert 301 in the expanded dataset.
-- ============================================================

SELECT fn_reserved_seats(301) AS seats_for_concert_without_tickets;

-- ============================================================
-- TEST F2: Ticket with three fans contributes three seats.
-- In the seed dataset ticket 1 has three fans. In the expanded
-- dataset the original seed rows are retained.
-- Expected: 3.
-- ============================================================

SELECT COUNT(*) AS seats_on_ticket_1
FROM ticket_fans
WHERE ticket_id = 1;

-- ============================================================
-- TEST F3: Several tickets for a concert are counted together.
-- Expected: result equals the number of ticket_fans rows for concert 1.
-- ============================================================

SELECT
    fn_reserved_seats(1) AS function_result,
    (
        SELECT COUNT(*)
        FROM tickets AS t
        JOIN ticket_fans AS tf ON tf.ticket_id = t.ticket_id
        WHERE t.concert_id = 1
    ) AS direct_count;

-- TEST F4: Nonexistent concert ID.
-- Expected: SQL error "Concert does not exist".
-- RUN SEPARATELY.
SELECT fn_reserved_seats(999999999);

-- ============================================================
-- TEST P1: Missing association; insert it and update a later song
-- release date to the earlier album release date.
-- A dedicated fixture ensures this works with either dataset.
-- Expected: association exists with track number 1; song date becomes
-- 2020-01-01. The transaction is rolled back after inspection.
-- ============================================================

START TRANSACTION;

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9000001, 'Test Artist P1', 'Test', 2020);

INSERT INTO albums (album_id, album_title, release_date)
VALUES (9000001, 'Test Album P1', '2020-01-01');

INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES (9000001, 'Test Song P1', 180, '2022-01-01');

CALL sp_add_song_to_album(9000001, 9000001);

SELECT *
FROM album_songs
WHERE song_id = 9000001 AND album_id = 9000001;

SELECT song_id, song_title, release_date
FROM songs
WHERE song_id = 9000001;

ROLLBACK;

-- ============================================================
-- TEST P2: Existing association is not duplicated, and an earlier
-- song release date is not changed.
-- Expected: association_count = 1; release date remains 2019-01-01.
-- ============================================================

START TRANSACTION;

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9000002, 'Test Artist P2', 'Test', 2020);

INSERT INTO albums (album_id, album_title, release_date)
VALUES (9000002, 'Test Album P2', '2020-01-01');

INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES (9000002, 'Test Song P2', 180, '2019-01-01');

INSERT INTO album_songs (album_id, song_id, track_number)
VALUES (9000002, 9000002, 1);

CALL sp_add_song_to_album(9000002, 9000002);

SELECT COUNT(*) AS association_count
FROM album_songs
WHERE song_id = 9000002 AND album_id = 9000002;

SELECT release_date
FROM songs
WHERE song_id = 9000002;

ROLLBACK;

-- ============================================================
-- TEST P3: Song date NULL; procedure inserts association but leaves
-- the missing date unchanged.
-- Expected: association exists and release_date remains NULL.
-- ============================================================

START TRANSACTION;

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9000003, 'Test Artist P3', 'Test', 2020);

INSERT INTO albums (album_id, album_title, release_date)
VALUES (9000003, 'Test Album P3', '2020-01-01');

INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES (9000003, 'Test Song P3', 180, NULL);

CALL sp_add_song_to_album(9000003, 9000003);

SELECT *
FROM album_songs
WHERE song_id = 9000003 AND album_id = 9000003;

SELECT release_date
FROM songs
WHERE song_id = 9000003;

ROLLBACK;

-- TEST P4: Album release date NULL; procedure inserts the association
-- but does not change the song's known release date.
-- Expected: association exists and song date remains 2019-01-01.
START TRANSACTION;

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9000005, 'Test Artist P4', 'Test', 2020);

INSERT INTO albums (album_id, album_title, release_date)
VALUES (9000005, 'Test Album P4', NULL);

INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES (9000005, 'Test Song P4', 180, '2019-01-01');

CALL sp_add_song_to_album(9000005, 9000005);

SELECT *
FROM album_songs
WHERE song_id = 9000005 AND album_id = 9000005;

SELECT release_date
FROM songs
WHERE song_id = 9000005;

ROLLBACK;

-- TEST P5: Invalid song identifier. Expected error:
-- "Song recording does not exist". RUN SEPARATELY.
CALL sp_add_song_to_album(999999999, 1);

-- TEST P6: Invalid album identifier. Expected error:
-- "Album does not exist". RUN SEPARATELY.
CALL sp_add_song_to_album(1, 999999999);

-- TEST P7: Repeat call should not create a duplicate association.
-- This fixture checks repeatability; the procedure is called twice.
-- Expected: association_count = 1.
START TRANSACTION;

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9000004, 'Test Artist P6', 'Test', 2020);

INSERT INTO albums (album_id, album_title, release_date)
VALUES (9000004, 'Test Album P6', '2020-01-01');

INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES (9000004, 'Test Song P6', 180, '2019-01-01');

CALL sp_add_song_to_album(9000004, 9000004);
CALL sp_add_song_to_album(9000004, 9000004);

SELECT COUNT(*) AS association_count
FROM album_songs
WHERE song_id = 9000004 AND album_id = 9000004;

ROLLBACK;

-- ============================================================
-- TEST T1 and T2: BEFORE and AFTER triggers.
-- Insert two tickets for the same concert and a test fan. The first
-- reservation should succeed and create an audit row. The second
-- reservation for the same fan/concert should be rejected.
-- Use high fixture IDs to avoid collisions with generated data.
-- ============================================================

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES (9000010, 'Trigger Test Artist', 'Test', 2020);

INSERT INTO concerts (concert_id, concert_title, location, date_of_concert)
VALUES (9000010, 'Trigger Test Concert', 'Limerick', '2027-06-01');

INSERT INTO concert_artists (concert_id, artist_id)
VALUES (9000010, 9000010);

INSERT INTO fans (fan_id, fan_name, fan_email, age)
VALUES (9000010, 'Trigger Test Fan', 'trigger-test-9000010@example.com', 30);

INSERT INTO tickets (ticket_id, concert_id, purchase_date, ticket_price)
VALUES
    (9000010, 9000010, '2026-10-17', 45.00),
    (9000011, 9000010, '2026-10-17', 45.00);

-- TEST T1: Expected to succeed and create RESERVATION_CREATED audit row.
INSERT INTO ticket_fans (ticket_id, fan_id, seat_zone, seat_number)
VALUES (9000010, 9000010, 'C', '01');

SELECT *
FROM reservation_audit
WHERE ticket_id = 9000010
  AND fan_id = 9000010
  AND action_type = 'RESERVATION_CREATED';

-- TEST T2: Expected error "Fan already has a reservation for this concert".
-- RUN SEPARATELY; run only after the first reservation above succeeds.
INSERT INTO ticket_fans (ticket_id, fan_id, seat_zone, seat_number)
VALUES (9000011, 9000010, 'C', '02');

-- ============================================================
-- TEST I1: Representative integrity constraints.
-- Each statement below is expected to fail; run each separately.
-- ============================================================

-- Invalid foreign key: artist ID does not exist. Expected FK error.
INSERT INTO concert_artists (concert_id, artist_id)
VALUES (9000010, 999999999);

-- Duplicate primary key in album_songs. Expected duplicate-key error.
-- Run only if TEST P1 fixture has not been rolled back or use an existing
-- valid association from the loaded dataset.
INSERT INTO album_songs (album_id, song_id, track_number)
VALUES (1, 1, 999);

-- Invalid duration (CHECK duration_seconds > 0). Expected CHECK error.
INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES (9000099, 'Invalid Duration Test', 0, '2020-01-01');

-- ============================================================
-- TEST CLEANUP
-- Run after recording results. Safe to rerun if rows are already gone.
-- Delete children before parents.
-- ============================================================

DELETE FROM ticket_fans WHERE ticket_id IN (9000010, 9000011);
DELETE FROM reservation_audit WHERE ticket_id IN (9000010, 9000011);
DELETE FROM tickets WHERE ticket_id IN (9000010, 9000011);
DELETE FROM fans WHERE fan_id = 9000010;
DELETE FROM concert_artists WHERE concert_id = 9000010;
DELETE FROM concerts WHERE concert_id = 9000010;
DELETE FROM artists WHERE artist_id IN (9000001, 9000002, 9000003, 9000004, 9000005, 9000010);
DELETE FROM album_songs WHERE album_id IN (9000001, 9000002, 9000003, 9000004, 9000005)
    OR song_id IN (9000001, 9000002, 9000003, 9000004, 9000005);
DELETE FROM songs WHERE song_id IN (9000001, 9000002, 9000003, 9000004, 9000005, 9000099);
DELETE FROM albums WHERE album_id IN (9000001, 9000002, 9000003, 9000004, 9000005);

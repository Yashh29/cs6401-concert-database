-- ============================================================
-- CS6401 Database Systems Project
-- File: data.sql
-- Purpose: reproducible synthetic dataset for the modified schema
-- Target DBMS: MySQL 9.7
-- Duration unit: seconds | Currency: EUR
--
-- IMPORTANT:
-- This script clears existing project data. Run only when you intend
-- to replace the current dataset. Run modified_concerts_schema.sql first.
--
-- Expected target: 71,502 rows across the 14 tables before test-generated audit rows.
-- IDs 1-4 and the first few records retain deliberate test cases.
-- ============================================================

USE cs6401_concerts;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE reservation_audit;
TRUNCATE TABLE ticket_fans;
TRUNCATE TABLE tickets;
TRUNCATE TABLE fan_favourite_artists;
TRUNCATE TABLE concert_songs;
TRUNCATE TABLE concert_artists;
TRUNCATE TABLE album_songs;
TRUNCATE TABLE song_artists;
TRUNCATE TABLE album_artists;
TRUNCATE TABLE fans;
TRUNCATE TABLE concerts;
TRUNCATE TABLE songs;
TRUNCATE TABLE albums;
TRUNCATE TABLE artists;
SET FOREIGN_KEY_CHECKS = 1;

-- Number sequences are generated inline in each INSERT statement.
-- This avoids temporary/helper-table session issues in DBeaver.

-- 1. Artists: 100 total, including four named seed artists.
INSERT INTO artists (artist_id, artist_name, genre, debut_year)
VALUES
    (1, 'Aurora Lane', 'Indie Pop', 2015),
    (2, 'The Northern Lights', 'Alternative Rock', 2012),
    (3, 'Maya Rivers', 'Pop', 2018),
    (4, 'Echo Harbour', 'Electronic', 2016);

INSERT INTO artists (artist_id, artist_name, genre, debut_year)
SELECT n + 4,
       CONCAT('Artist ', LPAD(n + 4, 4, '0')),
       ELT(MOD(n, 8) + 1, 'Pop', 'Rock', 'Indie', 'Electronic',
           'Jazz', 'Folk', 'Alternative', 'R&B'),
       1980 + MOD(n * 7, 45)
FROM (
    SELECT ones.n + tens.n * 10 + hundreds.n * 100 + thousands.n * 1000 + 1 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
          UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
          UNION ALL SELECT 8 UNION ALL SELECT 9) ones
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) tens
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) hundreds
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) thousands
) AS _load_numbers
WHERE n BETWEEN 1 AND 96;

-- 2. Albums: 500 total.
INSERT INTO albums (album_id, album_title, release_date)
VALUES
    (1, 'Midnight Skies', '2022-05-10'),
    (2, 'Live at the Harbour', '2023-08-20'),
    (3, 'Acoustic Sessions', '2024-02-15');

INSERT INTO albums (album_id, album_title, release_date)
SELECT n + 3,
       CONCAT('Album Collection ', LPAD(n + 3, 4, '0')),
       DATE_ADD('2010-01-01', INTERVAL MOD(n * 37, 5500) DAY)
FROM (
    SELECT ones.n + tens.n * 10 + hundreds.n * 100 + thousands.n * 1000 + 1 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
          UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
          UNION ALL SELECT 8 UNION ALL SELECT 9) ones
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) tens
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) hundreds
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) thousands
) AS _load_numbers
WHERE n BETWEEN 1 AND 497;

-- 3. Song recordings: 3,000 total. Song IDs represent distinct recordings.
INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
VALUES
    (1, 'Open Roads', 215, '2021-11-12'),
    (2, 'City Lights', 198, '2022-01-20'),
    (3, 'Northern Wind', 242, '2022-04-01'),
    (4, 'Open Roads', 220, '2023-03-15'),
    (5, 'Quiet Harbour', 205, '2023-06-05'),
    (6, 'Falling Stars', 230, '2024-01-10');

INSERT INTO songs (song_id, song_title, duration_seconds, release_date)
SELECT n + 6,
       CONCAT('Song Recording ', LPAD(n + 6, 5, '0')),
       150 + MOD(n * 17, 240),
       DATE_ADD('2005-01-01', INTERVAL MOD(n * 29, 7300) DAY)
FROM (
    SELECT ones.n + tens.n * 10 + hundreds.n * 100 + thousands.n * 1000 + 1 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
          UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
          UNION ALL SELECT 8 UNION ALL SELECT 9) ones
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) tens
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) hundreds
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) thousands
) AS _load_numbers
WHERE n BETWEEN 1 AND 2994;

-- 4. Album artists: two artists per album.
INSERT INTO album_artists (album_id, artist_id)
SELECT album_id, MOD(album_id - 1, 100) + 1
FROM albums;

INSERT INTO album_artists (album_id, artist_id)
SELECT album_id, MOD(album_id + 36, 100) + 1
FROM albums
WHERE MOD(album_id + 36, 100) + 1 <> MOD(album_id - 1, 100) + 1;

-- 5. Song artists: two artists per recording.
INSERT INTO song_artists (song_id, artist_id)
SELECT song_id, MOD(song_id - 1, 100) + 1
FROM songs;

INSERT INTO song_artists (song_id, artist_id)
SELECT song_id, MOD(song_id + 22, 100) + 1
FROM songs
WHERE MOD(song_id + 22, 100) + 1 <> MOD(song_id - 1, 100) + 1;

-- 6. Album tracks: six recordings per album, plus deliberate shared recordings.
-- The base mapping gives each album track numbers 1..6 without collisions.
INSERT INTO album_songs (album_id, song_id, track_number)
SELECT FLOOR((song_id - 1) / 6) + 1,
       song_id,
       MOD(song_id - 1, 6) + 1
FROM songs;

-- Same recording appears on multiple albums, as required by the specification.
-- Album 1 already contains song 1; add that recording to album 2 at track 7.
INSERT INTO album_songs (album_id, song_id, track_number)
VALUES (2, 1, 7);

-- 7. Concerts: 301 total. Generated concerts use IDs 4..300; concert 301 deliberately has no tickets.
INSERT INTO concerts (concert_id, concert_title, location, date_of_concert)
VALUES
    (1, 'Summer Sound Festival', 'Limerick', '2026-11-15'),
    (2, 'Harbour Nights', 'Galway', '2026-12-05'),
    (3, 'Acoustic Evening', 'Dublin', '2027-01-20');

INSERT INTO concerts (concert_id, concert_title, location, date_of_concert)
SELECT n + 3,
       CONCAT('Concert Event ', LPAD(n + 3, 4, '0')),
       ELT(MOD(n, 8) + 1, 'Limerick', 'Galway', 'Dublin', 'Cork',
           'Waterford', 'Kilkenny', 'Athlone', 'Sligo'),
       DATE_ADD('2026-01-01', INTERVAL MOD(n * 13, 900) DAY)
FROM (
    SELECT ones.n + tens.n * 10 + hundreds.n * 100 + thousands.n * 1000 + 1 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
          UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
          UNION ALL SELECT 8 UNION ALL SELECT 9) ones
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) tens
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) hundreds
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) thousands
) AS _load_numbers
WHERE n BETWEEN 1 AND 297;

INSERT INTO concerts (concert_id, concert_title, location, date_of_concert)
VALUES (301, 'Indian International Concert', 'Limerick', '2027-12-31');

-- 8. Concert artists: three artists for the first concert, two for others.
INSERT INTO concert_artists (concert_id, artist_id)
SELECT concert_id, MOD(concert_id - 1, 100) + 1
FROM concerts
WHERE concert_id <= 300;

INSERT INTO concert_artists (concert_id, artist_id)
SELECT concert_id, MOD(concert_id + 17, 100) + 1
FROM concerts
WHERE concert_id <= 300
  AND MOD(concert_id + 17, 100) + 1 <> MOD(concert_id - 1, 100) + 1;

INSERT INTO concert_artists (concert_id, artist_id)
VALUES (1, 3);

-- 9. Songs performed at concerts: ten songs per concert for concerts 1..300.
INSERT INTO concert_songs (concert_id, song_id, performance_order)
SELECT MOD(song_id - 1, 300) + 1,
       song_id,
       FLOOR((song_id - 1) / 300) + 1
FROM songs
WHERE song_id <= 3000;

-- 10. Fans: 12,000 total.
INSERT INTO fans (fan_id, fan_name, fan_email, age)
VALUES
    (1, 'Alex Murphy', 'alex.murphy@example.com', 24),
    (2, 'Jamie Kelly', 'jamie.kelly@example.com', 27),
    (3, 'Taylor Singh', 'taylor.singh@example.com', 22),
    (4, 'Morgan Chen', 'morgan.chen@example.com', 29),
    (5, 'Casey Walsh', 'casey.walsh@example.com', 25);

INSERT INTO fans (fan_id, fan_name, fan_email, age)
SELECT n + 5,
       CONCAT('Fan ', LPAD(n + 5, 5, '0')),
       CONCAT('fan', LPAD(n + 5, 5, '0'), '@example.com'),
       CASE WHEN MOD(n, 17) = 0 THEN NULL ELSE 18 + MOD(n * 11, 63) END
FROM (
    SELECT ones.n + tens.n * 10 + hundreds.n * 100 + thousands.n * 1000 + ten_thousands.n * 10000 + 1 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
          UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
          UNION ALL SELECT 8 UNION ALL SELECT 9) ones
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) tens
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) hundreds
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) thousands
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1) ten_thousands
) AS _load_numbers
WHERE n BETWEEN 1 AND 11995;

-- 11. Multiple favourite artists per fan (two per fan).
INSERT INTO fan_favourite_artists (fan_id, artist_id)
SELECT fan_id, MOD(fan_id - 1, 100) + 1
FROM fans;

INSERT INTO fan_favourite_artists (fan_id, artist_id)
SELECT fan_id, MOD(fan_id + 31, 100) + 1
FROM fans
WHERE MOD(fan_id + 31, 100) + 1 <> MOD(fan_id - 1, 100) + 1;

-- 12. Tickets: 6,000 total, spread evenly across concerts 1..300.
-- Concert 301 has no ticket records, for the required function test.
INSERT INTO tickets (ticket_id, concert_id, purchase_date, ticket_price)
VALUES
    (1, 1, '2026-09-10', 90.00),
    (2, 1, '2026-09-12', 60.00),
    (3, 2, '2026-09-15', 75.00),
    (4, 3, '2026-09-20', 45.00);

INSERT INTO tickets (ticket_id, concert_id, purchase_date, ticket_price)
SELECT n + 4,
       MOD(n + 3, 300) + 1,
       DATE_ADD('2026-01-01', INTERVAL MOD(n * 3, 300) DAY),
       25.00 + MOD(n * 19, 176) + (MOD(n, 2) * 0.50)
FROM (
    SELECT ones.n + tens.n * 10 + hundreds.n * 100 + thousands.n * 1000 + 1 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
          UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
          UNION ALL SELECT 8 UNION ALL SELECT 9) ones
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) tens
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) hundreds
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9) thousands
) AS _load_numbers
WHERE n BETWEEN 1 AND 5996;

-- 13. Fan-seat reservations.
-- Ticket 1 deliberately covers three fans (three seats).
-- Ticket 4 deliberately has no reservations.
-- Each other ticket gets two different fans. The ID ranges are arranged
-- so the same fan is not assigned to multiple tickets for the same concert.
INSERT INTO ticket_fans (ticket_id, fan_id, seat_zone, seat_number)
VALUES
    (1, 1, 'A', '01'),
    (1, 2, 'A', '02'),
    (1, 3, 'A', '03');

INSERT INTO ticket_fans (ticket_id, fan_id, seat_zone, seat_number)
SELECT ticket_id,
       ticket_id + 3,
       ELT(MOD(ticket_id, 4) + 1, 'A', 'B', 'C', 'VIP'),
       LPAD(MOD(ticket_id * 7, 500) + 1, 3, '0')
FROM tickets
WHERE ticket_id NOT IN (1, 4);

INSERT INTO ticket_fans (ticket_id, fan_id, seat_zone, seat_number)
SELECT ticket_id,
       ticket_id + 6000,
       ELT(MOD(ticket_id + 1, 4) + 1, 'A', 'B', 'C', 'VIP'),
       LPAD(MOD(ticket_id * 11, 500) + 501, 3, '0')
FROM tickets
WHERE ticket_id NOT IN (1, 4);

-- No audit rows are inserted here; the AFTER trigger creates them when
-- reservation inserts are performed after code.sql has been installed.


-- 14. Verification queries: run after the inserts to inspect actual counts.
SELECT 'artists' AS table_name, COUNT(*) AS row_count FROM artists
UNION ALL SELECT 'albums', COUNT(*) FROM albums
UNION ALL SELECT 'songs', COUNT(*) FROM songs
UNION ALL SELECT 'album_artists', COUNT(*) FROM album_artists
UNION ALL SELECT 'song_artists', COUNT(*) FROM song_artists
UNION ALL SELECT 'album_songs', COUNT(*) FROM album_songs
UNION ALL SELECT 'concerts', COUNT(*) FROM concerts
UNION ALL SELECT 'concert_artists', COUNT(*) FROM concert_artists
UNION ALL SELECT 'concert_songs', COUNT(*) FROM concert_songs
UNION ALL SELECT 'fans', COUNT(*) FROM fans
UNION ALL SELECT 'fan_favourite_artists', COUNT(*) FROM fan_favourite_artists
UNION ALL SELECT 'tickets', COUNT(*) FROM tickets
UNION ALL SELECT 'ticket_fans', COUNT(*) FROM ticket_fans
UNION ALL SELECT 'reservation_audit', COUNT(*) FROM reservation_audit;

-- Required three-fan ticket test: expected result is 3.
SELECT ticket_id, COUNT(*) AS reserved_seats
FROM ticket_fans
WHERE ticket_id = 1
GROUP BY ticket_id;

-- Required concert-with-no-tickets test: expected reserved seats are 0.
SELECT c.concert_id, c.concert_title, COUNT(t.ticket_id) AS ticket_count
FROM concerts c
LEFT JOIN tickets t ON t.concert_id = c.concert_id
WHERE c.concert_id = 301
GROUP BY c.concert_id, c.concert_title;


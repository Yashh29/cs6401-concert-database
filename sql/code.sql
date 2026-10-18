-- ============================================================
-- CS6401 Database Systems Project
-- File: code.sql
-- Target DBMS: MySQL
-- ============================================================

USE cs6401_concerts;

-- ------------------------------------------------------------
-- TASK 3: VIEW
-- Purpose: show concerts with at least two reserved seats,
-- including distinct performing artists and reserved seats.
-- COUNT(DISTINCT ...) prevents join multiplication from inflating
-- the counts when a concert has multiple artists and tickets.
-- ------------------------------------------------------------

DROP VIEW IF EXISTS vw_concert_summary;

CREATE VIEW vw_concert_summary AS
SELECT
    c.concert_id,
    c.concert_title,
    c.location,
    c.date_of_concert,
    COUNT(DISTINCT ca.artist_id) AS artist_count,
    COUNT(DISTINCT tf.fan_id) AS reserved_seats
FROM concerts AS c
JOIN concert_artists AS ca
    ON ca.concert_id = c.concert_id
JOIN tickets AS t
    ON t.concert_id = c.concert_id
JOIN ticket_fans AS tf
    ON tf.ticket_id = t.ticket_id
GROUP BY
    c.concert_id,
    c.concert_title,
    c.location,
    c.date_of_concert
HAVING COUNT(DISTINCT tf.fan_id) >= 2;


-- ------------------------------------------------------------
-- TASK 4A: BEFORE INSERT TRIGGER
-- Prevent a fan from reserving more than one seat for the same
-- concert, including through different tickets.
-- ------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_before_ticket_fan_insert;

DELIMITER $$

CREATE TRIGGER trg_before_ticket_fan_insert
BEFORE INSERT ON ticket_fans
FOR EACH ROW
BEGIN
    DECLARE v_existing_reservations INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_existing_reservations
    FROM ticket_fans AS tf
    JOIN tickets AS existing_ticket
      ON existing_ticket.ticket_id = tf.ticket_id
    JOIN tickets AS new_ticket
      ON new_ticket.ticket_id = NEW.ticket_id
    WHERE tf.fan_id = NEW.fan_id
      AND existing_ticket.concert_id = new_ticket.concert_id;

    IF v_existing_reservations > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Fan already has a reservation for this concert';
    END IF;
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- TASK 4B: AFTER INSERT TRIGGER
-- Audit each successfully inserted fan-seat reservation.
-- ------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_after_ticket_fan_insert;

DELIMITER $$

CREATE TRIGGER trg_after_ticket_fan_insert
AFTER INSERT ON ticket_fans
FOR EACH ROW
BEGIN
    INSERT INTO reservation_audit
        (ticket_id, fan_id, action_type)
    VALUES
        (NEW.ticket_id, NEW.fan_id, 'RESERVATION_CREATED');
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- TASK 5: STORED FUNCTION
-- Count ticket_fans rows for the concert. Each row is one seat.
-- Return 0 for an existing concert with no tickets or no seats.
-- Raise a clear error for a nonexistent concert ID.
-- ------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_reserved_seats;

DELIMITER $$

CREATE FUNCTION fn_reserved_seats(
    p_concert_id BIGINT UNSIGNED
)
RETURNS BIGINT UNSIGNED
READS SQL DATA
BEGIN
    DECLARE v_concert_exists INT DEFAULT 0;
    DECLARE v_reserved_seats BIGINT UNSIGNED DEFAULT 0;

    SELECT COUNT(*)
      INTO v_concert_exists
    FROM concerts
    WHERE concert_id = p_concert_id;

    IF v_concert_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Concert does not exist';
    END IF;

    SELECT COUNT(tf.fan_id)
      INTO v_reserved_seats
    FROM tickets AS t
    JOIN ticket_fans AS tf
      ON tf.ticket_id = t.ticket_id
    WHERE t.concert_id = p_concert_id;

    RETURN v_reserved_seats;
END$$

DELIMITER ;


-- ------------------------------------------------------------
-- TASK 6: STORED PROCEDURE
-- Ensure a song-recording/album association exists.
-- If missing, insert it with the next available track number.
-- In either case, if both dates exist and the song date is later
-- than the album date, update the song date to the album date.
-- Missing IDs raise errors; missing dates cause no date update.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_add_song_to_album;

DELIMITER $$

CREATE PROCEDURE sp_add_song_to_album(
    IN p_song_id BIGINT UNSIGNED,
    IN p_album_id BIGINT UNSIGNED
)
BEGIN
    DECLARE v_song_exists INT DEFAULT 0;
    DECLARE v_album_exists INT DEFAULT 0;
    DECLARE v_association_exists INT DEFAULT 0;
    DECLARE v_song_release_date DATE;
    DECLARE v_album_release_date DATE;
    DECLARE v_next_track_number INT DEFAULT 1;

    -- Validate the song recording.
    SELECT COUNT(*)
      INTO v_song_exists
    FROM songs
    WHERE song_id = p_song_id;

    IF v_song_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Song recording does not exist';
    END IF;

    -- Validate the album.
    SELECT COUNT(*)
      INTO v_album_exists
    FROM albums
    WHERE album_id = p_album_id;

    IF v_album_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Album does not exist';
    END IF;

    -- Read the relevant release dates.
    SELECT release_date
      INTO v_song_release_date
    FROM songs
    WHERE song_id = p_song_id;

    SELECT release_date
      INTO v_album_release_date
    FROM albums
    WHERE album_id = p_album_id;

    -- Check for an existing association.
    SELECT COUNT(*)
      INTO v_association_exists
    FROM album_songs
    WHERE song_id = p_song_id
      AND album_id = p_album_id;

    -- Insert only when the association is missing.
    IF v_association_exists = 0 THEN
        SELECT COALESCE(MAX(track_number), 0) + 1
          INTO v_next_track_number
        FROM album_songs
        WHERE album_id = p_album_id;

        INSERT INTO album_songs (album_id, song_id, track_number)
        VALUES (p_album_id, p_song_id, v_next_track_number);
    END IF;

    -- Apply the date rule whether or not the association already existed.
    IF v_song_release_date IS NOT NULL
       AND v_album_release_date IS NOT NULL
       AND v_song_release_date > v_album_release_date THEN
        UPDATE songs
        SET release_date = v_album_release_date
        WHERE song_id = p_song_id;
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- Optional object verification queries.
-- Run these after the CREATE statements have completed.
-- Keep the nonexistent-ID function call separate because it
-- intentionally raises an error.
-- ------------------------------------------------------------

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SHOW TRIGGERS;

SHOW FUNCTION STATUS
WHERE Db = 'cs6401_concerts';

SHOW PROCEDURE STATUS
WHERE Db = 'cs6401_concerts';

-- Expected to return 0 for concert 301 after data.sql is loaded.
SELECT fn_reserved_seats(301) AS seats_for_concert_without_tickets;

-- Run separately; expected to raise "Concert does not exist".
-- SELECT fn_reserved_seats(999999);

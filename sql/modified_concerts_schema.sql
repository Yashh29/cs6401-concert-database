
-- ============================================================
-- CS6401 Database Systems Project
-- File: modified_concerts_schema.sql
-- Target DBMS: MySQL
-- Duration unit: seconds
-- Currency: EUR
-- ============================================================

USE cs6401_concerts;

-- WARNING:
-- These statements remove existing project tables and data.
-- Run this setup only when you intend to rebuild the schema.

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS reservation_audit;
DROP TABLE IF EXISTS ticket_fans;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS fan_favourite_artists;
DROP TABLE IF EXISTS concert_songs;
DROP TABLE IF EXISTS concert_artists;
DROP TABLE IF EXISTS album_songs;
DROP TABLE IF EXISTS song_artists;
DROP TABLE IF EXISTS album_artists;
DROP TABLE IF EXISTS fans;
DROP TABLE IF EXISTS concerts;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS artists;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Artists, including solo artists and bands
CREATE TABLE artists (
    artist_id BIGINT UNSIGNED AUTO_INCREMENT,
    artist_name VARCHAR(128) NOT NULL,
    genre VARCHAR(64),
    debut_year YEAR,

    CONSTRAINT pk_artists PRIMARY KEY (artist_id),
    CONSTRAINT uq_artists_name UNIQUE (artist_name)
) ENGINE = InnoDB;

-- 2. Albums
CREATE TABLE albums (
    album_id BIGINT UNSIGNED AUTO_INCREMENT,
    album_title VARCHAR(256) NOT NULL,
    release_date DATE,

    CONSTRAINT pk_albums PRIMARY KEY (album_id)
) ENGINE = InnoDB;

-- 3. Song recordings.
-- Each song_id represents one specific recording/version.
-- release_date is the recording's earliest release date.
-- NULL dates are permitted for procedure edge-case testing.
CREATE TABLE songs (
    song_id BIGINT UNSIGNED AUTO_INCREMENT,
    song_title VARCHAR(128) NOT NULL,
    duration_seconds INT UNSIGNED NOT NULL,
    release_date DATE,

    CONSTRAINT pk_songs PRIMARY KEY (song_id),
    CONSTRAINT chk_song_duration
        CHECK (duration_seconds > 0)
) ENGINE = InnoDB;

-- 4. Artists associated with albums
CREATE TABLE album_artists (
    album_id BIGINT UNSIGNED NOT NULL,
    artist_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_album_artists
        PRIMARY KEY (album_id, artist_id),

    CONSTRAINT fk_album_artists_album
        FOREIGN KEY (album_id) REFERENCES albums(album_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_album_artists_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 5. Artists who performed a particular recording
CREATE TABLE song_artists (
    song_id BIGINT UNSIGNED NOT NULL,
    artist_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_song_artists
        PRIMARY KEY (song_id, artist_id),

    CONSTRAINT fk_song_artists_song
        FOREIGN KEY (song_id) REFERENCES songs(song_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_song_artists_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 6. Recordings appearing on albums.
-- A recording can appear on several albums.
CREATE TABLE album_songs (
    album_id BIGINT UNSIGNED NOT NULL,
    song_id BIGINT UNSIGNED NOT NULL,
    track_number SMALLINT UNSIGNED NOT NULL,

    CONSTRAINT pk_album_songs
        PRIMARY KEY (album_id, song_id),

    CONSTRAINT uq_album_track
        UNIQUE (album_id, track_number),

    CONSTRAINT chk_track_number
        CHECK (track_number > 0),

    CONSTRAINT fk_album_songs_album
        FOREIGN KEY (album_id) REFERENCES albums(album_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_album_songs_song
        FOREIGN KEY (song_id) REFERENCES songs(song_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 7. Concerts
CREATE TABLE concerts (
    concert_id BIGINT UNSIGNED AUTO_INCREMENT,
    concert_title VARCHAR(256) NOT NULL,
    location VARCHAR(256) NOT NULL,
    date_of_concert DATE NOT NULL,

    CONSTRAINT pk_concerts PRIMARY KEY (concert_id),
    INDEX idx_concert_date (date_of_concert)
) ENGINE = InnoDB;

-- 8. Artists performing at concerts
CREATE TABLE concert_artists (
    concert_id BIGINT UNSIGNED NOT NULL,
    artist_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_concert_artists
        PRIMARY KEY (concert_id, artist_id),

    CONSTRAINT fk_concert_artists_concert
        FOREIGN KEY (concert_id) REFERENCES concerts(concert_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_concert_artists_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 9. Songs performed at concerts
CREATE TABLE concert_songs (
    concert_id BIGINT UNSIGNED NOT NULL,
    song_id BIGINT UNSIGNED NOT NULL,
    performance_order SMALLINT UNSIGNED NOT NULL,

    CONSTRAINT pk_concert_songs
        PRIMARY KEY (concert_id, song_id),

    CONSTRAINT uq_concert_performance_order
        UNIQUE (concert_id, performance_order),

    CONSTRAINT chk_performance_order
        CHECK (performance_order > 0),

    CONSTRAINT fk_concert_songs_concert
        FOREIGN KEY (concert_id) REFERENCES concerts(concert_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_concert_songs_song
        FOREIGN KEY (song_id) REFERENCES songs(song_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 10. Fans
CREATE TABLE fans (
    fan_id BIGINT UNSIGNED AUTO_INCREMENT,
    fan_name VARCHAR(128) NOT NULL,
    fan_email VARCHAR(254) NOT NULL,
    age TINYINT UNSIGNED,

    CONSTRAINT pk_fans PRIMARY KEY (fan_id),
    CONSTRAINT uq_fan_email UNIQUE (fan_email),
    CONSTRAINT chk_fan_age CHECK (age IS NULL OR age <= 120)
) ENGINE = InnoDB;

-- 11. Multiple favourite artists per fan
CREATE TABLE fan_favourite_artists (
    fan_id BIGINT UNSIGNED NOT NULL,
    artist_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_fan_favourite_artists
        PRIMARY KEY (fan_id, artist_id),

    CONSTRAINT fk_favourites_fan
        FOREIGN KEY (fan_id) REFERENCES fans(fan_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_favourites_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 12. Tickets.
-- Each ticket belongs to exactly one concert.
-- ticket_price is the total price of the ticket in EUR,
-- stored as DECIMAL to avoid floating-point money errors.
CREATE TABLE tickets (
    ticket_id BIGINT UNSIGNED AUTO_INCREMENT,
    concert_id BIGINT UNSIGNED NOT NULL,
    purchase_date DATE NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_tickets PRIMARY KEY (ticket_id),
    CONSTRAINT chk_ticket_price CHECK (ticket_price >= 0),

    INDEX idx_tickets_concert (concert_id),

    CONSTRAINT fk_tickets_concert
        FOREIGN KEY (concert_id) REFERENCES concerts(concert_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 13. Fans and their individual seats under a ticket.
-- Every row represents one reserved seat.
CREATE TABLE ticket_fans (
    ticket_id BIGINT UNSIGNED NOT NULL,
    fan_id BIGINT UNSIGNED NOT NULL,
    seat_zone VARCHAR(16) NOT NULL,
    seat_number VARCHAR(16) NOT NULL,

    CONSTRAINT pk_ticket_fans
        PRIMARY KEY (ticket_id, fan_id),

    CONSTRAINT uq_seat_within_ticket
        UNIQUE (ticket_id, seat_zone, seat_number),

    INDEX idx_ticket_fans_fan (fan_id),

    CONSTRAINT fk_ticket_fans_ticket
        FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_ticket_fans_fan
        FOREIGN KEY (fan_id) REFERENCES fans(fan_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 14. Audit records for reservation events.
-- This table will be populated by the AFTER trigger in code.sql.
-- No foreign keys are defined here so audit history can remain available
-- even if related operational records are later removed.
CREATE TABLE reservation_audit (
    audit_id BIGINT UNSIGNED AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL,
    fan_id BIGINT UNSIGNED NOT NULL,
    action_type VARCHAR(32) NOT NULL,
    action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_reservation_audit PRIMARY KEY (audit_id),

    INDEX idx_reservation_audit_ticket (ticket_id),
    INDEX idx_reservation_audit_fan (fan_id)
) ENGINE = InnoDB;

-- End of schema



USE cs6401_concerts;

SHOW TABLES;

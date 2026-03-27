-- SQLite версия
/*
Создание БД
    sqlite3 /var/db/ovpnstatus/ovpnstatus.db < create_db_sqlite.sql
*/

-- Включаем поддержку внешних ключей (делаем это сразу после подключения к БД)
PRAGMA foreign_keys = ON;

/* Таблица для хранения имени пользователя и его IP
*/
CREATE TABLE IF NOT EXISTS t_clients ( 
	id_client INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(40) NOT NULL UNIQUE
);

/* Таблица для хранения статистики TX и RX в байтах по каждому пользователю
CURRENT_DATE,      -- только дата: 2026-03-04
CURRENT_TIME,      -- только время: 15:30:45
strftime('%s', 'now') — функция SQLite, которая превращает текущее время в Unix timestamp
    (например, 1677936645).
*/
CREATE TABLE IF NOT EXISTS t_session_log  (
    id_statistic INTEGER PRIMARY KEY AUTOINCREMENT,
    id_client INTEGER NOT NULL,
    client_ip VARCHAR(15) NOT NULL,
    rx_total INTEGER,
    tx_total INTEGER,
    session_start DATETIME NOT NULL,
    session_start_unix INTEGER NOT NULL,  -- Unix timestamp: 1677936645
    session_end DATETIME NOT NULL DEFAULT (datetime('now')), -- 2025-10-06 21:36:18
    session_duration INTEGER,
    FOREIGN KEY (id_client) REFERENCES t_clients (id_client)
);

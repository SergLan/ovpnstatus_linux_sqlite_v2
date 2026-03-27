## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)
* [Start](#start)
* [SQLite](#sqlite)

## General info
Designed for Unix/Linux, this Bash script executes upon OpenVPN client disconnection and records client data to a database.
	
## Technologies
The script is written for:
* Bash
* SQL
	
## Setup
Database initialization:
```
$ sqlite3 ovpnstatus.db < create_db_sqlite.sql
```

Configuring the OpenVPN server
```
script-security 2
client-disconnect "/usr/local/bin/ovpnstatus.sh"
```
In the OpenVPN configuration, client-disconnect is used.
This option runs a script when the client disconnects and passes the following environment variables to the script:

Variable:                       Description:
common_name                     Common Name (CN) of the client certificate
trusted_ip                      Actual IP address of the connected client
trusted_port                    Client port
ifconfig_pool_remote_ip	        Virtual IP address assigned to the client
bytes_received	                Total number of bytes received from the client during the session
bytes_sent	                    Total number of bytes sent to the client during the session
time_duration	                Client session duration in seconds
username	                    Username (if auth-user-pass authentication is used)
time_ascii	                    Connection time (human-readable format)
time_unix	                    Connection time (Unix timestamp)

## Start
The script runs automatically when the client disconnects.


## SQLite
Several commands for viewing tables in a database:
```
$ sqlite3 /var/lib/ovpnstatus/ovpnstatus.db -cmd ".headers on" -cmd ".mode column" "SELECT t_clients.name, client_ip, rx_total, tx_total, session_start, session_end  FROM t_session_log JOIN t_clients ON t_session_log.id_client = t_clients.id_client;"
```
```
$ sqlite3 /var/lib/ovpnstatus/ovpnstatus.db -cmd ".headers on" -cmd ".mode column" "SELECT t_clients.name, SUM(rx_total) as rx_total, SUM(tx_total) as tx_total FROM t_session_log JOIN t_clients ON t_session_log.id_client = t_clients.id_client GROUP BY t_clients.name ORDER BY tx_total DESC;"
```

![Image alt](screenshots/Screenshot01.png)

#!/usr/local/bin/bash

# Файл базы данных
db_file="/var/db/ovpnstatus/ovpnstatus.db"

# Массив для хранения пользователей из таблицы t_clients
declare -a db_clients

# Рабочие переменные
declare -i id_client_db=0 # -i означает integer

if [[ ! -f $db_file ]]; then
    printf "Error: File ovpnstatus.db Not Found.\n"
    exit 0
fi

# Проверяем находится ли текущий пользователь в таблице t_user и если нет то добавляем его
# Перебераем всех пользователей в БД и заносим их в массив db_clients
# IFS - Internal Field Separator
# IFS - это системная переменная bash которая определяет разделитель полей при чтении строк.
#   IFS=','     - разделитель запятая
#   IFS=" \t\n" - по умолчанию: пробел, табуляция, перенос строки
#   IFS=        - никакого разделителя, строка как есть
#
while IFS= read -r row; do
    db_clients+=("$row")
done < <(sqlite3 $db_file "SELECT name FROM t_clients;")
# < - перенаправление ввода
# < говорит циклу - читай строки отсюда
# <() - process substitution (подстановка процесса)
# Bash выполняет команду и её вывод представляет как виртуальный файл.
# Это не pipe, это именно файл - у него даже есть путь типа /dev/fd/63
# done  <               - читай из файла
#       <(sqlite3....)  - этот "файл" это вывод команды sqlite3
# Почему не просто pipe?
# Потому что pipe создаёт **subshell** - дочерний процесс
# Массив заполняется там, а в основном скрипте он пустой.

# Функция проверки вхождения элемента в массив
in_array() {
    local needle="$1"    # что ищем
    local element        # текущий элемент
    shift                # сдвигаем аргументы, остаются только элементы массива
    for element in "$@"; do
        if [[ "$element" == "$needle" ]]; then
            # нашли - true
            return 0
        fi
    done
    # не нашли - false
    return 1
}

# Проверяем содержится ли только что отключившийся клиент $common_name в БД
# Если нет, то добавляем нового клиента
if ! in_array "$common_name" "${db_clients[@]}"; then
    # добавляем нового клиента в БД
    sqlite3 "$db_file" "INSERT INTO t_clients (name) VALUES ('$common_name');"
fi

# Записываем данные отлючившевогося клиента в таблицу t_session_log
# получаем id клиента
id_client_db=$(sqlite3 "$db_file" "SELECT id_client FROM t_clients WHERE name='$common_name';")
sqlite3 "$db_file" "INSERT INTO t_session_log (id_client, \
                                             client_ip, \
                                             rx_total, \
                                             tx_total, \
                                             session_start, \
                                             session_start_unix, \
                                             session_duration)
                        VALUES ($id_client_db, \
                                '$trusted_ip', \
                                $bytes_received, \
                                $bytes_sent, \
                                '$time_ascii', \
                                $time_unix, \
                                $time_duration);"

unset id_client_db
unset db_clients

exit 0

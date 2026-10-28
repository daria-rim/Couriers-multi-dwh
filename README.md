# 📦 DWH: Courier Settlement Report. Расчёт выплат курьерам

> Расширение существующего многослойного хранилища данных (DWH) третьим источником — REST API курьерской службы — и создание новой витрины `cdm.dm_courier_ledger` для автоматизированного расчёта вознаграждений курьерам.

---

## 🎯 Описание проекта

Изначально хранилище данных было построено на основе **двух источников**:
1. **MongoDB** — основные транзакционные данные:
   - `restaurants`, `users`, `orders`
2. **PostgreSQL (справочники)** — дополнительные данные для обогащения:
   - `ranks`, `users`

На их основе была сформирована первая витрина — `cdm.dm_settlement_report` — для расчёта выплат **ресторанам**.

В рамках этого проекта добавляется **третий источник**:  

3. **REST API курьерской службы**, предоставляющий:
   - Список курьеров (`/couriers`)
   - Список доставок (`/deliveries`) с датой заказа, рейтингом и чаевыми

Цель — **построить новую витрину `cdm.dm_courier_ledger`**, содержащую корректные суммы выплат каждому курьеру за предыдущий месяц на основе:
- данных о заказах (уже в DWH),
- данных о доставках (из нового API),
- бизнес-правил, зависящих от среднего рейтинга курьера.

> 💡 Расчёт ведётся **по дате создания заказа (`order_ts`)**, а не доставки. Учитываются только заказы со статусом `CLOSED`.

### 🧱 Изменения в DWH
- **Существующие таблицы DDS модифицируются**: в `dds.dm_orders` добавляется `courier_id`.
- **Новые таблицы в DDS**:
  - `dds.dm_couriers` — справочник курьеров,
  - `dds.fct_deliveries` — факты доставок (с `rate`, `tip_sum`, `order_ts`).
- **Новая витрина CDM**: `cdm.dm_courier_ledger`.

### 🛠 Стек технологий
- **Источники**: MongoDB, PostgreSQL, REST API
- **Хранилище**: PostgreSQL
- **Оркестрация**: Apache Airflow
- **Язык**: Python 3.9+
- **Инструменты**: SQL, REST, JSON, пагинация (limit/offset)

---

## 🧪 Выводы

- Успешно интегрирован **третий источник данных** в существующую DWH-архитектуру.
- Реализована **многослойная модель "снежинка"**, расширенная новыми измерениями и связями.
- Все бизнес-правила (пороговые выплаты, рейтинговая дифференциация, комиссии) корректно реализованы в слое CDM.
- Решение **сохраняет обратную совместимость**: исходные DAG-и и витрина `dm_settlement_report` продолжают работать без изменений.

---

## 🏷️ Теги

`#dwh` `#etl` `#airflow` `#postgresql` `#mongodb` `#rest-api` `#data-engineering` `#python` `#courier-payment` `#cdm` `#dds`

# Инструкция по развертыванию:

1. клонировать репозиторий (если из гитхаба)
   ```bash
   git clone
   ```

2. перейти в корень репозитория
   ```bash
   cd multi-dwh
   ```

3. создать виртуальное окружение
   ```bash
   python -m venv venv
   ```

4. активировать виртуальное окружение
   ```bash
   .\venv\Scripts\Activate.ps1
   ```

5. установить зависимости
   ```bash
   pip install -r requirements.txt
   ```

6. Создайте файл `.env` в том же каталоге, в котором лежит файл `docker-compose.yml` .
   В `docker-compose.yml` объявлена переменная `AIRFLOW_DAGS_DIR`. Пропишите в файле `.env` строчку `AIRFLOW_DAGS_DIR={путь_до_директории}`. Например, `AIRFLOW_DAGS_DIR="C:\Users\Daria\Dev\multi-dwh\dags"` .

7. запустить докер десктоп

8. развернуть контейнер
   ```bash
   docker compose up -d
   ```

9. подключиться к бд в дбеавер:

   1:    
```
   dbname: 
   host: 
   port: 
   login: 
   password: 
   ssl: 
      режим: disable    
```
   2:    
```
   dbname: 
   host: 
   port:
   login: 
   password: 
   ssl:
      указать путь к сертификату CA.pem
      режим: verify-full    
```

10. подключиться к бд в MongoDB Compass:
    URI: `mongodb://student:student1@rc1a-ba83ae33hvt4pokq.mdb.yandexcloud.net:27018/db-mongo?authMechanism=DEFAULT&authSource=db-mongo&tls=true&replicaSet=rs01`

11. подключиться к airflow:
    У вас в Docker развёрнут Airflow. Чтобы попасть в UI Airflow, откройте в браузере адрес: `http://localhost:3000/airflow`. Для входа используйте:
    login: 
    пароль: 

12. установить подключения к БД (2 постгрес + монго):

    1: Создайте Connection в Airflow для подключения к источнику — БД PostgreSQL.    
```
    Connection Id: 
    Connection Type: 
    Host: 
    Schema: 
    Login: 
    Password: 
    Port:     
```
   2: Аналогичным образом заведите Сonnection для локальной инсталляции PostgreSQL, которая служит хранилищем.    

```
    Connection Id: 
    Connection Type: 
    Host: 
    Schema: 
    Login: 
    Password: 
    Port:     
```
   3: Перейдите в разделы Admin -> Variables. Через кнопку + добавьте следующие параметры:
    
```
    MONGO_DB_CERTIFICATE_PATH=
    MONGO_DB_USER=
    MONGO_DB_PASSWORD=
    MONGO_DB_HOST=
    MONGO_DB_REPLICA_SET=
    MONGO_DB_DATABASE_NAME=
```

13. запустить скрипт ддл в базе de (`short_ddl.sql`)

14. запустить ДАГи в эирфлоу в таком порядке:
    1. `bonus_system_ranks_dag.py` (3 раза) + проверить, что в базе появились три ранка JUNIOR, MIDDLE, SENIOR в таблице `stg.bonussystem_ranks`
    2. `order_system_restaurants_dag.py`
    3. `stg_api_dag.py`
    4. `dm_users_dag.py`
    5. `api_dds_dag.py`
    6. `cdm_dag.py`
    7. `api_cdm_dag.py`

15. Данные подгружаются пачками. Можно вручную запускать даги AirFlow или включить запуск по расписанию (pause/unpause DAG)
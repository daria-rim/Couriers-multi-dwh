
CREATE TABLE stg.bonussystem_ranks (
    id int4 NOT NULL,
    "name" varchar NOT NULL,
    bonus_percent numeric(19,5) DEFAULT 0 NOT NULL,
    min_payment_threshold numeric(19,5) DEFAULT 0 NOT NULL,
    CONSTRAINT bonussystem_ranks_bonus_percent_check CHECK (bonus_percent >= 0::numeric),
    CONSTRAINT bonussystem_ranks_min_payment_threshold_check CHECK (min_payment_threshold >= 0::numeric),
    CONSTRAINT bonussystem_ranks_pkey PRIMARY KEY (id)
);


CREATE TABLE stg.bonussystem_events (
    id int4 NOT NULL,
    event_ts timestamp NOT NULL,
    event_type varchar(255) NOT NULL,
    event_value text NOT NULL,
    CONSTRAINT bonussystem_events_pkey PRIMARY KEY (id)
);

CREATE INDEX idx_bonussystem_events__event_ts
    ON stg.bonussystem_events USING btree (event_ts);

CREATE TABLE stg.bonussystem_users (
    id int4 NOT NULL,
    order_user_id text NOT NULL,
    CONSTRAINT bonussystem_users_pkey PRIMARY KEY (id)
);

CREATE TABLE stg.get_couriers (
    id serial4 NOT NULL,
    object_id varchar NOT NULL,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL,
    CONSTRAINT get_couriers_object_id_key UNIQUE (object_id),
    CONSTRAINT get_couriers_pkey PRIMARY KEY (id)
);

CREATE TABLE stg.get_deliveries (
    id serial4 NOT NULL,
    object_id varchar NOT NULL,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL,
    CONSTRAINT get_deliveries_object_id_key UNIQUE (object_id),
    CONSTRAINT get_deliveries_pkey PRIMARY KEY (id)
);

CREATE TABLE stg.ordersystem_orders (
    id int4 NOT NULL GENERATED ALWAYS AS IDENTITY (
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 2147483647
        START 1
        CACHE 1
        NO CYCLE
    ),
    object_id varchar NOT NULL,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL,
    CONSTRAINT ordersystem_orders_object_id_key UNIQUE (object_id),
    CONSTRAINT ordersystem_orders_pkey PRIMARY KEY (id)
);

CREATE TABLE stg.ordersystem_restaurants (
    id int4 NOT NULL GENERATED ALWAYS AS IDENTITY (
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 2147483647
        START 1
        CACHE 1
        NO CYCLE
    ),
    object_id varchar NOT NULL,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL,
    CONSTRAINT ordersystem_restaurants_object_id_key UNIQUE (object_id),
    CONSTRAINT ordersystem_restaurants_pkey PRIMARY KEY (id)
);

CREATE TABLE stg.ordersystem_users (
    id int4 NOT NULL GENERATED ALWAYS AS IDENTITY (
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 2147483647
        START 1
        CACHE 1
        NO CYCLE
    ),
    object_id varchar NOT NULL,
    object_value text NOT NULL,
    update_ts timestamp NOT NULL,
    CONSTRAINT ordersystem_users_object_id_key UNIQUE (object_id),
    CONSTRAINT ordersystem_users_pkey PRIMARY KEY (id)
);

CREATE TABLE stg.srv_wf_settings (
    id int4 NOT NULL GENERATED ALWAYS AS IDENTITY (
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 2147483647
        START 1
        CACHE 1
        NO CYCLE
    ),
    workflow_key varchar NOT NULL,
    workflow_settings json NOT NULL,
    CONSTRAINT srv_wf_settings_pkey PRIMARY KEY (id),
    CONSTRAINT srv_wf_settings_workflow_key_key UNIQUE (workflow_key)
);

CREATE TABLE dds.dm_couriers (
    id serial4 NOT NULL,
    courier_id varchar NOT NULL,
    courier_name varchar NOT NULL,
    CONSTRAINT dm_couriers_courier_id_key UNIQUE (courier_id),
    CONSTRAINT dm_couriers_pkey PRIMARY KEY (id)
);

CREATE TABLE dds.dm_deliveries (
    id serial4 NOT NULL,
    delivery_id varchar NOT NULL,
    courier_id int4 NOT NULL,
    rate int2 NOT NULL,
    tip_sum numeric(14,2) DEFAULT 0 NOT NULL,
    CONSTRAINT dm_deliveries_delivery_id_key UNIQUE (delivery_id),
    CONSTRAINT dm_deliveries_pkey PRIMARY KEY (id),
    CONSTRAINT dm_deliveries_rate_check CHECK (rate >= 1 AND rate <= 5),
    CONSTRAINT dm_deliveries_tip_sum_check CHECK (tip_sum >= 0::numeric)
);

CREATE TABLE dds.dm_timestamps (
    id serial4 NOT NULL,
    ts timestamp NOT NULL,
    "year" int4 NOT NULL,
    "month" int4 NOT NULL,
    "day" int4 NOT NULL,
    "date" date NOT NULL,
    "time" time NOT NULL,
    CONSTRAINT dm_timestamps_pkey PRIMARY KEY (id),
    CONSTRAINT dm_timestamps_ts_key UNIQUE (ts)
);

CREATE TABLE dds.dm_users (
    id serial4 NOT NULL,
    user_id varchar NOT NULL,
    user_name varchar NOT NULL,
    user_login varchar NOT NULL,
    CONSTRAINT dm_users_pkey PRIMARY KEY (id),
    CONSTRAINT dm_users_user_id_key UNIQUE (user_id)
);

CREATE TABLE dds.dm_restaurants (
    id serial4 NOT NULL,
    restaurant_id varchar NOT NULL,
    restaurant_name varchar NOT NULL,
    active_from timestamp NOT NULL,
    active_to timestamp NOT NULL,
    CONSTRAINT dm_restaurants_pkey PRIMARY KEY (id),
    CONSTRAINT dm_restaurants_restaurant_id_key UNIQUE (restaurant_id)
);

CREATE TABLE dds.dm_orders (
    id serial4 NOT NULL,
    user_id int4 NOT NULL,
    restaurant_id int4 NOT NULL,
    timestamp_id int4 NOT NULL,
    order_key varchar NOT NULL,
    order_status varchar NOT NULL,
    delivery_id int4 NULL,
    CONSTRAINT dm_orders_order_unique UNIQUE (order_key),
    CONSTRAINT dm_orders_pkey PRIMARY KEY (id)
);

CREATE TABLE dds.dm_products (
    id serial4 NOT NULL,
    restaurant_id int4 NOT NULL,
    product_id varchar NOT NULL,
    product_name varchar NOT NULL,
    product_price numeric(14,2) DEFAULT 0 NOT NULL,
    active_from timestamp NOT NULL,
    active_to timestamp NOT NULL,
    CONSTRAINT dm_products_pkey PRIMARY KEY (id),
    CONSTRAINT dm_products_product_price_check CHECK (product_price >= 0::numeric),
    CONSTRAINT dm_products_product_unique UNIQUE (product_id)
);

CREATE TABLE dds.fct_product_sales (
    id serial4 NOT NULL,
    product_id int4 NOT NULL,
    order_id int4 NOT NULL,
    count int4 DEFAULT 0 NOT NULL,
    price numeric(14,2) DEFAULT 0 NOT NULL,
    total_sum numeric(14,2) DEFAULT 0 NOT NULL,
    bonus_payment numeric(14,2) DEFAULT 0 NOT NULL,
    bonus_grant numeric(14,2) DEFAULT 0 NOT NULL,
    CONSTRAINT fct_product_sales_bonus_grant_check CHECK (bonus_grant >= 0::numeric),
    CONSTRAINT fct_product_sales_bonus_payment_check CHECK (bonus_payment >= 0::numeric),
    CONSTRAINT fct_product_sales_count_check CHECK (count >= 0),
    CONSTRAINT fct_product_sales_pkey PRIMARY KEY (id),
    CONSTRAINT fct_product_sales_price_check CHECK (price >= 0::numeric),
    CONSTRAINT fct_product_sales_total_sum_check CHECK (total_sum >= 0::numeric),
    CONSTRAINT fct_product_sales_unique UNIQUE (product_id, order_id)
);

CREATE TABLE dds.srv_wf_settings (
    id int4 NOT NULL GENERATED ALWAYS AS IDENTITY (
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 2147483647
        START 1
        CACHE 1
        NO CYCLE
    ),
    workflow_key varchar NOT NULL,
    workflow_settings json NOT NULL,
    CONSTRAINT srv_wf_settings_pkey PRIMARY KEY (id),
    CONSTRAINT srv_wf_settings_workflow_key_key UNIQUE (workflow_key)
);

ALTER TABLE dds.dm_deliveries
    ADD CONSTRAINT dm_deliveries_courier_id_fkey
    FOREIGN KEY (courier_id) REFERENCES dds.dm_couriers(id);

ALTER TABLE dds.dm_orders
    ADD CONSTRAINT dm_orders_dm_timestamps_fkey
    FOREIGN KEY (timestamp_id) REFERENCES dds.dm_timestamps(id);

ALTER TABLE dds.dm_orders
    ADD CONSTRAINT dm_orders_restaurant_id_fkey
    FOREIGN KEY (restaurant_id) REFERENCES dds.dm_restaurants(id);

ALTER TABLE dds.dm_orders
    ADD CONSTRAINT dm_orders_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES dds.dm_users(id);

ALTER TABLE dds.dm_orders
    ADD CONSTRAINT dm_orders_delivery_id_fkey
    FOREIGN KEY (delivery_id) REFERENCES dds.dm_deliveries(id);

ALTER TABLE dds.dm_products
    ADD CONSTRAINT dm_products_restaurant_id_fkey
    FOREIGN KEY (restaurant_id) REFERENCES dds.dm_restaurants(id);

ALTER TABLE dds.fct_product_sales
    ADD CONSTRAINT fct_product_sales_dm_orders_fkey
    FOREIGN KEY (order_id) REFERENCES dds.dm_orders(id);

ALTER TABLE dds.fct_product_sales
    ADD CONSTRAINT fct_product_sales_dm_products_fkey
    FOREIGN KEY (product_id) REFERENCES dds.dm_products(id);

CREATE TABLE cdm.dm_courier_ledger (
    id serial4 NOT NULL,
    courier_id varchar NOT NULL,
    courier_name varchar NOT NULL,
    settlement_year int2 NOT NULL,
    settlement_month int2 NOT NULL,
    orders_count int4 DEFAULT 0 NOT NULL,
    orders_total_sum numeric(14,2) DEFAULT 0 NOT NULL,
    rate_avg int2 NOT NULL,
    order_processing_fee numeric(14,2) DEFAULT 0 NOT NULL,
    courier_order_sum numeric(14,2) DEFAULT 0 NOT NULL,
    courier_tips_sum numeric(14,2) DEFAULT 0 NOT NULL,
    courier_reward_sum numeric(14,2) DEFAULT 0 NOT NULL,
    CONSTRAINT dm_courier_ledger_courier_order_sum_check CHECK (courier_order_sum >= 0::numeric),
    CONSTRAINT dm_courier_ledger_courier_reward_sum_check CHECK (courier_reward_sum >= 0::numeric),
    CONSTRAINT dm_courier_ledger_courier_tips_sum_check CHECK (courier_tips_sum >= 0::numeric),
    CONSTRAINT dm_courier_ledger_order_processing_fee_check CHECK (order_processing_fee >= 0::numeric),
    CONSTRAINT dm_courier_ledger_orders_count_check CHECK (orders_count >= 0),
    CONSTRAINT dm_courier_ledger_orders_total_sum_check CHECK (orders_total_sum >= 0::numeric),
    CONSTRAINT dm_courier_ledger_pkey PRIMARY KEY (id),
    CONSTRAINT dm_courier_ledger_rate_avg_check CHECK (rate_avg >= 1 AND rate_avg <= 5),
    CONSTRAINT dm_courier_ledger_settlement_month_check CHECK (settlement_month >= 1 AND settlement_month <= 12),
    CONSTRAINT dm_courier_ledger_settlement_year_check CHECK (settlement_year >= 2022 AND settlement_year < 2500),
    CONSTRAINT uniq_courier_date UNIQUE (courier_id, settlement_year, settlement_month)
);

CREATE TABLE cdm.dm_settlement_report (
    id serial4 NOT NULL,
    restaurant_id varchar NOT NULL,
    restaurant_name varchar NOT NULL,
    settlement_date date NOT NULL,
    orders_count int4 NOT NULL,
    orders_total_sum numeric(14,2) NOT NULL,
    orders_bonus_payment_sum numeric(14,2) NOT NULL,
    orders_bonus_granted_sum numeric(14,2) NOT NULL,
    order_processing_fee numeric(14,2) NOT NULL,
    restaurant_reward_sum numeric(14,2) NOT NULL,
    CONSTRAINT dm_settlement_report_pkey PRIMARY KEY (id),
    CONSTRAINT uniq_restaurant_date UNIQUE (restaurant_id, settlement_date)
);
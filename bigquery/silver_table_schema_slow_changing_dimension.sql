
------------------------------CUSTOMER-----------------------------------
--Step 1: Create the customers Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.customers`
(
    customer_id INT64,
    name STRING,
    email STRING,
    updated_at STRING,
    derived_updated_at TIMESTAMP,
    is_quarantined BOOL,
    effective_start_date TIMESTAMP,
    effective_end_date TIMESTAMP,
    is_active BOOL
);
---step 2 full load
INSERT INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.customers`

(
customer_id,
name,
email,
updated_at,
derived_updated_at,
is_quarantined,
effective_start_date,
effective_end_date,
is_active

)
SELECT DISTINCT
    *,
     TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CASE
      WHEN customer_id IS NULL OR email IS NULL OR name IS NULL THEN TRUE
      ELSE FALSE
    END AS is_quarantined,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    True as is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.customers`


--Step 3: Update Existing Active Records if There Are Changes
MERGE INTO  `project-e89263b7-f16e-4dc3-9db.silver_dataset.customers` target
USING
  (SELECT DISTINCT
    *,
     TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CASE
      WHEN customer_id IS NULL OR email IS NULL OR name IS NULL THEN TRUE
      ELSE FALSE
    END AS is_quarantined,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    True as is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.customers`) source
ON target.customer_id = source.customer_id AND target.is_active = true
WHEN MATCHED AND
            (
             target.name != source.name OR
             target.email != source.email OR
             target.updated_at != source.updated_at)
    THEN UPDATE SET
        target.is_active = false,
        target.effective_end_date = current_timestamp();

--Step 3: Insert New or Updated Records
MERGE INTO  `project-e89263b7-f16e-4dc3-9db.silver_dataset.customers` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CASE
      WHEN customer_id IS NULL OR email IS NULL OR name IS NULL THEN TRUE
      ELSE FALSE
    END AS is_quarantined,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    True as is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.customers`) source
ON target.customer_id = source.customer_id AND target.is_active = true
WHEN NOT MATCHED THEN
    INSERT (customer_id, name, email, updated_at, is_quarantined, effective_start_date, effective_end_date, is_active)
    VALUES (source.customer_id, source.name, source.email, source.updated_at, source.is_quarantined, source.effective_start_date, source.effective_end_date, source.is_active);

------------------------------ORDERS-----------------------------------

--Step 1: Create the orders Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.orders`
(
    order_id INT64,
    customer_id INT64,
    order_date STRING,
    total_amount FLOAT64,
    updated_at STRING,
    derived_updated_at TIMESTAMP,
    effective_start_date TIMESTAMP,
    effective_end_date TIMESTAMP,
    is_active BOOL
);
--Step 2:  full load
INSERT INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.orders`
(
  order_id,
  customer_id,
  order_date,
  total_amount,
  updated_at,
  derived_updated_at,
  effective_start_date,
  effective_end_date,
  is_active
)

SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.orders`

--Step 2: Update Existing Active Records if There Are Changes
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.orders` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.orders`) source
ON target.order_id = source.order_id AND target.is_active = true
WHEN MATCHED AND
            (
             target.customer_id != source.customer_id OR
             target.order_date != source.order_date OR
             target.total_amount != source.total_amount OR
             target.updated_at != source.updated_at
            )
    THEN UPDATE SET
        target.is_active = false,
        target.effective_end_date = current_timestamp();

--Step 3: Insert New or Updated Records
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.orders` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.orders`) source
ON target.order_id = source.order_id AND target.is_active = true
WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, order_date, total_amount, updated_at, effective_start_date, effective_end_date, is_active)
    VALUES (source.order_id, source.customer_id, source.order_date, source.total_amount, source.updated_at, source.effective_start_date, source.effective_end_date, source.is_active);

--Step 1: Create the order_items Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items`
(
    order_item_id INT64,
    order_id INT64,
    product_id INT64,
    quantity INT64,
    price FLOAT64,
    updated_at STRING,
    derived_updated_at TIMESTAMP,
    effective_start_date TIMESTAMP,
    effective_end_date TIMESTAMP,
    is_active BOOL
);

--Step 2: Update Existing Active Records if There Are Changes
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.order_items`) source
ON target.order_item_id = source.order_item_id AND target.is_active = true
WHEN MATCHED AND
            (
             target.order_id != source.order_id OR
             target.product_id != source.product_id OR
             target.quantity != source.quantity OR
             target.price != source.price OR
             target.updated_at != source.updated_at
            )
    THEN UPDATE SET
        target.is_active = false,
        target.effective_end_date = current_timestamp();

--Step 3: Insert New or Updated Records
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.order_items`) source
ON target.order_item_id = source.order_item_id AND target.is_active = true
WHEN NOT MATCHED THEN
    INSERT (order_item_id, order_id, product_id, quantity, price, updated_at, effective_start_date, effective_end_date, is_active)
    VALUES (source.order_item_id, source.order_id, source.product_id, source.quantity, source.price, source.updated_at, source.effective_start_date, source.effective_end_date, source.is_active);

------------------------------CATEGORIES-----------------------------------

--Step 1: Create the categories Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.categories`
(
    category_id INT64,
    name STRING,
    updated_at STRING,
    derived_updated_at TIMESTAMP,
    is_quarantined BOOL
);

--Step 2: Truncate table
TRUNCATE TABLE `project-e89263b7-f16e-4dc3-9db.silver_dataset.categories`;

--Step 3: Insert New or Updated Records
INSERT INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.categories`
SELECT
  *,
  TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
  CASE
    WHEN category_id IS NULL OR name IS NULL THEN TRUE
    ELSE FALSE
  END AS is_quarantined

FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.categories`;

------------------------------PRODUCTS-----------------------------------
--Step 1: Create the products Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.products`
(
  product_id INT64,
  name STRING,
  category_id INT64,
  price FLOAT64,
  updated_at STRING,
  derived_updated_at TIMESTAMP,
  is_quarantined BOOL
);

--Step 2: Truncate table
TRUNCATE TABLE `project-e89263b7-f16e-4dc3-9db.silver_dataset.products`;

--Step 3: Insert New or Updated Records
INSERT INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.products`
SELECT
  *,
  TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
  CASE
    WHEN category_id IS NULL OR name IS NULL THEN TRUE
    ELSE FALSE
  END AS is_quarantined

FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.products`;
------------------------------PRODUCTS-----------------------------------
--Step 1: Create the product_supplier Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.product_suppliers`
(
    supplier_id INT64,
    product_id INT64,
    supply_price FLOAT64,
    last_updated STRING,
    derived_updated_at TIMESTAMP,
    effective_start_date TIMESTAMP,
    effective_end_date TIMESTAMP,
    is_active BOOL
);

--Step 2: Update Existing Active Records if There Are Changes
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.product_suppliers` target
USING
  (SELECT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(last_updated AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.product_suppliers`) source
ON target.supplier_id = source.supplier_id
   AND target.product_id = source.product_id
   AND target.is_active = true
WHEN MATCHED AND
            (
             target.supply_price != source.supply_price OR
             target.last_updated != source.last_updated
            )
    THEN UPDATE SET
        target.is_active = false,
        target.effective_end_date = current_timestamp();

--Step 3: Insert New or Updated Records
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.product_suppliers` target
USING
  (SELECT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(last_updated AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.product_suppliers`) source
ON target.supplier_id = source.supplier_id
   AND target.product_id = source.product_id
   AND target.is_active = true
WHEN NOT MATCHED THEN
    INSERT (supplier_id, product_id, supply_price, last_updated, effective_start_date, effective_end_date, is_active)
    VALUES (source.supplier_id, source.product_id, source.supply_price, source.last_updated, source.effective_start_date, source.effective_end_date, source.is_active);
------------------------------ORDER ITEMS
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items`
(
    order_item_id INT64,
    order_id INT64,
    product_id INT64,
    quantity INT64,
    price FLOAT64,
    updated_at STRING,
    derived_updated_at TIMESTAMP,
    effective_start_date TIMESTAMP,
    effective_end_date TIMESTAMP,
    is_active BOOL
);
INSERT INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items`
(
  order_id,
  order_item_id,
  product_id,
  quantity,
  price,
  updated_at,
  derived_updated_at,
  effective_start_date,
  effective_end_date,
  is_active
)
SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.order_items`

--Step 2: Update Existing Active Records if There Are Changes
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.order_items`) source
ON target.order_item_id = source.order_item_id AND target.is_active = true
WHEN MATCHED AND
            (
             target.order_id != source.order_id OR
             target.product_id != source.product_id OR
             target.quantity != source.quantity OR
             target.price != source.price OR
             target.updated_at != source.updated_at
            )
    THEN UPDATE SET
        target.is_active = false,
        target.effective_end_date = current_timestamp();

--Step 3: Insert New or Updated Records
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.order_items` target
USING
  (SELECT DISTINCT
    *,
    TIMESTAMP_MILLIS(SAFE_CAST(updated_at AS INT64)) as derived_updated_at,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.order_items`) source
ON target.order_item_id = source.order_item_id AND target.is_active = true
WHEN NOT MATCHED THEN
    INSERT (order_item_id, order_id, product_id, quantity, price, updated_at, effective_start_date, effective_end_date, is_active)
    VALUES (source.order_item_id, source.order_id, source.product_id, source.quantity, source.price, source.updated_at, source.effective_start_date, source.effective_end_date, source.is_active);

------------------------------CUSTOMER REVIEWS-----------------------------------
    --Step 1: Create the customer_reviews Table in the Silver Layer
CREATE TABLE IF NOT EXISTS `project-e89263b7-f16e-4dc3-9db.silver_dataset.customer_reviews`
(
    id STRING,
    customer_id INT64,
    product_id INT64,
    rating INT64,
    review_text STRING,
    review_date STRING,
    effective_start_date TIMESTAMP,
    effective_end_date TIMESTAMP,
    is_active BOOL
);
----Step 2: full load
INSERT INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.customer_reviews`
(
  customer_id,
  id,
  product_id,
  rating,
  review_date,
  effective_start_date,
  effective_end_date,
  is_active
)
SELECT
    *,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.customer_reviews`

--Step 2: Update Existing Active Records if There Are Changes
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.customer_reviews` target
USING
  (SELECT
    *,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.customer_reviews`) source
ON target.id = source.id AND target.is_active = true
WHEN MATCHED AND
            (
             target.customer_id != source.customer_id OR
             target.product_id != source.product_id OR
             target.rating != source.rating OR
             target.review_text != source.review_text OR
             target.review_date != source.review_date
            )
    THEN UPDATE SET
        target.is_active = false,
        target.effective_end_date = current_timestamp();

--Step 3: Insert New or Updated Records
MERGE INTO `project-e89263b7-f16e-4dc3-9db.silver_dataset.customer_reviews` target
USING
  (SELECT
    *,
    CURRENT_TIMESTAMP() AS effective_start_date,
    CURRENT_TIMESTAMP() AS effective_end_date,
    TRUE AS is_active
  FROM `project-e89263b7-f16e-4dc3-9db.bronze_dataset.customer_reviews`) source
ON target.id = source.id AND target.is_active = true
WHEN NOT MATCHED THEN
    INSERT (id, customer_id, product_id, rating, review_text, review_date, effective_start_date, effective_end_date, is_active)
    VALUES (source.id, source.customer_id, source.product_id, source.rating, source.review_text, source.review_date, source.effective_start_date, source.effective_end_date, source.is_active);
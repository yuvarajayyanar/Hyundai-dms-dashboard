-- =============================================================================
-- HYUNDAI NEXT-GEN DEALERSHIP MANAGEMENT SYSTEM (DMS)
-- Highly Normalized MySQL Schema — 12 Tables
-- Author: Hyundai Autoever Developer Team
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- TABLE 1: car_types — Master data for vehicle categories
-- =============================================================================
DROP TABLE IF EXISTS car_types;
CREATE TABLE car_types (
    car_type_id   INT AUTO_INCREMENT PRIMARY KEY,
    type_name     VARCHAR(50)  NOT NULL UNIQUE COMMENT 'e.g. SUV, Sedan, Hatchback, MPV',
    description   VARCHAR(255) DEFAULT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_car_types_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 2: models — Vehicle model master
-- =============================================================================
DROP TABLE IF EXISTS models;
CREATE TABLE models (
    model_id      INT AUTO_INCREMENT PRIMARY KEY,
    car_type_id   INT          NOT NULL,
    model_name    VARCHAR(100) NOT NULL COMMENT 'e.g. Creta, Venue, i20, Tucson',
    model_year    YEAR         NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_model_name_year (model_name, model_year),
    INDEX idx_models_car_type (car_type_id),
    INDEX idx_models_active   (is_active),

    CONSTRAINT fk_models_car_type
        FOREIGN KEY (car_type_id) REFERENCES car_types(car_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 3: variants — Trim / variant within a model
-- =============================================================================
DROP TABLE IF EXISTS variants;
CREATE TABLE variants (
    variant_id        INT AUTO_INCREMENT PRIMARY KEY,
    model_id          INT            NOT NULL,
    variant_name      VARCHAR(100)   NOT NULL COMMENT 'e.g. SX(O) Turbo DCT, E, S, SX',
    fuel_type         ENUM('Petrol','Diesel','Electric','Hybrid','CNG') NOT NULL DEFAULT 'Petrol',
    transmission      ENUM('Manual','Automatic','DCT','iMT','CVT')     NOT NULL DEFAULT 'Manual',
    engine_cc         INT            DEFAULT NULL COMMENT 'Engine displacement in cc',
    ex_showroom_price DECIMAL(12,2)  NOT NULL COMMENT 'Ex-showroom price in INR',
    is_active         TINYINT(1)     NOT NULL DEFAULT 1,
    created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_variants_model    (model_id),
    INDEX idx_variants_fuel     (fuel_type),
    INDEX idx_variants_price    (ex_showroom_price),

    CONSTRAINT fk_variants_model
        FOREIGN KEY (model_id) REFERENCES models(model_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 4: colours — Available colour palette
-- =============================================================================
DROP TABLE IF EXISTS colours;
CREATE TABLE colours (
    colour_id   INT AUTO_INCREMENT PRIMARY KEY,
    colour_name VARCHAR(60)  NOT NULL UNIQUE COMMENT 'e.g. Phantom Black, Titan Grey',
    hex_code    CHAR(7)      DEFAULT NULL COMMENT '#RRGGBB format',
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_colours_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 5: plants — Manufacturing / assembly plants
-- =============================================================================
DROP TABLE IF EXISTS plants;
CREATE TABLE plants (
    plant_id     INT AUTO_INCREMENT PRIMARY KEY,
    plant_name   VARCHAR(100) NOT NULL,
    city         VARCHAR(80)  NOT NULL,
    state        VARCHAR(80)  NOT NULL,
    country      VARCHAR(60)  NOT NULL DEFAULT 'India',
    capacity     INT          DEFAULT NULL COMMENT 'Annual production capacity',
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_plant_name_city (plant_name, city),
    INDEX idx_plants_state (state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 6: dealers — Authorized dealership groups
-- =============================================================================
DROP TABLE IF EXISTS dealers;
CREATE TABLE dealers (
    dealer_id    INT AUTO_INCREMENT PRIMARY KEY,
    dealer_name  VARCHAR(150) NOT NULL,
    dealer_code  VARCHAR(20)  NOT NULL UNIQUE COMMENT 'Internal unique dealer code',
    contact_email VARCHAR(150) DEFAULT NULL,
    contact_phone VARCHAR(20)  DEFAULT NULL,
    gst_number   VARCHAR(20)  DEFAULT NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_dealers_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 7: branches — Physical showroom / branch of a dealer
-- =============================================================================
DROP TABLE IF EXISTS branches;
CREATE TABLE branches (
    branch_id    INT AUTO_INCREMENT PRIMARY KEY,
    dealer_id    INT          NOT NULL,
    branch_name  VARCHAR(150) NOT NULL,
    branch_code  VARCHAR(20)  NOT NULL UNIQUE,
    city         VARCHAR(80)  NOT NULL,
    state        VARCHAR(80)  NOT NULL,
    pincode      VARCHAR(10)  DEFAULT NULL,
    address      TEXT         DEFAULT NULL,
    phone        VARCHAR(20)  DEFAULT NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_branches_dealer (dealer_id),
    INDEX idx_branches_city   (city),
    INDEX idx_branches_state  (state),

    CONSTRAINT fk_branches_dealer
        FOREIGN KEY (dealer_id) REFERENCES dealers(dealer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 8: employees — Sales / service staff linked to branches
-- =============================================================================
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    employee_id   INT AUTO_INCREMENT PRIMARY KEY,
    branch_id     INT          NOT NULL,
    first_name    VARCHAR(60)  NOT NULL,
    last_name     VARCHAR(60)  NOT NULL,
    email         VARCHAR(150) DEFAULT NULL,
    phone         VARCHAR(20)  DEFAULT NULL,
    role          ENUM('Sales Executive','Sales Manager','Service Advisor',
                       'Service Manager','General Manager','Admin') NOT NULL DEFAULT 'Sales Executive',
    hire_date     DATE         NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_employees_branch (branch_id),
    INDEX idx_employees_role   (role),

    CONSTRAINT fk_employees_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 9: customers — Customer master
-- =============================================================================
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(60)  NOT NULL,
    last_name     VARCHAR(60)  NOT NULL,
    email         VARCHAR(150) DEFAULT NULL,
    phone         VARCHAR(20)  NOT NULL,
    address       TEXT         DEFAULT NULL,
    city          VARCHAR(80)  DEFAULT NULL,
    state         VARCHAR(80)  DEFAULT NULL,
    pincode       VARCHAR(10)  DEFAULT NULL,
    date_of_birth DATE         DEFAULT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_customers_city  (city),
    INDEX idx_customers_phone (phone),
    INDEX idx_customers_name  (last_name, first_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 10: enquiries — Lead / enquiry management
-- =============================================================================
DROP TABLE IF EXISTS enquiries;
CREATE TABLE enquiries (
    enquiry_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT  NOT NULL,
    branch_id      INT  NOT NULL,
    employee_id    INT  DEFAULT NULL COMMENT 'Assigned sales executive',
    variant_id     INT  NOT NULL,
    colour_id      INT  DEFAULT NULL COMMENT 'Preferred colour',
    enquiry_date   DATE NOT NULL,
    source         ENUM('Walk-in','Online','Referral','Campaign','Phone') NOT NULL DEFAULT 'Walk-in',
    status         ENUM('New','Follow-up','Test Drive','Negotiation',
                        'Converted','Lost') NOT NULL DEFAULT 'New',
    expected_purchase_date DATE DEFAULT NULL,
    remarks        TEXT DEFAULT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_enquiries_customer  (customer_id),
    INDEX idx_enquiries_branch    (branch_id),
    INDEX idx_enquiries_variant   (variant_id),
    INDEX idx_enquiries_status    (status),
    INDEX idx_enquiries_date      (enquiry_date),

    CONSTRAINT fk_enquiries_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enquiries_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enquiries_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_enquiries_variant
        FOREIGN KEY (variant_id) REFERENCES variants(variant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enquiries_colour
        FOREIGN KEY (colour_id) REFERENCES colours(colour_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 11: sales — Finalized vehicle sales / bookings
-- =============================================================================
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    sale_id        INT AUTO_INCREMENT PRIMARY KEY,
    enquiry_id     INT            DEFAULT NULL COMMENT 'Originating enquiry (nullable for walk-in direct)',
    customer_id    INT            NOT NULL,
    branch_id      INT            NOT NULL,
    employee_id    INT            NOT NULL COMMENT 'Sales executive who closed',
    variant_id     INT            NOT NULL,
    colour_id      INT            NOT NULL,
    plant_id       INT            DEFAULT NULL COMMENT 'Manufacturing plant allocated',
    sale_date      DATE           NOT NULL,
    vin_number     VARCHAR(20)    DEFAULT NULL COMMENT 'Vehicle Identification Number',
    ex_showroom_price DECIMAL(12,2) NOT NULL,
    road_tax       DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    insurance      DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    accessories    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    gst_percent    DECIMAL(5,2)   NOT NULL DEFAULT 28.00,
    gst_amount     DECIMAL(12,2)  GENERATED ALWAYS AS (
                       ROUND(ex_showroom_price * gst_percent / 100, 2)
                   ) STORED,
    total_on_road  DECIMAL(14,2)  GENERATED ALWAYS AS (
                       ROUND(ex_showroom_price + (ex_showroom_price * gst_percent / 100) + road_tax + insurance + accessories, 2)
                   ) STORED,
    delivery_status ENUM('Booked','Allocated','In-Transit','Delivered','Cancelled')
                       NOT NULL DEFAULT 'Booked',
    delivery_date  DATE           DEFAULT NULL,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_sales_customer   (customer_id),
    INDEX idx_sales_branch     (branch_id),
    INDEX idx_sales_employee   (employee_id),
    INDEX idx_sales_variant    (variant_id),
    INDEX idx_sales_date       (sale_date),
    INDEX idx_sales_delivery   (delivery_status),
    INDEX idx_sales_enquiry    (enquiry_id),

    CONSTRAINT fk_sales_enquiry
        FOREIGN KEY (enquiry_id) REFERENCES enquiries(enquiry_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_variant
        FOREIGN KEY (variant_id) REFERENCES variants(variant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_colour
        FOREIGN KEY (colour_id) REFERENCES colours(colour_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_plant
        FOREIGN KEY (plant_id) REFERENCES plants(plant_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- TABLE 12: payments — Payment transactions against a sale
-- =============================================================================
DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    sale_id        INT            NOT NULL,
    payment_date   DATE           NOT NULL,
    amount         DECIMAL(14,2)  NOT NULL,
    payment_mode   ENUM('Cash','Cheque','NEFT','UPI','Card','Finance') NOT NULL DEFAULT 'NEFT',
    reference_no   VARCHAR(80)    DEFAULT NULL COMMENT 'Transaction / cheque reference',
    status         ENUM('Pending','Completed','Failed','Refunded') NOT NULL DEFAULT 'Pending',
    remarks        TEXT           DEFAULT NULL,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_payments_sale   (sale_id),
    INDEX idx_payments_date   (payment_date),
    INDEX idx_payments_status (status),

    CONSTRAINT fk_payments_sale
        FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE payments;
TRUNCATE TABLE sales;
TRUNCATE TABLE enquiries;
TRUNCATE TABLE customers;
TRUNCATE TABLE employees;
TRUNCATE TABLE branches;
TRUNCATE TABLE dealers;
TRUNCATE TABLE plants;
TRUNCATE TABLE colours;
TRUNCATE TABLE variants;
TRUNCATE TABLE models;
TRUNCATE TABLE car_types;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------- Car Types ------------------------------------
INSERT INTO car_types (type_name, description) VALUES
('SUV',        'Sport Utility Vehicle'),
('Sedan',      'Sedan / Saloon body style'),
('Hatchback',  'Compact hatchback body style'),
('MPV',        'Multi-Purpose Vehicle'),
('Electric',   'Battery Electric Vehicle');

-- ----------------------------- Models ---------------------------------------
INSERT INTO models (car_type_id, model_name, model_year) VALUES
(1, 'Creta',   2025),
(1, 'Tucson',  2025),
(1, 'Venue',   2025),
(2, 'Verna',   2025),
(2, 'Aura',    2025),
(3, 'i20',     2025),
(3, 'Grand i10 Nios', 2025),
(4, 'Alcazar', 2025),
(5, 'Ioniq 5', 2025),
(5, 'Ioniq 6', 2025);

-- ----------------------------- Variants -------------------------------------
INSERT INTO variants (model_id, variant_name, fuel_type, transmission, engine_cc, ex_showroom_price) VALUES
-- Creta variants
(1, 'E',             'Petrol',  'Manual',    1497,  1099900.00),
(1, 'EX',            'Petrol',  'Manual',    1497,  1249900.00),
(1, 'S',             'Petrol',  'Manual',    1497,  1399900.00),
(1, 'S(O)',           'Petrol',  'iMT',      1497,  1499900.00),
(1, 'SX',            'Petrol',  'Automatic', 1497,  1699900.00),
(1, 'SX(O)',          'Diesel',  'Automatic', 1493,  1899900.00),
(1, 'SX(O) Turbo DCT','Petrol', 'DCT',       1482,  1999900.00),
-- Venue variants
(3, 'E',             'Petrol',  'Manual',    1197,   769900.00),
(3, 'S',             'Petrol',  'Manual',    1197,   899900.00),
(3, 'SX',            'Petrol',  'Automatic', 1197,  1099900.00),
(3, 'SX(O) Turbo DCT','Petrol', 'DCT',       998,  1249900.00),
-- i20 variants
(6, 'Magna',         'Petrol',  'Manual',    1197,   699900.00),
(6, 'Sportz',        'Petrol',  'Manual',    1197,   849900.00),
(6, 'Asta',          'Petrol',  'Automatic', 1197,   999900.00),
(6, 'Asta(O) Turbo DCT','Petrol','DCT',      998,  1149900.00),
-- Verna variants
(4, 'EX',            'Petrol',  'Manual',    1497,  1099900.00),
(4, 'S',             'Petrol',  'Manual',    1497,  1249900.00),
(4, 'SX',            'Petrol',  'Automatic', 1497,  1499900.00),
(4, 'SX(O) Turbo DCT','Petrol', 'DCT',       1482,  1799900.00),
-- Tucson variants
(2, 'GL',            'Petrol',  'Automatic', 1999,  2799900.00),
(2, 'GLS',           'Diesel',  'Automatic', 1995,  3099900.00),
(2, 'Signature',     'Diesel',  'Automatic', 1995,  3499900.00),
-- Alcazar variants
(8, 'Prestige',      'Petrol',  'Automatic', 1999,  1699900.00),
(8, 'Platinum',      'Diesel',  'Automatic', 1493,  2099900.00),
(8, 'Signature',     'Diesel',  'Automatic', 1493,  2299900.00),
-- Ioniq 5
(9, 'Standard Range','Electric','Automatic', NULL,  4499900.00),
(9, 'Long Range AWD','Electric','Automatic', NULL,  4999900.00),
-- Ioniq 6
(10,'Standard Range','Electric','Automatic', NULL,  4599900.00),
(10,'Long Range',    'Electric','Automatic', NULL,  5199900.00);

-- ----------------------------- Colours --------------------------------------
INSERT INTO colours (colour_name, hex_code) VALUES
('Phantom Black',       '#1a1a2e'),
('Titan Grey',          '#6b7b8d'),
('Polar White',         '#f5f5f5'),
('Fiery Red',           '#c0392b'),
('Typhoon Silver',      '#bdc3c7'),
('Starry Night',        '#2c3e50'),
('Atlas White',         '#ecf0f1'),
('Robust Emerald',      '#27ae60'),
('Abyss Black Pearl',   '#0d0d0d'),
('Ranger Khaki',        '#a0855b'),
('Lucid Lime',          '#a8d948'),
('Ocean Blue',          '#2980b9');

-- ----------------------------- Plants ---------------------------------------
INSERT INTO plants (plant_name, city, state, country, capacity) VALUES
('Hyundai Motor India Plant 1', 'Sriperumbudur', 'Tamil Nadu',  'India', 300000),
('Hyundai Motor India Plant 2', 'Sriperumbudur', 'Tamil Nadu',  'India', 300000),
('Hyundai Motor India Plant 3', 'Talegaon',      'Maharashtra', 'India', 200000),
('Hyundai EV Plant',            'Sriperumbudur', 'Tamil Nadu',  'India',  50000);

-- ----------------------------- Dealers --------------------------------------
INSERT INTO dealers (dealer_name, dealer_code, contact_email, contact_phone, gst_number) VALUES
('Pioneer Hyundai',    'DLR-001', 'info@pioneerhyundai.in',  '+91-44-23456789', '33AABCP1234A1Z5'),
('Prestige Hyundai',   'DLR-002', 'info@prestigehyundai.in', '+91-80-34567890', '29AABCP5678B1Z3'),
('Lakshmi Hyundai',    'DLR-003', 'info@lakshmihyundai.in',  '+91-40-45678901', '36AABCP9012C1Z1'),
('Capital Hyundai',    'DLR-004', 'info@capitalhyundai.in',   '+91-11-56789012', '07AABCP3456D1Z9'),
('Western Hyundai',    'DLR-005', 'info@westernhyundai.in',  '+91-22-67890123', '27AABCP7890E1Z7');

-- ----------------------------- Branches -------------------------------------
INSERT INTO branches (dealer_id, branch_name, branch_code, city, state, pincode, address, phone) VALUES
(1, 'Pioneer Hyundai — Anna Nagar',   'BR-001', 'Chennai',   'Tamil Nadu',    '600040', 'Plot 23, Anna Nagar Main Rd, Chennai',        '+91-44-23456701'),
(1, 'Pioneer Hyundai — OMR',          'BR-002', 'Chennai',   'Tamil Nadu',    '600096', '123, OMR Thoraipakkam, Chennai',               '+91-44-23456702'),
(2, 'Prestige Hyundai — Whitefield',   'BR-003', 'Bengaluru', 'Karnataka',     '560066', 'ITPL Main Road, Whitefield, Bengaluru',        '+91-80-34567801'),
(2, 'Prestige Hyundai — Koramangala',  'BR-004', 'Bengaluru', 'Karnataka',     '560034', '5th Block, Koramangala, Bengaluru',            '+91-80-34567802'),
(3, 'Lakshmi Hyundai — Banjara Hills', 'BR-005', 'Hyderabad', 'Telangana',     '500034', 'Road No. 12, Banjara Hills, Hyderabad',        '+91-40-45678901'),
(3, 'Lakshmi Hyundai — Gachibowli',    'BR-006', 'Hyderabad', 'Telangana',     '500032', 'Gachibowli Main Road, Hyderabad',              '+91-40-45678902'),
(4, 'Capital Hyundai — Rajouri Garden', 'BR-007', 'New Delhi', 'Delhi',         '110027', 'A-12, Rajouri Garden, New Delhi',              '+91-11-56789001'),
(4, 'Capital Hyundai — Dwarka',         'BR-008', 'New Delhi', 'Delhi',         '110075', 'Sector 21, Dwarka, New Delhi',                 '+91-11-56789002'),
(5, 'Western Hyundai — Andheri',        'BR-009', 'Mumbai',    'Maharashtra',   '400069', 'Western Express Highway, Andheri East, Mumbai','+91-22-67890101'),
(5, 'Western Hyundai — Thane',          'BR-010', 'Mumbai',    'Maharashtra',   '400601', 'Ghodbunder Road, Thane West',                  '+91-22-67890102');

-- ----------------------------- Employees ------------------------------------
INSERT INTO employees (branch_id, first_name, last_name, email, phone, role, hire_date) VALUES
(1,  'Anand',   'Kumar',     'anand.kumar@pioneerhyundai.in',   '+91-9876543001', 'Sales Manager',    '2021-06-01'),
(1,  'Priya',   'Sharma',    'priya.sharma@pioneerhyundai.in',  '+91-9876543002', 'Sales Executive',  '2022-01-15'),
(2,  'Ravi',    'Verma',     'ravi.verma@pioneerhyundai.in',    '+91-9876543003', 'Sales Executive',  '2022-03-10'),
(3,  'Kavitha', 'Reddy',     'kavitha.reddy@prestigehyundai.in','+91-9876543004', 'Sales Manager',    '2020-11-01'),
(3,  'Suresh',  'Patel',     'suresh.patel@prestigehyundai.in', '+91-9876543005', 'Sales Executive',  '2023-02-20'),
(4,  'Deepak',  'Nair',      'deepak.nair@prestigehyundai.in',  '+91-9876543006', 'Sales Executive',  '2021-08-12'),
(5,  'Meena',   'Iyer',      'meena.iyer@lakshmihyundai.in',    '+91-9876543007', 'Sales Manager',    '2019-05-01'),
(5,  'Arjun',   'Singh',     'arjun.singh@lakshmihyundai.in',   '+91-9876543008', 'Sales Executive',  '2022-07-01'),
(6,  'Fatima',  'Khan',      'fatima.khan@lakshmihyundai.in',   '+91-9876543009', 'Sales Executive',  '2023-01-10'),
(7,  'Rajesh',  'Gupta',     'rajesh.gupta@capitalhyundai.in',  '+91-9876543010', 'Sales Manager',    '2020-03-15'),
(7,  'Sneha',   'Tiwari',    'sneha.tiwari@capitalhyundai.in',  '+91-9876543011', 'Sales Executive',  '2022-09-01'),
(8,  'Vikram',  'Joshi',     'vikram.joshi@capitalhyundai.in',  '+91-9876543012', 'Sales Executive',  '2021-12-01'),
(9,  'Pooja',   'Malhotra',  'pooja.malhotra@westernhyundai.in','+91-9876543013', 'Sales Manager',    '2020-07-20'),
(9,  'Nikhil',  'Deshmukh',  'nikhil.deshmukh@westernhyundai.in','+91-9876543014','Sales Executive',  '2023-04-01'),
(10, 'Aarti',   'Chavan',    'aarti.chavan@westernhyundai.in',  '+91-9876543015', 'Sales Executive',  '2022-06-15');

-- ----------------------------- Customers ------------------------------------
INSERT INTO customers (first_name, last_name, email, phone, city, state, pincode) VALUES
('Amit',     'Mehta',      'amit.mehta@email.com',       '+91-9000000001', 'Chennai',   'Tamil Nadu',   '600040'),
('Neha',     'Agarwal',    'neha.agarwal@email.com',     '+91-9000000002', 'Chennai',   'Tamil Nadu',   '600096'),
('Rohit',    'Kapoor',     'rohit.kapoor@email.com',     '+91-9000000003', 'Bengaluru', 'Karnataka',    '560066'),
('Sanya',    'Malhotra',   'sanya.malhotra@email.com',   '+91-9000000004', 'Bengaluru', 'Karnataka',    '560034'),
('Karan',    'Oberoi',     'karan.oberoi@email.com',     '+91-9000000005', 'Hyderabad', 'Telangana',    '500034'),
('Divya',    'Jain',       'divya.jain@email.com',       '+91-9000000006', 'Hyderabad', 'Telangana',    '500032'),
('Manish',   'Tiwari',     'manish.tiwari@email.com',    '+91-9000000007', 'New Delhi', 'Delhi',        '110027'),
('Aisha',    'Bano',       'aisha.bano@email.com',       '+91-9000000008', 'New Delhi', 'Delhi',        '110075'),
('Vijay',    'Desai',      'vijay.desai@email.com',      '+91-9000000009', 'Mumbai',    'Maharashtra',  '400069'),
('Lakshmi',  'Nambiar',    'lakshmi.nambiar@email.com',  '+91-9000000010', 'Mumbai',    'Maharashtra',  '400601'),
('Sunil',    'Rawat',      'sunil.rawat@email.com',      '+91-9000000011', 'Chennai',   'Tamil Nadu',   '600040'),
('Prachi',   'Kulkarni',   'prachi.kulkarni@email.com',  '+91-9000000012', 'Bengaluru', 'Karnataka',    '560066'),
('Harish',   'Menon',      'harish.menon@email.com',     '+91-9000000013', 'Hyderabad', 'Telangana',    '500034'),
('Tanvi',    'Saxena',     'tanvi.saxena@email.com',     '+91-9000000014', 'New Delhi', 'Delhi',        '110027'),
('Gaurav',   'Rane',       'gaurav.rane@email.com',      '+91-9000000015', 'Mumbai',    'Maharashtra',  '400069');

-- ----------------------------- Enquiries ------------------------------------
INSERT INTO enquiries (customer_id, branch_id, employee_id, variant_id, colour_id, enquiry_date, source, status, expected_purchase_date, remarks) VALUES
(1,  1,  2,  5,  1,  '2025-01-05', 'Walk-in',  'Converted',  '2025-01-20', 'Customer interested in Creta SX'),
(2,  2,  3,  7,  3,  '2025-01-12', 'Online',   'Converted',  '2025-02-01', 'Wants top-end Creta Turbo'),
(3,  3,  5,  10, 6,  '2025-02-03', 'Referral', 'Converted',  '2025-02-20', 'Referred by existing customer'),
(4,  4,  6,  14, 4,  '2025-02-15', 'Walk-in',  'Converted',  '2025-03-01', 'Test drove i20 Asta'),
(5,  5,  8,  19, 1,  '2025-03-01', 'Campaign', 'Converted',  '2025-03-15', 'Verna SX(O) — responded to campaign'),
(6,  6,  9,  22, 12, '2025-03-10', 'Online',   'Converted',  '2025-03-25', 'Interested in Tucson'),
(7,  7,  11, 1,  5,  '2025-04-02', 'Walk-in',  'Converted',  '2025-04-15', 'Budget entry Creta'),
(8,  8,  12, 25, 7,  '2025-04-18', 'Phone',    'Converted',  '2025-05-01', 'Alcazar Signature diesel'),
(9,  9,  14, 27, 9,  '2025-05-05', 'Walk-in',  'Converted',  '2025-05-20', 'Ioniq 5 Long Range'),
(10, 10, 15, 3,  2,  '2025-05-20', 'Referral', 'Converted',  '2025-06-01', 'Creta S variant'),
(11, 1,  2,  12, 3,  '2025-06-10', 'Online',   'Converted',  '2025-06-20', 'i20 Magna — first car buyer'),
(12, 3,  5,  16, 1,  '2025-06-22', 'Walk-in',  'Converted',  '2025-07-05', 'Verna EX — compact sedan'),
(13, 5,  8,  6,  6,  '2025-07-05', 'Campaign', 'Converted',  '2025-07-20', 'Creta SX(O) diesel'),
(14, 7,  11, 9,  12, '2025-07-15', 'Walk-in',  'Converted',  '2025-08-01', 'Venue S — city driving'),
(15, 9,  14, 20, 5,  '2025-08-01', 'Online',   'Converted',  '2025-08-15', 'Verna top-end Turbo DCT'),
(1,  1,  2,  21, 1,  '2025-08-20', 'Walk-in',  'Follow-up',  '2025-09-10', 'Considering Tucson upgrade'),
(3,  3,  5,  28, 3,  '2025-09-01', 'Online',   'New',        '2025-10-01', 'Ioniq 6 enquiry'),
(5,  5,  8,  15, 8,  '2025-09-10', 'Walk-in',  'Follow-up',  '2025-10-15', 'Spouse interested in i20 Asta(O)'),
(7,  7,  11, 23, 4,  '2025-09-20', 'Referral', 'Lost',       NULL,          'Price concern for Alcazar'),
(9,  9,  14, 29, 12, '2025-10-01', 'Online',   'Negotiation','2025-11-01', 'Ioniq 6 Standard Range'),
(2,  2,  3,  4,  2,  '2025-10-10', 'Walk-in',  'Converted',  '2025-10-20', 'Creta S(O) iMT'),
(4,  4,  6,  13, 11, '2025-10-18', 'Online',   'Converted',  '2025-11-01', 'i20 Sportz — lime green'),
(6,  6,  9,  8,  10, '2025-11-01', 'Walk-in',  'Converted',  '2025-11-15', 'Venue E — entry level'),
(8,  8,  12, 2,  7,  '2025-11-10', 'Phone',    'Converted',  '2025-11-25', 'Creta EX — for family'),
(10, 10, 15, 11, 9,  '2025-11-20', 'Campaign', 'Converted',  '2025-12-05', 'Venue SX(O) Turbo'),
(11, 1,  2,  26, 1,  '2025-12-01', 'Walk-in',  'Converted',  '2025-12-15', 'Ioniq 5 Standard Range'),
(13, 5,  8,  17, 3,  '2025-12-05', 'Referral', 'Converted',  '2025-12-20', 'Verna S — value for money'),
(14, 7,  11, 24, 5,  '2025-12-10', 'Walk-in',  'Converted',  '2025-12-25', 'Alcazar Platinum diesel'),
(15, 9,  14, 5,  12, '2025-12-15', 'Online',   'Converted',  '2025-12-28', 'Creta SX auto — upgrade'),
(12, 4,  6,  22, 6,  '2025-12-20', 'Walk-in',  'Converted',  '2026-01-05', 'Tucson GLS diesel');

-- ----------------------------- Sales ----------------------------------------
INSERT INTO sales (enquiry_id, customer_id, branch_id, employee_id, variant_id, colour_id, plant_id, sale_date, vin_number, ex_showroom_price, road_tax, insurance, accessories, gst_percent, delivery_status, delivery_date) VALUES
(1,  1,  1,  2,  5,  1,  1, '2025-01-18', 'MALBA51BLHM000101', 1699900.00, 42000.00, 45000.00, 25000.00, 28.00, 'Delivered', '2025-02-01'),
(2,  2,  2,  3,  7,  3,  1, '2025-01-30', 'MALBA51BLHM000102', 1999900.00, 48000.00, 52000.00, 35000.00, 28.00, 'Delivered', '2025-02-15'),
(3,  3,  3,  5,  10, 6,  2, '2025-02-18', 'MALBB51BLHM000201', 1099900.00, 28000.00, 32000.00, 15000.00, 28.00, 'Delivered', '2025-03-05'),
(4,  4,  4,  6,  14, 4,  2, '2025-02-28', 'MALBC51BLHM000301',  999900.00, 25000.00, 28000.00, 12000.00, 28.00, 'Delivered', '2025-03-12'),
(5,  5,  5,  8,  19, 1,  1, '2025-03-14', 'MALBD51BLHM000401', 1499900.00, 38000.00, 42000.00, 20000.00, 28.00, 'Delivered', '2025-03-28'),
(6,  6,  6,  9,  22, 12, 3, '2025-03-24', 'MALBE51BLHM000501', 3099900.00, 75000.00, 85000.00, 40000.00, 28.00, 'Delivered', '2025-04-10'),
(7,  7,  7,  11, 1,  5,  1, '2025-04-12', 'MALBF51BLHM000601', 1099900.00, 28000.00, 30000.00, 10000.00, 28.00, 'Delivered', '2025-04-25'),
(8,  8,  8,  12, 25, 7,  3, '2025-04-30', 'MALBG51BLHM000701', 2299900.00, 55000.00, 62000.00, 30000.00, 28.00, 'Delivered', '2025-05-15'),
(9,  9,  9,  14, 27, 9,  4, '2025-05-18', 'MALBH51BLHM000801', 4999900.00, 120000.00,110000.00,50000.00, 28.00, 'Delivered', '2025-06-01'),
(10, 10, 10, 15, 3,  2,  1, '2025-05-30', 'MALBI51BLHM000901', 1399900.00, 35000.00, 38000.00, 18000.00, 28.00, 'Delivered', '2025-06-12'),
(11, 11, 1,  2,  12, 3,  2, '2025-06-18', 'MALBJ51BLHM001001',  699900.00, 18000.00, 22000.00,  8000.00, 28.00, 'Delivered', '2025-07-01'),
(12, 12, 3,  5,  16, 1,  1, '2025-07-02', 'MALBK51BLHM001101', 1099900.00, 28000.00, 30000.00, 12000.00, 28.00, 'Delivered', '2025-07-18'),
(13, 13, 5,  8,  6,  6,  1, '2025-07-18', 'MALBL51BLHM001201', 1899900.00, 45000.00, 50000.00, 28000.00, 28.00, 'Delivered', '2025-08-02'),
(14, 14, 7,  11, 9,  12, 2, '2025-07-30', 'MALBM51BLHM001301',  899900.00, 23000.00, 25000.00, 10000.00, 28.00, 'Delivered', '2025-08-12'),
(15, 15, 9,  14, 20, 5,  1, '2025-08-14', 'MALBN51BLHM001401', 1799900.00, 42000.00, 48000.00, 25000.00, 28.00, 'Delivered', '2025-08-28'),
(21, 2,  2,  3,  4,  2,  1, '2025-10-18', 'MALBO51BLHM001501', 1499900.00, 38000.00, 42000.00, 20000.00, 28.00, 'Delivered', '2025-11-01'),
(22, 4,  4,  6,  13, 11, 2, '2025-10-30', 'MALBP51BLHM001601',  849900.00, 22000.00, 25000.00,  8000.00, 28.00, 'Delivered', '2025-11-12'),
(23, 6,  6,  9,  8,  10, 2, '2025-11-12', 'MALBQ51BLHM001701',  769900.00, 20000.00, 22000.00,  7000.00, 28.00, 'Delivered', '2025-11-25'),
(24, 8,  8,  12, 2,  7,  1, '2025-11-24', 'MALBR51BLHM001801', 1249900.00, 32000.00, 35000.00, 15000.00, 28.00, 'Delivered', '2025-12-08'),
(25, 10, 10, 15, 11, 9,  2, '2025-11-30', 'MALBS51BLHM001901', 1249900.00, 32000.00, 35000.00, 15000.00, 28.00, 'Delivered', '2025-12-12'),
(26, 11, 1,  2,  26, 1,  4, '2025-12-12', 'MALBT51BLHM002001', 4499900.00, 110000.00,100000.00,45000.00, 28.00, 'Delivered', '2025-12-28'),
(27, 13, 5,  8,  17, 3,  1, '2025-12-18', 'MALBU51BLHM002101', 1249900.00, 32000.00, 35000.00, 12000.00, 28.00, 'Delivered', '2026-01-05'),
(28, 14, 7,  11, 24, 5,  3, '2025-12-22', 'MALBV51BLHM002201', 2099900.00, 50000.00, 58000.00, 28000.00, 28.00, 'In-Transit', NULL),
(29, 15, 9,  14, 5,  12, 1, '2025-12-26', 'MALBW51BLHM002301', 1699900.00, 42000.00, 45000.00, 22000.00, 28.00, 'In-Transit', NULL),
(30, 12, 4,  6,  22, 6,  3, '2026-01-04', 'MALBX51BLHM002401', 3099900.00, 75000.00, 85000.00, 40000.00, 28.00, 'Booked',     NULL);

-- ----------------------------- Payments -------------------------------------
INSERT INTO payments (sale_id, payment_date, amount, payment_mode, reference_no, status, remarks) VALUES
-- Sale 1 — Paid in full
(1,  '2025-01-18', 500000.00,   'NEFT',    'NEFT20250118001', 'Completed', 'Booking amount'),
(1,  '2025-01-28', 1742872.00,  'Finance', 'FIN20250128001',  'Completed', 'Final amount via HDFC finance'),
-- Sale 2
(2,  '2025-01-30', 600000.00,   'UPI',     'UPI20250130001',  'Completed', 'Booking payment'),
(2,  '2025-02-10', 2094872.00,  'Finance', 'FIN20250210001',  'Completed', 'Full settlement via SBI'),
-- Sale 3
(3,  '2025-02-18', 300000.00,   'Card',    'CARD20250218001', 'Completed', 'Card payment booking'),
(3,  '2025-03-01', 1142872.00,  'NEFT',    'NEFT20250301001', 'Completed', 'Balance payment'),
-- Sale 4
(4,  '2025-02-28', 250000.00,   'Cash',    'CASH20250228001', 'Completed', 'Cash booking'),
(4,  '2025-03-08', 1062872.00,  'Finance', 'FIN20250308001',  'Completed', 'ICICI car loan'),
-- Sale 5
(5,  '2025-03-14', 400000.00,   'NEFT',    'NEFT20250314001', 'Completed', 'Online booking'),
(5,  '2025-03-25', 1619872.00,  'Finance', 'FIN20250325001',  'Completed', 'Axis bank finance'),
-- Sale 6
(6,  '2025-03-24', 800000.00,   'Cheque',  'CHQ20250324001',  'Completed', 'Booking via cheque'),
(6,  '2025-04-05', 3527872.00,  'Finance', 'FIN20250405001',  'Completed', 'Kotak finance'),
-- Sale 7
(7,  '2025-04-12', 1205872.00,  'UPI',     'UPI20250412001',  'Completed', 'Full payment via UPI'),
-- Sale 8
(8,  '2025-04-30', 600000.00,   'NEFT',    'NEFT20250430001', 'Completed', 'Booking payment'),
(8,  '2025-05-10', 2490872.00,  'Finance', 'FIN20250510001',  'Completed', 'HDFC finance'),
-- Sale 9
(9,  '2025-05-18', 1500000.00,  'NEFT',    'NEFT20250518001', 'Completed', 'Booking for Ioniq 5'),
(9,  '2025-05-28', 5179872.00,  'Finance', 'FIN20250528001',  'Completed', 'Green car loan'),
-- Sale 10
(10, '2025-05-30', 350000.00,   'UPI',     'UPI20250530001',  'Completed', 'UPI booking'),
(10, '2025-06-08', 1433872.00,  'NEFT',    'NEFT20250608001', 'Completed', 'Balance cleared'),
-- Sale 11
(11, '2025-06-18', 943872.00,   'Cash',    'CASH20250618001', 'Completed', 'Full payment cash'),
-- Sale 12
(12, '2025-07-02', 300000.00,   'NEFT',    'NEFT20250702001', 'Completed', 'Booking'),
(12, '2025-07-15', 1097872.00,  'Finance', 'FIN20250715001',  'Completed', 'SBI car loan'),
-- Sale 13
(13, '2025-07-18', 500000.00,   'Card',    'CARD20250718001', 'Completed', 'Card booking'),
(13, '2025-07-28', 1970872.00,  'Finance', 'FIN20250728001',  'Completed', 'Bajaj finance'),
-- Sale 14
(14, '2025-07-30', 1045872.00,  'UPI',     'UPI20250730001',  'Completed', 'Full UPI payment'),
-- Sale 15
(15, '2025-08-14', 450000.00,   'NEFT',    'NEFT20250814001', 'Completed', 'Booking'),
(15, '2025-08-25', 1914872.00,  'Finance', 'FIN20250825001',  'Completed', 'Kotak car loan'),
-- Sale 16
(16, '2025-10-18', 400000.00,   'UPI',     'UPI20251018001',  'Completed', 'Booking'),
(16, '2025-10-28', 1519872.00,  'Finance', 'FIN20251028001',  'Completed', 'Balance via finance'),
-- Sale 17
(17, '2025-10-30', 992872.00,   'NEFT',    'NEFT20251030001', 'Completed', 'Full NEFT payment'),
-- Sale 18
(18, '2025-11-12', 906872.00,   'Cash',    'CASH20251112001', 'Completed', 'Full cash payment'),
-- Sale 19
(19, '2025-11-24', 350000.00,   'NEFT',    'NEFT20251124001', 'Completed', 'Booking'),
(19, '2025-12-05', 1368872.00,  'Finance', 'FIN20251205001',  'Completed', 'Finance balance'),
-- Sale 20
(20, '2025-11-30', 300000.00,   'Card',    'CARD20251130001', 'Completed', 'Card booking'),
(20, '2025-12-10', 1334872.00,  'NEFT',    'NEFT20251210001', 'Completed', 'Balance NEFT'),
-- Sale 21
(21, '2025-12-12', 1200000.00,  'NEFT',    'NEFT20251212001', 'Completed', 'Booking for Ioniq 5'),
(21, '2025-12-24', 4914872.00,  'Finance', 'FIN20251224001',  'Completed', 'EV green finance'),
-- Sale 22
(22, '2025-12-18', 1428872.00,  'UPI',     'UPI20251218001',  'Completed', 'Full UPI payment'),
-- Sale 23
(23, '2025-12-22', 600000.00,   'NEFT',    'NEFT20251222001', 'Completed', 'Booking Alcazar'),
(23, '2025-12-30', 2285872.00,  'Finance', 'FIN20251230001',  'Pending',   'Finance in progress'),
-- Sale 24
(24, '2025-12-26', 500000.00,   'UPI',     'UPI20251226001',  'Completed', 'Booking Creta SX'),
(24, '2026-01-10', 1308872.00,  'Finance', 'PENDING001',      'Pending',   'Awaiting finance approval'),
-- Sale 25
(25, '2026-01-04', 800000.00,   'Cheque',  'CHQ20260104001',  'Completed', 'Booking Tucson GLS');

-- ============================================================================
-- INS3064 - Homework 06: Database Design - Online Bookstore
-- Student: Pham Hoang Long (23070638)
-- File: bookstore_db.sql
-- Run in phpMyAdmin (SQL tab / Import) or: source bookstore_db.sql
-- (Chạy trong phpMyAdmin tab SQL hoặc Import, hoặc dùng lệnh source)
-- ============================================================================

/* ============================================================================
   NORMALIZATION (3NF) EXPLANATION / GIẢI THÍCH CHUẨN HÓA 3NF
   ============================================================================

   1NF - Atomic values, no repeating groups
         (Mỗi ô chỉ 1 giá trị, không có nhóm cột lặp)
   - A book can have many authors and many categories. Instead of columns
     like author1, author2 or a text "Fiction, Kids", each link is ONE row
     in the junction tables book_authors and book_categories.
     (Một sách có nhiều tác giả và nhiều thể loại. Thay vì cột author1,
      author2 hay chuỗi "Fiction, Kids", mỗi liên kết là MỘT dòng trong
      bảng trung gian book_authors và book_categories.)
   - An order has many lines, so each line is one row in order_items.
     (Một đơn có nhiều dòng hàng, mỗi dòng là một row trong order_items.)
   - Every table has a PRIMARY KEY. (Mọi bảng đều có khóa chính.)

   2NF - No partial dependency on a composite key
         (Không phụ thuộc vào một phần của khóa ghép)
   - book_authors (book_id, author_id) and book_categories (book_id,
     category_id) use a composite PK and hold NO other columns, so nothing
     can depend on only half of the key. Book title, author name, category
     name live in their own tables.
     (Hai bảng trung gian dùng khóa ghép và KHÔNG chứa cột nào khác, nên
      không thể có phụ thuộc bộ phận. Tên sách, tên tác giả, tên thể loại
      nằm ở bảng riêng của chúng.)
   - order_items does NOT store the book title or author: those depend
     only on book_id, so they stay in books.
     (order_items KHÔNG lưu tên sách: tên sách chỉ phụ thuộc book_id.)

   3NF - No transitive dependency (non-key -> non-key)
         (Không có phụ thuộc bắc cầu giữa các cột thường)
   - books stores only publisher_id, not publisher_name / address / website.
     Otherwise: book.id -> publisher_id -> publisher_name (transitive).
     (books chỉ lưu publisher_id, không lưu tên/địa chỉ NXB, vì nếu lưu thì
      có chuỗi bắc cầu: id sách -> publisher_id -> tên NXB.)
   - orders stores only customer_id, not customer name / email.
     (orders chỉ lưu customer_id, không lưu tên/email khách hàng.)
   - reviews stores customer_id and book_id only, not names.

   Intentional "snapshot" columns (not redundancy)
   (Các cột "chụp lại tại thời điểm mua", không phải dư thừa):
   - order_items.unit_price: price AT ORDER TIME. books.price can change
     later, but an old invoice must not change.
     (Giá tại lúc đặt hàng. Giá sách sau này có thể đổi, hóa đơn cũ thì không.)
   - orders.shipping_address: the address for THIS order; a customer may
     ship to a different place than their profile address.
     (Địa chỉ giao cho ĐƠN NÀY, có thể khác địa chỉ trong hồ sơ khách.)
   - order_items.subtotal is a GENERATED column (quantity * unit_price):
     MySQL/MariaDB computes it, so it can never be inconsistent.
     (subtotal là cột TỰ TÍNH, không ai nhập tay nên không thể sai lệch.)
   - orders.total_amount is required by the assignment; it records the
     amount the customer was charged for the order.
     (total_amount do đề yêu cầu; lưu số tiền khách phải trả cho đơn.)
   ============================================================================ */

CREATE DATABASE IF NOT EXISTS bookstore_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE bookstore_db;

-- Drop old tables so the script can be re-run (child tables first)
-- (Xóa bảng cũ để chạy lại script nhiều lần; xóa bảng con trước bảng cha)
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS authors;

-- ============================================================================
-- PART 1: CREATE TABLES (parents first / bảng cha tạo trước)
-- ============================================================================

-- 1. authors: author information (thông tin tác giả)
CREATE TABLE authors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    nationality VARCHAR(60),
    birth_year SMALLINT,
    biography TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. publishers: publisher details (nhà xuất bản)
CREATE TABLE publishers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL UNIQUE,           -- No duplicate publisher names (không trùng tên NXB)
    address VARCHAR(255),
    website VARCHAR(255),
    email VARCHAR(100) UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. categories: genres with self-reference for sub-genres
--    (thể loại, tự tham chiếu để tạo thể loại con)
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INT NULL,                          -- NULL = root category (thể loại gốc)
    CONSTRAINT fk_categories_parent
        FOREIGN KEY (parent_id) REFERENCES categories(id)
        ON DELETE SET NULL                       -- Delete parent -> child becomes root (xóa cha thì con thành gốc)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. books: catalog (danh mục sách). Publishers -> Books is 1:N
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) NOT NULL UNIQUE,            -- ISBN-13, unique per book (mỗi sách 1 ISBN riêng)
    publisher_id INT NOT NULL,                   -- FK on the "many" side (FK nằm ở phía "nhiều")
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    publication_date DATE,
    pages INT,
    language VARCHAR(30) DEFAULT 'Vietnamese',
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_books_price CHECK (price > 0),
    CONSTRAINT chk_books_stock CHECK (stock >= 0),
    CONSTRAINT chk_books_pages CHECK (pages IS NULL OR pages > 0),
    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id) REFERENCES publishers(id)
        ON DELETE RESTRICT                       -- Cannot delete a publisher that still has books (không xóa NXB khi còn sách)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. book_authors: junction table, Books <-> Authors is M:N
--    (bảng trung gian, sách - tác giả là nhiều - nhiều)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),            -- Composite PK blocks duplicate pairs (khóa ghép chặn cặp trùng)
    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE CASCADE ON UPDATE CASCADE,     -- Delete book -> delete its links (xóa sách thì xóa liên kết)
    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. book_categories: junction table, Books <-> Categories is M:N
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_categories_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_categories_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. customers: customer accounts (tài khoản khách hàng)
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,          -- Login email, no duplicates (email đăng nhập, không trùng)
    password_hash VARCHAR(255) NOT NULL,         -- Store a hash, never the plain password (chỉ lưu mã băm)
    phone VARCHAR(20),
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. orders: order header, Customers -> Orders is 1:N
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending','processing','shipped','delivered','cancelled')
        NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    shipping_address VARCHAR(255) NOT NULL,
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON DELETE RESTRICT                       -- Keep order history (giữ lịch sử đơn hàng)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. order_items: line items, Orders <-> Books is M:N through this table
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,           -- Price at order time (giá tại lúc đặt)
    subtotal DECIMAL(12,2)
        AS (quantity * unit_price) STORED,       -- Generated column: computed by the DB (cột tự tính)
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price CHECK (unit_price > 0),
    CONSTRAINT uq_order_items_order_book UNIQUE (order_id, book_id),  -- One line per book per order (mỗi sách 1 dòng/đơn)
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON DELETE CASCADE                        -- Delete order -> delete its items (xóa đơn thì xóa chi tiết)
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE RESTRICT                       -- Cannot delete a book that was sold (không xóa sách đã bán)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. reviews: Customers -> Reviews 1:N, Books -> Reviews 1:N
CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    book_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comment TEXT,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT uq_reviews_customer_book UNIQUE (customer_id, book_id),  -- One review per book per customer (mỗi khách review 1 sách 1 lần)
    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PART 2: SAMPLE DATA (parents first / chèn bảng cha trước)
-- Note: ISBNs, prices, emails and password hashes are sample values,
-- not real data. (ISBN, giá, email, mã băm là dữ liệu mẫu, không phải thật.)
-- ============================================================================

-- 7 authors (yêu cầu tối thiểu 6)
INSERT INTO authors (id, full_name, nationality, birth_year, biography) VALUES
(1, 'Nguyễn Nhật Ánh',  'Vietnamese', 1955, 'Vietnamese writer known for books about childhood and youth.'),
(2, 'Tô Hoài',          'Vietnamese', 1920, 'Vietnamese writer, author of Dế Mèn phiêu lưu ký.'),
(3, 'Robert C. Martin', 'American',   1952, 'Software engineer known as "Uncle Bob", author of Clean Code.'),
(4, 'Andrew Hunt',      'American',   NULL, 'Co-author of The Pragmatic Programmer.'),
(5, 'David Thomas',     'British',    NULL, 'Co-author of The Pragmatic Programmer.'),
(6, 'Haruki Murakami',  'Japanese',   1949, 'Japanese novelist, author of Norwegian Wood.'),
(7, 'Paulo Coelho',     'Brazilian',  1947, 'Brazilian novelist, author of The Alchemist.');

-- 5 publishers (yêu cầu tối thiểu 4)
INSERT INTO publishers (id, name, address, website, email) VALUES
(1, 'NXB Trẻ',        'Ho Chi Minh City, Vietnam', 'https://www.nxbtre.com.vn', 'contact@nxbtre.example.com'),
(2, 'NXB Kim Đồng',   'Hanoi, Vietnam',            'https://nxbkimdong.com.vn', 'contact@kimdong.example.com'),
(3, 'Nhã Nam',        'Hanoi, Vietnam',            'https://nhanam.vn',         'contact@nhanam.example.com'),
(4, 'Prentice Hall',  'United States',             NULL,                        NULL),
(5, 'Addison-Wesley', 'United States',             NULL,                        NULL);

-- 6 categories, 3 of them are sub-categories (yêu cầu tối thiểu 5)
INSERT INTO categories (id, name, description, parent_id) VALUES
(1, 'Văn học',             'Literature',                  NULL),
(2, 'Văn học Việt Nam',    'Vietnamese literature',       1),   -- child of Văn học (con của Văn học)
(3, 'Văn học nước ngoài',  'Foreign literature',          1),
(4, 'Thiếu nhi',           'Books for children',          NULL),
(5, 'Công nghệ thông tin', 'Information technology',      NULL),
(6, 'Lập trình',           'Software development',        5);   -- child of CNTT

-- 8 books (yêu cầu tối thiểu 8)
INSERT INTO books (id, title, isbn, publisher_id, price, stock, publication_date, pages, language) VALUES
(1, 'Mắt biếc',                       '9786040000011', 1, 110000.00, 40, '2019-05-01', 300, 'Vietnamese'),
(2, 'Cho tôi xin một vé đi tuổi thơ', '9786040000028', 1,  85000.00, 55, '2018-03-15', 220, 'Vietnamese'),
(3, 'Dế Mèn phiêu lưu ký',            '9786040000035', 2,  65000.00, 80, '2020-06-01', 180, 'Vietnamese'),
(4, 'Clean Code',                     '9780000000041', 4, 450000.00, 15, '2008-08-01', 464, 'English'),
(5, 'The Pragmatic Programmer',       '9780000000058', 5, 520000.00, 10, '2019-09-13', 352, 'English'),
(6, 'Clean Architecture',             '9780000000065', 4, 480000.00, 12, '2017-09-20', 432, 'English'),
(7, 'Rừng Na Uy',                     '9786040000072', 3, 150000.00, 25, '2021-01-10', 556, 'Vietnamese'),
(8, 'Nhà giả kim',                    '9786040000089', 3,  79000.00, 60, '2020-02-01', 228, 'Vietnamese');

-- Books <-> Authors (M:N). Book 5 has 2 authors, author 1 and 3 have 2 books
-- (Sách 5 có 2 tác giả; tác giả 1 và 3 mỗi người có 2 sách)
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), (2, 1),
(3, 2),
(4, 3), (6, 3),
(5, 4), (5, 5),
(7, 6),
(8, 7);

-- Books <-> Categories (M:N). Some books belong to 2 categories
-- (Một số sách thuộc 2 thể loại)
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 2),
(2, 2), (2, 4),
(3, 2), (3, 4),
(4, 6),
(5, 6),
(6, 5), (6, 6),
(7, 3),
(8, 3);

-- 5 customers. password_hash values are placeholders, in PHP use password_hash()
-- (Mã băm chỉ là giá trị mẫu; trong PHP dùng hàm password_hash())
INSERT INTO customers (id, full_name, email, password_hash, phone, address) VALUES
(1, 'Nguyễn Văn An',   'an.nguyen@example.com',  '$2y$10$sampleHashForCustomer0000000000000000000000000000001', '0901000001', '144 Xuân Thủy, Cầu Giấy, Hà Nội'),
(2, 'Trần Thị Bình',   'binh.tran@example.com',  '$2y$10$sampleHashForCustomer0000000000000000000000000000002', '0901000002', '12 Lê Lợi, Quận 1, TP.HCM'),
(3, 'Lê Hoàng Cường',  'cuong.le@example.com',   '$2y$10$sampleHashForCustomer0000000000000000000000000000003', '0901000003', '35 Trần Phú, Hải Châu, Đà Nẵng'),
(4, 'Phạm Thu Dung',   'dung.pham@example.com',  '$2y$10$sampleHashForCustomer0000000000000000000000000000004', '0901000004', '8 Nguyễn Trãi, Thanh Xuân, Hà Nội'),
(5, 'Hoàng Minh Đức',  'duc.hoang@example.com',  '$2y$10$sampleHashForCustomer0000000000000000000000000000005', '0901000005', '20 Hùng Vương, Ninh Kiều, Cần Thơ');

-- 6 orders. total_amount = sum of subtotals of that order's items
-- (total_amount = tổng subtotal các dòng của đơn đó)
INSERT INTO orders (id, customer_id, order_date, status, total_amount, shipping_address) VALUES
(1, 1, '2026-09-02 09:15:00', 'delivered',  240000.00, '144 Xuân Thủy, Cầu Giấy, Hà Nội'),
(2, 2, '2026-09-05 14:30:00', 'delivered',  949000.00, '12 Lê Lợi, Quận 1, TP.HCM'),
(3, 3, '2026-09-12 20:05:00', 'shipped',    308000.00, '35 Trần Phú, Hải Châu, Đà Nẵng'),
(4, 1, '2026-09-20 08:45:00', 'processing', 565000.00, 'VNU-IS, 144 Xuân Thủy, Cầu Giấy, Hà Nội'),  -- different address (giao tới trường)
(5, 4, '2026-10-01 11:00:00', 'pending',    430000.00, '8 Nguyễn Trãi, Thanh Xuân, Hà Nội'),
(6, 5, '2026-10-03 16:20:00', 'cancelled',  600000.00, '20 Hùng Vương, Ninh Kiều, Cần Thơ');

-- 13 order items (yêu cầu 12+). Do NOT insert subtotal: it is generated
-- (KHÔNG chèn subtotal vì cột này tự tính)
INSERT INTO order_items (order_id, book_id, quantity, unit_price) VALUES
(1, 1, 1, 110000.00),
(1, 3, 2,  65000.00),
(2, 4, 1, 450000.00),
(2, 5, 1, 499000.00),   -- sold at a discount, lower than books.price (bán giảm giá, thấp hơn giá hiện tại)
(3, 8, 2,  79000.00),
(3, 7, 1, 150000.00),
(4, 6, 1, 480000.00),
(4, 2, 1,  85000.00),
(5, 2, 3,  85000.00),
(5, 3, 1,  65000.00),
(5, 1, 1, 110000.00),
(6, 7, 1, 150000.00),
(6, 4, 1, 450000.00);

-- 10 reviews, rating 1-5 (yêu cầu tối thiểu 10)
INSERT INTO reviews (customer_id, book_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Rất cảm động, đọc một mạch là hết.',            '2026-09-10 21:00:00'),
(1, 3, 4, 'Mua cho em trai, bé rất thích.',               '2026-09-11 19:30:00'),
(2, 4, 5, 'Must-read for every developer.',               '2026-09-15 10:00:00'),
(2, 5, 5, 'Practical advice, easy to apply at work.',     '2026-09-18 22:10:00'),
(3, 8, 4, 'Nhẹ nhàng, nhiều ý nghĩa.',                    '2026-09-20 09:00:00'),
(3, 7, 3, 'Hay nhưng hơi buồn.',                          '2026-09-22 23:15:00'),
(1, 6, 4, 'Khó hơn Clean Code nhưng rất đáng đọc.',       '2026-09-28 20:40:00'),
(4, 2, 5, 'Gợi lại nhiều kỷ niệm tuổi thơ.',              '2026-10-05 18:00:00'),
(4, 3, 4, 'Kinh điển cho thiếu nhi.',                     '2026-10-06 18:30:00'),
(5, 1, 4, 'Đọc lại lần thứ hai vẫn thấy hay.',            '2026-10-08 07:45:00');

-- ============================================================================
-- Quick check after import (Kiểm tra nhanh sau khi import):
--   SHOW TABLES;                          -- 10 tables (10 bảng)
--   SELECT COUNT(*) FROM order_items;     -- 13
-- ============================================================================

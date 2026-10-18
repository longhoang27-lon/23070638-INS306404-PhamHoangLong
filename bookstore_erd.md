# Online Bookstore - Entity Relationship Diagram (ERD)

**Course:** INS3064 - Homework 06 · **Student:** Pham Hoang Long (23070638)
**Database:** `bookstore_db` (MySQL/MariaDB, InnoDB, utf8mb4)

Legend / Ký hiệu: **PK** = Primary Key · **FK** = Foreign Key · **UQ** = Unique ·
`1` = one (một) · `N` / `M` = many (nhiều)

---

## 1. Overview diagram (Sơ đồ tổng quan)

```text
                                 +----------------------+
                                 |      categories      |<--+ parent_id
                                 +----------------------+   | (self 1:N,
                                 | PK id                |---+  cha - con)
                                 | UQ name              |
                                 |    description       |
                                 | FK parent_id (NULL)  |
                                 +----------+-----------+
                                            | 1
                                            | N
+----------------------+         +----------+-----------+         +----------------------+
|       authors        |         |   book_categories    |         |      publishers      |
+----------------------+         +----------------------+         +----------------------+
| PK id                |         | PK,FK book_id        |         | PK id                |
|    full_name         |         | PK,FK category_id    |         | UQ name              |
|    nationality       |         +----------+-----------+         |    address           |
|    birth_year        |                    | N                   |    website           |
|    biography         |                    | 1                   | UQ email             |
+----------+-----------+         +----------+-----------+         +----------+-----------+
           | 1                   |        books         |                    | 1
           | N                   +----------------------+                    |
+----------+-----------+  N    1 | PK id                | N                  |
|     book_authors     |-------->| UQ isbn              |<-------------------+
+----------------------+         |    title             |
| PK,FK book_id        |         | FK publisher_id      |
| PK,FK author_id      |         |    price, stock      |
+----------------------+         |    publication_date  |
                                 +----+------------+----+
                                    1 |            | 1
                  +-----------------+              +-----------------+
                  | N                                                | N
       +----------+-----------+                           +----------+-----------+
       |     order_items      |                           |       reviews        |
       +----------------------+                           +----------------------+
       | PK id                |                           | PK id                |
       | FK order_id          |                           | FK customer_id       |
       | FK book_id           |                           | FK book_id           |
       |    quantity          |                           |    rating (1-5)      |
       |    unit_price        |                           |    comment           |
       |    subtotal (auto)   |                           |    review_date       |
       +----------+-----------+                           +----------+-----------+
                  | N                                                | N
                  | 1                                                |
       +----------+-----------+                                      |
       |        orders        |                                      |
       +----------------------+                                      |
       | PK id                |                                      |
       | FK customer_id       |                                      |
       |    order_date        |                                      |
       |    status            |                                      |
       |    total_amount      |                                      |
       |    shipping_address  |                                      |
       +----------+-----------+                                      |
                  | N                                                |
                  | 1                                              1 |
       +----------+--------------------------------------------------+-------+
       |                              customers                              |
       +---------------------------------------------------------------------+
       | PK id | full_name | UQ email | password_hash | phone | address      |
       +---------------------------------------------------------------------+
```

---

## 2. Relationships and cardinality (Quan hệ và bản số)

| # | Relationship | Type | How it is implemented (Cách cài đặt) | ON DELETE |
|---|---|---|---|---|
| 1 | publishers → books | 1:N | `books.publisher_id` FK (NOT NULL) | RESTRICT |
| 2 | books ↔ authors | M:N | junction `book_authors (book_id, author_id)` | CASCADE |
| 3 | books ↔ categories | M:N | junction `book_categories (book_id, category_id)` | CASCADE |
| 4 | categories → categories | 1:N (self) | `categories.parent_id` FK (NULL = root) | SET NULL |
| 5 | customers → orders | 1:N | `orders.customer_id` FK | RESTRICT |
| 6 | orders ↔ books | M:N | junction `order_items (order_id, book_id)` + quantity, price | order: CASCADE · book: RESTRICT |
| 7 | customers → reviews | 1:N | `reviews.customer_id` FK | CASCADE |
| 8 | books → reviews | 1:N | `reviews.book_id` FK | CASCADE |

Rule used (Quy tắc): in a 1:N relationship the FK is on the **N side**; an M:N
relationship is split into two 1:N relationships by a **junction table**.
(Quan hệ 1:N thì FK đặt ở phía N; quan hệ M:N tách thành hai quan hệ 1:N qua bảng trung gian.)

---

## 3. Entities and attributes (Thực thể và thuộc tính)

### authors
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| full_name | VARCHAR(150) | NOT NULL |
| nationality | VARCHAR(60) | |
| birth_year | SMALLINT | |
| biography | TEXT | |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP |

### publishers
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| name | VARCHAR(150) | NOT NULL, **UQ** |
| address | VARCHAR(255) | |
| website | VARCHAR(255) | |
| email | VARCHAR(100) | **UQ** |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP |

### categories
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| name | VARCHAR(100) | NOT NULL, **UQ** |
| description | TEXT | |
| parent_id | INT NULL | **FK** → categories.id (ON DELETE SET NULL) |

### books
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| title | VARCHAR(255) | NOT NULL |
| isbn | VARCHAR(13) | NOT NULL, **UQ** |
| publisher_id | INT | NOT NULL, **FK** → publishers.id (ON DELETE RESTRICT) |
| price | DECIMAL(10,2) | NOT NULL, CHECK (price > 0) |
| stock | INT | NOT NULL, DEFAULT 0, CHECK (stock >= 0) |
| publication_date | DATE | |
| pages | INT | CHECK (pages > 0) |
| language | VARCHAR(30) | DEFAULT 'Vietnamese' |
| description | TEXT | |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP |

### book_authors (junction / bảng trung gian)
| Column | Type | Key / Constraint |
|---|---|---|
| book_id | INT | **PK** (composite), **FK** → books.id (CASCADE) |
| author_id | INT | **PK** (composite), **FK** → authors.id (CASCADE) |

### book_categories (junction / bảng trung gian)
| Column | Type | Key / Constraint |
|---|---|---|
| book_id | INT | **PK** (composite), **FK** → books.id (CASCADE) |
| category_id | INT | **PK** (composite), **FK** → categories.id (CASCADE) |

### customers
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| full_name | VARCHAR(150) | NOT NULL |
| email | VARCHAR(100) | NOT NULL, **UQ** |
| password_hash | VARCHAR(255) | NOT NULL |
| phone | VARCHAR(20) | |
| address | VARCHAR(255) | |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP |

### orders
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| customer_id | INT | NOT NULL, **FK** → customers.id (ON DELETE RESTRICT) |
| order_date | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| status | ENUM('pending','processing','shipped','delivered','cancelled') | NOT NULL, DEFAULT 'pending' |
| total_amount | DECIMAL(12,2) | NOT NULL, DEFAULT 0, CHECK (>= 0) |
| shipping_address | VARCHAR(255) | NOT NULL |

### order_items (junction orders ↔ books)
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| order_id | INT | NOT NULL, **FK** → orders.id (ON DELETE CASCADE) |
| book_id | INT | NOT NULL, **FK** → books.id (ON DELETE RESTRICT) |
| quantity | INT | NOT NULL, DEFAULT 1, CHECK (quantity > 0) |
| unit_price | DECIMAL(10,2) | NOT NULL, CHECK (unit_price > 0) |
| subtotal | DECIMAL(12,2) | GENERATED AS (quantity * unit_price) STORED |
| | | **UQ** (order_id, book_id) |

### reviews
| Column | Type | Key / Constraint |
|---|---|---|
| id | INT AUTO_INCREMENT | **PK** |
| customer_id | INT | NOT NULL, **FK** → customers.id (CASCADE) |
| book_id | INT | NOT NULL, **FK** → books.id (CASCADE) |
| rating | TINYINT | NOT NULL, CHECK (rating BETWEEN 1 AND 5) |
| comment | TEXT | |
| review_date | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| | | **UQ** (customer_id, book_id) |

---

## 4. 3NF example (Ví dụ 3NF)

If `books` also stored `publisher_name`, we would have
`books.id → publisher_id → publisher_name` (a transitive dependency). Renaming a
publisher would then mean updating every one of its books. Keeping only
`publisher_id` in `books` and the name in `publishers` removes that problem.

(Nếu `books` lưu thêm `publisher_name` thì có phụ thuộc bắc cầu
`books.id → publisher_id → publisher_name`. Đổi tên NXB sẽ phải sửa mọi sách của NXB đó.
Chỉ giữ `publisher_id` trong `books` thì hết vấn đề này.)

-- ============================================================================
-- INS3064 - Homework 07: Advanced SQL (Online Bookstore)
-- Student   : Pham Hoang Long
-- Student ID: 23070638
-- Assignment: Homework 07 - bookstore_queries.sql
-- Date      : 2026-10-24
-- Database  : bookstore_db (run Homework 06 bookstore_db.sql first)
-- (Chạy bookstore_db.sql của Homework 06 trước khi chạy file này)
-- ============================================================================

USE bookstore_db;

-- ----------------------------------------------------------------------------
-- Query 1: Books with Authors (JOIN)
-- List every book with its author: title, ISBN, author name.
-- books -> book_authors -> authors. A book with 2 authors appears twice.
-- (Mỗi sách kèm tác giả; sách có 2 tác giả sẽ hiện 2 dòng.)
-- ----------------------------------------------------------------------------
SELECT b.title AS book_title, b.isbn, a.full_name AS author_name
FROM books b
JOIN book_authors ba ON ba.book_id = b.id
JOIN authors a ON a.id = ba.author_id
ORDER BY b.title, a.full_name;

/* Expected output (9 rows):
+--------------------------------+---------------+------------------+
| book_title                     | isbn          | author_name      |
+--------------------------------+---------------+------------------+
| Cho tôi xin một vé đi tuổi thơ | 9786040000028 | Nguyễn Nhật Ánh  |
| Clean Architecture             | 9780000000065 | Robert C. Martin |
| Clean Code                     | 9780000000041 | Robert C. Martin |
| Dế Mèn phiêu lưu ký            | 9786040000035 | Tô Hoài          |
| Mắt biếc                       | 9786040000011 | Nguyễn Nhật Ánh  |
| Nhà giả kim                    | 9786040000089 | Paulo Coelho     |
| Rừng Na Uy                     | 9786040000072 | Haruki Murakami  |
| The Pragmatic Programmer       | 9780000000058 | Andrew Hunt      |
| The Pragmatic Programmer       | 9780000000058 | David Thomas     |
+--------------------------------+---------------+------------------+
*/

-- ----------------------------------------------------------------------------
-- Query 2: Order Details (JOIN)
-- All orders with customer name, order date, book title, quantity and
-- line total (quantity x unit_price), newest orders first.
-- (Chi tiết đơn hàng, đơn mới nhất lên đầu; line_total = số lượng x đơn giá.)
-- ----------------------------------------------------------------------------
SELECT o.id AS order_id, c.full_name AS customer_name, o.order_date, o.status,
       b.title AS book_title, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN order_items oi ON oi.order_id = o.id
JOIN books b ON b.id = oi.book_id
ORDER BY o.order_date DESC, b.title;

/* Expected output (13 rows):
+----------+----------------+---------------------+------------+--------------------------------+----------+------------+------------+
| order_id | customer_name  | order_date          | status     | book_title                     | quantity | unit_price | line_total |
+----------+----------------+---------------------+------------+--------------------------------+----------+------------+------------+
| 6        | Hoàng Minh Đức | 2026-10-03 16:20:00 | cancelled  | Clean Code                     | 1        | 450000.00  | 450000.00  |
| 6        | Hoàng Minh Đức | 2026-10-03 16:20:00 | cancelled  | Rừng Na Uy                     | 1        | 150000.00  | 150000.00  |
| 5        | Phạm Thu Dung  | 2026-10-01 11:00:00 | pending    | Cho tôi xin một vé đi tuổi thơ | 3        | 85000.00   | 255000.00  |
| 5        | Phạm Thu Dung  | 2026-10-01 11:00:00 | pending    | Dế Mèn phiêu lưu ký            | 1        | 65000.00   | 65000.00   |
| 5        | Phạm Thu Dung  | 2026-10-01 11:00:00 | pending    | Mắt biếc                       | 1        | 110000.00  | 110000.00  |
| 4        | Nguyễn Văn An  | 2026-09-20 08:45:00 | processing | Cho tôi xin một vé đi tuổi thơ | 1        | 85000.00   | 85000.00   |
| 4        | Nguyễn Văn An  | 2026-09-20 08:45:00 | processing | Clean Architecture             | 1        | 480000.00  | 480000.00  |
| 3        | Lê Hoàng Cường | 2026-09-12 20:05:00 | shipped    | Nhà giả kim                    | 2        | 79000.00   | 158000.00  |
| 3        | Lê Hoàng Cường | 2026-09-12 20:05:00 | shipped    | Rừng Na Uy                     | 1        | 150000.00  | 150000.00  |
| 2        | Trần Thị Bình  | 2026-09-05 14:30:00 | delivered  | Clean Code                     | 1        | 450000.00  | 450000.00  |
| 2        | Trần Thị Bình  | 2026-09-05 14:30:00 | delivered  | The Pragmatic Programmer       | 1        | 499000.00  | 499000.00  |
| 1        | Nguyễn Văn An  | 2026-09-02 09:15:00 | delivered  | Dế Mèn phiêu lưu ký            | 2        | 65000.00   | 130000.00  |
| 1        | Nguyễn Văn An  | 2026-09-02 09:15:00 | delivered  | Mắt biếc                       | 1        | 110000.00  | 110000.00  |
+----------+----------------+---------------------+------------+--------------------------------+----------+------------+------------+
*/

-- ----------------------------------------------------------------------------
-- Query 3: Books with Publisher and Categories (multi-table JOIN, 4 tables)
-- Each book with its publisher and ALL its categories in one row.
-- GROUP_CONCAT joins the category names into one text, e.g. 'A, B'.
-- (Mỗi sách 1 dòng, các thể loại được gộp bằng GROUP_CONCAT.)
-- ----------------------------------------------------------------------------
SELECT b.title AS book_title, p.name AS publisher_name,
       GROUP_CONCAT(cat.name ORDER BY cat.name SEPARATOR ', ') AS category_names
FROM books b
JOIN publishers p ON p.id = b.publisher_id
JOIN book_categories bc ON bc.book_id = b.id
JOIN categories cat ON cat.id = bc.category_id
GROUP BY b.id, b.title, p.name
ORDER BY b.title;

/* Expected output (8 rows):
+--------------------------------+----------------+--------------------------------+
| book_title                     | publisher_name | category_names                 |
+--------------------------------+----------------+--------------------------------+
| Cho tôi xin một vé đi tuổi thơ | NXB Trẻ        | Thiếu nhi, Văn học Việt Nam    |
| Clean Architecture             | Prentice Hall  | Công nghệ thông tin, Lập trình |
| Clean Code                     | Prentice Hall  | Lập trình                      |
| Dế Mèn phiêu lưu ký            | NXB Kim Đồng   | Thiếu nhi, Văn học Việt Nam    |
| Mắt biếc                       | NXB Trẻ        | Văn học Việt Nam               |
| Nhà giả kim                    | Nhã Nam        | Văn học nước ngoài             |
| Rừng Na Uy                     | Nhã Nam        | Văn học nước ngoài             |
| The Pragmatic Programmer       | Addison-Wesley | Lập trình                      |
+--------------------------------+----------------+--------------------------------+
*/

-- ----------------------------------------------------------------------------
-- Query 4: Sales by Book (GROUP BY)
-- Total quantity sold and total revenue per book, highest revenue first.
-- Cancelled orders are not counted. The status filter is in the ON clause,
-- not in WHERE, so a book with no valid sales would still appear with 0.
-- (Không tính đơn bị hủy. Điều kiện đặt trong ON chứ không đặt trong WHERE,
--  để LEFT JOIN không bị biến thành INNER JOIN.)
-- ----------------------------------------------------------------------------
SELECT b.title AS book_title,
       SUM(CASE WHEN o.id IS NOT NULL THEN oi.quantity ELSE 0 END) AS total_quantity_sold,
       SUM(CASE WHEN o.id IS NOT NULL THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_revenue
FROM books b
LEFT JOIN order_items oi ON oi.book_id = b.id
LEFT JOIN orders o
       ON o.id = oi.order_id
      AND o.status <> 'cancelled'
GROUP BY b.id, b.title
ORDER BY total_revenue DESC, b.title;

/* Expected output (8 rows):
+--------------------------------+---------------------+---------------+
| book_title                     | total_quantity_sold | total_revenue |
+--------------------------------+---------------------+---------------+
| The Pragmatic Programmer       | 1                   | 499000.00     |
| Clean Architecture             | 1                   | 480000.00     |
| Clean Code                     | 1                   | 450000.00     |
| Cho tôi xin một vé đi tuổi thơ | 4                   | 340000.00     |
| Mắt biếc                       | 2                   | 220000.00     |
| Dế Mèn phiêu lưu ký            | 3                   | 195000.00     |
| Nhà giả kim                    | 2                   | 158000.00     |
| Rừng Na Uy                     | 1                   | 150000.00     |
+--------------------------------+---------------------+---------------+
*/

-- ----------------------------------------------------------------------------
-- Query 5: Customer Order Summary (GROUP BY + LEFT JOIN)
-- Number of orders and total amount spent per customer.
-- LEFT JOIN keeps customers with zero orders (they would show 0 / 0.00).
-- COUNT(o.id) instead of COUNT(*) so a customer with no orders counts as 0.
-- total_spent ignores cancelled orders.
-- (LEFT JOIN giữ cả khách chưa có đơn; COUNT(o.id) để khách không có đơn ra 0;
--  total_spent không cộng đơn bị hủy.)
-- ----------------------------------------------------------------------------
SELECT c.full_name AS customer_name, c.email,
       COUNT(o.id) AS order_count,
       COALESCE(SUM(CASE WHEN o.status <> 'cancelled' THEN o.total_amount END), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.full_name, c.email
ORDER BY total_spent DESC;

/* Expected output (5 rows):
+----------------+-----------------------+-------------+-------------+
| customer_name  | email                 | order_count | total_spent |
+----------------+-----------------------+-------------+-------------+
| Trần Thị Bình  | binh.tran@example.com | 1           | 949000.00   |
| Nguyễn Văn An  | an.nguyen@example.com | 2           | 805000.00   |
| Phạm Thu Dung  | dung.pham@example.com | 1           | 430000.00   |
| Lê Hoàng Cường | cuong.le@example.com  | 1           | 308000.00   |
| Hoàng Minh Đức | duc.hoang@example.com | 1           | 0.00        |
+----------------+-----------------------+-------------+-------------+
*/

-- ----------------------------------------------------------------------------
-- Query 6: Books Above Average Price (subquery in WHERE)
-- Books whose price is higher than the average price of all books.
-- The inner query computes AVG(price) first, the outer query compares.
-- (Câu con tính giá trung bình trước, câu ngoài so sánh với giá trị đó.)
-- ----------------------------------------------------------------------------
SELECT b.title AS book_title, b.price
FROM books b
WHERE b.price > (SELECT AVG(price) FROM books)
ORDER BY b.price DESC;

/* Expected output (3 rows):
+--------------------------+-----------+
| book_title               | price     |
+--------------------------+-----------+
| The Pragmatic Programmer | 520000.00 |
| Clean Architecture       | 480000.00 |
| Clean Code               | 450000.00 |
+--------------------------+-----------+
*/

-- ----------------------------------------------------------------------------
-- Query 7: Best-Selling Author (subquery, handles ties)
-- Author(s) with the highest total quantity sold (cancelled orders excluded).
-- No LIMIT 1: HAVING compares each author's total with the MAX total from a
-- derived table, so if two authors tie, both are returned.
-- (Không dùng LIMIT để nếu 2 tác giả bằng điểm thì cả hai đều hiện.)
-- ----------------------------------------------------------------------------
SELECT a.full_name AS author_name, SUM(oi.quantity) AS total_quantity_sold
FROM authors a
JOIN book_authors ba ON ba.author_id = a.id
JOIN order_items oi ON oi.book_id = ba.book_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY a.id, a.full_name
HAVING SUM(oi.quantity) = (
    SELECT MAX(author_total)
    FROM (
        SELECT SUM(oi2.quantity) AS author_total
        FROM book_authors ba2
        JOIN order_items oi2 ON oi2.book_id = ba2.book_id
        JOIN orders o2 ON o2.id = oi2.order_id
        WHERE o2.status <> 'cancelled'
        GROUP BY ba2.author_id
    ) AS author_sales
);

/* Expected output (1 row):
+-----------------+---------------------+
| author_name     | total_quantity_sold |
+-----------------+---------------------+
| Nguyễn Nhật Ánh | 6                   |
+-----------------+---------------------+
*/

-- ----------------------------------------------------------------------------
-- Query 8: Prolific Reviewers (HAVING)
-- Customers with more than 2 reviews, counting only reviews rated 3 or higher.
-- WHERE filters review ROWS (rating >= 3) before grouping;
-- HAVING filters customer GROUPS (count > 2) after grouping.
-- (WHERE lọc từng review trước khi gom nhóm, HAVING lọc nhóm sau khi gom.)
-- ----------------------------------------------------------------------------
SELECT c.full_name AS customer_name, COUNT(r.id) AS review_count
FROM customers c
JOIN reviews r ON r.customer_id = c.id
WHERE r.rating >= 3
GROUP BY c.id, c.full_name
HAVING COUNT(r.id) > 2
ORDER BY review_count DESC;

/* Expected output (1 row):
+---------------+--------------+
| customer_name | review_count |
+---------------+--------------+
| Nguyễn Văn An | 3            |
+---------------+--------------+
*/

-- ----------------------------------------------------------------------------
-- Query 9: Book Sales Summary View
-- View v_book_sales_summary: title, ISBN, publisher, total quantity sold,
-- total revenue, average rating, number of reviews (cancelled orders excluded).
-- Sales and reviews are aggregated in two separate derived tables BEFORE joining,
-- otherwise joining order_items and reviews together would multiply rows
-- and inflate the totals. No sales -> 0, no reviews -> avg_rating NULL, count 0.
-- (Tính doanh số và review ở 2 bảng con riêng rồi mới JOIN, tránh nhân dòng.)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_book_sales_summary AS
SELECT b.title AS book_title, b.isbn, p.name AS publisher_name,
       COALESCE(s.total_quantity_sold, 0) AS total_quantity_sold,
       COALESCE(s.total_revenue, 0) AS total_revenue,
       r.avg_rating,
       COALESCE(r.review_count, 0) AS review_count
FROM books b
JOIN publishers p ON p.id = b.publisher_id
LEFT JOIN (
    SELECT oi.book_id, SUM(oi.quantity) AS total_quantity_sold,
           SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY oi.book_id
) AS s ON s.book_id = b.id
LEFT JOIN (
    SELECT book_id, ROUND(AVG(rating), 2) AS avg_rating, COUNT(*) AS review_count
    FROM reviews
    GROUP BY book_id
) AS r ON r.book_id = b.id;

SELECT book_title, isbn, publisher_name, total_quantity_sold, total_revenue, avg_rating, review_count
FROM v_book_sales_summary
ORDER BY total_revenue DESC;

/* Expected output (8 rows):
+--------------------------------+---------------+----------------+---------------------+---------------+------------+--------------+
| book_title                     | isbn          | publisher_name | total_quantity_sold | total_revenue | avg_rating | review_count |
+--------------------------------+---------------+----------------+---------------------+---------------+------------+--------------+
| The Pragmatic Programmer       | 9780000000058 | Addison-Wesley | 1                   | 499000.00     | 5.00       | 1            |
| Clean Architecture             | 9780000000065 | Prentice Hall  | 1                   | 480000.00     | 4.00       | 1            |
| Clean Code                     | 9780000000041 | Prentice Hall  | 1                   | 450000.00     | 5.00       | 1            |
| Cho tôi xin một vé đi tuổi thơ | 9786040000028 | NXB Trẻ        | 4                   | 340000.00     | 5.00       | 1            |
| Mắt biếc                       | 9786040000011 | NXB Trẻ        | 2                   | 220000.00     | 4.50       | 2            |
| Dế Mèn phiêu lưu ký            | 9786040000035 | NXB Kim Đồng   | 3                   | 195000.00     | 4.00       | 2            |
| Nhà giả kim                    | 9786040000089 | Nhã Nam        | 2                   | 158000.00     | 4.00       | 1            |
| Rừng Na Uy                     | 9786040000072 | Nhã Nam        | 1                   | 150000.00     | 3.00       | 1            |
+--------------------------------+---------------+----------------+---------------------+---------------+------------+--------------+
*/

-- ----------------------------------------------------------------------------
-- Query 10: Monthly Revenue Report for the current year (combined)
-- Revenue for every month of YEAR(CURDATE()), including months with 0 revenue.
-- Techniques: UNION ALL derived table (12 months), LEFT JOIN, GROUP BY,
-- date functions (MONTH, YEAR, CURDATE, MONTHNAME), COUNT(DISTINCT).
-- Cancelled orders excluded. COUNT(DISTINCT o.id) because the JOIN repeats
-- an order once per order line.
-- Note: sample orders are in 2026, so run this in 2026 to see the numbers.
-- (Bảng 12 tháng tạo bằng UNION ALL rồi LEFT JOIN để tháng không có đơn vẫn hiện 0.)
-- ----------------------------------------------------------------------------
SELECT m.month_number,
       MONTHNAME(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', m.month_number, '-01'), '%Y-%c-%d')) AS month_name,
       COUNT(DISTINCT o.id) AS order_count,
       COALESCE(SUM(oi.quantity), 0) AS items_sold,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM (
    SELECT 1 AS month_number UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) AS m
LEFT JOIN orders o
       ON MONTH(o.order_date) = m.month_number
      AND YEAR(o.order_date) = YEAR(CURDATE())
      AND o.status <> 'cancelled'
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY m.month_number
ORDER BY m.month_number;

/* Expected output (12 rows):
+--------------+------------+-------------+------------+---------------+
| month_number | month_name | order_count | items_sold | total_revenue |
+--------------+------------+-------------+------------+---------------+
| 1            | January    | 0           | 0          | 0.00          |
| 2            | February   | 0           | 0          | 0.00          |
| 3            | March      | 0           | 0          | 0.00          |
| 4            | April      | 0           | 0          | 0.00          |
| 5            | May        | 0           | 0          | 0.00          |
| 6            | June       | 0           | 0          | 0.00          |
| 7            | July       | 0           | 0          | 0.00          |
| 8            | August     | 0           | 0          | 0.00          |
| 9            | September  | 4           | 10         | 2062000.00    |
| 10           | October    | 1           | 5          | 430000.00     |
| 11           | November   | 0           | 0          | 0.00          |
| 12           | December   | 0           | 0          | 0.00          |
+--------------+------------+-------------+------------+---------------+
*/


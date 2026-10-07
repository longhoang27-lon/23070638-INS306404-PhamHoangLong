-- =====================================================================
-- Author:     Pham Hoang Long
-- Student ID: 23070638
-- Assignment: INS3064 - Homework 05 (Introduction to SQL - University Queries)
-- Date:       2026-10-07
-- =====================================================================

-- Chọn database của Homework 4 / Target the Homework 4 database
USE university_db;

/*
 * Query 1: List all semesters
 * Description: Retrieve every column and every row from the semesters table.
 *              Lấy toàn bộ cột và toàn bộ dòng của bảng semesters.
 * Expected Output: All 5 semesters with their start and end dates.
 *                  5 học kỳ kèm ngày bắt đầu và kết thúc.
 */
SELECT * FROM semesters;

/*
 * +----+---------------+------------+------------+
 * | id | semester_name | start_date | end_date   |
 * +----+---------------+------------+------------+
 * |  1 | Fall 2024     | 2024-09-05 | 2025-01-15 |
 * |  2 | Spring 2025   | 2025-02-15 | 2025-06-30 |
 * |  3 | Fall 2025     | 2025-09-05 | 2026-01-15 |
 * |  4 | Spring 2026   | 2026-02-15 | 2026-06-30 |
 * |  5 | Fall 2026     | 2026-09-05 | 2027-01-15 |
 * +----+---------------+------------+------------+
 * (5 rows)
 */

/*
 * Query 2: Students with GPA above 3.5
 * Description: Filter students with a comparison operator (gpa > 3.5); the column full_name is renamed with AS.
 *              Lọc sinh viên bằng toán tử so sánh (gpa > 3.5); đổi tên cột full_name bằng AS.
 * Expected Output: 2 students: 230001 and 230004.
 *                  2 sinh viên: 230001 và 230004.
 */
SELECT student_code, full_name AS student_name, gpa
FROM students
WHERE gpa > 3.5;

/*
 * +--------------+---------------+------+
 * | student_code | student_name  |  gpa |
 * +--------------+---------------+------+
 * | 230001       | Đỗ Hoàng Long | 3.65 |
 * | 230004       | Lê Thị Phương | 3.85 |
 * +--------------+---------------+------+
 * (2 rows)
 */

/*
 * Query 3: Courses with 3+ credits in the IT or Electronics department
 * Description: Combine conditions: credits >= 3 AND the department is 1 (IT) OR 4 (ET). The parentheses make OR run first.
 *              Kết hợp điều kiện: tín chỉ >= 3 VÀ khoa là 1 (IT) HOẶC 4 (ET). Dấu ngoặc để OR được tính trước.
 * Expected Output: 2 courses: INS3064 and ET301.
 *                  2 môn học: INS3064 và ET301.
 */
SELECT course_code, course_name, credits
FROM courses
WHERE credits >= 3
  AND (department_id = 1 OR department_id = 4);

/*
 * +-------------+-------------------------------------------+---------+
 * | course_code | course_name                               | credits |
 * +-------------+-------------------------------------------+---------+
 * | INS3064     | Phát triển Web và Thiết kế Đa phương tiện |       3 |
 * | ET301       | Mạng máy tính và An ninh mạng             |       3 |
 * +-------------+-------------------------------------------+---------+
 * (2 rows)
 */

/*
 * Query 4: Students ranked by GPA
 * Description: Sort students by GPA from high to low; ties would be broken by name A to Z.
 *              Sắp xếp sinh viên theo GPA từ cao xuống thấp; nếu bằng nhau thì xếp theo tên A đến Z.
 * Expected Output: All 5 students, highest GPA first.
 *                  Cả 5 sinh viên, GPA cao nhất đứng đầu.
 */
SELECT student_code, full_name, gpa
FROM students
ORDER BY gpa DESC, full_name ASC;

/*
 * +--------------+----------------+------+
 * | student_code | full_name      |  gpa |
 * +--------------+----------------+------+
 * | 230004       | Lê Thị Phương  | 3.85 |
 * | 230001       | Đỗ Hoàng Long  | 3.65 |
 * | 230002       | Nguyễn Thị Thu | 3.40 |
 * | 230003       | Trần Văn Đức   | 3.20 |
 * | 230005       | Phạm Minh Tuấn | 3.10 |
 * +--------------+----------------+------+
 * (5 rows)
 */

/*
 * Query 5: Top 3 highest-graded enrollments
 * Description: Sort enrollments by grade descending, then keep only the first 3 rows with LIMIT.
 *              Sắp xếp đăng ký học phần theo điểm giảm dần, rồi chỉ giữ 3 dòng đầu bằng LIMIT.
 * Expected Output: 3 rows with grades 9.10, 9.00 and 8.90.
 *                  3 dòng với điểm 9.10, 9.00 và 8.90.
 */
SELECT student_id, course_id, grade AS final_grade
FROM enrollments
ORDER BY grade DESC
LIMIT 3;

/*
 * +------------+-----------+-------------+
 * | student_id | course_id | final_grade |
 * +------------+-----------+-------------+
 * |          2 |         3 |        9.10 |
 * |          4 |         1 |        9.00 |
 * |          4 |         4 |        8.90 |
 * +------------+-----------+-------------+
 * (3 rows)
 */

/*
 * Query 6: Instructors whose name contains 'Thị'
 * Description: Search text with a LIKE pattern; % on both sides matches 'Thị' anywhere in the name.
 *              Tìm chuỗi bằng LIKE; dấu % ở hai đầu giúp khớp 'Thị' ở bất kỳ vị trí nào trong tên.
 * Expected Output: 2 instructors: GV002 and GV005.
 *                  2 giảng viên: GV002 và GV005.
 */
SELECT instructor_code, full_name, email
FROM instructors
WHERE full_name LIKE '%Thị%';

/*
 * +-----------------+--------------+------------------+
 * | instructor_code | full_name    | email            |
 * +-----------------+--------------+------------------+
 * | GV002           | Trần Thị Mai | maitt@vnu.edu.vn |
 * | GV005           | Vũ Thị Lan   | lanvt@vnu.edu.vn |
 * +-----------------+--------------+------------------+
 * (2 rows)
 */

/*
 * Query 7: Total number of courses and total credits
 * Description: Use aggregate functions COUNT and SUM to collapse the courses table into a single summary row.
 *              Dùng hàm tổng hợp COUNT và SUM để gộp bảng courses thành một dòng thống kê.
 * Expected Output: One row: 5 courses, 15 credits in total (3+3+2+3+4).
 *                  Một dòng: 5 môn học, tổng 15 tín chỉ (3+3+2+3+4).
 */
SELECT COUNT(*) AS total_courses, SUM(credits) AS total_credits
FROM courses;

/*
 * +---------------+---------------+
 * | total_courses | total_credits |
 * +---------------+---------------+
 * |             5 |            15 |
 * +---------------+---------------+
 * (1 rows)
 */

/*
 * Query 8: Courses with an average grade of at least 8.0
 * Description: Group enrollments by course, then HAVING keeps only the groups whose average grade is >= 8.0.
 *              Gom đăng ký theo môn học, rồi HAVING chỉ giữ các nhóm có điểm trung bình >= 8.0.
 * Expected Output: 3 groups: course 1 (8.75), course 4 (8.35), course 2 (8.10).
 *                  3 nhóm: môn 1 (8.75), môn 4 (8.35), môn 2 (8.10).
 */
SELECT course_id,
       COUNT(*) AS enrollment_count,
       ROUND(AVG(grade), 2) AS avg_grade
FROM enrollments
GROUP BY course_id
HAVING AVG(grade) >= 8.0
ORDER BY avg_grade DESC;

/*
 * +-----------+------------------+-----------+
 * | course_id | enrollment_count | avg_grade |
 * +-----------+------------------+-----------+
 * |         1 |                2 |      8.75 |
 * |         4 |                2 |      8.35 |
 * |         2 |                2 |      8.10 |
 * +-----------+------------------+-----------+
 * (3 rows)
 */

/*
 * Query 9: Courses with their instructor names
 * Description: JOIN courses with instructors through the foreign key instructor_id to show each course next to its instructor.
 *              JOIN bảng courses với instructors qua khóa ngoại instructor_id để hiện mỗi môn cùng giảng viên.
 * Expected Output: 5 rows, sorted by course code.
 *                  5 dòng, sắp xếp theo mã môn.
 */
SELECT c.course_code,
       c.course_name AS course_title,
       i.full_name AS instructor_name
FROM courses c
JOIN instructors i ON c.instructor_id = i.id
ORDER BY c.course_code;

/*
 * +-------------+-------------------------------------------+-----------------+
 * | course_code | course_title                              | instructor_name |
 * +-------------+-------------------------------------------+-----------------+
 * | DS401       | Học máy cơ bản                            | Vũ Thị Lan      |
 * | ECO101      | Kinh tế vi mô đại cương                   | Trần Thị Mai    |
 * | ENG202      | Tiếng Anh chuyên ngành CNTT               | Lê Hoàng Nam    |
 * | ET301       | Mạng máy tính và An ninh mạng             | Phạm Quốc Hưng  |
 * | INS3064     | Phát triển Web và Thiết kế Đa phương tiện | Nguyễn Văn Minh |
 * +-------------+-------------------------------------------+-----------------+
 * (5 rows)
 */

/*
 * Query 10: Full enrollment report (4-table JOIN)
 * Description: JOIN enrollments with students, courses and semesters to turn the id numbers into readable names.
 *              JOIN enrollments với students, courses và semesters để đổi các số id thành tên dễ đọc.
 * Expected Output: 10 rows: student, course, semester and grade for every enrollment.
 *                  10 dòng: sinh viên, môn học, học kỳ và điểm của mỗi lượt đăng ký.
 */
SELECT s.student_code,
       s.full_name AS student_name,
       c.course_code,
       sem.semester_name,
       e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
JOIN semesters sem ON e.semester_id = sem.id
ORDER BY e.id;

/*
 * +--------------+----------------+-------------+---------------+-------+
 * | student_code | student_name   | course_code | semester_name | grade |
 * +--------------+----------------+-------------+---------------+-------+
 * | 230001       | Đỗ Hoàng Long  | INS3064     | Fall 2024     |  8.50 |
 * | 230001       | Đỗ Hoàng Long  | ET301       | Fall 2024     |  7.80 |
 * | 230002       | Nguyễn Thị Thu | ECO101      | Fall 2024     |  8.00 |
 * | 230002       | Nguyễn Thị Thu | ENG202      | Spring 2025   |  9.10 |
 * | 230003       | Trần Văn Đức   | ENG202      | Fall 2024     |  6.50 |
 * | 230003       | Trần Văn Đức   | DS401       | Spring 2025   |  7.20 |
 * | 230004       | Lê Thị Phương  | ET301       | Spring 2025   |  8.90 |
 * | 230004       | Lê Thị Phương  | INS3064     | Spring 2025   |  9.00 |
 * | 230005       | Phạm Minh Tuấn | DS401       | Fall 2024     |  7.50 |
 * | 230005       | Phạm Minh Tuấn | ECO101      | Spring 2025   |  8.20 |
 * +--------------+----------------+-------------+---------------+-------+
 * (10 rows)
 */

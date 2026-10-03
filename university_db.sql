-- =====================================================================
-- Author: Pham Hoang Long
-- Assignment: INS3064 - Homework 04 (University Course Registration System)
-- =====================================================================

DROP DATABASE IF EXISTS university_db;

CREATE DATABASE university_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_db;

-- 1. Bảng Khoa (departments)
CREATE TABLE departments (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE COMMENT 'Tên khoa',
    code        VARCHAR(10)  NOT NULL UNIQUE COMMENT 'Mã khoa',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Bảng Giảng viên (instructors)
CREATE TABLE instructors (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    instructor_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Mã giảng viên',
    full_name       VARCHAR(100) NOT NULL COMMENT 'Họ tên giảng viên',
    email           VARCHAR(100) NOT NULL UNIQUE COMMENT 'Email liên hệ',
    department_id   INT NOT NULL COMMENT 'Thuộc khoa nào',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. Bảng Sinh viên (students)
CREATE TABLE students (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    student_code  VARCHAR(20) NOT NULL UNIQUE COMMENT 'Mã sinh viên',
    full_name     VARCHAR(100) NOT NULL COMMENT 'Họ tên sinh viên',
    email         VARCHAR(100) NOT NULL UNIQUE COMMENT 'Email sinh viên',
    gender        ENUM('Male', 'Female', 'Other') DEFAULT 'Male' COMMENT 'Giới tính',
    department_id INT NOT NULL COMMENT 'Chuyên ngành (thuộc khoa nào)',
    gpa           DECIMAL(3,2) COMMENT 'Điểm trung bình tích lũy' CHECK (gpa >= 0.00 AND gpa <= 4.00),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. Bảng Học phần/Môn học (courses)
CREATE TABLE courses (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    course_code   VARCHAR(20) NOT NULL UNIQUE COMMENT 'Mã môn học',
    course_name   VARCHAR(150) NOT NULL COMMENT 'Tên môn học',
    credits       INT NOT NULL COMMENT 'Số tín chỉ' CHECK (credits > 0),
    department_id INT NOT NULL COMMENT 'Khoa quản lý môn học',
    instructor_id INT NOT NULL COMMENT 'Giảng viên phụ trách mặc định',
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (instructor_id) REFERENCES instructors(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Bảng Học kỳ (semesters)
CREATE TABLE semesters (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Tên học kỳ',
    start_date    DATE NOT NULL COMMENT 'Ngày bắt đầu học kỳ',
    end_date      DATE NOT NULL COMMENT 'Ngày kết thúc học kỳ'
) ENGINE=InnoDB;

-- 6. Bảng Đăng ký học phần (enrollments)
CREATE TABLE enrollments (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL COMMENT 'Sinh viên đăng ký',
    course_id     INT NOT NULL COMMENT 'Môn học đăng ký',
    semester_id   INT NOT NULL COMMENT 'Đăng ký trong học kỳ nào',
    grade         DECIMAL(4,2) COMMENT 'Điểm tổng kết' CHECK (grade >= 0.00 AND grade <= 10.00),
    enrolled_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `unique_enrollment` UNIQUE (`student_id`, `course_id`, `semester_id`),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- CHÈN DỮ LIỆU MẪU (SAMPLE DATA)
-- =====================================================================

INSERT INTO departments (name, code) VALUES
('Khoa Công nghệ Thông tin', 'IT'),
('Khoa Kinh tế và Quản trị', 'ECO'),
('Khoa Ngôn ngữ và Văn hóa', 'LC'),
('Khoa Điện tử Viễn thông', 'ET'),
('Khoa Khoa học Dữ liệu', 'DS');

INSERT INTO instructors (instructor_code, full_name, email, department_id) VALUES
('GV001', 'Nguyễn Văn Minh', 'minhnv@vnu.edu.vn', 1),
('GV002', 'Trần Thị Mai', 'maitt@vnu.edu.vn', 2),
('GV003', 'Lê Hoàng Nam', 'namlh@vnu.edu.vn', 3),
('GV004', 'Phạm Quốc Hưng', 'hungpq@vnu.edu.vn', 4),
('GV005', 'Vũ Thị Lan', 'lanvt@vnu.edu.vn', 5);

INSERT INTO students (student_code, full_name, email, gender, department_id, gpa) VALUES
('230001', 'Đỗ Hoàng Long', 'longdh@vnu.edu.vn', 'Male', 1, 3.65),
('230002', 'Nguyễn Thị Thu', 'thunt@vnu.edu.vn', 'Female', 2, 3.40),
('230003', 'Trần Văn Đức', 'ductv@vnu.edu.vn', 'Male', 3, 3.20),
('230004', 'Lê Thị Phương', 'phuonglt@vnu.edu.vn', 'Female', 4, 3.85),
('230005', 'Phạm Minh Tuấn', 'tuanpm@vnu.edu.vn', 'Male', 5, 3.10);

INSERT INTO courses (course_code, course_name, credits, department_id, instructor_id) VALUES
('INS3064', 'Phát triển Web và Thiết kế Đa phương tiện', 3, 1, 1),
('ECO101', 'Kinh tế vi mô đại cương', 3, 2, 2),
('ENG202', 'Tiếng Anh chuyên ngành CNTT', 2, 3, 3),
('ET301', 'Mạng máy tính và An ninh mạng', 3, 4, 4),
('DS401', 'Học máy cơ bản', 4, 5, 5);

INSERT INTO semesters (semester_name, start_date, end_date) VALUES
('Fall 2024', '2024-09-05', '2025-01-15'),
('Spring 2025', '2025-02-15', '2025-06-30'),
('Fall 2025', '2025-09-05', '2026-01-15'),
('Spring 2026', '2026-02-15', '2026-06-30'),
('Fall 2026', '2026-09-05', '2027-01-15');

INSERT INTO enrollments (student_id, course_id, semester_id, grade) VALUES
(1, 1, 1, 8.50),
(1, 4, 1, 7.80),
(2, 2, 1, 8.00),
(2, 3, 2, 9.10),
(3, 3, 1, 6.50),
(3, 5, 2, 7.20),
(4, 4, 2, 8.90),
(4, 1, 2, 9.00),
(5, 5, 1, 7.50),
(5, 2, 2, 8.20);
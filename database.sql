-- ====================================================================
-- LIBRARY MANAGEMENT SYSTEM - DATABASE CREATION SCRIPT
-- Micro-Project: Diploma in Computer Engineering (DBMS / RDBMS)
-- Tables: Student, Book, Issue
-- Key Features: Primary Keys, Foreign Keys, Referential Integrity
-- ====================================================================

-- 1. Create the Database if it does not exist
CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

-- 2. Drop existing tables if re-initializing (Issue first due to foreign keys)
DROP TABLE IF EXISTS Issue;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Student;

-- ====================================================================
-- Table 1: Student
-- Stores details of registered diploma / college students
-- ====================================================================
CREATE TABLE Student (
    student_id VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    class VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- Table 2: Book
-- Stores catalog of books, total stock, and available stock
-- ====================================================================
CREATE TABLE Book (
    book_id INT NOT NULL AUTO_INCREMENT,
    isbn VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(60) NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id),
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- Table 3: Issue
-- Relational table linking Student and Book with foreign keys
-- Tracks issue date, due date, return date, and issue status
-- ====================================================================
CREATE TABLE Issue (
    issue_id INT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('Issued', 'Returned', 'Overdue') NOT NULL DEFAULT 'Issued',
    remarks VARCHAR(255) DEFAULT 'Standard borrow',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (issue_id),
    CONSTRAINT fk_issue_student 
        FOREIGN KEY (student_id) REFERENCES Student(student_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_issue_book 
        FOREIGN KEY (book_id) REFERENCES Book(book_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- SAMPLE DATA INSERTION
-- Realistic Computer Engineering & Polytechnic textbook records
-- ====================================================================

-- Insert Students
INSERT INTO Student (student_id, name, class, email, phone) VALUES
('STU-TY-01', 'Aarav Sharma', 'TY Computer', 'aarav.sharma@example.edu', '9820112233'),
('STU-TY-02', 'Priya Patil', 'TY Computer', 'priya.patil@example.edu', '9820223344'),
('STU-SY-03', 'Rohan Mehta', 'SY Computer', 'rohan.mehta@example.edu', '9820334455'),
('STU-SY-04', 'Ananya Joshi', 'SY Computer', 'ananya.joshi@example.edu', '9820445566'),
('STU-FY-05', 'Aditya Kulkarni', 'FY Computer', 'aditya.k@example.edu', '9820556677'),
('STU-FY-06', 'Sneha Deshmukh', 'FY Computer', 'sneha.d@example.edu', '9820667788'),
('STU-TY-07', 'Karan Verma', 'TY Computer', 'karan.v@example.edu', '9820778899'),
('STU-SY-08', 'Neha Shinde', 'SY Computer', 'neha.s@example.edu', '9820889900');

-- Insert Books
INSERT INTO Book (isbn, title, author, category, total_copies, available_copies) VALUES
('978-0131103627', 'The C Programming Language', 'Brian W. Kernighan, Dennis Ritchie', 'Programming', 5, 4),
('978-0072465631', 'Database System Concepts', 'Abraham Silberschatz, Henry F. Korth', 'DBMS', 6, 4),
('978-0133591620', 'Operating System Concepts', 'Silberschatz, Galvin, Gagne', 'Operating Systems', 4, 3),
('978-0132126953', 'Computer Networks', 'Andrew S. Tanenbaum, David J. Wetherall', 'Networks', 4, 3),
('978-0262033848', 'Introduction to Algorithms', 'Thomas H. Cormen, Charles E. Leiserson', 'Data Structures', 5, 4),
('978-0134685991', 'Effective Java', 'Joshua Bloch', 'Programming', 3, 3),
('978-1491957660', 'Python Crash Course', 'Eric Matthes', 'Programming', 4, 2),
('978-0134444321', 'Web Technologies: HTML, CSS, JS', 'Jeffrey C. Jackson', 'Web Development', 5, 4),
('978-0070582873', 'Software Engineering: A Practitioner Approach', 'Roger S. Pressman', 'Software Engineering', 3, 3);

-- Insert Issue Records
-- Note: available_copies in Book table reflect these active 'Issued' and 'Overdue' items
INSERT INTO Issue (student_id, book_id, issue_date, due_date, return_date, status, remarks) VALUES
-- Active Issue: Aarav borrowed Database System Concepts
('STU-TY-01', 2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), NULL, 'Issued', 'Mid-term study'),
-- Active Issue: Priya borrowed C Programming
('STU-TY-02', 1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 11 DAY), NULL, 'Issued', 'Lab practical assignment'),
-- Overdue Issue: Rohan borrowed Python Crash Course 20 days ago (14 days loan period exceeded)
('STU-SY-03', 7, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), NULL, 'Overdue', 'Reminder email sent'),
-- Active Issue: Ananya borrowed Computer Networks
('STU-SY-04', 4, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL, 'Issued', 'Semester exam reference'),
-- Active Issue: Aditya borrowed Operating Systems
('STU-FY-05', 3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), NULL, 'Issued', 'Theory syllabus study'),
-- Active Issue: Karan Verma borrowed Database System Concepts
('STU-TY-07', 2, DATE_SUB(CURDATE(), INTERVAL 4 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), NULL, 'Issued', 'Project work reference'),
-- Active Issue: Neha Shinde borrowed Python Crash Course
('STU-SY-08', 7, DATE_SUB(CURDATE(), INTERVAL 6 DAY), DATE_ADD(CURDATE(), INTERVAL 8 DAY), NULL, 'Issued', 'Micro-project coding'),
-- Active Issue: Sneha Deshmukh borrowed Web Technologies
('STU-FY-06', 8, DATE_SUB(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL, 'Issued', 'Web lab practice'),
-- Returned Issue 1: Aarav borrowed and returned Algorithms on time
('STU-TY-01', 5, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'Returned', 'Returned in good condition'),
-- Returned Issue 2: Priya borrowed and returned Operating Systems
('STU-TY-02', 3, DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 11 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Returned', 'Returned on time');

-- ====================================================================
-- VERIFICATION SELECT QUERIES
-- ====================================================================
SELECT 'Students Count:' AS Metric, COUNT(*) AS Value FROM Student
UNION ALL
SELECT 'Books Count:', COUNT(*) FROM Book
UNION ALL
SELECT 'Active Issues:', COUNT(*) FROM Issue WHERE status IN ('Issued', 'Overdue');

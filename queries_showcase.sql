-- ====================================================================
-- DIPLOMA COMPUTER ENGINEERING - DBMS MICRO-PROJECT
-- SQL QUERIES SHOWCASE & EXPLANATION GUIDE
-- Topics Covered: DDL, DML, Relational JOINs, Aggregate Functions, GROUP BY
-- ====================================================================

USE library_db;

-- ====================================================================
-- 1. DDL (DATA DEFINITION LANGUAGE) - TABLE CREATION & KEYS
-- ====================================================================

-- 1.1 Table Creation with Primary Key:
-- CREATE TABLE Student (
--     student_id VARCHAR(30) PRIMARY KEY,
--     name VARCHAR(100) NOT NULL,
--     class VARCHAR(50) NOT NULL,
--     email VARCHAR(100) NOT NULL,
--     phone VARCHAR(20) NOT NULL
-- );

-- 1.2 Table Creation with AUTO_INCREMENT and Check Constraint:
-- CREATE TABLE Book (
--     book_id INT AUTO_INCREMENT PRIMARY KEY,
--     isbn VARCHAR(30) UNIQUE NOT NULL,
--     title VARCHAR(150) NOT NULL,
--     author VARCHAR(100) NOT NULL,
--     category VARCHAR(60) NOT NULL,
--     total_copies INT NOT NULL,
--     available_copies INT NOT NULL
-- );

-- 1.3 Relational Table with Multiple Foreign Keys (Referential Integrity):
-- CREATE TABLE Issue (
--     issue_id INT AUTO_INCREMENT PRIMARY KEY,
--     student_id VARCHAR(30) NOT NULL,
--     book_id INT NOT NULL,
--     issue_date DATE NOT NULL,
--     due_date DATE NOT NULL,
--     return_date DATE NULL,
--     status ENUM('Issued', 'Returned', 'Overdue') DEFAULT 'Issued',
--     FOREIGN KEY (student_id) REFERENCES Student(student_id),
--     FOREIGN KEY (book_id) REFERENCES Book(book_id)
-- );


-- ====================================================================
-- 2. DML (DATA MANIPULATION LANGUAGE) - INSERTION
-- ====================================================================

-- 2.1 Inserting a new student record:
INSERT INTO Student (student_id, name, class, email, phone) 
VALUES ('STU-TY-09', 'Vikram Patel', 'TY Computer', 'vikram.p@example.edu', '9811223344');

-- 2.2 Inserting a new book into the library:
INSERT INTO Book (isbn, title, author, category, total_copies, available_copies) 
VALUES ('978-0201633610', 'Design Patterns', 'Erich Gamma, Richard Helm', 'Software Engineering', 4, 4);

-- 2.3 Issuing a book (Inserting into Issue table):
INSERT INTO Issue (student_id, book_id, issue_date, due_date, status, remarks) 
VALUES ('STU-TY-09', 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Issued', 'Regular loan');


-- ====================================================================
-- 3. SELECT QUERIES - FILTERING, SORTING & SEARCHING
-- ====================================================================

-- 3.1 Basic SELECT with all columns:
SELECT * FROM Book;

-- 3.2 Filtering with WHERE clause:
SELECT * FROM Book WHERE category = 'DBMS';

-- 3.3 Searching with LIKE pattern matching (Wildcard search):
SELECT * FROM Book 
WHERE title LIKE '%Programming%' OR author LIKE '%Kernighan%';

-- 3.4 Sorting with ORDER BY (Ascending / Descending):
SELECT title, author, total_copies, available_copies 
FROM Book 
ORDER BY title ASC;

-- 3.5 Finding books that are completely out of stock:
SELECT title, category, total_copies, available_copies 
FROM Book 
WHERE available_copies = 0;


-- ====================================================================
-- 4. UPDATE QUERIES
-- ====================================================================

-- 4.1 Updating student contact info:
UPDATE Student 
SET phone = '9899887766', class = 'TY Computer' 
WHERE student_id = 'STU-TY-01';

-- 4.2 Decreasing available copies when book is issued:
UPDATE Book 
SET available_copies = available_copies - 1 
WHERE book_id = 1 AND available_copies > 0;

-- 4.3 Returning an issued book (Updating return date and status):
UPDATE Issue 
SET return_date = CURDATE(), status = 'Returned' 
WHERE issue_id = 1;

-- 4.4 Increasing available copies when book is returned:
UPDATE Book 
SET available_copies = available_copies + 1 
WHERE book_id = 1;


-- ====================================================================
-- 5. DELETE QUERIES
-- ====================================================================

-- 5.1 Deleting a specific book (only if not currently referenced or after cascade):
DELETE FROM Book WHERE book_id = 99;

-- 5.2 Deleting student record:
DELETE FROM Student WHERE student_id = 'STU-TEMP-01';


-- ====================================================================
-- 6. RELATIONAL JOINS (INNER JOIN, MULTI-TABLE JOIN)
-- ====================================================================

-- 6.1 Multi-table INNER JOIN: Display complete issue ledger with student and book details
-- (Core requirement for Diploma DBMS Project)
SELECT 
    i.issue_id,
    i.student_id,
    s.name AS student_name,
    s.class AS student_class,
    i.book_id,
    b.title AS book_title,
    b.author AS book_author,
    i.issue_date,
    i.due_date,
    i.return_date,
    i.status
FROM Issue i
INNER JOIN Student s ON i.student_id = s.student_id
INNER JOIN Book b ON i.book_id = b.book_id
ORDER BY i.issue_id DESC;

-- 6.2 Filtered JOIN: Show only active unreturned books
SELECT 
    s.name AS student_name,
    s.class,
    b.title AS book_title,
    i.issue_date,
    i.due_date
FROM Issue i
INNER JOIN Student s ON i.student_id = s.student_id
INNER JOIN Book b ON i.book_id = b.book_id
WHERE i.status IN ('Issued', 'Overdue')
ORDER BY i.due_date ASC;

-- 6.3 Overdue Books Query: Find students whose return date is past due date
SELECT 
    i.issue_id,
    s.student_id,
    s.name AS student_name,
    s.phone AS student_phone,
    b.title AS book_title,
    i.due_date,
    DATEDIFF(CURDATE(), i.due_date) AS days_overdue
FROM Issue i
INNER JOIN Student s ON i.student_id = s.student_id
INNER JOIN Book b ON i.book_id = b.book_id
WHERE i.status = 'Overdue' OR (i.status = 'Issued' AND i.due_date < CURDATE());


-- ====================================================================
-- 7. AGGREGATE FUNCTIONS (COUNT, SUM, AVG, MIN, MAX)
-- ====================================================================

-- 7.1 Dashboard KPI counts:
SELECT 
    (SELECT COUNT(*) FROM Book) AS total_books_count,
    (SELECT SUM(total_copies) FROM Book) AS total_physical_copies,
    (SELECT SUM(available_copies) FROM Book) AS total_available_copies,
    (SELECT COUNT(*) FROM Student) AS total_students_count,
    (SELECT COUNT(*) FROM Issue WHERE status IN ('Issued', 'Overdue')) AS total_currently_issued;


-- ====================================================================
-- 8. GROUP BY & HAVING QUERIES (REPORTS & ANALYTICS)
-- ====================================================================

-- 8.1 Category-wise book distribution:
-- Count of distinct titles and total physical copies per category
SELECT 
    category,
    COUNT(*) AS total_titles,
    SUM(total_copies) AS total_stock,
    SUM(available_copies) AS available_stock
FROM Book
GROUP BY category
ORDER BY total_stock DESC;

-- 8.2 Most Borrowed Books Report (Ranked by borrowing frequency):
SELECT 
    b.book_id,
    b.title,
    b.author,
    b.category,
    COUNT(i.issue_id) AS total_times_borrowed
FROM Book b
LEFT JOIN Issue i ON b.book_id = i.book_id
GROUP BY b.book_id, b.title, b.author, b.category
ORDER BY total_times_borrowed DESC;

-- 8.3 Student Borrowing Activity Report:
-- Shows total books borrowed per student
SELECT 
    s.student_id,
    s.name,
    s.class,
    COUNT(i.issue_id) AS books_borrowed,
    SUM(CASE WHEN i.status IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS active_books
FROM Student s
LEFT JOIN Issue i ON s.student_id = i.student_id
GROUP BY s.student_id, s.name, s.class
ORDER BY books_borrowed DESC;

-- 8.4 GROUP BY with HAVING clause:
-- Find students who currently have 2 or more active books borrowed
SELECT 
    s.student_id,
    s.name,
    s.class,
    COUNT(i.issue_id) AS active_books_count
FROM Student s
INNER JOIN Issue i ON s.student_id = i.student_id
WHERE i.status IN ('Issued', 'Overdue')
GROUP BY s.student_id, s.name, s.class
HAVING active_books_count >= 2;

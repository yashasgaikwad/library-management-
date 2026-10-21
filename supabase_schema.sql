-- ====================================================================
-- SUPABASE POSTGRESQL SCHEMA & INITIAL SEED SCRIPT
-- Library Management System (DBMS Micro-Project)
-- Tables: student, book, issue (with case-preserving views)
-- ====================================================================

-- 1. Compatibility Helper Functions (MySQL to PostgreSQL parity)
CREATE OR REPLACE FUNCTION DATEDIFF(d1 DATE, d2 DATE) 
RETURNS INT AS $$
BEGIN
    RETURN (d1 - d2)::INT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION CURDATE() 
RETURNS DATE AS $$
BEGIN
    RETURN CURRENT_DATE;
END;
$$ LANGUAGE plpgsql STABLE;

-- 2. Drop existing views and tables if re-initializing
DROP VIEW IF EXISTS "Issue" CASCADE;
DROP VIEW IF EXISTS "Book" CASCADE;
DROP VIEW IF EXISTS "Student" CASCADE;

DROP TABLE IF EXISTS issue CASCADE;
DROP TABLE IF EXISTS book CASCADE;
DROP TABLE IF EXISTS student CASCADE;

-- ====================================================================
-- Table 1: student
-- Stores details of registered diploma / college students
-- ====================================================================
CREATE TABLE student (
    student_id VARCHAR(30) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- Table 2: book
-- Stores catalog of books, total stock, and available stock
-- ====================================================================
CREATE TABLE book (
    book_id SERIAL PRIMARY KEY,
    isbn VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(60) NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
);

-- ====================================================================
-- Table 3: issue
-- Relational table linking student and book with foreign keys
-- Tracks issue date, due date, return date, and circulation status
-- ====================================================================
CREATE TABLE issue (
    issue_id SERIAL PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Issued' CHECK (status IN ('Issued', 'Returned', 'Overdue')),
    remarks VARCHAR(255) DEFAULT 'Standard borrow',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_issue_student 
        FOREIGN KEY (student_id) REFERENCES student(student_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_issue_book 
        FOREIGN KEY (book_id) REFERENCES book(book_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
);

-- Case-preserving Views (Ensure queries with "Student", "Book", "Issue" or Student, Book, Issue work identically)
CREATE OR REPLACE VIEW "Student" AS SELECT * FROM student;
CREATE OR REPLACE VIEW "Book" AS SELECT * FROM book;
CREATE OR REPLACE VIEW "Issue" AS SELECT * FROM issue;

-- Enable Row Level Security (RLS) with permissive policies for web application client
ALTER TABLE student ENABLE ROW LEVEL SECURITY;
ALTER TABLE book ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all operations for student" ON student FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for book" ON book FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for issue" ON issue FOR ALL USING (true) WITH CHECK (true);

-- Grant permissions to public/anon/authenticated/service_role
GRANT ALL ON TABLE student TO anon, authenticated, service_role, postgres;
GRANT ALL ON TABLE book TO anon, authenticated, service_role, postgres;
GRANT ALL ON TABLE issue TO anon, authenticated, service_role, postgres;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role, postgres;

-- ====================================================================
-- SAMPLE SEED DATA INSERTION
-- Realistic Computer Engineering & Polytechnic textbook records
-- ====================================================================

-- Insert Students
INSERT INTO student (student_id, name, class, email, phone) VALUES
('STU-TY-01', 'Aarav Sharma', 'TY Computer', 'aarav.sharma@example.edu', '9820112233'),
('STU-TY-02', 'Priya Patil', 'TY Computer', 'priya.patil@example.edu', '9820223344'),
('STU-SY-03', 'Rohan Mehta', 'SY Computer', 'rohan.mehta@example.edu', '9820334455'),
('STU-SY-04', 'Ananya Joshi', 'SY Computer', 'ananya.joshi@example.edu', '9820445566'),
('STU-FY-05', 'Aditya Kulkarni', 'FY Computer', 'aditya.k@example.edu', '9820556677'),
('STU-FY-06', 'Sneha Deshmukh', 'FY Computer', 'sneha.d@example.edu', '9820667788'),
('STU-TY-07', 'Karan Verma', 'TY Computer', 'karan.v@example.edu', '9820778899'),
('STU-SY-08', 'Neha Shinde', 'SY Computer', 'neha.s@example.edu', '9820889900')
ON CONFLICT (student_id) DO NOTHING;

-- Insert Books
INSERT INTO book (isbn, title, author, category, total_copies, available_copies) VALUES
('978-0131103627', 'The C Programming Language', 'Brian W. Kernighan, Dennis Ritchie', 'Programming', 5, 4),
('978-0072465631', 'Database System Concepts', 'Abraham Silberschatz, Henry F. Korth', 'DBMS', 6, 4),
('978-0133591620', 'Operating System Concepts', 'Silberschatz, Galvin, Gagne', 'Operating Systems', 4, 3),
('978-0132126953', 'Computer Networks', 'Andrew S. Tanenbaum, David J. Wetherall', 'Networks', 4, 3),
('978-0262033848', 'Introduction to Algorithms', 'Thomas H. Cormen, Charles E. Leiserson', 'Data Structures', 5, 4),
('978-0134685991', 'Effective Java', 'Joshua Bloch', 'Programming', 3, 3),
('978-1491957660', 'Python Crash Course', 'Eric Matthes', 'Programming', 4, 2),
('978-0134444321', 'Web Technologies: HTML, CSS, JS', 'Jeffrey C. Jackson', 'Web Development', 5, 4),
('978-0070582873', 'Software Engineering: A Practitioner Approach', 'Roger S. Pressman', 'Software Engineering', 3, 3)
ON CONFLICT (isbn) DO NOTHING;

-- Insert Issue Records
INSERT INTO issue (student_id, book_id, issue_date, due_date, return_date, status, remarks) VALUES
('STU-TY-01', 2, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '9 days', NULL, 'Issued', 'Mid-term study'),
('STU-TY-02', 1, CURRENT_DATE - INTERVAL '3 days', CURRENT_DATE + INTERVAL '11 days', NULL, 'Issued', 'Lab practical assignment'),
('STU-SY-03', 7, CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE - INTERVAL '6 days', NULL, 'Overdue', 'Reminder email sent'),
('STU-SY-04', 4, CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '12 days', NULL, 'Issued', 'Semester exam reference'),
('STU-FY-05', 3, CURRENT_DATE - INTERVAL '1 days', CURRENT_DATE + INTERVAL '13 days', NULL, 'Issued', 'Theory syllabus study'),
('STU-TY-07', 2, CURRENT_DATE - INTERVAL '4 days', CURRENT_DATE + INTERVAL '10 days', NULL, 'Issued', 'Project work reference'),
('STU-SY-08', 7, CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE + INTERVAL '8 days', NULL, 'Issued', 'Micro-project coding'),
('STU-FY-06', 8, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE + INTERVAL '7 days', NULL, 'Issued', 'Web lab practice'),
('STU-TY-01', 5, CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '16 days', CURRENT_DATE - INTERVAL '18 days', 'Returned', 'Returned in good condition'),
('STU-TY-02', 3, CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE - INTERVAL '11 days', CURRENT_DATE - INTERVAL '12 days', 'Returned', 'Returned on time');

-- Verification Query
SELECT 'Students Count:' AS metric, COUNT(*)::TEXT AS value FROM student
UNION ALL
SELECT 'Books Count:', COUNT(*)::TEXT FROM book
UNION ALL
SELECT 'Active Issues:', COUNT(*)::TEXT FROM issue WHERE status IN ('Issued', 'Overdue');

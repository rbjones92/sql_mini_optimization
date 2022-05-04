USE springboardopt;

-- -------------------------------------
SET @v1 = 1612521;
SET @v2 = 1145072;
SET @v3 = 1828467;
SET @v4 = 'MGT382';
SET @v5 = 'Amber Hill';
SET @v6 = 'MGT';
SET @v7 = 'EE';			  
SET @v8 = 'MAT';

-- 1. List the name of the student with id equal to v1 (id).
EXPLAIN ANALYZE
SELECT name 
FROM Student
WHERE id = @v1;

# ORIGINAL
/*
EXPLAIN ANALYZE
SELECT name 
FROM Student
WHERE id = @v1;
-> Filter: (student.id = <cache>((@v1)))  (cost=41.00 rows=40) (actual time=0.067..0.201 rows=1 loops=1)
     -> Table scan on Student  (cost=41.00 rows=400) (actual time=0.029..0.180 rows=400 loops=1)
 /*
 
 # USING INDEX
 /*
Created student_index on id column in student table
CREATE INDEX student_index  
ON student (id);
-> Index lookup on Student using student_index (id=(@v1))  (cost=0.35 rows=1) (actual time=0.017..0.019 rows=1 loops=1)
# Using indices on the ID column for this query speeds it up significantly. 

*/



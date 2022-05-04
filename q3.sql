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

-- 3. List the names of students who have taken course v4 (crsCode). 

### original
/*
SELECT name FROM Student WHERE id IN (SELECT studId FROM Transcript WHERE crsCode = @v4);
-> Nested loop inner join  (cost=5.50 rows=10) (actual time=0.087..0.091 rows=2 loops=1)
    -> Filter: (`<subquery2>`.studId is not null)  (cost=10.33..2.00 rows=10) (actual time=0.078..0.079 rows=2 loops=1)
        -> Table scan on <subquery2>  (cost=0.26..2.62 rows=10) (actual time=0.000..0.001 rows=2 loops=1)
            -> Materialize with deduplication  (cost=11.51..13.88 rows=10) (actual time=0.078..0.078 rows=2 loops=1)
                -> Filter: (transcript.studId is not null)  (cost=10.25 rows=10) (actual time=0.034..0.071 rows=2 loops=1)
                    -> Filter: (transcript.crsCode = <cache>((@v4)))  (cost=10.25 rows=10) (actual time=0.034..0.071 rows=2 loops=1)
                        -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.016..0.057 rows=100 loops=1)
    -> Covering index lookup on Student using q2_index (id=`<subquery2>`.studId)  (cost=2.60 rows=1) (actual time=0.005..0.005 rows=1 loops=2)
*/

### try an inner join
/*
EXPLAIN ANALYZE
SELECT name 
FROM Student 
INNER JOIN 
transcript as trans 
ON trans.studId = student.id
AND crsCode = @v4
-> Nested loop inner join  (cost=13.75 rows=10) (actual time=0.049..0.092 rows=2 loops=1)
    -> Filter: ((trans.crsCode = <cache>((@v4))) and (trans.studId is not null))  (cost=10.25 rows=10) (actual time=0.036..0.076 rows=2 loops=1)
        -> Table scan on trans  (cost=10.25 rows=100) (actual time=0.017..0.061 rows=100 loops=1)
    -> Covering index lookup on Student using q2_index (id=trans.studId)  (cost=0.26 rows=1) (actual time=0.006..0.007 rows=1 loops=2)
### shorter execution path. Not sure if it speed it up. 
*/

### after removing q2_index
/*
-> Inner hash join (student.id = trans.studId)  (cost=411.29 rows=400) (actual time=0.100..0.283 rows=2 loops=1)
    -> Table scan on Student  (cost=0.50 rows=400) (actual time=0.005..0.168 rows=400 loops=1)
    -> Hash
        -> Filter: (trans.crsCode = <cache>((@v4)))  (cost=10.25 rows=10) (actual time=0.034..0.071 rows=2 loops=1)
            -> Table scan on trans  (cost=10.25 rows=100) (actual time=0.016..0.058 rows=100 loops=1)

### None of these look too bad. This one included a hash join, rather than using the index. Searching more rows (400 rather that 1 in student), so gonna be slower.
*/
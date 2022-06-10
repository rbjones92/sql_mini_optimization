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


# < > ARE inclusive
# Between is sometimes inclusive, sometimes exlusive, based on the query engine. 



# CREATE UNIQUE INDEX id_index
# ON student(id)

EXPLAIN ANALYZE
SELECT name 
FROM student 
WHERE id >= @v2 AND id <= @v3;

-- 2. List the names of students with id in the range of v2 (id) to v3 (inclusive).

### ORIGINAL 
/*
EXPLAIN ANALYZE
SELECT name 
FROM student 
WHERE id BETWEEN @v2 AND @v3;
-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=41.00 rows=278) (actual time=0.018..0.201 rows=278 loops=1)
     -> Table scan on student  (cost=41.00 rows=400) (actual time=0.016..0.171 rows=400 loops=1)
 */
 
 ### add indices to name as well
 /*
 CREATE INDEX name_index
 ON student(name);
 -> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=41.00 rows=278) (actual time=0.022..0.204 rows=278 loops=1)
     -> Table scan on student  (cost=41.00 rows=400) (actual time=0.020..0.170 rows=400 loops=1)
# Still scanning table. Index positions probably out of order. 
 */
 
### rearrange column order to read name, then student. Create new index to include name and id
# ALTER TABLE student MODIFY COLUMN name VARCHAR(40) FIRST;
/*EXPLAIN ANALYZE
SELECT name
FROM student 
WHERE id BETWEEN @v2 AND @v3;
-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=5.44 rows=44) (actual time=0.023..0.206 rows=278 loops=1)
     -> Covering index scan on student using q2_index  (cost=5.44 rows=400) (actual time=0.020..0.172 rows=400 loops=1)
# not seeing any speed up. Try rearranging indices. 
*/

### rearrange indices so id is first, name is second
/*
EXPLAIN ANALYZE
SELECT name
FROM student 
WHERE id BETWEEN @v2 AND @v3;
-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=57.30 rows=278) (actual time=0.014..0.161 rows=278 loops=1)
     -> Covering index range scan on student using q2_index  (cost=57.30 rows=278) (actual time=0.012..0.133 rows=278 loop...
# Seeing some speed up. Reads less rows on student 
*/

 
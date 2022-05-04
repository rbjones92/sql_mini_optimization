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

-- 4. List the names of students who have taken a course taught by professor v5 (name).
EXPLAIN ANALYZE
SELECT student.name
FROM student
INNER JOIN 
transcript as trans
ON student.id = trans.studId
INNER JOIN
teaching as teach
ON trans.crsCode = teach.crsCode
AND teach.profId = 3148201

### Original
/*
# Original doesn't work? Doesn't come up with any output...
SELECT name FROM Student,
	(SELECT studId FROM Transcript,
		(SELECT crsCode, semester FROM Professor
			JOIN Teaching
			WHERE Professor.name = @v5 AND Professor.id = Teaching.profId) as alias1
	WHERE Transcript.crsCode = alias1.crsCode AND Transcript.semester = alias1.semester) as alias2
WHERE Student.id = alias2.studId;
*/

### First try using inner joins
/*
SELECT student.name
FROM student
INNER JOIN 
transcript as trans
ON student.id = trans.studId
INNER JOIN
teaching as teach
ON trans.crsCode = teach.crsCode
AND teach.profId = 3148201
-> Inner hash join (student.id = trans.studId)  (cost=4112.29 rows=4000) (actual time=0.224..0.397 rows=2 loops=1)
    -> Table scan on student  (cost=0.06 rows=400) (actual time=0.006..0.159 rows=400 loops=1)
    -> Hash
        -> Filter: (trans.crsCode = teach.crsCode)  (cost=110.51 rows=100) (actual time=0.137..0.193 rows=2 loops=1)
            -> Inner hash join (<hash>(trans.crsCode)=<hash>(teach.crsCode))  (cost=110.51 rows=100) (actual time=0.135..0.191 rows=2 loops=1)
                -> Table scan on trans  (cost=0.13 rows=100) (actual time=0.006..0.063 rows=100 loops=1)
                -> Hash
                    -> Filter: (teach.profId = 3148201)  (cost=10.25 rows=10) (actual time=0.035..0.080 rows=1 loops=1)
                        -> Table scan on teach  (cost=10.25 rows=100) (actual time=0.018..0.073 rows=100 loops=1)

# 2 results given. Seems very expensive. Will try to use indices. 
*/

### Use index on student.name

/*
'-> Inner hash join (student.id = trans.studId)  (cost=4112.29 rows=4000) (actual time=0.537..0.714 rows=2 loops=1)
    -> Table scan on student  (cost=0.06 rows=400) (actual time=0.022..0.181 rows=400 loops=1)
    -> Hash
        -> Filter: (trans.crsCode = teach.crsCode)  (cost=110.51 rows=100) (actual time=0.434..0.472 rows=2 loops=1)
            -> Inner hash join (<hash>(trans.crsCode)=<hash>(teach.crsCode))  (cost=110.51 rows=100) (actual time=0.433..0.470 rows=2 loops=1)
                -> Table scan on trans  (cost=0.13 rows=100) (actual time=0.293..0.333 rows=100 loops=1)
                -> Hash
                    -> Filter: (teach.profId = 3148201)  (cost=10.25 rows=10) (actual time=0.075..0.107 rows=1 loops=1)
                        -> Table scan on teach  (cost=10.25 rows=100) (actual time=0.059..0.099 rows=100 loops=1)
'
*/

### Using more indices on transcript and teaching 
/*
-> Nested loop inner join  (cost=17.47 rows=10) (actual time=0.455..0.505 rows=2 loops=1)
    -> Nested loop inner join  (cost=13.86 rows=10) (actual time=0.111..0.153 rows=2 loops=1)
        -> Filter: ((teach.profId = 3148201) and (teach.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.086..0.124 rows=1 loops=1)
            -> Table scan on teach  (cost=10.25 rows=100) (actual time=0.070..0.115 rows=100 loops=1)
        -> Filter: (trans.studId is not null)  (cost=0.27 rows=1) (actual time=0.024..0.029 rows=2 loops=1)
            -> Index lookup on trans using trans_index (crsCode=teach.crsCode)  (cost=0.27 rows=1) (actual time=0.024..0.028 rows=2 loops=1)
    -> Index lookup on student using student_id (id=trans.studId)  (cost=0.26 rows=1) (actual time=0.173..0.175 rows=1 loops=2)
*/
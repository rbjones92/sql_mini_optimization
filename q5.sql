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

# Had some issues with the logic of the original solutions. Needs checking. 

-- 5. List the names of students who have taken a course from department v6 (deptId), but not v7.
SELECT student.name
FROM student
INNER JOIN 
transcript as trans
ON student.id = trans.studId
INNER JOIN
teaching as teach
ON trans.crsCode = teach.crsCode
INNER JOIN 
professor as prof
ON teach.profId = prof.id
WHERE deptId = @v6
AND student.id NOT IN
	(SELECT student.id
	FROM student
	INNER JOIN 
	transcript as trans
	ON student.id = trans.studId
	INNER JOIN
	teaching as teach
	ON trans.crsCode = teach.crsCode
	INNER JOIN 
	professor as prof
	ON teach.profId = prof.id
	WHERE deptId = @v7)
ORDER BY name
# WHERE deptId = @v6 XOR deptId = @v7


### Original
/*

# Too many rows selected, only need student name. Too many full table scans. 

SELECT * FROM Student, 
	(SELECT studId FROM Transcript, Course WHERE deptId = @v6 AND Course.crsCode = Transcript.crsCode
	AND studId NOT IN
	(SELECT studId FROM Transcript, Course WHERE deptId = @v7 AND Course.crsCode = Transcript.crsCode)) as alias
WHERE Student.id = alias.studId;
-> Filter: <in_optimizer>(transcript.studId,<exists>(select #3) is false)  (cost=4112.69 rows=4000) (actual time=0.394..3.983 rows=30 loops=1)
    -> Inner hash join (student.id = transcript.studId)  (cost=4112.69 rows=4000) (actual time=0.226..0.443 rows=30 loops=1)
        -> Table scan on Student  (cost=0.06 rows=400) (actual time=0.011..0.193 rows=400 loops=1)
        -> Hash
            -> Filter: (transcript.crsCode = course.crsCode)  (cost=110.52 rows=100) (actual time=0.137..0.200 rows=30 loops=1)
                -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.136..0.195 rows=30 loops=1)
                    -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.010..0.054 rows=100 loops=1)
                    -> Hash
                        -> Filter: (course.deptId = <cache>((@v6)))  (cost=10.25 rows=10) (actual time=0.058..0.108 rows=26 loops=1)
                            -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.054..0.095 rows=100 loops=1)
    -> Select #3 (subquery in condition; dependent)
        -> Limit: 1 row(s)  (cost=110.52 rows=1) (actual time=0.114..0.114 rows=0 loops=30)
            -> Filter: <if>(outer_field_is_not_null, <is_not_null_test>(transcript.studId), true)  (cost=110.52 rows=100) (actual time=0.114..0.114 rows=0 loops=30)
                -> Filter: (<if>(outer_field_is_not_null, ((<cache>(transcript.studId) = transcript.studId) or (transcript.studId is null)), true) and (transcript.crsCode = course.crsCode))  (cost=110.52 rows=100) (actual time=0.114..0.114 rows=0 loops=30)
                    -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.061..0.111 rows=34 loops=30)
                        -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.001..0.039 rows=100 loops=30)
                        -> Hash
                            -> Filter: (course.deptId = <cache>((@v7)))  (cost=10.25 rows=10) (actual time=0.004..0.051 rows=32 loops=30)
                                -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.040 rows=100 loops=30)

*/
/*
### Using indices, inner join, and subquery. Wasn't any faster. 

-> Sort: student.`name`  (actual time=10.202..10.202 rows=24 loops=1)
    -> Stream results  (cost=52.47 rows=10) (actual time=0.466..10.181 rows=24 loops=1)
        -> Nested loop inner join  (cost=52.47 rows=10) (actual time=0.465..10.169 rows=24 loops=1)
            -> Nested loop inner join  (cost=48.86 rows=10) (actual time=0.047..0.327 rows=26 loops=1)
                -> Nested loop inner join  (cost=45.25 rows=10) (actual time=0.041..0.263 rows=25 loops=1)
                    -> Filter: ((teach.profId is not null) and (teach.crsCode is not null))  (cost=10.25 rows=100) (actual time=0.011..0.067 rows=100 loops=1)
                        -> Table scan on teach  (cost=10.25 rows=100) (actual time=0.010..0.054 rows=100 loops=1)
                    -> Filter: (prof.deptId = <cache>((@v6)))  (cost=0.25 rows=0) (actual time=0.002..0.002 rows=0 loops=100)
                        -> Index lookup on prof using profId_index_2 (id=teach.profId)  (cost=0.25 rows=1) (actual time=0.001..0.002 rows=1 loops=100)
                -> Filter: (trans.studId is not null)  (cost=0.27 rows=1) (actual time=0.002..0.002 rows=1 loops=25)
                    -> Index lookup on trans using crs_index_1 (crsCode=teach.crsCode)  (cost=0.27 rows=1) (actual time=0.002..0.002 rows=1 loops=25)
            -> Filter: <in_optimizer>(student.`name`,<exists>(select #2) is false)  (cost=0.26 rows=1) (actual time=0.378..0.378 rows=1 loops=26)
                -> Index lookup on student using id_index (id=trans.studId)  (cost=0.26 rows=1) (actual time=0.001..0.002 rows=1 loops=26)
                -> Select #2 (subquery in condition; dependent)
                    -> Limit: 1 row(s)  (cost=52.47 rows=1) (actual time=0.373..0.373 rows=0 loops=26)
                        -> Filter: <if>(outer_field_is_not_null, <is_not_null_test>(student.`name`), true)  (cost=52.47 rows=10) (actual time=0.373..0.373 rows=0 loops=26)
                            -> Nested loop inner join  (cost=52.47 rows=10) (actual time=0.373..0.373 rows=0 loops=26)
                                -> Nested loop inner join  (cost=48.86 rows=10) (actual time=0.010..0.323 rows=27 loops=26)
                                    -> Nested loop inner join  (cost=45.25 rows=10) (actual time=0.007..0.267 rows=25 loops=26)
                                        -> Filter: (teach.profId is not null)  (cost=10.25 rows=100) (actual time=0.003..0.092 rows=99 loops=26)
                                            -> Index range scan on teach using crs_index_2, with index condition: (teach.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.002..0.085 rows=99 loops=26)
                                        -> Filter: (prof.deptId = <cache>((@v7)))  (cost=0.25 rows=0) (actual time=0.002..0.002 rows=0 loops=2562)
                                            -> Index lookup on prof using profId_index_2 (id=teach.profId)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=2562)
                                    -> Filter: (trans.studId is not null)  (cost=0.27 rows=1) (actual time=0.002..0.002 rows=1 loops=646)
                                        -> Index lookup on trans using crs_index_1 (crsCode=teach.crsCode)  (cost=0.27 rows=1) (actual time=0.001..0.002 rows=1 loops=646)
                                -> Filter: <if>(outer_field_is_not_null, ((<cache>(student.`name`) = student.`name`) or (student.`name` is null)), true)  (cost=0.26 rows=1) (actual time=0.002..0.002 rows=0 loops=697)
                                    -> Index lookup on student using id_index (id=trans.studId)  (cost=0.26 rows=1) (actual time=0.001..0.001 rows=1 loops=697)
*/

/*

### Using inner join and no indices. 

-> Sort: student.`name`  (actual time=13.756..13.758 rows=24 loops=1)
    -> Stream results  (cost=164490.09 rows=160000) (actual time=1.036..13.739 rows=24 loops=1)
        -> Filter: <in_optimizer>(student.`name`,<exists>(select #2) is false)  (cost=164490.09 rows=160000) (actual time=1.033..13.724 rows=24 loops=1)
            -> Inner hash join (student.id = trans.studId)  (cost=164490.09 rows=160000) (actual time=0.389..0.578 rows=26 loops=1)
                -> Table scan on student  (cost=0.01 rows=400) (actual time=0.004..0.157 rows=400 loops=1)
                -> Hash
                    -> Filter: (trans.crsCode = teach.crsCode)  (cost=4442.07 rows=4000) (actual time=0.316..0.371 rows=26 loops=1)
                        -> Inner hash join (<hash>(trans.crsCode)=<hash>(teach.crsCode))  (cost=4442.07 rows=4000) (actual time=0.316..0.367 rows=26 loops=1)
                            -> Table scan on trans  (cost=0.01 rows=100) (actual time=0.003..0.041 rows=100 loops=1)
                            -> Hash
                                -> Inner hash join (teach.profId = prof.id)  (cost=441.04 rows=400) (actual time=0.251..0.298 rows=25 loops=1)
                                    -> Table scan on teach  (cost=0.03 rows=100) (actual time=0.003..0.043 rows=100 loops=1)
                                    -> Hash
                                        -> Filter: (prof.deptId = <cache>((@v6)))  (cost=40.75 rows=40) (actual time=0.025..0.220 rows=99 loops=1)
                                            -> Table scan on prof  (cost=40.75 rows=400) (actual time=0.017..0.175 rows=400 loops=1)
            -> Select #2 (subquery in condition; dependent)
                -> Limit: 1 row(s)  (cost=164490.09 rows=1) (actual time=0.499..0.499 rows=0 loops=26)
                    -> Filter: <if>(outer_field_is_not_null, <is_not_null_test>(student.`name`), true)  (cost=164490.09 rows=160000) (actual time=0.499..0.499 rows=0 loops=26)
                        -> Filter: <if>(outer_field_is_not_null, ((<cache>(student.`name`) = student.`name`) or (student.`name` is null)), true)  (cost=164490.09 rows=160000) (actual time=0.499..0.499 rows=0 loops=26)
                            -> Inner hash join (student.id = trans.studId)  (cost=164490.09 rows=160000) (actual time=0.330..0.496 rows=26 loops=26)
                                -> Table scan on student  (cost=0.01 rows=400) (actual time=0.001..0.141 rows=373 loops=26)
                                -> Hash
                                    -> Filter: (trans.crsCode = teach.crsCode)  (cost=4442.07 rows=4000) (actual time=0.266..0.319 rows=27 loops=26)
                                        -> Inner hash join (<hash>(trans.crsCode)=<hash>(teach.crsCode))  (cost=4442.07 rows=4000) (actual time=0.266..0.315 rows=27 loops=26)
                                            -> Table scan on trans  (cost=0.01 rows=100) (actual time=0.001..0.039 rows=100 loops=26)
                                            -> Hash
                                                -> Inner hash join (teach.profId = prof.id)  (cost=441.04 rows=400) (actual time=0.212..0.255 rows=25 loops=26)
                                                    -> Table scan on teach  (cost=0.03 rows=100) (actual time=0.001..0.038 rows=100 loops=26)
                                                    -> Hash
                                                        -> Filter: (prof.deptId = <cache>((@v7)))  (cost=40.75 rows=40) (actual time=0.006..0.193 rows=104 loops=26)
                                                            -> Table scan on prof  (cost=40.75 rows=400) (actual time=0.002..0.151 rows=400 loops=26)
*/
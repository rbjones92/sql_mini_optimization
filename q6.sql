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

-- 6. List the names of students who have taken all courses offered by department v8 (deptId).
SELECT student.name
FROM student
INNER JOIN 
transcript AS trans
ON student.id = trans.studId
INNER JOIN
teaching AS teach
ON trans.crsCode = teach.crsCode
INNER JOIN 
professor AS prof
ON teach.profId = prof.id
WHERE teach.crsCode = ALL
	(SELECT teaching.crsCode
    FROM teaching
    WHERE SUBSTRING(crsCode,1,3) = 'MGT')


### Original 
/*
SELECT name FROM Student,
	(SELECT studId
	FROM Transcript
		WHERE crsCode IN
		(SELECT crsCode FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))
		GROUP BY studId
		HAVING COUNT(*) = 
			(SELECT COUNT(*) FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))) as alias
WHERE id = alias.studId;
### Doesn't return any rows. Is this...what we want? 
*/


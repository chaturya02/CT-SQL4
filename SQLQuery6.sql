-- Reset before testing
UPDATE SubjectDetails
SET RemainingSeats = CASE 
    WHEN SubjectId = 'PO1491' THEN 2
    WHEN SubjectId = 'PO1492' THEN 119
    WHEN SubjectId = 'PO1493' THEN 90
    WHEN SubjectId = 'PO1494' THEN 50
    WHEN SubjectId = 'PO1495' THEN 60
    ELSE RemainingSeats
END;

DELETE FROM Allotments;
DELETE FROM UnallottedStudents;

EXEC AllocateSubjects;

-- Final check
SELECT * FROM Allotments;
SELECT * FROM UnallottedStudents;

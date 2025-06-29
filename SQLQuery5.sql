DROP PROCEDURE IF EXISTS AllocateSubjects;
GO

CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentId INT, @SubjectId VARCHAR(10), @Preference INT, @RemainingSeats INT;
    DECLARE @Allotted BIT;

    DELETE FROM Allotments;
    DELETE FROM UnallottedStudents;

    DECLARE student_cursor CURSOR FOR
    SELECT StudentId
    FROM StudentDetails
    ORDER BY GPA DESC;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Allotted = 0;
        SET @Preference = 1;

        WHILE @Preference <= 5 AND @Allotted = 0
        BEGIN
            -- Reset SubjectId before fetching
            SET @SubjectId = NULL;

            SELECT @SubjectId = SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId AND Preference = @Preference;

            IF @SubjectId IS NOT NULL
            BEGIN
                SELECT @RemainingSeats = RemainingSeats
                FROM SubjectDetails
                WHERE SubjectId = @SubjectId;

                IF @RemainingSeats IS NOT NULL AND @RemainingSeats > 0
                BEGIN
                    INSERT INTO Allotments (SubjectId, StudentId)
                    VALUES (@SubjectId, @StudentId);

                    UPDATE SubjectDetails
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE SubjectId = @SubjectId;

                    SET @Allotted = 1;
                END
            END

            SET @Preference = @Preference + 1;
        END

        IF @Allotted = 0
        BEGIN
            INSERT INTO UnallottedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END
GO

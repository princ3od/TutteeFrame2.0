CREATE DATABASE 
TutteeFrame02 
GO

USE 
TutteeFrame02 
GO

CREATE TABLE [SUBJECT]
(
	SubjectID VARCHAR(6) NOT NULL PRIMARY KEY,
	SubjectName NVARCHAR(100) NOT NULL,
);
GO

CREATE TABLE TEACHER
(
	TeacherID VARCHAR(8) NOT NULL PRIMARY KEY,
	Surname NVARCHAR(20) NOT NULL,
	Firstname NVARCHAR(20) NOT NULL,
	TeacherImage IMAGE,
	DateBorn DateTime,
	Sex BIT NOT NULL DEFAULT 1,
	Address NVARCHAR(1000) NOT NULL,
	Phone VARCHAR(12) NOT NULL,
	Maill VARCHAR(50) NOT NULL,
	SubjectID VARCHAR(6) NOT NULL REFERENCES SUBJECT(SubjectID),
	IsMinistry BIT NOT NULL DEFAULT 0,
	IsAdmin BIT NOT NULL DEFAULT 0,
	Posittion NVARCHAR(50)
);
GO

CREATE TABLE ACCOUNT
(
	AccountID VARCHAR(12) NOT NULL PRIMARY KEY,
	TeacherID VARCHAR(8) REFERENCES TEACHER(TeacherID) ON DELETE CASCADE,
	Password VARCHAR(1000) NOT NULL,
);
GO

CREATE TABLE [SESSION]
(
	AccountID VARCHAR(12) REFERENCES ACCOUNT(AccountID) ON DELETE CASCADE,
	SessionID VARCHAR(10) NOT NULL,
	CONSTRAINT PK_TC_SS PRIMARY KEY (AccountID, SessionID)
);
GO

CREATE TABLE CLASS
(
	ClassID VARCHAR(5) NOT NULL PRIMARY KEY,
	RoomNum VARCHAR(5) NOT NULL,
	StudentNum TINYINT NOT NULL DEFAULT 0,
	TeacherID VARCHAR(8) REFERENCES TEACHER(TeacherID),
);
GO
CREATE TABLE STUDENT
(
	StudentID VARCHAR(8) NOT NULL PRIMARY KEY,
	Surname NVARCHAR(20) NOT NULL,
	Firstname NVARCHAR(20) NOT NULL,
	StudentImage IMAGE,
	DateBorn DateTime,
	Sex BIT NOT NULL DEFAULT 1,
	Address NVARCHAR(100) NOT NULL,
	Phonne VARCHAR(12) NOT NULL,
	ClassID VARCHAR(5) NOT NULL REFERENCES CLASS(ClassID),
	Status BIT NOT NULL DEFAULT 1,
);
GO
CREATE TABLE  TEACHING
(
	TeachingID INT NOT NULL PRIMARY KEY,
	ClassID VARCHAR(5) NOT NULL REFERENCES CLASS(ClassID) ON DELETE CASCADE,
	SubjectID VARCHAR(6) NOT NULL REFERENCES SUBJECT(SubjectID) ON DELETE CASCADE,
	TeacherID VARCHAR(8) REFERENCES TEACHER(TeacherID),
	Semester	INT NOT NULL DEFAULT 1,
	SchoolYear INT NOT NULL DEFAULT YEAR(GETDATE()),
	Editable BIT NOT NULL DEFAULT 1,

);
GO
CREATE TABLE SCOREBOARD
(
	ScoreBoardID VARCHAR(8) PRIMARY KEY,
	StudentID VARCHAR(8) NOT NULL REFERENCES  STUDENT(StudentID) ON DELETE CASCADE,
	Semester INT NOT NULL DEFAULT 1,
	SemesterAverage FLOAT,
);
GO
CREATE TABLE SUBJECTSCORE
(
	SubjectScoreID VARCHAR(10) NOT NULL PRIMARY KEY,
	ScoreBoardID VARCHAR(8) NOT NULL REFERENCES SCOREBOARD(ScoreBoardID) ON DELETE CASCADE,
	SubjectID VARCHAR(6) NOT NULL REFERENCES SUBJECT(SubjectID) ON DELETE CASCADE,
	Quiz FLOAT,
	_15MinuteS01 FLOAT,
	_15MinuteS02 FLOAT,
	_15MinuteS03 FLOAT,
	_45MinuteS01 FLOAT,
	_45MinuteS02 FLOAT,
	_45minuteS03 FLOAT,
	Final FLOAT,
	SubjectAverage FLOAT,
);
GO

CREATE TABLE LEARNRESULT
(
	LearnResultID VARCHAR(10) PRIMARY KEY,
	StudentID VARCHAR(8) NOT NULL REFERENCES STUDENT(StudentID) ON DELETE CASCADE,
	ClassID VARCHAR(5) NOT NULL REFERENCES CLASS(ClassID) ON DELETE CASCADE, 
	Year INT NOT NULL DEFAULT YEAR(GETDATE()),
	ScoreBoardSE01ID VARCHAR(8) REFERENCES SCOREBOARD(ScoreBoardID),
	ScoreBoardSE02ID VARCHAR(8) REFERENCES SCOREBOARD(ScoreBoardID),
	Grade VARCHAR(2),
	ConductSE01 NVARCHAR(10),
	ConductSE02 NVARCHAR(10),
	YearConduct NVARCHAR(10),
	AverageScore FLOAT,
);
GO


CREATE TABLE PUNISHMENT
(
	PunishmentID VARCHAR(8) PRIMARY KEY,
	StudentID VARCHAR(8) REFERENCES STUDENT(StudentID) ON DELETE CASCADE,
	Content NTEXT,
	Fault NTEXT NOT NULL,
	Grade VARCHAR(2),
	Semester INT DEFAULT 1,
	Year INT DEFAULT YEAR(GETDATE())
);
GO
CREATE TABLE SCHOOLINFO
(
	STT VARCHAR(5) NOT NULL PRIMARY KEY,
	Logo IMAGE,
	Slogan NVARCHAR(1000),
	FullName NVARCHAR(1000),
);
GO
CREATE TABLE REWARD
(
	RewardID VARCHAR(8) NOT NULL PRIMARY KEY,
	StudentID VARCHAR(8) NOT NULL REFERENCES STUDENT(StudentID) ON DELETE CASCADE,
	RewardName NTEXT NOT NULL,
	Content NTEXT,
	Grade VARCHAR(2),
	Semester INT  NOT NULL DEFAULT 1,
	Year INT NOT NULL DEFAULT YEAR(GETDATE()),
);
GO
CREATE TABLE TOKEN
(
	 AccountID VARCHAR(12) REFERENCES ACCOUNT(AccountID) ON DELETE CASCADE,
	 TokenID VARCHAR(6) NOT NULL,
	 CreatedDate DATETIME DEFAULT GETDATE(),
	 CONSTRAINT PK_AC_TK PRIMARY KEY (AccountID, TokenID)
);
GO
CREATE TABLE SCHEDULES
(
	SchedulesID VARCHAR(6) PRIMARY KEY,
	ClassID VARCHAR(5) REFERENCES CLASS(ClassID) ON DELETE CASCADE,
	Semester tinyint DEFAULT 1,
	Year tinyint DEFAULT YEAR(GETDATE())
);
GO

CREATE TABLE SCHEDULE
(
	ID VARCHAR(8) PRIMARY KEY,
	SubjectID VARCHAR(6) REFERENCES SUBJECT(SubjectID) ON DELETE CASCADE,
	Day tinyint NOT NULL,
	[Session] tinyint NOT NULL,
	SchedulesID VARCHAR(6) NOT NULL REFERENCES SCHEDULES(SchedulesID) ON DELETE CASCADE,
);
GO
CREATE TRIGGER UPDATE_TOTAL_NUMBER_STUDENT_OF_CLASS ON STUDENT
AFTER INSERT
AS
	SET NOCOUNT ON
	--
	UPDATE CLASS
	SET StudentNum = StudentNum + s.dem
	FROM CLASS p JOIN (SELECT ClassID, COUNT(*) AS dem FROM inserted GROUP BY ClassID ) s
	ON P.ClassID  = s.ClassID
GO

CREATE TRIGGER UPDATE_TOTAL_NUMBER_STUDENT_OF_CLASS_FOR_DELETE ON STUDENT
AFTER DELETE
AS
	SET NOCOUNT ON
	UPDATE CLASS
	SET StudentNum = StudentNum - s.dem
	FROM CLASS p JOIN (SELECT ClassID, COUNT(*) AS dem FROM deleted GROUP BY ClassID ) s
	ON p.ClassID  = s.ClassID
GO

CREATE TRIGGER STUDENT_CLASS_UPD ON STUDENT
FOR UPDATE
AS
BEGIN
	UPDATE CLASS 
	SET StudentNum = (SELECT COUNT(*) FROM STUDENT WHERE CLASS.ClassID = STUDENT.ClassID)
END
GO

CREATE TRIGGER UPDATE_SEMESTER_SCORE ON SUBJECTSCORE
FOR UPDATE
AS
BEGIN
	DECLARE @SoMon TINYINT, @SoMonCoDiem TINYINT, @TongDiem FLOAT, @MaBangDiem VARCHAR(8)
	SELECT @MaBangDiem = inserted.ScoreBoardID FROM inserted
	SELECT @SoMon = COUNT(*) FROM [SUBJECT]
	SELECT @SoMonCoDiem = COUNT(*) FROM SUBJECTSCORE WHERE ScoreBoardID = @MaBangDiem AND SubjectAverage IS NOT NULL
	IF (@SoMonCoDiem = @SoMon)
	BEGIN
		SELECT @TongDiem = SUM(SubjectAverage) FROM SUBJECTSCORE WHERE ScoreBoardID = @MaBangDiem GROUP BY ScoreBoardID
		UPDATE SCOREBOARD SET SemesterAverage = @TongDiem / @SoMonCoDiem WHERE ScoreBoardID = @MaBangDiem
	END
	ELSE
		UPDATE SCOREBOARD SET SemesterAverage = NULL WHERE ScoreBoardID = @MaBangDiem
END
GO

CREATE TRIGGER UPDATE_YEAR_SCORE ON SCOREBOARD
FOR UPDATE
AS
BEGIN
	DECLARE @MaBangDiem VARCHAR(8), @LearnID VARCHAR(10), @Board1 VARCHAR(8), @Board2 VARCHAR(8), @SoHK_CoDiem TINYINT, @TongDiem FLOAT, @diemHK1 FLOAT, @diemHK2 FLOAT
	SELECT @MaBangDiem = inserted.ScoreBoardID FROM inserted
	SELECT @LearnID = LEARNRESULT.LearnResultID, @Board1 = LEARNRESULT.ScoreBoardSE01ID, @Board2 = LEARNRESULT.ScoreBoardSE02ID
	FROM LEARNRESULT WHERE LEARNRESULT.ScoreBoardSE01ID = @MaBangDiem OR LEARNRESULT.ScoreBoardSE02ID = @MaBangDiem
	SELECT @SoHK_CoDiem = COUNT(*)
	FROM SCOREBOARD WHERE (ScoreBoardID = @Board1 OR ScoreBoardID = @Board2) AND SemesterAverage IS NOT NULL
	IF (@SoHK_CoDiem = 2)
	BEGIN
		--SELECT @TongDiem = SUM(SemesterAverage) FROM SCOREBOARD WHERE (ScoreBoardID = @Board1 OR ScoreBoardID = @Board2)
		SELECT @diemHK1 = SemesterAverage FROM SCOREBOARD WHERE ScoreBoardID = @Board1
		SELECT @diemHK2 = SemesterAverage FROM SCOREBOARD WHERE ScoreBoardID = @Board2
		UPDATE LEARNRESULT SET AverageScore = (@diemHK1 + @diemHK2 * 2) / 3  WHERE LearnResultID = @LearnID
	END
	ELSE
		UPDATE LEARNRESULT SET AverageScore = NULL WHERE LearnResultID = @LearnID
END
GO

CREATE TRIGGER INSERT_SESSION ON [SESSION]
FOR INSERT
AS
BEGIN
	DECLARE @AccountID VARCHAR(12), @SessionID VARCHAR(10)
	SELECT @AccountID = AccountID, @SessionID = SessionID 
	FROM inserted 
	DELETE FROM SESSION WHERE AccountID = @AccountID AND SessionID != @SessionID
END
GO
CREATE TRIGGER DELETE_TEACHER ON TEACHER
FOR DELETE
AS
BEGIN
	DECLARE @teacherID VARCHAR(8)
	SELECT @teacherID = deleted.TeacherID FROM deleted
	UPDATE TEACHING SET TeacherID = NULL WHERE TEACHING.TeacherID = @teacherID
	UPDATE CLASS SET TeacherID = NULL WHERE CLASS.TeacherID = @teacherID
END



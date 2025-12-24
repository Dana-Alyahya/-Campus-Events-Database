/* ============================================================
   PROJECT 2 – CAMPUS EVENTS DATABASE (MySQL Version)
   Full Schema + Data + Stored Procedure + Test Queries
   ============================================================ */

DROP DATABASE IF EXISTS CampusEventsDB;
CREATE DATABASE CampusEventsDB;
USE CampusEventsDB;

/* ============================================================
   1. SCHEMA CREATION
   ============================================================ */

-- Department
CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL UNIQUE,
    ResponsiblePersonName VARCHAR(100) NOT NULL,
    ResponsiblePersonPhone VARCHAR(20) NOT NULL
);

-- Venue + Subclasses
CREATE TABLE Venue (
    VenueID INT PRIMARY KEY,
    VenueName VARCHAR(100) NOT NULL UNIQUE,
    VenueLocation VARCHAR(255) NOT NULL,
    VenueType VARCHAR(50) NOT NULL
);

CREATE TABLE SportArea (
    VenueID INT PRIMARY KEY,
    SurfaceType VARCHAR(50) NOT NULL,
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE
);

CREATE TABLE LectureHall (
    VenueID INT PRIMARY KEY,
    Building VARCHAR(100) NOT NULL,
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE
);

CREATE TABLE ConferenceHall (
    VenueID INT PRIMARY KEY,
    HasStage BOOLEAN NOT NULL,
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE
);

CREATE TABLE PublicSpace (
    VenueID INT PRIMARY KEY,
    OpenHours VARCHAR(100) NOT NULL,
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE CASCADE
);

-- Person + Subclasses
CREATE TABLE Person (
    PersonID INT PRIMARY KEY,
    PersonType VARCHAR(50) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    ContactInfo VARCHAR(255) UNIQUE
);

CREATE TABLE Faculty (
    PersonID INT PRIMARY KEY,
    FacultySpecificAttribute VARCHAR(100),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

CREATE TABLE Student (
    PersonID INT PRIMARY KEY,
    StudentSpecificAttribute VARCHAR(100),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

CREATE TABLE Staff (
    PersonID INT PRIMARY KEY,
    StaffSpecificAttribute VARCHAR(100),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

CREATE TABLE Dependent (
    DependentID INT PRIMARY KEY,
    StaffOrFacultyID INT NOT NULL,
    DependentSpecificAttribute VARCHAR(100),
    FOREIGN KEY (StaffOrFacultyID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

-- Event + Subclasses
CREATE TABLE Event (
    EventID INT PRIMARY KEY,
    EventName VARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Duration INT,
    ApprovalStatus VARCHAR(50) NOT NULL DEFAULT 'Pending',
    ApprovalDate DATE,
    RejectionJustification TEXT,
    VenueID INT NOT NULL,
    DeptID INT NOT NULL,
    EventType VARCHAR(50) NOT NULL,

    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),

    CHECK (DATEDIFF(EndDate, StartDate) <= 2), -- Max 3 days
    CHECK (StartTime >= '08:00:00' AND EndTime <= '23:59:59'),
    CHECK (StartDate < EndDate OR StartTime < EndTime)
);

CREATE TABLE SportEvent (
    EventID INT PRIMARY KEY,
    SportType VARCHAR(100) NOT NULL,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE
);

CREATE TABLE SocialEvent (
    EventID INT PRIMARY KEY,
    DressCode VARCHAR(100) NOT NULL,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE
);

CREATE TABLE AcademicEvent (
    EventID INT PRIMARY KEY,
    Topic VARCHAR(255) NOT NULL,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE
);

CREATE TABLE ReligiousEvent (
    EventID INT PRIMARY KEY,
    Denomination VARCHAR(100) NOT NULL,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE
);

-- SubEvent + Organizes
CREATE TABLE SubEvent (
    EventID INT NOT NULL,
    SubEventNo INT NOT NULL,
    PersonInChargeID INT NOT NULL,
    StartTime TIME NOT NULL,
    AllocatedTime INT NOT NULL,

    PRIMARY KEY (EventID, SubEventNo),
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE,
    FOREIGN KEY (PersonInChargeID) REFERENCES Person(PersonID)
);

CREATE TABLE Organizes (
    EventID INT NOT NULL,
    PersonID INT NOT NULL,

    PRIMARY KEY (EventID, PersonID),
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

/* ============================================================
   Email Log + Trigger (MySQL)
   ============================================================ */

CREATE TABLE EmailNotificationLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    EventID INT NOT NULL,
    NotificationTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Recipient VARCHAR(100) NOT NULL,
    Message TEXT
);

DELIMITER $$

CREATE TRIGGER EventApprovedNotification
AFTER UPDATE ON Event
FOR EACH ROW
BEGIN
    IF NEW.ApprovalStatus = 'Approved' AND OLD.ApprovalStatus <> 'Approved' THEN

        INSERT INTO EmailNotificationLog (EventID, Recipient, Message)
        VALUES (NEW.EventID, 'Maintenance', CONCAT('Event ', NEW.EventName, ' has been approved. Please prepare the venue.'));

        INSERT INTO EmailNotificationLog (EventID, Recipient, Message)
        VALUES (NEW.EventID, 'Office Services', CONCAT('Event ', NEW.EventName, ' has been approved. Please prepare office support.'));

        INSERT INTO EmailNotificationLog (EventID, Recipient, Message)
        VALUES (NEW.EventID, 'Security', CONCAT('Event ', NEW.EventName, ' has been approved. Please prepare security detail.'));
    END IF;
END $$

DELIMITER ;

/* ============================================================
   VIEW
   ============================================================ */

CREATE VIEW ApprovedEventDetails AS
SELECT
    E.EventID,
    E.EventName,
    E.StartDate,
    E.EndDate,
    E.StartTime,
    E.EndTime,
    E.EventType,
    V.VenueName,
    V.VenueLocation,
    D.DeptName AS SponsoringDepartment,
    D.ResponsiblePersonName AS DeptContact
FROM Event E
JOIN Venue V ON E.VenueID = V.VenueID
JOIN Department D ON E.DeptID = D.DeptID
WHERE E.ApprovalStatus = 'Approved';

/* ============================================================
   2. STORED PROCEDURE FOR DATA POPULATION
   ============================================================ */

DELIMITER $$

CREATE PROCEDURE SetupData()
BEGIN

    -- Department
    INSERT INTO Department VALUES
    (101,'Computer Science','Dr. Ahmed Khan','555-1001'),
    (102,'Electrical Engineering','Prof. Sara Alali','555-1002'),
    (103,'Business Administration','Mr. Khalid Hassan','555-1003'),
    (104,'Physical Education','Coach Fatima Zaki','555-1004'),
    (105,'Islamic Studies','Sheikh Abdullah','555-1005');

    -- Venue
    INSERT INTO Venue VALUES
    (201,'Main Football Field','Sports Complex','SportArea'),
    (202,'Lecture Hall A-101','Academic Building A','LectureHall'),
    (203,'Executive Conference Room','Admin Tower, 5th Floor','ConferenceHall'),
    (204,'Central Plaza','Near Library','PublicSpace'),
    (205,'Indoor Basketball Court','Sports Complex','SportArea'),
    (206,'Lecture Hall B-205','Academic Building B','LectureHall');

    INSERT INTO SportArea VALUES (201,'Natural Grass'),(205,'Hardwood');
    INSERT INTO LectureHall VALUES (202,'Academic Building A'),(206,'Academic Building B');
    INSERT INTO ConferenceHall VALUES (203, TRUE);
    INSERT INTO PublicSpace VALUES (204,'24/7');

    -- Person
    INSERT INTO Person VALUES
    (301,'Faculty','Dr. Omar Sharif','omar.sharif@uni.edu'),
    (302,'Student','Laila Mansour','laila.mansour@student.uni.edu'),
    (303,'Staff','Mr. Tariq Jaber','tariq.jaber@uni.edu'),
    (304,'Faculty','Dr. Mona Said','mona.said@uni.edu'),
    (305,'Student','Fahad Alotaibi','fahad.alotaibi@student.uni.edu'),
    (306,'Staff','Ms. Huda Ali','huda.ali@uni.edu');

    INSERT INTO Faculty VALUES (301,'Associate Professor'),(304,'Assistant Professor');
    INSERT INTO Student VALUES (302,'Senior'),(305,'Junior');
    INSERT INTO Staff VALUES (303,'Maintenance'),(306,'Office Services');

    INSERT INTO Dependent VALUES (401,301,'Spouse'),(402,304,'Child');

    -- Events
    INSERT INTO Event VALUES
    (501,'Annual Football Tournament','2025-12-15','2025-12-15','10:00','14:00',1,'Approved',NULL,NULL,201,104,'Sport');

    INSERT INTO SportEvent VALUES (501,'Football');

    INSERT INTO Event VALUES
    (502,'AI & Ethics Conference','2025-12-18','2025-12-20','09:00','17:00',3,'Pending',NULL,NULL,203,101,'Academic');
    INSERT INTO AcademicEvent VALUES (502,'Future of AI in Education');

    INSERT INTO Event VALUES
    (503,'Student Gala Night','2025-12-22','2025-12-22','20:00','23:00',1,'Rejected','2025-12-01',
    'Venue is not suitable for large social gatherings.',204,103,'Social');
    INSERT INTO SocialEvent VALUES (503,'Black Tie');

    INSERT INTO Event VALUES
    (504,'Weekly Prayer Gathering','2025-12-05','2025-12-05','18:00','19:00',1,'Approved',NULL,NULL,206,105,'Religious');
    INSERT INTO ReligiousEvent VALUES (504,'Sunni');

    INSERT INTO Event VALUES
    (505,'Inter-Department Basketball','2025-12-10','2025-12-11','16:00','20:00',2,'Pending',NULL,NULL,205,104,'Sport');
    INSERT INTO SportEvent VALUES (505,'Basketball');

    -- SubEvents
    INSERT INTO SubEvent VALUES
    (501,1,303,'10:00',60),
    (501,2,306,'11:00',60),
    (501,3,302,'12:00',60),
    (502,1,301,'09:00',120),
    (502,2,304,'11:00',90);

    -- Organizers
    INSERT INTO Organizes VALUES
    (501,304),
    (501,305),
    (502,301),
    (503,302),
    (504,303);

END $$

DELIMITER ;

-- Run data setup
CALL SetupData();

/* ============================================================
   3. TEST QUERIES
   ============================================================ */

-- Trigger test (Event 502 becomes Approved)
UPDATE Event
SET ApprovalStatus='Approved', ApprovalDate='2025-12-02'
WHERE EventID=502;

-- Delete pending event
DELETE FROM Event WHERE EventID=505;

-- Test Query 1
SELECT 'Approved Events View' AS Test;
SELECT * FROM ApprovedEventDetails;

-- Test Query 2
SELECT 'Email Notification Log' AS Test;
SELECT * FROM EmailNotificationLog;

-- Test Query 3 Sub-events for Event 501
SELECT 'SubEvents for 501' AS Test;
SELECT S.SubEventNo, S.StartTime, S.AllocatedTime, P.Name AS PersonInCharge
FROM SubEvent S
JOIN Person P ON S.PersonInChargeID = P.PersonID
WHERE S.EventID = 501;

-- Test Query 4 Organizers for Event 501
SELECT 'Organizers for 501' AS Test;
SELECT P.Name, P.PersonType
FROM Organizes O
JOIN Person P ON O.PersonID = P.PersonID
WHERE O.EventID = 501;

/* ============================================================
   ВОЛОНТЕРЛЕРДІ БАСҚАРУ ЖӘНЕ ІС-ШАРАЛАРҒА
   АВТОМАТТЫ БӨЛУ АҚПАРАТТЫҚ ЖҮЙЕСІ

   Microsoft SQL Server
   ============================================================ */


/* ============================================================
   1. БАЗАНЫ ҚҰРУ
   ============================================================ */

CREATE DATABASE VolunteerManagementDB;
GO

USE VolunteerManagementDB;
GO


/* ============================================================
   2. VOLUNTEER - ВОЛОНТЕРЛЕР
   ============================================================ */

CREATE TABLE Volunteer
(
    volunteerId INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100) NOT NULL UNIQUE,
    skills NVARCHAR(500),
    interests NVARCHAR(500),
    freeTime NVARCHAR(300),
    points INT NOT NULL DEFAULT 0,

    CONSTRAINT CK_Volunteer_Points
        CHECK (points >= 0)
);
GO


/* ============================================================
   3. ORGANIZER - ІС-ШАРА ҰЙЫМДАСТЫРУШЫЛАРЫ
   ============================================================ */

CREATE TABLE Organizer
(
    organizerId INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    organization NVARCHAR(150) NOT NULL
);
GO


/* ============================================================
   4. EVENT - ІС-ШАРАЛАР
   ============================================================ */

CREATE TABLE Event
(
    eventId INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(150) NOT NULL,
    description NVARCHAR(1000),
    eventDate DATE NOT NULL,
    location NVARCHAR(200),
    requiredSkills NVARCHAR(500),
    availablePlaces INT NOT NULL,
    organizerId INT NOT NULL,

    CONSTRAINT CK_Event_AvailablePlaces
        CHECK (availablePlaces >= 0),

    CONSTRAINT FK_Event_Organizer
        FOREIGN KEY (organizerId)
        REFERENCES Organizer(organizerId)
);
GO


/* ============================================================
   5. APPLICATION - ВОЛОНТЕРДІҢ ІС-ШАРАҒА ӨТІНІМІ
   ============================================================ */

CREATE TABLE Application
(
    applicationId INT IDENTITY(1,1) PRIMARY KEY,
    applicationDate DATE NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(30) NOT NULL DEFAULT N'Күтілуде',
    volunteerId INT NOT NULL,
    eventId INT NOT NULL,

    CONSTRAINT FK_Application_Volunteer
        FOREIGN KEY (volunteerId)
        REFERENCES Volunteer(volunteerId),

    CONSTRAINT FK_Application_Event
        FOREIGN KEY (eventId)
        REFERENCES Event(eventId),

    CONSTRAINT CK_Application_Status
        CHECK (status IN
        (
            N'Күтілуде',
            N'Қабылданды',
            N'Қабылданбады'
        )),

    CONSTRAINT UQ_Application
        UNIQUE (volunteerId, eventId)
);
GO


/* ============================================================
   6. RECOMMENDATION - АВТОМАТТЫ ҰСЫНЫСТАР
   ============================================================ */

CREATE TABLE Recommendation
(
    recommendationId INT IDENTITY(1,1) PRIMARY KEY,
    volunteerId INT NOT NULL,
    eventId INT NOT NULL,
    matchPercent DECIMAL(5,2) NOT NULL,

    CONSTRAINT FK_Recommendation_Volunteer
        FOREIGN KEY (volunteerId)
        REFERENCES Volunteer(volunteerId),

    CONSTRAINT FK_Recommendation_Event
        FOREIGN KEY (eventId)
        REFERENCES Event(eventId),

    CONSTRAINT CK_Recommendation_Percent
        CHECK (matchPercent >= 0 AND matchPercent <= 100),

    CONSTRAINT UQ_Recommendation
        UNIQUE (volunteerId, eventId)
);
GO


/* ============================================================
   7. PARTICIPATION - ҚАТЫСУ ТАРИХЫ
   ============================================================ */

CREATE TABLE Participation
(
    participationId INT IDENTITY(1,1) PRIMARY KEY,
    volunteerId INT NOT NULL,
    eventId INT NOT NULL,
    participationDate DATE NOT NULL DEFAULT GETDATE(),
    pointsEarned INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Participation_Volunteer
        FOREIGN KEY (volunteerId)
        REFERENCES Volunteer(volunteerId),

    CONSTRAINT FK_Participation_Event
        FOREIGN KEY (eventId)
        REFERENCES Event(eventId),

    CONSTRAINT CK_Participation_Points
        CHECK (pointsEarned >= 0),

    CONSTRAINT UQ_Participation
        UNIQUE (volunteerId, eventId)
);
GO


/* ============================================================
   8. NOTIFICATION - ХАБАРЛАМАЛАР
   ============================================================ */

CREATE TABLE Notification
(
    notificationId INT IDENTITY(1,1) PRIMARY KEY,
    volunteerId INT NOT NULL,
    message NVARCHAR(500) NOT NULL,
    notificationDate DATETIME NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(30) NOT NULL DEFAULT N'Оқылмады',

    CONSTRAINT FK_Notification_Volunteer
        FOREIGN KEY (volunteerId)
        REFERENCES Volunteer(volunteerId),

    CONSTRAINT CK_Notification_Status
        CHECK (status IN
        (
            N'Оқылды',
            N'Оқылмады'
        ))
);
GO


/* ============================================================
   9. CERTIFICATE - СЕРТИФИКАТТАР
   ============================================================ */

CREATE TABLE Certificate
(
    certificateId INT IDENTITY(1,1) PRIMARY KEY,
    volunteerId INT NOT NULL,
    eventId INT NOT NULL,
    certificateDate DATE NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Certificate_Volunteer
        FOREIGN KEY (volunteerId)
        REFERENCES Volunteer(volunteerId),

    CONSTRAINT FK_Certificate_Event
        FOREIGN KEY (eventId)
        REFERENCES Event(eventId)
);
GO


/* ============================================================
   10. ТЕСТТІК МӘЛІМЕТТЕР - VOLUNTEER
   ============================================================ */

INSERT INTO Volunteer
(
    name,
    phone,
    email,
    skills,
    interests,
    freeTime,
    points
)
VALUES
(
    N'Айдана Серікқызы',
    N'+77001234567',
    N'aidana@mail.com',
    N'Ұйымдастыру, коммуникация',
    N'Экология, балалармен жұмыс',
    N'Сенбі, жексенбі',
    50
),
(
    N'Алихан Нұрланұлы',
    N'+77007654321',
    N'alikhan@mail.com',
    N'IT, дизайн',
    N'Технология, білім',
    N'Жұма, сенбі',
    30
),
(
    N'Мадина Ермекқызы',
    N'+77005554433',
    N'madina@mail.com',
    N'Фото, әлеуметтік желі',
    N'Мәдениет, қайырымдылық',
    N'Жексенбі',
    70
);
GO


/* ============================================================
   11. ТЕСТТІК МӘЛІМЕТТЕР - ORGANIZER
   ============================================================ */

INSERT INTO Organizer
(
    name,
    email,
    organization
)
VALUES
(
    N'Арман Қайратұлы',
    N'arman@organization.kz',
    N'Жастар ұйымы'
),
(
    N'Дана Мұратқызы',
    N'dana@ngo.kz',
    N'Қайырымдылық қоры'
);
GO


/* ============================================================
   12. ТЕСТТІК МӘЛІМЕТТЕР - EVENT
   ============================================================ */

INSERT INTO Event
(
    title,
    description,
    eventDate,
    location,
    requiredSkills,
    availablePlaces,
    organizerId
)
VALUES
(
    N'Таза қала',
    N'Қаланы тазарту бойынша экологиялық акция',
    '2026-10-20',
    N'Ақтөбе қаласы',
    N'Ұйымдастыру, коммуникация',
    20,
    1
),
(
    N'Балаларға көмек',
    N'Балаларға арналған қайырымдылық іс-шарасы',
    '2026-10-25',
    N'Ақтөбе қаласы',
    N'Коммуникация',
    15,
    2
),
(
    N'IT және білім',
    N'Жастарға арналған IT іс-шарасы',
    '2026-11-01',
    N'Ақтөбе қаласы',
    N'IT, дизайн',
    10,
    1
);
GO


/* ============================================================
   13. ТЕСТТІК МӘЛІМЕТТЕР - APPLICATION
   ============================================================ */

INSERT INTO Application
(
    applicationDate,
    status,
    volunteerId,
    eventId
)
VALUES
(
    '2026-10-08',
    N'Қабылданды',
    1,
    1
),
(
    '2026-10-08',
    N'Күтілуде',
    2,
    3
),
(
    '2026-10-08',
    N'Қабылданды',
    3,
    2
);
GO


/* ============================================================
   14. ТЕСТТІК МӘЛІМЕТТЕР - RECOMMENDATION
   ============================================================ */

INSERT INTO Recommendation
(
    volunteerId,
    eventId,
    matchPercent
)
VALUES
(
    1,
    1,
    95.00
),
(
    2,
    3,
    92.00
),
(
    3,
    2,
    88.00
);
GO


/* ============================================================
   15. ТЕСТТІК МӘЛІМЕТТЕР - PARTICIPATION
   ============================================================ */

INSERT INTO Participation
(
    volunteerId,
    eventId,
    participationDate,
    pointsEarned
)
VALUES
(
    1,
    1,
    '2026-10-20',
    20
),
(
    3,
    2,
    '2026-10-25',
    25
);
GO


/* ============================================================
   16. ТЕСТТІК МӘЛІМЕТТЕР - NOTIFICATION
   ============================================================ */

INSERT INTO Notification
(
    volunteerId,
    message,
    status
)
VALUES
(
    1,
    N'Сіздің өтінішіңіз қабылданды.',
    N'Оқылмады'
),
(
    2,
    N'Сізге жаңа іс-шара ұсынылды.',
    N'Оқылмады'
),
(
    3,
    N'Сіздің өтінішіңіз қабылданды.',
    N'Оқылды'
);
GO


/* ============================================================
   17. ТЕСТТІК МӘЛІМЕТТЕР - CERTIFICATE
   ============================================================ */

INSERT INTO Certificate
(
    volunteerId,
    eventId,
    certificateDate
)
VALUES
(
    1,
    1,
    '2026-10-20'
),
(
    3,
    2,
    '2026-10-25'
);
GO


SELECT 
    E.eventId,
    E.title,
    E.eventDate,
    E.location,
    E.availablePlaces,
    O.name AS organizerName,
    O.organization
FROM Event E
INNER JOIN Organizer O
    ON E.organizerId = O.organizerId;
GO

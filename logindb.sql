USE medicaldosagedb;

CREATE TABLE User1 (
    UserID INT PRIMARY KEY IDENTITY(1,1), 
    Username VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(255),
    LicenseNumber VARCHAR(50) UNIQUE,
    Hospital VARCHAR(255),
    RegistrationDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME
);
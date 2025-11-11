USE medicaldosagedb;
IF OBJECT_ID('Patient', 'U') IS NOT NULL 
    DROP TABLE Patient;
    
CREATE TABLE Patient (
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PatientName NVARCHAR(200) NOT NULL,
    Age INT,
    Weight DECIMAL(6,2),
    Disease NVARCHAR(500),
    DiseaseCode NVARCHAR(50), 
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES User1(UserID) ON DELETE CASCADE
);

CREATE INDEX idx_patient_user ON Patient(UserID);
CREATE INDEX idx_patient_disease ON Patient(DiseaseCode);
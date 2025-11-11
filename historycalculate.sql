USE medicaldosagedb;
GO 

IF OBJECT_ID('calculations', 'U') IS NOT NULL
BEGIN
    DROP TABLE calculations;
    PRINT '🗑️ ลบตาราง calculations เก่าแล้ว';
END
GO

CREATE TABLE calculations (
    id INT PRIMARY KEY IDENTITY(1,1), 
    
    doctor_id INT NOT NULL, 
    
    patient_name VARCHAR(255) NOT NULL,
    patient_age INT,
    patient_age_category VARCHAR(20),
    patient_weight DECIMAL(5,2),
    patient_disease VARCHAR(500),
    
    medicine_name VARCHAR(255) NOT NULL,
    medicine_type VARCHAR(255),
    
    base_dose DECIMAL(10,2),
    age_adjustment_factor DECIMAL(5,2),
    dosage_per_time DECIMAL(10,2) NOT NULL, 
    frequency INT NOT NULL,
    total_daily_dose DECIMAL(10,2) NOT NULL,
    
    tablets_per_dose DECIMAL(10,2),
    tablet_size INT,
    
    crcl DECIMAL(10,2),
    child_pugh_score INT,
    adjusted_body_weight DECIMAL(10,2),
    body_surface_area DECIMAL(5,2),
    
    is_override BIT DEFAULT 0, 
    override_reason TEXT,
    override_doctor_name VARCHAR(255),
    
    recommended_min_dose DECIMAL(10,2),
    recommended_max_dose DECIMAL(10,2),
    recommended_frequency INT,
    
    calculated_at DATETIME DEFAULT GETDATE(), 
    
    FOREIGN KEY (doctor_id) REFERENCES User1(UserID) ON DELETE CASCADE
);

PRINT '✅ สร้างตาราง calculations พร้อม Age Tracking สำเร็จ';
GO
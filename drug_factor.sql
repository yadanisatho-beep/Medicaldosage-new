USE medicaldosagedb;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[drugs]') AND type in (N'U'))
BEGIN
    CREATE TABLE drugs (
        drug_id INT IDENTITY(1,1) PRIMARY KEY,
        generic_name NVARCHAR(500) NOT NULL,
        type NVARCHAR(255),
        dosage NVARCHAR(MAX),
        [condition] NVARCHAR(MAX),
        caution NVARCHAR(MAX),
        created_date DATETIME DEFAULT GETDATE()
    );
    
    PRINT '✅ สร้างตาราง drugs สำเร็จ';
    
    -- เพิ่มข้อมูลตัวอย่าง
    INSERT INTO drugs (generic_name, type, dosage, [condition], caution) VALUES
    ('Aluminium hydroxide + Magnesium hydroxide', 'Antacid', 'chewable tab, tab, susp', 'กรดไหลย้อน แผลในกระเพาะ', 'ห่างจากยาอื่น 1-2 ชั่วโมง'),
    ('Paracetamol', 'Analgesic/Antipyretic', '500mg tablet, 120mg/5ml syrup', 'ลดไข้ แก้ปวด', 'ไม่เกิน 4000mg/วัน ระวังโรคตับ'),
    ('Amoxicillin', 'Antibiotic', '250mg, 500mg capsule', 'การติดเชื้อแบคทีเรีย', 'แพ้ Penicillin ห้ามใช้');
    
    PRINT '✅ เพิ่มข้อมูลตัวอย่างใน drugs สำเร็จ';
END
ELSE
BEGIN
    PRINT 'ℹ️ ตาราง drugs มีอยู่แล้ว';
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_medicine_factors]') AND type in (N'U'))
BEGIN
    DROP TABLE user_medicine_factors;
    PRINT '🗑️ ลบตาราง user_medicine_factors เดิมแล้ว';
END
GO

CREATE TABLE user_medicine_factors (
    factor_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    drug_id INT NOT NULL,
    medicine_name NVARCHAR(500),
    medicine_type NVARCHAR(255),
    
    standard_dose_per_kg DECIMAL(10,2) NOT NULL,
    standard_dose_per_m2 DECIMAL(10,2),
    elimination_route NVARCHAR(50) NOT NULL,
    half_life_hours DECIMAL(10,2),
    standard_frequency NVARCHAR(20) NOT NULL,
    standard_frequency_int INT NOT NULL,
    max_dose_per_unit DECIMAL(10,2) NOT NULL,
    max_daily_dose DECIMAL(10,2) NOT NULL,
    
    requires_renal_adjustment BIT DEFAULT 0,
    crcl_threshold_mild DECIMAL(10,2),
    crcl_threshold_moderate DECIMAL(10,2),
    crcl_threshold_severe DECIMAL(10,2),
    renal_adjustment_mild DECIMAL(5,2),
    renal_adjustment_moderate DECIMAL(5,2),
    renal_adjustment_severe DECIMAL(5,2),
    
    requires_hepatic_adjustment BIT DEFAULT 0,
    child_pugh_a_factor DECIMAL(5,2) DEFAULT 1.0,
    child_pugh_b_factor DECIMAL(5,2),
    child_pugh_c_factor DECIMAL(5,2),
    
    notes NVARCHAR(MAX),
    
    created_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_UserMedicineFactors_User FOREIGN KEY (user_id) 
        REFERENCES User1(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_UserMedicineFactors_Drug FOREIGN KEY (drug_id) 
        REFERENCES drugs(drug_id) ON DELETE CASCADE,
    
    CONSTRAINT UQ_UserDrug UNIQUE(user_id, drug_id)
);
GO

PRINT '✅ สร้างตาราง user_medicine_factors สำเร็จ';
GO

CREATE INDEX IDX_UserMedicineFactors_UserId 
    ON user_medicine_factors(user_id);
GO

CREATE INDEX IDX_UserMedicineFactors_DrugId 
    ON user_medicine_factors(drug_id);
GO

PRINT '✅ สร้าง Index สำเร็จ';
GO

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('drugs', 'user_medicine_factors')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

PRINT '✅ ตารางทั้งหมดพร้อมใช้งาน';
GO
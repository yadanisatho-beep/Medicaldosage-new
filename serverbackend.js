require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const sql = require('mssql');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fs = require('fs').promises;
const path = require('path');
const app = express();
const fetch = require('node-fetch');
const port = 3000;

// ***************************************************************
// 1. CONFIGURATION (ตั้งค่า)
// ***************************************************************
const saltRounds = 10;
// 💡 สำคัญ: ควรเปลี่ยนคีย์นี้ให้ซับซ้อนและเก็บเป็น Environment Variable
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
// Database Config
const sqlConfig = {
  user: 'sa',
  password: '150348',
  server: 'PREAMLABTOP\\SQLEXPRESS',
  database: 'medicaldosagedb',
  options: {
    trustServerCertificate: true,
    enableArithAbort: true
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 600000,
    acquireTimeoutMillis: 30000
  },
  // ✅ ADD THIS:
  requestTimeout: 60000, // Increase to 60 seconds (was default 15s)
  connectionTimeout: 30000 // 30 seconds for initial connection
};

// ***************************************************************
// 2. DATABASE CONNECTION & HELPER
// ***************************************************************

let pool; // Pool สำหรับจัดการ Connection

async function connectToDb() {
  try {
    if (!pool) {
      console.log('🔄 Connecting to database...');
      pool = await sql.connect(sqlConfig);
      console.log('✅ Database connected successfully');
      
      // ✅ เพิ่ม: ตั้งค่า default timeout สำหรับทุก request
      pool.config.requestTimeout = 60000;
      
      pool.on('error', err => {
        console.error('⚠️ Database Pool Error (Resetting pool):', err);
        if (pool) { 
            pool.close(); 
            pool = null; 
        }
      });
    }
    return pool;
  } catch (err) {
    console.error('❌ Database Connection Failed (Fatal):', err);
    pool = null;
    throw err;
  }
}
async function queryWithRetry(connection, queryString, maxRetries = 2) {
  let attempt = 0;
  
  while (attempt <= maxRetries) {
    try {
      const request = connection.request();
      request.timeout = 60000; // 60 seconds
      
      const result = await request.query(queryString);
      return result;
      
    } catch (error) {
      attempt++;
      
      if (error.code === 'ETIMEOUT' && attempt <= maxRetries) {
        console.warn(`⚠️ Query timeout, retrying... (Attempt ${attempt}/${maxRetries})`);
        await new Promise(resolve => setTimeout(resolve, 1000)); // รอ 1 วินาที
        continue;
      }
      
      throw error; 
    }
  }
}


// Helper function: ฟังก์ชันแปลงค่าว่างเป็น NULL เพื่อให้ SQL ไม่เกิด error
function cleanDataForSQL(value) { // นำเข้าจาก calculatedb.js
  return (value === '' || value === null || value === undefined || (typeof value === 'string' && value.trim() === '')) ? null : value;
}

// ***************************************************************
// 3. MIDDLEWARE
// ***************************************************************

app.use(bodyParser.json());
app.use(cors({
  origin: [
    'http://localhost:3000',
    'https://elementarily-divisionary-mildred.ngrok-free.dev/'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'ngrok-skip-browser-warning']
}));

// ✅ เพิ่ม middleware สำหรับ ngrok warning bypass
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', req.headers.origin);
  res.header('Access-Control-Allow-Credentials', 'true');
  next();
});

app.use(express.static('public'));

async function requireAuth(req, res, next) {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            return res.status(401).json({ message: 'Authorization token missing' });
        }
        
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded; 
        
        next();
    } catch (err) {
        console.error('JWT Verification Error:', err);
        res.status(401).json({ message: 'Invalid token' });
    }
}
// ***************************************************************
// 4. API Routes: AUTHENTICATION & USER (สมมติจาก Client-Side)
// ***************************************************************

// POST /api/register
app.post('/api/register', async (req, res) => {
  const { username, password, firstName, lastName, email, licenseNumber, hospital } = req.body;

  try {
    // ตรวจข้อมูล
    if (!username || !password || !firstName || !lastName || !email || !licenseNumber) {
      return res.status(400).json({ success: false, error: 'กรุณากรอกข้อมูลให้ครบถ้วน', code: 'MISSING_FIELDS' });
    }

    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const connection = await connectToDb();

    // ✅ ลอง insert
    await connection.request()
      .input('Username', sql.VarChar(100), username)
      .input('PasswordHash', sql.VarChar(255), hashedPassword)
      .input('FirstName', sql.VarChar(100), firstName)
      .input('LastName', sql.VarChar(100), lastName)
      .input('Email', sql.VarChar(255), email)
      .input('LicenseNumber', sql.VarChar(50), licenseNumber)
      .input('Hospital', sql.VarChar(255), hospital)
      .query(`
        INSERT INTO User1 (Username, PasswordHash, FirstName, LastName, Email, LicenseNumber, Hospital)
        VALUES (@Username, @PasswordHash, @FirstName, @LastName, @Email, @LicenseNumber, @Hospital)
      `);

    res.status(201).json({ success: true, message: 'ลงทะเบียนสำเร็จแล้ว' });

  } catch (error) {
    console.error('❌ [Register] error:', error);

    // ตรวจว่าซ้ำหรือไม่ (SQL error 2627 = duplicate key)
    if (error.code === 'EREQUEST' && error.number === 2627) {
      const message = error.message?.toLowerCase() || '';

      // ✅ แยกกรณีชัดเจน
      if (message.includes('username')) {
        return res.status(409).json({
          success: false,
          error: 'ชื่อผู้ใช้นี้ถูกใช้งานแล้ว กรุณาเลือกชื่ออื่น',
          code: 'DUPLICATE_USERNAME'
        });
      }
      if (message.includes('license')) {
        return res.status(409).json({
          success: false,
          error: 'เลขที่ใบอนุญาตนี้ถูกลงทะเบียนแล้ว',
          code: 'DUPLICATE_LICENSE'
        });
      }
      if (message.includes('email')) {
        return res.status(409).json({
          success: false,
          error: 'อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่นหรือเข้าสู่ระบบ',
          code: 'DUPLICATE_EMAIL'
        });
      }

      // fallback ถ้าหาไม่เจอ
      return res.status(409).json({
        success: false,
        error: 'ข้อมูลซ้ำในระบบ อาจเป็นชื่อผู้ใช้ อีเมล หรือเลขที่ใบอนุญาตที่มีอยู่แล้ว',
        code: 'DUPLICATE_ENTRY'
      });
    }

    // error อื่นๆ
    return res.status(500).json({ success: false, error: 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์', code: 'SERVER_ERROR' });
  }
});

// POST /api/login - เข้าสู่ระบบ
app.post('/api/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    console.log('🔍 Login attempt for username:', username);
    
    if (!username || !password) {
      return res.status(400).json({ 
        success: false,
        error: 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน', 
        code: 'MISSING_FIELDS' 
      });
    }

    const connection = await connectToDb();
    const result = await connection.request()
      .input('Username', sql.VarChar(100), username)
      .query('SELECT UserID, Username, PasswordHash, FirstName, LastName, Email, LicenseNumber, Hospital FROM User1 WHERE Username = @Username');

    if (result.recordset.length === 0) {
      console.log('❌ User not found:', username);
      return res.status(401).json({ 
        success: false,
        error: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง', 
        code: 'INVALID_CREDENTIALS' 
      });
    }

    const user = result.recordset[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.PasswordHash);
    
    if (!isPasswordValid) {
      console.log('❌ Invalid password for user:', username);
      return res.status(401).json({ 
        success: false,
        error: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง', 
        code: 'INVALID_CREDENTIALS' 
      });
    }

    await connection.request()
      .input('UserID', sql.Int, user.UserID)
      .query(`
        UPDATE User1 
        SET LastLogin = DATEADD(HOUR, 7, GETUTCDATE()) 
        WHERE UserID = @UserID
      `);

    console.log(`✅ Updated LastLogin for UserID: ${user.UserID} with Thailand timezone`);

    // Generate JWT token
    const token = jwt.sign(
      { 
        UserID: user.UserID,
        Username: user.Username 
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    console.log('✅ Login successful for user:', username);

    res.json({
      success: true,
      message: 'เข้าสู่ระบบสำเร็จ',
      token: token,
      user: {
        UserID: user.UserID,
        Username: user.Username,
        FirstName: user.FirstName,
        LastName: user.LastName,
        Email: user.Email,
        LicenseNumber: user.LicenseNumber,
        Hospital: user.Hospital
      }
    });

  } catch (error) {
    console.error('❌ [Login] error:', error);
    res.status(500).json({ 
      success: false,
      error: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ', 
      code: 'DB_ERROR' 
    });
  }
});

app.get('/api/user/profile', requireAuth, async (req, res) => {
    try {
        const UserID = req.user.UserID; 
        
        const pool = await connectToDb();
        const request = pool.request();
        
        // ✅ แปลงเวลาเป็น Thailand timezone
        const result = await request
            .input('UserID', sql.Int, UserID)
            .query(`
              SELECT 
                UserID, 
                Username, 
                FirstName, 
                LastName, 
                LicenseNumber, 
                Hospital,
                Email,
                CONVERT(VARCHAR(50), DATEADD(HOUR, -7, RegistrationDate), 126) + 'Z' as RegistrationDate,
                CONVERT(VARCHAR(50), DATEADD(HOUR, -7, LastLogin), 126) + 'Z' as LastLogin
              FROM User1 
              WHERE UserID = @UserID
            `);

        if (result.recordset.length === 0) {
            return res.status(404).json({ 
              message: 'User data not found in DB' 
            });
        }

        console.log('✅ User profile fetched with Thailand timezone');

        res.json({ 
          success: true, 
          user: result.recordset[0] 
        });

    } catch (error) {
        console.error('Error fetching full user profile:', error);
        res.status(500).json({ 
          message: 'Server error fetching user profile' 
        });
    }
});

app.post('/api/user/stats', requireAuth, async (req, res) => {
    try {
        const UserID = req.user.UserID;
        const { date, doseCount, doseTotal, note } = req.body; 

        if (!date || doseCount === undefined || doseTotal === undefined) {
            return res.status(400).json({ success: false, message: 'Missing required data: date, doseCount, or doseTotal.' });
        }

        const pool = await connectToDb();
        const request = pool.request();
        
        const insertResult = await request
            .input('UserID', sql.Int, UserID)
            .input('StatDate', sql.Date, date) 
            .input('DoseCount', sql.Int, doseCount)
            .input('DoseTotal', sql.Int, doseTotal)
            .input('Note', sql.NVarChar, note || null) 
            .query(`INSERT INTO DailyStats 
                    (UserID, StatDate, DoseCount, DoseTotal, Note)
                    VALUES (@UserID, @StatDate, @DoseCount, @DoseTotal, @Note)`);

        if (insertResult.rowsAffected[0] === 0) {
            return res.status(500).json({ success: false, message: 'Failed to insert data into database.' });
        }

        res.status(201).json({ success: true, message: 'Daily stats saved successfully.' });

    } catch (error) {
        console.error('Error submitting daily stats:', error);
        res.status(500).json({ success: false, message: 'Internal server error while saving stats.' });
    }
});
app.get('/api/user/stats', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        const pool = await connectToDb();
        
        const calcResult = await pool.request()
            .input('UserID', sql.Int, userID)
            .query('SELECT COUNT(*) as total FROM calculations WHERE doctor_id = @UserID');
        
        const patientResult = await pool.request()
            .input('UserID', sql.Int, userID)
            .query('SELECT COUNT(*) as total FROM Patient WHERE UserID = @UserID');
        
        res.json({
            success: true,
            stats: {
                totalCalculations: calcResult.recordset[0].total,
                totalPatients: patientResult.recordset[0].total
            }
        });
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch stats' });
    }
});
app.get('/api/user/personal-info', requireAuth, async (req, res) => {
  try {
    const connection = await connectToDb();
    
    const result = await connection.request()
      .input('UserID', sql.Int, req.user.UserID)
      .query(`
        SELECT 
          UserID, 
          Username, 
          FirstName, 
          LastName, 
          Email, 
          LicenseNumber, 
          Hospital, 
          CONVERT(VARCHAR(50), DATEADD(HOUR, -7, RegistrationDate), 126) + 'Z' as RegistrationDate,
          CONVERT(VARCHAR(50), DATEADD(HOUR, -7, LastLogin), 126) + 'Z' as LastLogin
        FROM User1
        WHERE UserID = @UserID
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ 
        success: false, 
        error: 'ไม่พบข้อมูลผู้ใช้' 
      });
    }

    console.log('✅ Personal info fetched with Thailand timezone');

    res.json({ 
      success: true, 
      user: result.recordset[0] 
    });
  } catch (error) {
    console.error('❌ [User] Fetch error:', error);
    res.status(500).json({ 
      error: 'ไม่สามารถดึงข้อมูลส่วนตัวได้', 
      code: 'DB_ERROR' 
    });
  }
});

app.put('/api/user/personal-info', requireAuth, async (req, res) => {
    try {
        const { firstName, lastName, email, hospital } = req.body;  
        const userID = req.user.UserID;
        if (!email || email.trim() === '') {
            return res.status(400).json({ 
                success: false, 
                error: 'กรุณาระบุอีเมล', 
                code: 'MISSING_EMAIL' 
            });
        }

        const connection = await connectToDb();
        const result = await connection.request()
            .input('UserID', sql.Int, userID)
            .input('FirstName', sql.VarChar(100), firstName)
            .input('LastName', sql.VarChar(100), lastName)
            .input('Email', sql.VarChar(255), email) // ใช้ email โดยตรง
            .input('Hospital', sql.VarChar(255), cleanDataForSQL(hospital))
            .query(`
                UPDATE User1
                SET 
                    FirstName = @FirstName,
                    LastName = @LastName,
                    Email = @Email,
                    Hospital = @Hospital
                WHERE UserID = @UserID
            `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'ไม่พบผู้ใช้ที่ต้องการอัปเดต' 
            });
        }

        res.json({ 
            success: true, 
            message: 'อัปเดตข้อมูลส่วนตัวสำเร็จ' 
        });

    } catch (error) {
        console.error('❌ [User] Update error:', error);
        if (error.code === 'EREQUEST' && error.number === 2627) {
            return res.status(409).json({ 
                success: false,
                error: 'อีเมลนี้ถูกใช้งานแล้ว', 
                code: 'DUPLICATE_EMAIL' 
            });
        }
        
        res.status(500).json({ 
            success: false,
            error: 'ไม่สามารถอัปเดตข้อมูลส่วนตัวได้', 
            code: 'DB_ERROR' 
        });
    }
});
app.put('/api/user/security', requireAuth, async (req, res) => {
    const { currentPassword, newPassword, licenseNumber } = req.body;
    const UserID = req.user.UserID;

    try {
        const pool = await connectToDb();

        if (newPassword && currentPassword) {
            const result = await pool.request()
                .input('UserID', sql.Int, UserID)
                .query('SELECT PasswordHash FROM User1 WHERE UserID = @UserID');

            if (result.recordset.length === 0) {
                return res.status(404).json({ success: false, message: 'ไม่พบผู้ใช้งาน' });
            }

            const currentHash = result.recordset[0].PasswordHash;

            const isMatch = await bcrypt.compare(currentPassword, currentHash);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'รหัสผ่านเดิมไม่ถูกต้อง' });
            }

            const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);
            await pool.request()
                .input('UserID', sql.Int, UserID)
                .input('NewPasswordHash', sql.VarChar(255), newPasswordHash)
                .query('UPDATE User1 SET PasswordHash = @NewPasswordHash WHERE UserID = @UserID');
        }

        if (licenseNumber) {
            await pool.request()
                .input('UserID', sql.Int, UserID)
                .input('LicenseNumber', sql.VarChar(50), licenseNumber)
                .query('UPDATE User1 SET LicenseNumber = @LicenseNumber WHERE UserID = @UserID');
        }

        res.json({ success: true, message: 'บันทึกการตั้งค่าความปลอดภัยสำเร็จ' });

    } catch (error) {
        console.error('❌ Error in PUT /api/user/security:', error);
        res.status(500).json({ success: false, message: 'เกิดข้อผิดพลาดในการบันทึกการตั้งค่าความปลอดภัย' });
    }
});

// ***************************************************************
// 7. License Verification Route 
// ***************************************************************

app.post('/api/user/verify-license', async (req, res) => {
    const { licenseNumber } = req.body;

    if (!licenseNumber) {
        return res.status(400).json({ success: false, error: 'กรุณากรอกเลขที่ใบอนุญาต' });
    }

    try {
        const connection = await connectToDb();
        const result = await connection.request()
            .input('licenseNumber', sql.VarChar(50), licenseNumber)
            .query(`
                SELECT TOP 1 licenseNumber
                FROM licenses 
                WHERE licenseNumber = @licenseNumber AND status = 'active'
            `);

        if (result.recordset.length > 0) {
            res.json({ 
                success: true, 
                message: 'ตรวจสอบใบอนุญาตสำเร็จ: หมายเลขนี้ถูกต้องและใช้งานได้' 
            });
        } else {
            res.status(404).json({ 
                success: false, 
                error: 'ไม่พบใบอนุญาต หรือใบอนุญาตหมดอายุ/ไม่ถูกต้อง' 
            });
        }
    } catch (error) {
        console.error('❌ DB Error verifying license:', error);
        res.status(500).json({ 
            success: false, 
            error: 'เกิดข้อผิดพลาดภายในในการตรวจสอบฐานข้อมูล' 
        });
    }
});


// ***************************************************************
// 5. API Routes: PATIENTS (CRUD)
// ***************************************************************

// GET /api/patients - ดึงผู้ป่วยทั้งหมดของผู้ใช้
app.get('/api/patients', requireAuth, async (req, res) => {
  try {
    const userID = req.user.UserID; //
    const connection = await connectToDb(); //
    const result = await connection.request() //
      .input('UserID', sql.Int, userID) //
      .query('SELECT PatientID, PatientName, Age, Weight, Disease, DiseaseCode FROM Patient WHERE UserID = @UserID ORDER BY UpdatedDate DESC'); //

    res.json({ //
      success: true, //
      patients: result.recordset //
    });
  } catch (error) { //
    console.error('❌ [Patients] Fetch error:', error); //
    res.status(500).json({ //
      error: 'ไม่สามารถดึงข้อมูลผู้ป่วยได้', //
      code: 'DB_ERROR' //
    });
  }
});

// GET /api/patients/:id - Fixed version
app.get('/api/patients/:id', requireAuth, async (req, res) => {
    const patientId = req.params.id;
    const userId = req.user.UserID; // Get UserID from Token verified by requireAuth
    
    try {
        const pool = await connectToDb();
        const result = await pool.request()
            .input('PatientID', sql.Int, patientId)
            .input('UserID', sql.Int, userId)
            .query(`SELECT * FROM Patient WHERE PatientID = @PatientID AND UserID = @UserID`);

        if (result.recordset.length === 0) {
            return res.status(404).json({ success: false, error: 'ไม่พบข้อมูลผู้ป่วย' });
        }
        
        res.json({ success: true, patient: result.recordset[0] });

    } catch (error) {
        console.error('❌ Error fetching patient data:', error);
        res.status(500).json({ success: false, error: 'ไม่สามารถดึงข้อมูลผู้ป่วยได้' });
    }
});

// POST /api/patients - สร้างผู้ป่วยใหม่
app.post('/api/patients', requireAuth, async (req, res) => {
  try {
    const { name, age, weight, disease, diseaseCode } = req.body; //
    const userID = req.user.UserID; //

    if (!name || !name.trim()) { //
      return res.status(400).json({ //
        error: 'กรุณากรอกชื่อผู้ป่วย', //
        code: 'MISSING_NAME' //
      });
    }

    const connection = await connectToDb(); //
    const result = await connection.request() //
      .input('UserID', sql.Int, userID) //
      .input('PatientName', sql.NVarChar(200), name.trim()) //
      .input('Age', sql.Int, age ? parseInt(age) : null) //
      .input('Weight', sql.Decimal(6,2), weight ? parseFloat(weight) : null) //
      .input('Disease', sql.NVarChar(500), disease || 'ไม่ระบุ') //
      .input('DiseaseCode', sql.NVarChar(50), diseaseCode || null) //
      .query(`
        INSERT INTO Patient (UserID, PatientName, Age, Weight, Disease, DiseaseCode)
        VALUES (@UserID, @PatientName, @Age, @Weight, @Disease, @DiseaseCode);
        SELECT SCOPE_IDENTITY() AS PatientID;
      `);

    res.status(201).json({ success: true, message: 'เพิ่มข้อมูลผู้ป่วยสำเร็จ', patientId: result.recordset[0].PatientID });
  } catch (error) {
    console.error('❌ [Patients] Create error:', error);
    res.status(500).json({ error: 'ไม่สามารถเพิ่มข้อมูลผู้ป่วยได้', code: 'DB_ERROR' });
  }
});

// PUT /api/patients/:PatientID - อัปเดตผู้ป่วย (สมมติจาก Client-Side)
app.put('/api/patients/:PatientID', requireAuth, async (req, res) => {
    try {
        const { PatientID } = req.params;
        const { name, age, weight, disease, diseaseCode } = req.body;
        const userID = req.user.UserID;

        const connection = await connectToDb();
        const result = await connection.request()
            .input('PatientID', sql.Int, PatientID)
            .input('UserID', sql.Int, userID)
            .input('PatientName', sql.NVarChar(200), name.trim())
            .input('Age', sql.Int, age ? parseInt(age) : null)
            .input('Weight', sql.Decimal(6,2), weight ? parseFloat(weight) : null)
            .input('Disease', sql.NVarChar(500), disease || 'ไม่ระบุ')
            .input('DiseaseCode', sql.NVarChar(50), diseaseCode || null)
            .query(`
                UPDATE Patient 
                SET 
                    PatientName = @PatientName, 
                    Age = @Age, 
                    Weight = @Weight, 
                    Disease = @Disease,
                    DiseaseCode = @DiseaseCode,
                    UpdatedDate = GETDATE()
                WHERE PatientID = @PatientID AND UserID = @UserID;
            `);
        
        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบผู้ป่วย หรือไม่ได้รับอนุญาตให้อัปเดต' });
        }

        res.json({ success: true, message: 'อัปเดตข้อมูลผู้ป่วยสำเร็จ' });

    } catch (error) {
        console.error('❌ [Patients] Update error:', error);
        res.status(500).json({ error: 'ไม่สามารถอัปเดตข้อมูลผู้ป่วยได้', code: 'DB_ERROR' });
    }
});

// DELETE /api/patients/:PatientID - ลบผู้ป่วย (สมมติจาก Client-Side)
app.delete('/api/patients/:PatientID', requireAuth, async (req, res) => {
    try {
        const { PatientID } = req.params;
        const userID = req.user.UserID;

        const connection = await connectToDb();
        const result = await connection.request()
            .input('PatientID', sql.Int, PatientID)
            .input('UserID', sql.Int, userID)
            .query(`
                DELETE FROM Patient 
                WHERE PatientID = @PatientID AND UserID = @UserID;
            `);
        
        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบผู้ป่วย หรือไม่ได้รับอนุญาตให้ลบ' });
        }

        res.json({ success: true, message: 'ลบข้อมูลผู้ป่วยสำเร็จ' });

    } catch (error) {
        console.error('❌ [Patients] Delete error:', error);
        res.status(500).json({ error: 'ไม่สามารถลบข้อมูลผู้ป่วยได้', code: 'DB_ERROR' });
    }
});

// ***************************************************************
// 7. API Routes: DISEASES (สำหรับ Autocomplete/ค้นหา)
// ***************************************************************
app.get('/api/diseases', async (req, res) => {
  try {
    const connection = await connectToDb();
    const result = await connection.request()
      .query(`
        SELECT 
          id AS Code,
          name AS Name,
          category AS Category,
          keyword AS Keyword
        FROM disease
        ORDER BY name
      `);

    res.json({ 
      success: true, 
      diseases: result.recordset 
    });
    
    console.log(`✅ โหลดข้อมูลโรค: ${result.recordset.length} รายการ`);
  } catch (error) {
    console.error('❌ Error loading diseases from DB:', error);
    res.status(500).json({ 
      success: false, 
      error: 'ไม่สามารถดึงข้อมูลโรคได้',
      diseases: [] 
    });
  }
});

// GET /api/diseases/search - ค้นหาโรคด้วย keyword
app.get('/api/diseases/search', async (req, res) => {
  try {
    const { q } = req.query;
    
    // ถ้าไม่มี query หรือสั้นเกินไป
    if (!q || q.trim().length < 2) {
      return res.json({ success: true, diseases: [] });
    }

    const connection = await connectToDb();
    const searchTerm = `%${q.trim()}%`;
    
    const result = await connection.request()
      .input('searchTerm', sql.NVarChar, searchTerm)
      .query(`
        SELECT TOP 15
          id AS Code,
          name AS Name,
          category AS Category,
          keyword AS Keyword
        FROM disease
        WHERE name LIKE @searchTerm 
           OR id LIKE @searchTerm
           OR keyword LIKE @searchTerm
           OR category LIKE @searchTerm
        ORDER BY 
          CASE 
            WHEN name LIKE @searchTerm THEN 1
            WHEN id LIKE @searchTerm THEN 2
            ELSE 3
          END,
          name
      `);

    res.json({ 
      success: true, 
      diseases: result.recordset 
    });
    
    console.log(`🔍 ค้นหา "${q}": พบ ${result.recordset.length} รายการ`);

  } catch (error) {
    console.error('❌ Error searching diseases:', error);
    res.status(500).json({ 
      success: false, 
      error: 'เกิดข้อผิดพลาดในการค้นหา',
      diseases: [] 
    });
  }
});

// GET /api/diseases/search - ค้นหาโรคด้วย keyword
app.get('/api/diseases/search', async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.trim().length < 2) {
      return res.json({ success: true, diseases: [] });
    }

    const connection = await connectToDb();
    const result = await connection.request()
      .input('searchTerm', sql.NVarChar, `%${q.trim()}%`)
      .query(`
        SELECT TOP 15
          id AS Code,
          name AS Name,
          category AS Category,
          keyword AS Keyword
        FROM disease
        WHERE name LIKE @searchTerm 
           OR id LIKE @searchTerm
           OR keyword LIKE @searchTerm
           OR category LIKE @searchTerm
        ORDER BY 
          CASE 
            WHEN name LIKE @searchTerm THEN 1
            WHEN id LIKE @searchTerm THEN 2
            ELSE 3
          END,
          name
      `);

    res.json({ 
      success: true, 
      diseases: result.recordset 
    });

  } catch (error) {
    console.error('❌ Error searching diseases:', error);
    res.status(500).json({ 
      success: false, 
      error: 'เกิดข้อผิดพลาดในการค้นหา',
      diseases: [] 
    });
  }
});

// ***************************************************************
// 6. API Routes: MEDICINES
// ***************************************************************
app.get('/api/medicines', requireAuth, async (req, res) => {
  try {
    const connection = await connectToDb();
    const request = connection.request();
    request.timeout = 60000;
    
    const result = await request.query(`
      SELECT 
        drug_id as MedicineID,
        generic_name as GenericName,
        type as Type,
        dosage as Dosage,
        condition as Indication,
        caution as Warning
      FROM drugs
      ORDER BY generic_name
    `);

    res.json({
      success: true,
      medicines: result.recordset
    });

    console.log(`✅ โหลดข้อมูลยา: ${result.recordset.length} รายการ`);

  } catch (error) {
    console.error('❌ [Medicines] Fetch error:', error);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงข้อมูลยา',
      error: error.message
    });
  }
});

// ***************************************************************
// ✅ NEW ROUTE: GET /api/medicines/configured - ดึงเฉพาะยาที่กรอกปัจจัยแล้ว
// ใช้สำหรับหน้า calculatemed.html
// ***************************************************************
app.get('/api/medicines/configured', requireAuth, async (req, res) => {
  try {
    const userID = req.user.UserID;
    const connection = await connectToDb();
    
    const result = await connection.request()
      .input('UserID', sql.Int, userID)
      .query(`
        SELECT 
          umf.drug_id,
          umf.medicine_name,
          umf.medicine_type,
          umf.standard_dose_per_kg,
          umf.standard_dose_per_m2,
          umf.elimination_route,
          umf.half_life_hours,
          umf.standard_frequency,
          umf.standard_frequency_int,
          umf.max_dose_per_unit,
          umf.max_daily_dose,
          umf.requires_renal_adjustment,
          umf.crcl_threshold_mild,
          umf.crcl_threshold_moderate,
          umf.crcl_threshold_severe,
          umf.renal_adjustment_mild,
          umf.renal_adjustment_moderate,
          umf.renal_adjustment_severe,
          umf.requires_hepatic_adjustment,
          umf.child_pugh_a_factor,
          umf.child_pugh_b_factor,
          umf.child_pugh_c_factor,
          umf.notes,
          d.dosage as dosage_guideline,
          d.condition as indication,
          d.caution as warning
        FROM user_medicine_factors umf
        INNER JOIN drugs d ON umf.drug_id = d.drug_id
        WHERE umf.user_id = @UserID
        ORDER BY umf.medicine_name
      `);
    
    res.json({
      success: true,
      medicines: result.recordset
    });
    
    console.log(`✅ ดึงยาที่กรอกปัจจัยแล้ว: ${result.recordset.length} รายการ สำหรับ User ${userID}`);
    
  } catch (error) {
    console.error('❌ Error fetching configured medicines:', error);
    res.status(500).json({
      success: false,
      message: 'ไม่สามารถดึงข้อมูลยาที่กรอกปัจจัยได้',
      error: error.message
    });
  }
});
// ========================================================================
// Calculation API
// ========================================================================

app.post('/api/calculate-dosage-advanced', requireAuth, async (req, res) => {
    let connection;
    try {
        const {
            patientAge, patientWeight, patientDisease, medicineName,
            standardDosePerKg, standardDosePerM2, eliminationRoute,
            halfLifeHours, standardFrequency, standardFrequencyInt,
            maxDosePerUnit, maxDailyDose,
            requiresRenalAdjustment,
            crclThresholdMild, crclThresholdModerate, crclThresholdSevere,
            renalAdjustmentMild, renalAdjustmentModerate, renalAdjustmentSevere,
            requiresHepaticAdjustment,
            childPughAFactor, childPughBFactor, childPughCFactor,
            crcl, childPughClass, childPughScore,
            adjustedBodyWeight, bodySurfaceArea,
            
            // 🆕 Age Adjustment Parameters
            requiresAgeAdjustment,
            neonateDoseFactor,
            pediatricDoseFactor,
            adolescentDoseFactor,
            adultDoseFactor,
            elderlyDoseFactor,
            pediatricMaxDose,
            pediatricMaxDailyDose
        } = req.body;

        // ========== 1. VALIDATION ==========
        if (!patientWeight || !patientAge || !standardDosePerKg) {
            return res.status(400).json({
                success: false,
                message: 'ข้อมูลไม่ครบถ้วน (ต้องมีอายุ น้ำหนัก และขนาดยามาตรฐาน)'
            });
        }

        connection = await connectToDb();

        // ========== 2. CALCULATE BASE DOSE ==========
        let baseDose = 0;
        const age = parseInt(patientAge);
        const weight = parseFloat(patientWeight);
        
        let weightUsed = weight;
        if (adjustedBodyWeight && adjustedBodyWeight > 0) {
            weightUsed = adjustedBodyWeight;
        }
        
        if (bodySurfaceArea && bodySurfaceArea > 0 && standardDosePerM2) {
            baseDose = standardDosePerM2 * bodySurfaceArea;
            console.log(`📊 Base Dose (BSA): ${baseDose.toFixed(2)} mg`);
        } else {
            baseDose = standardDosePerKg * weightUsed;
            console.log(`📊 Base Dose (Weight): ${baseDose.toFixed(2)} mg`);
        }

        // ========== 🆕 3. AGE-BASED ADJUSTMENT ==========
        let ageFactor = 1.0;
        let ageCategory = 'adult';
        let ageWarnings = [];
        
        if (requiresAgeAdjustment !== false) {
            if (age < 1) {
                // Neonate (0-1 ปี)
                ageFactor = neonateDoseFactor || 0.3;
                ageCategory = 'neonate';
                ageWarnings.push('ทารกแรกเกิด: ขนาดยาลด 70% (อวัยวะยังไม่เจริญเต็มที่)');
                ageWarnings.push('⚠️ ต้องตรวจ Renal/Hepatic Function ก่อนให้ยาทุกครั้ง');
                ageWarnings.push('📋 พิจารณาใช้ยาทางหลอดเลือดดำแทนทางปาก (Bioavailability ไม่แน่นอน)');
                
            } else if (age < 12) {
                // Pediatric (1-12 ปี)
                ageFactor = pediatricDoseFactor || 0.5;
                ageCategory = 'pediatric';
                ageWarnings.push(`เด็ก ${age} ปี: ปรับขนาดยาเป็น ${Math.round(ageFactor * 100)}%`);
                
            } else if (age < 18) {
                // Adolescent (13-17 ปี)
                ageFactor = adolescentDoseFactor || 0.75;
                ageCategory = 'adolescent';
                ageWarnings.push(`วัยรุ่น ${age} ปี: ปรับขนาดยาเป็น ${Math.round(ageFactor * 100)}%`);
                
            } else if (age < 65) {
                // Adult (18-64 ปี)
                ageFactor = adultDoseFactor || 1.0;
                ageCategory = 'adult';
                
            } else {
                // Elderly (65+ ปี)
                ageFactor = elderlyDoseFactor || 0.75;
                ageCategory = 'elderly';
                ageWarnings.push(`ผู้สูงอายุ ${age} ปี: ผู้สูงอายุ ${age} ปี: ปรับขนาดยาเป็น ${Math.round(ageFactor * 100)}% เนื่องจากการทำงานของไตและตับลดลง`);
                ageWarnings.push('📋 ระวังการทำงานของไตและตับลดลง');
                ageWarnings.push('💊 ระวัง Polypharmacy และ Drug-Drug Interaction');
            }
            
            baseDose = baseDose * ageFactor;
            
            console.log(`👤 Age Adjustment Applied:
            - Age: ${age} years
            - Category: ${ageCategory}
            - Age Factor: ${ageFactor}
            - Base Dose After Age Adj: ${baseDose.toFixed(2)} mg`);
        }

        // ========== 3.1 PEDIATRIC SAFETY CHECK ==========
        if (age < 18) {
            if (pediatricMaxDose && baseDose > pediatricMaxDose) {
                baseDose = pediatricMaxDose;
                ageWarnings.push(`⚠️ จำกัดที่ขนาดสูงสุดสำหรับเด็ก: ${pediatricMaxDose} mg/dose`);
                console.log(`⚠️ Dose capped at pediatric_max_dose: ${pediatricMaxDose} mg`);
            }
        }

        // ========== 4. INITIALIZE ADJUSTMENT VARIABLES ==========
        let adjustedDose = baseDose;
        let renalFactor = 1.0;
        let hepaticFactor = 1.0;
        let adjustedFrequency = standardFrequencyInt;
        let adjustedFrequencyText = standardFrequency;
        let warningMessages = [...ageWarnings];
        let guidelineText = 'คำนวนจากน้ำหนักและอายุของผู้ป่วย';
        
        let renalSeverity = 'normal';
        let intervalExtensionSuggestion = null;

        // ========== 5. RENAL ADJUSTMENT ==========
        if (requiresRenalAdjustment && eliminationRoute && 
            (eliminationRoute === 'Renal' || eliminationRoute === 'Both')) {
            
            if (crcl === null || crcl === undefined) {
                return res.status(400).json({
                    success: false,
                    message: 'กรุณากรอกค่า CrCl สำหรับยาที่ขับทางไต'
                });
            }

        // ========== 6. HEPATIC ADJUSTMENT ==========
            if (crcl < crclThresholdSevere) {
                renalFactor = renalAdjustmentSevere || 0.25;
                renalSeverity = 'severe';

                guidelineText = `ไตวายรุนแรง (CrCl ${crcl} mL/min): ลดขนาดยา ${Math.round((1 - renalFactor) * 100)}% (Dose Reduction)`;

                warningMessages.push('🚨 ไตวายรุนแรง - แนะนำปรึกษาแพทย์ผู้เชี่ยวชาญ');
                warningMessages.push('📊 ติดตามระดับ Creatinine อย่างใกล้ชิด');
                warningMessages.push('⚠️ พิจารณาเปลี่ยนเส้นทางการให้ยาหรือยาอื่นทดแทน');
                if (halfLifeHours && halfLifeHours > 0) {
                    const extendedFrequency = Math.max(1, Math.round(adjustedFrequency * renalFactor));
                    const intervalHours = Math.round(24 / extendedFrequency);

                    intervalExtensionSuggestion = {
                        method: 'interval_extension',
                        standardFrequency: adjustedFrequency,
                        extendedFrequency: extendedFrequency,
                        intervalHours: intervalHours,
                        description: `ทางเลือก: ให้ยาทุก ${intervalHours} ชั่วโมง แทน ${standardFrequency}`
                    };

                    warningMessages.push(
                        `💡 ทางเลือกสำหรับไตวายรุนแรง: ` +
                        `ให้ยาขนาดเต็มทุก ${intervalHours} ชั่วโมง (แทนการลดขนาด)`
                    );
                }

            } else if (crcl < crclThresholdModerate) {
                renalFactor = renalAdjustmentModerate || 0.5;
                renalSeverity = 'moderate';

                guidelineText = `ไตวายปานกลาง (CrCl ${crcl} mL/min): ลดขนาดยา ${Math.round((1 - renalFactor) * 100)}% (Dose Reduction)`;

                warningMessages.push('⚠️ ติดตามระดับ Creatinine เป็นประจำ');
                warningMessages.push('💧 ระวังภาวะคั่งของยาในร่างกาย');

                if (halfLifeHours && halfLifeHours > 0) {
                    const extendedFrequency = Math.max(1, Math.round(adjustedFrequency * renalFactor));
                    const intervalHours = Math.round(24 / extendedFrequency);

                    intervalExtensionSuggestion = {
                        method: 'interval_extension',
                        standardFrequency: adjustedFrequency,
                        extendedFrequency: extendedFrequency,
                        intervalHours: intervalHours,
                        description: `ทางเลือก: ให้ยาทุก ${intervalHours} ชั่วโมง`
                    };

                    warningMessages.push(
                        `💡 ทางเลือก: ให้ยาขนาดเต็มทุก ${intervalHours} ชั่วโมง (แทนการลดขนาด)`
                    );
                }

            } else if (crcl < crclThresholdMild) {
                renalFactor = renalAdjustmentMild || 0.75;
                renalSeverity = 'mild';

                guidelineText = `ไตเสื่อมเล็กน้อย (CrCl ${crcl} mL/min): ลดขนาดยา ${Math.round((1 - renalFactor) * 100)}% (Dose Reduction)`;

                warningMessages.push('📋 แนะนำติดตามการทำงานของไต');

            } else {
                renalSeverity = 'normal';
                guidelineText = `การทำงานของไตปกติ (CrCl ${crcl} mL/min) - ไม่ต้องปรับขนาดยา`;
            }

            console.log(`🔧 Renal Adjustment Applied:
            - CrCl: ${crcl} mL/min
            - Severity: ${renalSeverity}
            - Adjustment Method: Dose Reduction
            - Renal Factor: ${renalFactor}
            - Base Dose: ${baseDose.toFixed(2)} mg
            - Adjusted Dose: ${(baseDose * renalFactor).toFixed(2)} mg
            - Half-Life: ${halfLifeHours || 'N/A'} hours`);
      
                    if (intervalExtensionSuggestion) {
                        console.log(`💡 Alternative Interval Extension Suggested:
            - Standard: ${intervalExtensionSuggestion.standardFrequency}x/day (${standardFrequency})
            - Extended: ${intervalExtensionSuggestion.extendedFrequency}x/day (every ${intervalExtensionSuggestion.intervalHours}h)
            - Description: ${intervalExtensionSuggestion.description}`);
            }
        }

        // ========== Hepatic Adjustment ==========
        if (requiresHepaticAdjustment && eliminationRoute && 
            (eliminationRoute === 'Hepatic' || eliminationRoute === 'Both')) {

            let finalChildPughScore = childPughScore;

            if (!finalChildPughScore && childPughClass) {
                const classToScore = {
                    'A': 6,
                    'B': 8,
                    'C': 12
                };
                finalChildPughScore = classToScore[childPughClass];
                console.log(`🔄 Converted Child-Pugh Class ${childPughClass} to Score ${finalChildPughScore}`);
            }

            if (finalChildPughScore === null || finalChildPughScore === undefined) {
                return res.status(400).json({
                    success: false,
                    message: 'กรุณากรอกค่า Child-Pugh Class สำหรับยาที่เมแทบอไลซ์ที่ตับ'
                });
            }
          
            if (finalChildPughScore >= 10) {
                // Class C: Severe (10-15 points)
                hepaticFactor = childPughCFactor || 0.5;
                guidelineText = `ตับวายรุนแรง (Child-Pugh C, ${finalChildPughScore} คะแนน): ลดขนาดยา ${Math.round((1 - hepaticFactor) * 100)}%`;
                warningMessages.push('🚨 ตับวายรุนแรง - แนะนำหลีกเลี่ยงยาหรือปรึกษาแพทย์ผู้เชี่ยวชาญ');
                warningMessages.push('📊 ติดตามผลการทำงานของตับอย่างใกล้ชิด');
                warningMessages.push('⚠️ ระวังภาวะ Hepatic Encephalopathy');
                
            } else if (finalChildPughScore >= 7) {
                // Class B: Moderate (7-9 points)
                hepaticFactor = childPughBFactor || 0.75;
                guidelineText = `ตับวายปานกลาง (Child-Pugh B, ${finalChildPughScore} คะแนน): ลดขนาดยา ${Math.round((1 - hepaticFactor) * 100)}%`;
                warningMessages.push('⚠️ ติดตามผลการทำงานของตับเป็นประจำ');
                warningMessages.push('📋 ติดตามระดับ Albumin และ Bilirubin');
                
            } else {
                // Class A: Well-compensated (5-6 points)
                hepaticFactor = childPughAFactor || 1.0;
                guidelineText = `ตับทำงานปกติ (Child-Pugh A, ${finalChildPughScore} คะแนน)`;
                warningMessages.push('✅ การทำงานของตับยังเพียงพอ');
            }

            console.log(`🔧 Hepatic Adjustment: Base ${baseDose.toFixed(2)} mg × ${hepaticFactor} = ${(baseDose * hepaticFactor).toFixed(2)} mg`);
        }

        // ========== 7. FINAL DOSE CALCULATION ==========
        adjustedDose = baseDose * renalFactor * hepaticFactor;
        
        console.log(`📊 Final Dose Calculation:
        - Base Dose (after age adj): ${baseDose.toFixed(2)} mg/day
        - Age Factor: ${ageFactor}
        - Renal Factor: ${renalFactor}
        - Hepatic Factor: ${hepaticFactor}
        - Final Adjusted Dose: ${adjustedDose.toFixed(2)} mg/day`);

        // ========== 8. PEDIATRIC DAILY DOSE CHECK ==========
        if (age < 18 && pediatricMaxDailyDose) {
            const totalDailyDose = adjustedDose * adjustedFrequency;
            if (totalDailyDose > pediatricMaxDailyDose) {
                adjustedDose = pediatricMaxDailyDose / adjustedFrequency;
                warningMessages.push(`⚠️ จำกัดที่ขนาดสูงสุดต่อวันสำหรับเด็ก: ${pediatricMaxDailyDose} mg/day`);
                console.log(`⚠️ Daily dose capped at pediatric_max_daily_dose: ${pediatricMaxDailyDose} mg`);
            }
        }

        // ========== 9. SAFETY CHECKS (เหมือนเดิม) ==========
        let finalDosePerTime = adjustedDose / adjustedFrequency;

        if (maxDosePerUnit && finalDosePerTime > maxDosePerUnit) {
            finalDosePerTime = maxDosePerUnit;
            adjustedDose = finalDosePerTime * adjustedFrequency;
            warningMessages.push(`⚠️ ขนาดยาถูกจำกัดที่ ${maxDosePerUnit} mg ต่อครั้ง`);
        }

        if (maxDailyDose && adjustedDose > maxDailyDose) {
            adjustedDose = maxDailyDose;
            finalDosePerTime = adjustedDose / adjustedFrequency;
            warningMessages.push(`⚠️ ขนาดยารวมต่อวันถูกจำกัดที่ ${maxDailyDose} mg`);
        }

        // ========== 10. FINALIZE RESULTS ==========
        const recommendedMinDose = Math.round(finalDosePerTime);
        const recommendedMaxDose = Math.round(finalDosePerTime * 1.1);

        // ========== 11. RETURN RESPONSE ==========
        res.json({
            success: true,
            
            recommended_min_dose: recommendedMinDose,
            recommended_max_dose: recommendedMaxDose,
            recommended_frequency_text: adjustedFrequencyText,
            recommended_frequency_int: adjustedFrequency,
            
            guideline_text: guidelineText,
            warning_messages: warningMessages,
            unit: 'mg',
            
            interval_extension_suggestion: intervalExtensionSuggestion,
            base_dose_after_age_adj: parseFloat(baseDose.toFixed(2)),

            
            calculation_details: {
                base_dose: baseDose.toFixed(2),
                weight_used: weightUsed,
                dose_per_kg: standardDosePerKg,
                
                age_adjustment: {
                    age: age,
                    age_category: ageCategory,
                    age_factor: ageFactor,
                    requires_adjustment: requiresAgeAdjustment !== false
                },
                
                renal_adjustment: {
                    method: 'dose_reduction',
                    factor: renalFactor,
                    severity: renalSeverity,
                    crcl: crcl || null
                },
                hepatic_adjustment: {
                    factor: hepaticFactor,
                    child_pugh_class: childPughClass || null
                },
                adjustment_applied: adjustedDose !== baseDose,
                half_life_hours: halfLifeHours || null
            }
        });
    } catch (error) {
        console.error('❌ Error in /api/calculate-dosage-advanced:', error);
        res.status(500).json({
            success: false,
            message: 'เกิดข้อผิดพลาดในการคำนวณขนาดยา',
            error: error.message
        });
    }
});
// ***************************************************************
// CALCULATIONS ENDPOINT - POST /api/calculations
// ***************************************************************

app.post('/api/calculations', requireAuth, async (req, res) => {
    let connection;
    try {
        const userID = req.user.UserID;

        const {
            patientId, drugId,
            patientName, patientAge, patientWeight, patientDisease,
            medicineName, medicineType,
            recommendedMinDose, recommendedFrequencyInt,
            actualDosage, actualFrequencyInt,
            isOverride, overrideReason,
            overrideDoctorName,
            
            baseDose,
            ageCategory,
            ageAdjustmentFactor
        } = req.body;

        if (!patientName || !medicineName || !actualDosage || actualFrequencyInt === undefined) {
            return res.status(400).json({
                success: false,
                message: 'ข้อมูลไม่ครบถ้วน'
            });
        }

        connection = await connectToDb();
        const request = connection.request();

        const result = await request
            .input('doctor_id', sql.Int, userID)
            .input('patient_name', sql.NVarChar(255), patientName)
            .input('patient_age', sql.Int, cleanDataForSQL(patientAge))
            .input('patient_age_category', sql.VarChar(20), cleanDataForSQL(ageCategory))  // 🆕
            .input('patient_weight', sql.Decimal(5, 2), cleanDataForSQL(patientWeight))
            .input('patient_disease', sql.NVarChar(500), cleanDataForSQL(patientDisease))
            
            .input('medicine_name', sql.NVarChar(255), medicineName)
            .input('medicine_type', sql.NVarChar(255), cleanDataForSQL(medicineType))
            
            .input('base_dose', sql.Decimal(10, 2), cleanDataForSQL(baseDose))  // 🆕
            .input('age_adjustment_factor', sql.Decimal(5, 2), cleanDataForSQL(ageAdjustmentFactor))  // 🆕
            .input('dosage_per_time', sql.Decimal(10, 2), actualDosage)
            .input('frequency', sql.Int, actualFrequencyInt)
            .input('total_daily_dose', sql.Decimal(10, 2), actualDosage * actualFrequencyInt)
            
            .input('recommended_min_dose', sql.Decimal(10, 2), cleanDataForSQL(recommendedMinDose))
            .input('recommended_frequency', sql.Int, cleanDataForSQL(recommendedFrequencyInt))
            
            .input('is_override', sql.Bit, isOverride ? 1 : 0)
            .input('override_reason', sql.NVarChar(sql.MAX), cleanDataForSQL(overrideReason))
            .input('override_doctor_name', sql.NVarChar(255), cleanDataForSQL(overrideDoctorName))
            .query(`
                INSERT INTO calculations (
                    doctor_id,
                    patient_name, patient_age, patient_age_category, patient_weight, patient_disease,
                    medicine_name, medicine_type,
                    base_dose, age_adjustment_factor,
                    dosage_per_time, frequency, total_daily_dose,
                    recommended_min_dose, recommended_frequency,
                    is_override, override_reason, override_doctor_name,
                    calculated_at
                )
                VALUES (
                    @doctor_id,
                    @patient_name, @patient_age, @patient_age_category, @patient_weight, @patient_disease,
                    @medicine_name, @medicine_type,
                    @base_dose, @age_adjustment_factor,
                    @dosage_per_time, @frequency, @total_daily_dose,
                    @recommended_min_dose, @recommended_frequency,
                    @is_override, @override_reason, @override_doctor_name,
                    GETDATE()
                )
            `);

        console.log(`✅ บันทึกการคำนวณสำเร็จ สำหรับ ${patientName} (${ageCategory})`);

        res.status(201).json({
            success: true,
            message: 'บันทึกการคำนวณแล้ว',
        });

    } catch (error) {
        console.error('❌ Error in POST /api/calculations:', error);
        res.status(500).json({
            success: false,
            message: 'เกิดข้อผิดพลาดในการบันทึกการคำนวน',
            error: error.message
        });
    }
});
// ***************************************************************
// GET /api/calculations/latest - Fetch Latest Calculation for User
// ***************************************************************
app.get('/api/calculations/latest', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        const connection = await connectToDb();
        
        const result = await connection.request()
            .input('UserID', sql.Int, userID)
            .query(`
                SELECT TOP 1
                    id,
                    doctor_id,
                    patient_name,
                    patient_age,
                    patient_weight,
                    patient_disease,
                    medicine_name,
                    medicine_type,
                    dosage_per_time,
                    frequency,
                    total_daily_dose,
                    recommended_min_dose,
                    recommended_frequency,
                    is_override,
                    override_reason,
                    override_doctor_name,
                    calculated_at
                FROM calculations
                WHERE doctor_id = @UserID
                ORDER BY calculated_at DESC
            `);
        
        if (result.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'ไม่พบข้อมูลการคำนวณ'
            });
        }
        
        res.json({
            success: true,
            calculation: result.recordset[0]
        });
        
    } catch (error) {
        console.error('❌ Error fetching latest calculation:', error);
        res.status(500).json({
            success: false,
            message: 'ไม่สามารถดึงข้อมูลการคำนวณได้',
            error: error.message
        });
    }
});

// ***************************************************************
// GET /api/medicines/caution - Fetch Medicine Caution/Warning
// ***************************************************************
app.get('/api/medicines/caution', async (req, res) => {
    try {
        const { name } = req.query;
        
        console.log('🔍 Searching medicine caution for:', name);
        
        if (!name || name.trim() === '') {
            return res.json({
                success: false,
                caution: 'ไม่มีข้อมูลเตือน'
            });
        }
        
        const connection = await connectToDb();
        
        // ใช้ LIKE สำหรับค้นหาแบบ partial match
        const result = await connection.request()
            .input('medicineName', sql.NVarChar, `%${name.trim()}%`)
            .query(`
                SELECT TOP 1
                    generic_name,
                    caution,
                    [condition]
                FROM drugs
                WHERE generic_name LIKE @medicineName
                   OR type LIKE @medicineName
            `);
        
        console.log('📊 Query result:', result.recordset);
        
        if (result.recordset.length === 0) {
            console.log('⚠️ No medicine found for:', name);
            return res.json({
                success: false,
                caution: 'ไม่มีข้อมูลเตือน'
            });
        }
        
        const medicine = result.recordset[0];
        
        // รวม caution และ condition ถ้ามี
        let cautionText = '';
        if (medicine.caution) {
            cautionText = medicine.caution;
        }
        if (medicine.condition && medicine.condition !== medicine.caution) {
            cautionText += (cautionText ? ' | ' : '') + medicine.condition;
        }
        
        if (!cautionText) {
            cautionText = 'ไม่มีข้อมูลเตือน';
        }
        
        console.log('✅ Found caution:', cautionText);
        
        res.json({
            success: true,
            caution: cautionText,
            indication: medicine.condition || '',
            medicineName: medicine.generic_name
        });
        
    } catch (error) {
        console.error('❌ Error fetching medicine caution:', error);
        console.error('Error details:', error.message);
        console.error('Stack trace:', error.stack);
        
        res.status(500).json({
            success: false,
            caution: 'ไม่มีข้อมูลเตือน',
            error: error.message
        });
    }
});
// ***************************************************************
// USER MEDICINE FACTORS ENDPOINTS
// ***************************************************************

app.get('/api/user-medicine-factors/all', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        const connection = await connectToDb();
        
        const result = await connection.request()
            .input('UserID', sql.Int, userID)
            .query(`
                SELECT 
                    umf.drug_id,
                    umf.medicine_name,
                    umf.medicine_type,
                    umf.standard_dose_per_kg,
                    umf.standard_dose_per_m2,
                    umf.elimination_route,
                    umf.half_life_hours,
                    umf.standard_frequency,
                    umf.standard_frequency_int,
                    umf.max_dose_per_unit,
                    umf.max_daily_dose,
                    umf.requires_renal_adjustment,
                    umf.crcl_threshold_mild,
                    umf.crcl_threshold_moderate,
                    umf.crcl_threshold_severe,
                    umf.renal_adjustment_mild,
                    umf.renal_adjustment_moderate,
                    umf.renal_adjustment_severe,
                    umf.requires_hepatic_adjustment,
                    umf.child_pugh_a_factor,
                    umf.child_pugh_b_factor,
                    umf.child_pugh_c_factor,
                    umf.notes,
                    d.dosage,
                    d.condition as indication,
                    d.caution as warning
                FROM user_medicine_factors umf
                LEFT JOIN drugs d ON umf.drug_id = d.drug_id
                WHERE umf.user_id = @UserID
                ORDER BY umf.medicine_name
            `);
        
        res.json({
            success: true,
            medicines: result.recordset
        });
        
        console.log(`✅ Retrieved ${result.recordset.length} configured medicines for user ${userID}`);
        
    } catch (error) {
        console.error('❌ Error fetching user medicine factors:', error);
        res.status(500).json({
            success: false,
            message: 'ไม่สามารถโหลดข้อมูลยาที่กรอกปัจจัยได้',
            error: error.message
        });
    }
});

// GET /api/user-medicine-factors/:drugId - Get specific medicine factors
app.get('/api/user-medicine-factors/:drugId', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        const { drugId } = req.params;
        const connection = await connectToDb();
        
        const result = await connection.request()
            .input('UserID', sql.Int, userID)
            .input('DrugID', sql.Int, drugId)
            .query(`
                SELECT 
                    factor_id,
                    user_id,
                    drug_id,          -- ✅ Make sure this is included
                    medicine_name,
                    medicine_type,
                    standard_dose_per_kg,
                    standard_dose_per_m2,
                    elimination_route,
                    half_life_hours,
                    standard_frequency,
                    standard_frequency_int,
                    max_dose_per_unit,
                    max_daily_dose,
                    requires_renal_adjustment,
                    crcl_threshold_mild,
                    crcl_threshold_moderate,
                    crcl_threshold_severe,
                    renal_adjustment_mild,
                    renal_adjustment_moderate,
                    renal_adjustment_severe,
                    requires_hepatic_adjustment,
                    child_pugh_a_factor,
                    child_pugh_b_factor,
                    child_pugh_c_factor,
                    notes
                FROM user_medicine_factors
                WHERE user_id = @UserID AND drug_id = @DrugID
            `);
        
        if (result.recordset.length === 0) {
            return res.json({
                success: false,
                message: 'ไม่พบข้อมูลปัจจัยสำหรับยานี้'
            });
        }
        
        res.json({
            success: true,
            medicine: result.recordset[0]
        });
        
    } catch (error) {
        console.error('❌ Error fetching medicine factors:', error);
        res.status(500).json({
            success: false,
            message: 'ไม่สามารถโหลดข้อมูลปัจจัยยาได้',
            error: error.message
        });
    }
});

// POST /api/user-medicine-factors - Save or update medicine factors
app.post('/api/user-medicine-factors', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        const {
            drugId,
            standardDosePerKg,
            standardDosePerM2,
            eliminationRoute,
            halfLifeHours,
            standardFrequency,
            standardFrequencyInt,
            maxDosePerUnit,
            maxDailyDose,
            requiresRenalAdjustment,
            crclThresholdMild,
            crclThresholdModerate,
            crclThresholdSevere,
            renalAdjustmentMild,
            renalAdjustmentModerate,
            renalAdjustmentSevere,
            requiresHepaticAdjustment,
            childPughAFactor,
            childPughBFactor,
            childPughCFactor,
            notes
        } = req.body;
        
        // Validation
        if (!drugId || !standardDosePerKg || !eliminationRoute || !standardFrequency || !standardFrequencyInt || !maxDosePerUnit || !maxDailyDose) {
            return res.status(400).json({
                success: false,
                message: 'ข้อมูลไม่ครบถ้วน กรุณากรอกข้อมูลที่จำเป็นทั้งหมด'
            });
        }
        
        const connection = await connectToDb();
        
        // Get medicine name from drugs table
        const drugResult = await connection.request()
            .input('DrugID', sql.Int, drugId)
            .query('SELECT generic_name, type FROM drugs WHERE drug_id = @DrugID');
        
        if (drugResult.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'ไม่พบข้อมูลยาในระบบ'
            });
        }
        
        const medicine = drugResult.recordset[0];
        
        // Check if factors already exist (for update)
        const existingResult = await connection.request()
            .input('UserID', sql.Int, userID)
            .input('DrugID', sql.Int, drugId)
            .query('SELECT factor_id FROM user_medicine_factors WHERE user_id = @UserID AND drug_id = @DrugID');
        
        if (existingResult.recordset.length > 0) {
            // UPDATE existing record
            await connection.request()
                .input('UserID', sql.Int, userID)
                .input('DrugID', sql.Int, drugId)
                .input('MedicineName', sql.NVarChar(500), medicine.generic_name)
                .input('MedicineType', sql.NVarChar(255), medicine.type || '')
                .input('StandardDosePerKg', sql.Decimal(10, 2), standardDosePerKg)
                .input('StandardDosePerM2', sql.Decimal(10, 2), cleanDataForSQL(standardDosePerM2))
                .input('EliminationRoute', sql.NVarChar(50), eliminationRoute)
                .input('HalfLifeHours', sql.Decimal(10, 2), cleanDataForSQL(halfLifeHours))
                .input('StandardFrequency', sql.NVarChar(20), standardFrequency)
                .input('StandardFrequencyInt', sql.Int, standardFrequencyInt)
                .input('MaxDosePerUnit', sql.Decimal(10, 2), maxDosePerUnit)
                .input('MaxDailyDose', sql.Decimal(10, 2), maxDailyDose)
                .input('RequiresRenalAdjustment', sql.Bit, requiresRenalAdjustment ? 1 : 0)
                .input('CrclThresholdMild', sql.Decimal(10, 2), cleanDataForSQL(crclThresholdMild))
                .input('CrclThresholdModerate', sql.Decimal(10, 2), cleanDataForSQL(crclThresholdModerate))
                .input('CrclThresholdSevere', sql.Decimal(10, 2), cleanDataForSQL(crclThresholdSevere))
                .input('RenalAdjustmentMild', sql.Decimal(5, 2), cleanDataForSQL(renalAdjustmentMild))
                .input('RenalAdjustmentModerate', sql.Decimal(5, 2), cleanDataForSQL(renalAdjustmentModerate))
                .input('RenalAdjustmentSevere', sql.Decimal(5, 2), cleanDataForSQL(renalAdjustmentSevere))
                .input('RequiresHepaticAdjustment', sql.Bit, requiresHepaticAdjustment ? 1 : 0)
                .input('ChildPughAFactor', sql.Decimal(5, 2), cleanDataForSQL(childPughAFactor))
                .input('ChildPughBFactor', sql.Decimal(5, 2), cleanDataForSQL(childPughBFactor))
                .input('ChildPughCFactor', sql.Decimal(5, 2), cleanDataForSQL(childPughCFactor))
                .input('Notes', sql.NVarChar(sql.MAX), cleanDataForSQL(notes))
                .query(`
                    UPDATE user_medicine_factors
                    SET 
                        medicine_name = @MedicineName,
                        medicine_type = @MedicineType,
                        standard_dose_per_kg = @StandardDosePerKg,
                        standard_dose_per_m2 = @StandardDosePerM2,
                        elimination_route = @EliminationRoute,
                        half_life_hours = @HalfLifeHours,
                        standard_frequency = @StandardFrequency,
                        standard_frequency_int = @StandardFrequencyInt,
                        max_dose_per_unit = @MaxDosePerUnit,
                        max_daily_dose = @MaxDailyDose,
                        requires_renal_adjustment = @RequiresRenalAdjustment,
                        crcl_threshold_mild = @CrclThresholdMild,
                        crcl_threshold_moderate = @CrclThresholdModerate,
                        crcl_threshold_severe = @CrclThresholdSevere,
                        renal_adjustment_mild = @RenalAdjustmentMild,
                        renal_adjustment_moderate = @RenalAdjustmentModerate,
                        renal_adjustment_severe = @RenalAdjustmentSevere,
                        requires_hepatic_adjustment = @RequiresHepaticAdjustment,
                        child_pugh_a_factor = @ChildPughAFactor,
                        child_pugh_b_factor = @ChildPughBFactor,
                        child_pugh_c_factor = @ChildPughCFactor,
                        notes = @Notes,
                        updated_date = GETDATE()
                    WHERE user_id = @UserID AND drug_id = @DrugID
                `);
            
            console.log(`✅ Updated medicine factors for drug_id ${drugId}, user ${userID}`);
        } else {
            // INSERT new record
            await connection.request()
                .input('UserID', sql.Int, userID)
                .input('DrugID', sql.Int, drugId)
                .input('MedicineName', sql.NVarChar(500), medicine.generic_name)
                .input('MedicineType', sql.NVarChar(255), medicine.type || '')
                .input('StandardDosePerKg', sql.Decimal(10, 2), standardDosePerKg)
                .input('StandardDosePerM2', sql.Decimal(10, 2), cleanDataForSQL(standardDosePerM2))
                .input('EliminationRoute', sql.NVarChar(50), eliminationRoute)
                .input('HalfLifeHours', sql.Decimal(10, 2), cleanDataForSQL(halfLifeHours))
                .input('StandardFrequency', sql.NVarChar(20), standardFrequency)
                .input('StandardFrequencyInt', sql.Int, standardFrequencyInt)
                .input('MaxDosePerUnit', sql.Decimal(10, 2), maxDosePerUnit)
                .input('MaxDailyDose', sql.Decimal(10, 2), maxDailyDose)
                .input('RequiresRenalAdjustment', sql.Bit, requiresRenalAdjustment ? 1 : 0)
                .input('CrclThresholdMild', sql.Decimal(10, 2), cleanDataForSQL(crclThresholdMild))
                .input('CrclThresholdModerate', sql.Decimal(10, 2), cleanDataForSQL(crclThresholdModerate))
                .input('CrclThresholdSevere', sql.Decimal(10, 2), cleanDataForSQL(crclThresholdSevere))
                .input('RenalAdjustmentMild', sql.Decimal(5, 2), cleanDataForSQL(renalAdjustmentMild))
                .input('RenalAdjustmentModerate', sql.Decimal(5, 2), cleanDataForSQL(renalAdjustmentModerate))
                .input('RenalAdjustmentSevere', sql.Decimal(5, 2), cleanDataForSQL(renalAdjustmentSevere))
                .input('RequiresHepaticAdjustment', sql.Bit, requiresHepaticAdjustment ? 1 : 0)
                .input('ChildPughAFactor', sql.Decimal(5, 2), cleanDataForSQL(childPughAFactor))
                .input('ChildPughBFactor', sql.Decimal(5, 2), cleanDataForSQL(childPughBFactor))
                .input('ChildPughCFactor', sql.Decimal(5, 2), cleanDataForSQL(childPughCFactor))
                .input('Notes', sql.NVarChar(sql.MAX), cleanDataForSQL(notes))
                .query(`
                    INSERT INTO user_medicine_factors (
                        user_id, drug_id, medicine_name, medicine_type,
                        standard_dose_per_kg, standard_dose_per_m2, elimination_route, half_life_hours,
                        standard_frequency, standard_frequency_int, max_dose_per_unit, max_daily_dose,
                        requires_renal_adjustment, crcl_threshold_mild, crcl_threshold_moderate, crcl_threshold_severe,
                        renal_adjustment_mild, renal_adjustment_moderate, renal_adjustment_severe,
                        requires_hepatic_adjustment, child_pugh_a_factor, child_pugh_b_factor, child_pugh_c_factor,
                        notes, created_date, updated_date
                    ) VALUES (
                        @UserID, @DrugID, @MedicineName, @MedicineType,
                        @StandardDosePerKg, @StandardDosePerM2, @EliminationRoute, @HalfLifeHours,
                        @StandardFrequency, @StandardFrequencyInt, @MaxDosePerUnit, @MaxDailyDose,
                        @RequiresRenalAdjustment, @CrclThresholdMild, @CrclThresholdModerate, @CrclThresholdSevere,
                        @RenalAdjustmentMild, @RenalAdjustmentModerate, @RenalAdjustmentSevere,
                        @RequiresHepaticAdjustment, @ChildPughAFactor, @ChildPughBFactor, @ChildPughCFactor,
                        @Notes, GETDATE(), GETDATE()
                    )
                `);
            
            console.log(`✅ Created new medicine factors for drug_id ${drugId}, user ${userID}`);
        }
        
        res.json({
            success: true,
            message: 'บันทึกปัจจัยการคำนวณยาสำเร็จ'
        });
        
    } catch (error) {
        console.error('❌ Error saving medicine factors:', error);
        res.status(500).json({
            success: false,
            message: 'ไม่สามารถบันทึกข้อมูลได้',
            error: error.message
        });
    }
});
// ***************************************************************
// 8. FILE ROUTES: Hospital / License - ✅ FIXED: ลบ requireAuth
// ***************************************************************

// GET /api/hospitals - ดึงข้อมูลโรงพยาบาลจากฐานข้อมูล
// ✅ CRITICAL FIX: ลบ requireAuth middleware ออก เพราะใช้ตอนลงทะเบียน (ยังไม่มี Token)
app.get('/api/hospitals', async (req, res) => {
    try {
        console.log('📡 [API] GET /api/hospitals - Request received');
        
        const connection = await connectToDb();
        const result = await connection.request()
            .query(`
                SELECT 
                    hospital_id,
                    hospital_name as name,
                    province,
                    type
                FROM hospital 
                ORDER BY hospital_name
            `);

        console.log(`✅ [API] Found ${result.recordset.length} hospitals`);
        
        res.json({ 
            success: true, 
            hospitals: result.recordset 
        });
        
    } catch (error) {
        console.error('❌ [API] Error loading hospitals from DB:', error);
        res.status(500).json({ 
            success: false, 
            error: 'ไม่สามารถดึงข้อมูลโรงพยาบาลได้',
            hospitals: [] 
        });
    }
});

// GET /api/licenses - ดึงข้อมูลเลขใบอนุญาต
// ✅ CRITICAL FIX: ลบ requireAuth middleware ออก เพราะใช้ตอนลงทะเบียน (ยังไม่มี Token)
app.get('/api/licenses', async (req, res) => {
    try {
        console.log('📡 [API] GET /api/licenses - Request received');
        
        const connection = await connectToDb();
        const result = await connection.request()
            .query(`
                SELECT 
                    licenseNumber,
                    status,
                    issueDate
                FROM licenses 
                WHERE status = 'active'
                ORDER BY licenseNumber
            `);

        const licenses = result.recordset.map(item => ({
            licenseNumber: item.licenseNumber,
            status: item.status,
            issueDate: item.issueDate
        }));

        console.log(`✅ [API] Found ${licenses.length} active licenses`);

        res.json({ 
            success: true, 
            licenses: licenses 
        });
        
    } catch (error) {
        console.error('❌ [API] Error loading licenses from DB:', error);
        res.status(500).json({ 
            success: false, 
            error: 'ไม่สามารถดึงข้อมูลใบอนุญาตได้',
            licenses: [] 
        });
    }
});

// ***************************************************************
// GET /api/history - ดึงประวัติการคำนวณทั้งหมดของผู้ใช้
// ***************************************************************
app.get('/api/history', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        const connection = await connectToDb();
        
        const result = await connection.request()
            .input('UserID', sql.Int, userID)
            .query(`
                SELECT 
                    id,
                    doctor_id,
                    patient_name,
                    patient_age,
                    patient_weight,
                    patient_disease,
                    medicine_name,
                    medicine_type,
                    dosage_per_time,
                    frequency,
                    total_daily_dose,
                    recommended_min_dose,
                    recommended_max_dose,
                    recommended_frequency,
                    is_override,
                    override_reason,
                    override_doctor_name,
                    calculated_at
                FROM calculations
                WHERE doctor_id = @UserID
                ORDER BY calculated_at DESC
            `);
        
        res.json({
            success: true,
            history: result.recordset
        });
        
        console.log(`✅ โหลดประวัติการคำนวณ: ${result.recordset.length} รายการ`);
        
    } catch (error) {
        console.error('❌ Error fetching calculation history:', error);
        res.status(500).json({
            success: false,
            error: 'ไม่สามารถดึงประวัติการคำนวณได้',
            message: error.message
        });
    }
});

// ***************************************************************
// ⭐ DELETE /api/history/all - ต้องอยู่ก่อน route :id
// ***************************************************************
app.delete('/api/history/all', requireAuth, async (req, res) => {
    try {
        const userID = req.user.UserID;
        console.log(`🗑️ Deleting ALL history for user: ${userID}`);
        
        const connection = await connectToDb();
        
        const result = await connection.request()
            .input('UserID', sql.Int, userID)
            .query(`
                DELETE FROM calculations 
                WHERE doctor_id = @UserID
            `);
        
        console.log(`✅ ลบประวัติทั้งหมด: ${result.rowsAffected[0]} รายการ`);
        
        res.json({
            success: true,
            message: 'ลบประวัติทั้งหมดสำเร็จ',
            deletedCount: result.rowsAffected[0]
        });
        
    } catch (error) {
        console.error('❌ Error deleting all history:', error);
        res.status(500).json({
            success: false,
            error: 'ไม่สามารถลบประวัติทั้งหมดได้',
            message: error.message
        });
    }
});

// ***************************************************************
// DELETE /api/history/:id - ลบประวัติรายการเดียว (ต้องอยู่หลัง /all)
// ***************************************************************
app.delete('/api/history/:id', requireAuth, async (req, res) => {
    try {
        const { id } = req.params;
        const userID = req.user.UserID;

        console.log(`🗑️ Deleting single record - ID: ${id}, User: ${userID}`);

        const connection = await connectToDb();
        
        const result = await connection.request()
            .input('RecordID', sql.Int, id)
            .input('UserID', sql.Int, userID)
            .query(`
                DELETE FROM calculations 
                WHERE id = @RecordID AND doctor_id = @UserID
            `);

        console.log(`Delete result - Rows affected: ${result.rowsAffected[0]}`);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'ไม่พบประวัติ หรือไม่ได้รับอนุญาตให้ลบ' 
            });
        }

        res.json({ success: true, message: 'ลบประวัติสำเร็จ' });

    } catch (error) {
        console.error('❌ Error deleting history record:', error);
        res.status(500).json({ 
            success: false,
            error: 'ไม่สามารถลบประวัติได้', 
            message: error.message
        });
    }
});

// ⭐ Route สำหรับหน้าแรก - redirect ไปที่ homepage.html
app.get('/', (req, res) => {
  res.redirect('/homepage.html');
});

// กรณีที่ไฟล์ไม่พบ ให้กลับไปหน้า homepage
app.use((req, res, next) => {
  if (!req.path.includes('.') && !req.path.startsWith('/api')) {
    res.redirect('/homepage.html');
  } else {
    next();
  }
});

// ***************************************************************
// 9. START SERVER
// ***************************************************************
app.listen(port, () => {
  connectToDb();
  console.log(`✅ Server running at http://localhost:${port}`);
});
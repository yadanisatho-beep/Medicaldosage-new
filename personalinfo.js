// ***************************************************************
// 1. User Management
// ***************************************************************

async function getCurrentUser() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        return null;
    }

    try {
        const response = await fetch(`${API_BASE}/api/user/profile`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            sessionStorage.removeItem('authToken');
            return null;
        }

        const data = await response.json();
        return data.user;
    } catch (error) {
        console.error('Error fetching user:', error);
        return null;
    }
}

function confirmLogout() {
    sessionStorage.removeItem('authToken');
    localStorage.removeItem('authToken');
    closeLogoutPopup();
    showResultPopup('ออกจากระบบ', 'ออกจากระบบเรียบร้อยแล้ว');
    setTimeout(() => {
        window.location.href = 'login.html';
    }, 1000);
}

// ***************************************************************
// 2. Load & Display User Data
// ***************************************************************

async function loadUserData() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        console.error('❌ ไม่พบ token');
        window.location.href = 'login.html';
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/user/personal-info`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            if (response.status === 401) {
                console.error('❌ Token หมดอายุ');
                sessionStorage.removeItem('authToken');
                localStorage.removeItem('authToken');
                window.location.href = 'login.html';
                return;
            }
            throw new Error('ไม่สามารถดึงข้อมูลได้');
        }

        const data = await response.json();
        
        if (data.success) {
            displayUserData(data.user);
            console.log('✅ โหลดข้อมูลผู้ใช้สำเร็จ');
        }
    } catch (error) {
        console.error('❌ Error loading user data:', error);
        showResultPopup('เกิดข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลได้');
    }
}

function displayUserData(user) {
    const profileName = document.getElementById('profileName');
    if (profileName) {
        profileName.textContent = `${user.FirstName || ''} ${user.LastName || ''}`.trim() || 'ไม่ระบุชื่อ';
    }

    const displayFirstName = document.getElementById('displayFirstName');
    if (displayFirstName) {
        displayFirstName.textContent = user.FirstName || '-';
    }

    const displayLastName = document.getElementById('displayLastName');
    if (displayLastName) {
        displayLastName.textContent = user.LastName || '-';
    }

    const displayEmail = document.getElementById('displayEmail');
    if (displayEmail) {
        displayEmail.textContent = user.Email || '-';
    }

    const displayHospital = document.getElementById('displayHospital');
    if (displayHospital) {
        displayHospital.textContent = user.Hospital || '-';
    }

    const displayLicense = document.getElementById('displayLicense');
    if (displayLicense) {
        displayLicense.textContent = user.LicenseNumber || 'ยังไม่ได้ลงทะเบียน';
    }
    const displayLastLogin = document.getElementById('displayLastLogin');
    if (displayLastLogin) {
        if (user.LastLogin) {
            const lastLoginDate = new Date(user.LastLogin);
            
            const thaiTime = lastLoginDate.toLocaleString('th-TH', {
                timeZone: 'Asia/Bangkok',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                weekday: 'long',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });

            displayLastLogin.innerHTML = `
                <div style="font-weight: 700; margin-bottom: 4px; font-size: 16px;">
                    ${thaiTime}
                </div>
            `;
        } else {
            displayLastLogin.innerHTML = `
                <div style="color: #95a5a6;">ยังไม่มีข้อมูล</div>
            `;
        }
    }
    updateVerificationStatus(user.LicenseNumber);

    // Set values for edit forms
    const editFirstName = document.getElementById('editFirstName');
    if (editFirstName) {
        editFirstName.value = user.FirstName || '';
    }

    const editLastName = document.getElementById('editLastName');
    if (editLastName) {
        editLastName.value = user.LastName || '';
    }

    const editEmail = document.getElementById('editEmail');
    if (editEmail) {
        editEmail.value = user.Email || '';
    }

    const editHospital = document.getElementById('editHospital');
    if (editHospital) {
        editHospital.value = user.Hospital || '';
    }
}
function updateVerificationStatus(licenseNumber) {
    const statusElement = document.getElementById('verificationStatus');
    const textElement = document.getElementById('verificationText');

    if (statusElement && textElement) {
        if (licenseNumber && licenseNumber !== '') {
            statusElement.className = 'verification-status verified';
            textElement.innerHTML = 'ยืนยันเลขใบประกอบวิชาชีพแล้ว';
        } else {
            statusElement.className = 'verification-status unverified';
            textElement.innerHTML = 'ยังไม่ได้ยืนยันเลขใบประกอบวิชาชีพ';
        }
    }
}

window.displayUserData = displayUserData;
// ***************************************************************
// 3. Edit Personal Info
// ***************************************************************

function editPersonalInfo() {
    const personalInfo = document.getElementById('personalInfo');
    const editForm = document.getElementById('editPersonalForm');
    const editBtn = document.getElementById('editPersonalBtn');

    if (personalInfo) personalInfo.style.display = 'none';
    if (editForm) editForm.classList.add('active');
    if (editBtn) editBtn.style.display = 'none';
}

function cancelEditPersonal() {
    const personalInfo = document.getElementById('personalInfo');
    const editForm = document.getElementById('editPersonalForm');
    const editBtn = document.getElementById('editPersonalBtn');

    if (personalInfo) personalInfo.style.display = 'block';
    if (editForm) editForm.classList.remove('active');
    if (editBtn) editBtn.style.display = 'inline-flex';
}

async function savePersonalInfo() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        showResultPopup('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อน');
        return;
    }

    const firstName = document.getElementById('editFirstName').value.trim();
    const lastName = document.getElementById('editLastName').value.trim();
    const email = document.getElementById('editEmail')?.value.trim() || '';  
    const hospital = document.getElementById('editHospital').value.trim();

    if (!firstName || !lastName) {
        showResultPopup('กรุณากรอกข้อมูล', 'กรุณากรอกชื่อและนามสกุล');
        return;
    }
    
    // ตรวจสอบ Email ว่าต้องไม่เป็นค่าว่าง
    if (!email) {
        showResultPopup('กรุณากรอกข้อมูล', 'กรุณากรอกอีเมล');
        return;
    }
    
    // ตรวจสอบรูปแบบ Email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        showResultPopup('รูปแบบไม่ถูกต้อง', 'กรุณากรอกอีเมลให้ถูกต้อง');
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/user/personal-info`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ firstName, lastName, email, hospital })
        });

        const data = await response.json();

        if (response.ok && data.success) {
            showResultPopup('สำเร็จ', 'บันทึกข้อมูลเรียบร้อย');
            cancelEditPersonal();
            setTimeout(() => {
                loadUserData();
            }, 1000);
        } else {
            let errorMessage = data.error || 'ไม่สามารถบันทึกข้อมูลได้';
            
            // จัดการ Error แบบละเอียด
            if (response.status === 409 && data.code === 'DUPLICATE_EMAIL') {
                errorMessage = 'อีเมลนี้ถูกใช้งานโดยผู้ใช้อื่นแล้ว';
            }
            
            showResultPopup('เกิดข้อผิดพลาด', errorMessage);
        }
    } catch (error) {
        console.error('❌ Save error:', error);
        showResultPopup('เกิดข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์');
    }
}

// ***************************************************************
// 4. Edit Security (Password & License)
// ***************************************************************

function editSecurity() {
    const securityInfo = document.getElementById('securityInfo');
    const editForm = document.getElementById('editSecurityForm');
    const editBtn = document.getElementById('editSecurityBtn');

    if (securityInfo) securityInfo.style.display = 'none';
    if (editForm) editForm.classList.add('active');
    if (editBtn) editBtn.style.display = 'none';
}

function cancelEditSecurity() {
    const securityInfo = document.getElementById('securityInfo');
    const editForm = document.getElementById('editSecurityForm');
    const editBtn = document.getElementById('editSecurityBtn');

    if (securityInfo) securityInfo.style.display = 'block';
    if (editForm) editForm.classList.remove('active');
    if (editBtn) editBtn.style.display = 'inline-flex';

    // Clear form
    const currentPassword = document.getElementById('currentPassword');
    const newPassword = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmPassword');
    const licenseNumber = document.getElementById('licenseNumber');

    if (currentPassword) currentPassword.value = '';
    if (newPassword) newPassword.value = '';
    if (confirmPassword) confirmPassword.value = '';
    if (licenseNumber) licenseNumber.value = '';
}

async function saveSecurity() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        showResultPopup('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อน');
        return;
    }

    const currentPassword = document.getElementById('currentPassword').value;
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const licenseNumber = document.getElementById('licenseNumber').value.trim();

    // ตรวจสอบรหัสผ่าน (ถ้ามีการเปลี่ยน)
    if (newPassword || confirmPassword || currentPassword) {
        if (!currentPassword) {
            showResultPopup('กรุณากรอกข้อมูล', 'กรุณากรอกรหัสผ่านปัจจุบัน');
            return;
        }

        if (!newPassword) {
            showResultPopup('กรุณากรอกข้อมูล', 'กรุณากรอกรหัสผ่านใหม่');
            return;
        }

        if (newPassword.length < 6) {
            showResultPopup('รหัสผ่านไม่ถูกต้อง', 'รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร');
            return;
        }

        if (newPassword !== confirmPassword) {
            showResultPopup('รหัสผ่านไม่ตรงกัน', 'รหัสผ่านใหม่และยืนยันรหัสผ่านไม่ตรงกัน');
            return;
        }
    }

    // ต้องมีการเปลี่ยนแปลงอย่างน้อย 1 อย่าง
    if (!newPassword && !licenseNumber) {
        showResultPopup('ไม่มีการเปลี่ยนแปลง', 'กรุณากรอกข้อมูลที่ต้องการเปลี่ยนแปลง');
        return;
    }

    try {
        const requestBody = {};
        if (newPassword) {
            requestBody.currentPassword = currentPassword;
            requestBody.newPassword = newPassword;
        }
        if (licenseNumber) {
            requestBody.licenseNumber = licenseNumber.toUpperCase();
        }

        const response = await fetch(`${API_BASE}/api/user/security`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestBody)
        });

        const data = await response.json();

        if (response.ok && data.success) {
            showResultPopup('สำเร็จ', 'บันทึกการเปลี่ยนแปลงเรียบร้อย');
            cancelEditSecurity();
            setTimeout(() => {
                loadUserData();
            }, 1000);
        } else {
            showResultPopup('เกิดข้อผิดพลาด', data.message || 'ไม่สามารถบันทึกข้อมูลได้');
        }
    } catch (error) {
        console.error('❌ Save security error:', error);
        showResultPopup('เกิดข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์');
    }
}

// ***************************************************************
// 5. Verify License
// ***************************************************************

async function verifyLicense() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        showResultPopup('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อน');
        return;
    }

    try {
        // ดึงข้อมูล user ปัจจุบันเพื่อเอาเลขใบอนุญาต
        const userResponse = await fetch(`${API_BASE}/api/user/personal-info`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        if (!userResponse.ok) {
            showResultPopup('เกิดข้อผิดพลาด', 'ไม่สามารถดึงข้อมูลผู้ใช้ได้');
            return;
        }

        const userData = await userResponse.json();
        const licenseNumber = userData.user.LicenseNumber;

        if (!licenseNumber) {
            showResultPopup('ไม่พบข้อมูล', 'คุณยังไม่ได้ลงทะเบียนเลขใบอนุญาต');
            return;
        }

        // ตรวจสอบใบอนุญาต
        const response = await fetch(`${API_BASE}/api/user/verify-license`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ licenseNumber })
        });

        const data = await response.json();

        if (response.ok && data.success) {
            showResultPopup('ตรวจสอบสำเร็จ', data.message);
        } else {
            showResultPopup('ตรวจสอบไม่ผ่าน', data.error || data.message || 'ไม่สามารถตรวจสอบได้');
        }
    } catch (error) {
        console.error('❌ Verify license error:', error);
        showResultPopup('เกิดข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์เพื่อตรวจสอบได้');
    }
}

// ***************************************************************
// 6. Popup Functions
// ***************************************************************

function showResultPopup(title, message) {
    const popup = document.getElementById('resultPopup');
    const icon = document.getElementById('resultIcon');
    const titleElement = document.getElementById('resultTitle');
    const msgElement = document.getElementById('resultMsg');

    if (titleElement) titleElement.textContent = title;
    if (msgElement) msgElement.textContent = message;

    // เปลี่ยนไอคอนตามประเภท
    if (icon) {
        if (title.includes('สำเร็จ') || title.includes('ตรวจสอบสำเร็จ')) {
            icon.className = 'popup-icon success';
            icon.innerHTML = '<i class="fas fa-check"></i>';
        } else {
            icon.className = 'popup-icon warning';
            icon.innerHTML = '<i class="fas fa-exclamation"></i>';
        }
    }

    if (popup) popup.classList.add('show');
}

function closeResultPopup() {
    const popup = document.getElementById('resultPopup');
    if (popup) popup.classList.remove('show');
}

function showLogoutPopup() {
    const popup = document.getElementById('logoutPopup');
    if (popup) popup.classList.add('show');
}

function closeLogoutPopup() {
    const popup = document.getElementById('logoutPopup');
    if (popup) popup.classList.remove('show');
}

// ***************************************************************
// 7. Setup Auth Section (Navigation)
// ***************************************************************

async function setupAuthSection() {
    const authSection = document.getElementById('authSection');
    const user = await getCurrentUser();

    if (authSection && user) {
        authSection.innerHTML = `
            <div class="user-menu">
                <button class="user-btn" onclick="document.querySelector('.user-dropdown').classList.toggle('show')">
                    <i class="fas fa-user-doctor"></i>
                    <span>${user.FirstName || user.Username || 'บัญชีของฉัน'}</span>
                    <i class="fas fa-chevron-down"></i>
                </button>
                <div class="user-dropdown">
                    <a href="personalinfo.html">
                        <i class="fas fa-user"></i> ข้อมูลส่วนตัว
                    </a>
                    <a href="javascript:void(0)" onclick="showLogoutPopup()">
                        <i class="fas fa-sign-out-alt"></i> ออกจากระบบ
                    </a>
                </div>
            </div>
        `;
    }
}

// ***************************************************************
// 8. Initialize
// ***************************************************************

window.addEventListener('DOMContentLoaded', () => {
    console.log('📄 Personal Info page loaded');
    loadUserData();
    setupAuthSection();

    // Close dropdown on outside click
    document.addEventListener('click', function(e) {
        const userMenu = document.querySelector('.user-menu');
        const dropdown = document.querySelector('.user-dropdown');
        if (dropdown && userMenu && !userMenu.contains(e.target)) {
            dropdown.classList.remove('show');
        }
    });
});

// Export functions
window.editPersonalInfo = editPersonalInfo;
window.cancelEditPersonal = cancelEditPersonal;
window.savePersonalInfo = savePersonalInfo;
window.editSecurity = editSecurity;
window.cancelEditSecurity = cancelEditSecurity;
window.saveSecurity = saveSecurity;
window.verifyLicense = verifyLicense;
window.closeResultPopup = closeResultPopup;
window.showLogoutPopup = showLogoutPopup;
window.closeLogoutPopup = closeLogoutPopup;
window.confirmLogout = confirmLogout
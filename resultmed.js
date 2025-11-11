// ***************************************************************
// 1. CLIENT-SIDE COMMON HELPERS
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
            localStorage.removeItem('authToken');
            return null;
        }

        const data = await response.json();
        data.user.token = token;
        return data.user;
    } catch (error) {
        console.error('Error fetching user:', error);
        return null;
    }
}

function handleAuthError() {
    sessionStorage.removeItem('authToken');
    localStorage.removeItem('authToken');
    if (typeof showResultPopup === 'function') {
        showResultPopup('Session หมดอายุ', 'กรุณาเข้าสู่ระบบใหม่');
        setTimeout(() => window.location.href = 'login.html', 1500);
    } else {
        window.location.href = 'login.html';
    }
}

function confirmLogout() {
    localStorage.removeItem('rememberMedicalUser');
    sessionStorage.removeItem('currentMedicalUser');
    localStorage.removeItem('authToken');
    sessionStorage.removeItem('authToken');
    
    if (typeof closeLogoutPopup === 'function') closeLogoutPopup();
    
    if (typeof showResultPopup === 'function') { 
        showResultPopup('ออกจากระบบ', 'ออกจากระบบเรียบร้อยแล้ว');
        setTimeout(() => {
             window.location.href = 'login.html';
        }, 1000);
    } else {
        window.location.href = 'login.html'; 
    }
}
window.confirmLogout = confirmLogout;

// ***************************************************************
// 2. UI Helpers
// ***************************************************************

function showResultPopup(title, msg) {
    const popup = document.getElementById('resultPopup');
    if (popup) {
        const titleEl = document.getElementById('resultTitle');
        const msgEl = document.getElementById('resultMsg');
        if (titleEl) titleEl.innerText = title;
        if (msgEl) msgEl.innerText = msg;
        popup.classList.add('show');
    }
}
window.showResultPopup = showResultPopup;

function closeResultPopup() {
    const popup = document.getElementById('resultPopup');
    if (popup) popup.classList.remove('show');
}
window.closeResultPopup = closeResultPopup;

function showLogoutPopup() {
    const popup = document.getElementById('logoutPopup');
    if (popup) popup.classList.add('show');
}
window.showLogoutPopup = showLogoutPopup;

function closeLogoutPopup() {
    const popup = document.getElementById('logoutPopup');
    if (popup) popup.classList.remove('show');
}
window.closeLogoutPopup = closeLogoutPopup;

// ***************************************************************
// 3. FETCH LATEST CALCULATION FROM DATABASE
// ***************************************************************

async function fetchLatestCalculation(userToken) {
    try {
        const response = await fetch(`${API_BASE}/api/calculations/latest`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${userToken}`,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            if (response.status === 401) handleAuthError();
            return null;
        }

        const data = await response.json();
        return data.success ? data.calculation : null;

    } catch (error) {
        console.error('Error fetching latest calculation:', error);
        return null;
    }
}

// ***************************************************************
// 4. FETCH MEDICINE CAUTION FROM DATABASE
// ***************************************************************

async function fetchMedicineCaution(medicineName, userToken) {
    try {
        console.log('🔍 Fetching caution for:', medicineName);
        
        const response = await fetch(`${API_BASE}/api/medicines/caution?name=${encodeURIComponent(medicineName)}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('❌ Response not OK:', response.status);
            return 'ไม่มีข้อมูลเตือน';
        }

        const data = await response.json();
        console.log('✅ Caution data:', data);
        
        return data.caution || 'ไม่มีข้อมูลเตือน';

    } catch (error) {
        console.error('❌ Error fetching medicine caution:', error);
        return 'ไม่มีข้อมูลเตือน';
    }
}

// ***************************************************************
// 5. Display Result Data from Database
// ***************************************************************

async function displayResultData() {
    const user = await getCurrentUser();
    
    if (!user) {
        showResultPopup('กรุณาเข้าสู่ระบบ', 'ไม่พบข้อมูลผู้ใช้');
        setTimeout(() => window.location.href = 'login.html', 1500);
        return;
    }

    // Fetch latest calculation from database
    const calculation = await fetchLatestCalculation(user.token);
    
    if (!calculation) {
        showResultPopup('ไม่พบข้อมูล', 'ไม่พบผลการคำนวณล่าสุด กรุณาทำการคำนวณใหม่');
        setTimeout(() => window.location.href = 'calculatemed.html', 1500);
        return;
    }

    try {
        // Helper function to safely set text content
        const safeSetText = (id, value) => {
            const element = document.getElementById(id);
            if (element) {
                element.textContent = value;
            } else {
                console.warn(`⚠️ Element with id "${id}" not found in HTML`);
            }
        };
        
        // Display Patient Information
        safeSetText('displayName', calculation.patient_name || 'N/A');
        safeSetText('displayAge', `${calculation.patient_age || '-'} ปี`);
        safeSetText('displayWeight', `${calculation.patient_weight || '-'} kg`);
        safeSetText('displayDisease', calculation.patient_disease || 'ไม่ระบุ');
        
        // Display Medicine Information
        safeSetText('displayMedicineName', calculation.medicine_name || 'N/A');
        safeSetText('displayMedicineType', calculation.medicine_type || '-');
        safeSetText('medicineFreq', `${calculation.frequency || '-'} ครั้ง/วัน`);
        safeSetText('medicineTabletSize', `${calculation.dosage_per_time || '-'} mg/dose`);
        
        // Display Dosage Information
        safeSetText('dosePerTime', calculation.dosage_per_time || '0.00');
        
        const dailyDose = (calculation.dosage_per_time || 0) * (calculation.frequency || 1);
        safeSetText('dailyDoses', dailyDose.toFixed(2));
        
        const monthlyDose = dailyDose * 30;
        safeSetText('totalMonthlyDose', monthlyDose.toFixed(2));
        
        // Fetch and Display Medicine Caution
        const medicineCaution = await fetchMedicineCaution(calculation.medicine_name, user.token);
        const warningSection = document.getElementById('warningSection');
        const warningContent = document.getElementById('warningContent');
        
        if (warningSection && warningContent) {
            if (medicineCaution && medicineCaution !== 'ไม่มีข้อมูลเตือน') {
                warningContent.innerHTML = `
                    <div class="warning-item">
                        <strong>ข้อควรระวัง:</strong> ${medicineCaution}
                    </div>
                    <div class="warning-item">
                         โปรแกรมนี้เป็นเครื่องมือช่วยคำนวณเพื่อสนับสนุนการตัดสินใจทางคลินิก ไม่สามารถใช้แทนการพิจารณาทางการแพทย์ได้ แพทย์ควรตรวจสอบความถูกต้องและความเหมาะสมก่อนสั่งใช้ยา
                    </div>
                `;
                warningSection.style.display = 'block';
            } else {
                warningContent.innerHTML = `
                    <div class="warning-item">
                         โปรแกรมนี้เป็นเครื่องมือช่วยคำนวณเพื่อสนับสนุนการตัดสินใจทางคลินิก ไม่สามารถใช้แทนการพิจารณาทางการแพทย์ได้ แพทย์ควรตรวจสอบความถูกต้องและความเหมาะสมก่อนสั่งใช้ยา
                    </div>
                `;
                warningSection.style.display = 'block';
            }
        }
        
        console.log('✅ แสดงผลการคำนวณสำเร็จ');
        
    } catch (error) {
        console.error('Error displaying result data:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลผลการคำนวณได้');
    }
}

// ***************************************************************
// 6. UI Update Function
// ***************************************************************

async function updateUIForLoggedInUser() {
    const user = await getCurrentUser();
    const authSection = document.getElementById('authSection');
    
    if (!authSection) return;

    if (user) {
        authSection.innerHTML = `
            <div class="user-menu">
              <button class="user-btn" onclick="toggleUserDropdown()">
                <i class="fas fa-user-doctor"></i>
                ${user.FirstName || user.Username}
                <i class="fas fa-chevron-down"></i>
              </button>
              <div class="user-dropdown" id="userDropdown">
                <a href="personalinfo.html">
                  <i class="fas fa-user"></i> ข้อมูลส่วนตัว
                </a>
                <div class="divider"></div>
                <a href="#" onclick="showLogoutPopup();return false;">
                  <i class="fas fa-sign-out-alt"></i> ออกจากระบบ
                </a>
              </div>
            </div>
        `;
    } else {
        authSection.innerHTML = '<a href="login.html" class="login-btn">เข้าสู่ระบบ</a>';
    }
}
window.updateUIForLoggedInUser = updateUIForLoggedInUser;

function toggleUserDropdown() {
    const dropdown = document.getElementById('userDropdown');
    if (dropdown) dropdown.classList.toggle('show');
}
window.toggleUserDropdown = toggleUserDropdown;

// ***************************************************************
// 7. Print Function
// ***************************************************************

function printResult() {
    window.print();
}
window.printResult = printResult;

// ***************************************************************
// 8. Initialization
// ***************************************************************

document.addEventListener('DOMContentLoaded', async function() {
    console.log('📄 Result page initialized');
    await updateUIForLoggedInUser();
    await displayResultData();
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        const userMenu = document.querySelector('.user-menu');
        const dropdown = document.getElementById('userDropdown');
        if (dropdown && userMenu && !userMenu.contains(e.target)) {
            dropdown.classList.remove('show');
        }
    });
});

// Export functions
window.getCurrentUser = getCurrentUser;
window.handleAuthError = handleAuthError;
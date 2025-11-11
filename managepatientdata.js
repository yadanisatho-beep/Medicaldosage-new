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
        document.getElementById('resultTitle').innerText = title;
        document.getElementById('resultMsg').innerText = msg;
        popup.classList.add('show');
    }
}
window.showResultPopup = showResultPopup;

function closeResultPopup() {
    const popup = document.getElementById('resultPopup');
    if (popup) popup.classList.remove('show');
}
window.closeResultPopup = closeResultPopup;

function showWarningPopup(title, msg) {
    const popup = document.getElementById('warningPopup');
    if (popup) {
        document.getElementById('warningTitle').innerText = title;
        document.getElementById('warningMsg').innerText = msg;
        popup.classList.add('show');
    }
}
window.showWarningPopup = showWarningPopup;

function closeWarningPopup() {
    const popup = document.getElementById('warningPopup');
    if (popup) popup.classList.remove('show');
}
window.closeWarningPopup = closeWarningPopup;

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
// 3. Display Result Data
// ***************************************************************

async function displayResultData() {
    const user = await getCurrentUser();
    
    if (!user) {
        showResultPopup('กรุณาเข้าสู่ระบบ', 'ไม่พบข้อมูลผู้ใช้');
        setTimeout(() => window.location.href = 'login.html', 1500);
        return;
    }
}

// ***************************************************************
// 2. State and Utility
// ***************************************************************
let allDiseases = [];
let selectedDiseaseCode = null;
let searchTimeout = null;

// Utility function to get URL parameter
function getUrlParameter(name) {
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    const regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
    const results = regex.exec(location.search);
    return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
}

// ***************************************************************
// 3. Disease Autocomplete Functions
// ***************************************************************

/**
 * โหลดข้อมูลโรคทั้งหมดจาก API
 */
async function loadAllDiseases() {
    try {
        const response = await fetch(`${API_BASE}/api/diseases`);
        const data = await response.json();
        
        if (data.success && data.diseases) {
            allDiseases = data.diseases;
            console.log(`✅ โหลดข้อมูลโรค: ${allDiseases.length} รายการ`);
        }
    } catch (error) {
        console.error('❌ Error loading diseases:', error);
    }
}

/**
 * ค้นหาโรคจาก API (แบบ real-time)
 */
async function searchDiseases(query) {
    const suggestionsContainer = document.getElementById('diseaseSuggestionsContainer');
    
    console.log('🔍 searchDiseases called with query:', query);
    
    if (!suggestionsContainer) {
        console.error('❌ ไม่พบ element: diseaseSuggestionsContainer');
        return;
    }

    suggestionsContainer.innerHTML = '';
    
    if (!query || query.trim().length < 2) {
        console.log('⚠️ Query too short, hiding suggestions');
        suggestionsContainer.style.display = 'none';
        return;
    }

    try {
        const url = `${API_BASE}/api/diseases/search?q=${encodeURIComponent(query)}`;
        console.log('📡 Fetching:', url);
        
        const response = await fetch(url);
        const data = await response.json();

        console.log('✅ Response:', data);

        if (data.success && data.diseases && data.diseases.length > 0) {
            console.log(`📋 Found ${data.diseases.length} diseases`);
            
            data.diseases.forEach(disease => {
                const item = document.createElement('div');
                item.className = 'suggestion-item';
                
                item.innerHTML = `
                    <div class="disease-info">
                        <div class="disease-title">${disease.Name}</div>
                        <div class="disease-meta">
                            <span class="disease-code">${disease.Code}</span>
                            ${disease.Category ? `<span class="disease-category">${disease.Category}</span>` : ''}
                        </div>
                    </div>
                `;
                
                item.onclick = () => selectDisease(disease);
                suggestionsContainer.appendChild(item);
            });
            
            suggestionsContainer.style.display = 'block';
            console.log('✅ Suggestions displayed');
        } else {
            console.log('⚠️ No diseases found');
            suggestionsContainer.innerHTML = '<div class="suggestion-item" style="color: #999;">ไม่พบข้อมูลโรค</div>';
            suggestionsContainer.style.display = 'block';
        }
        
    } catch (error) {
        console.error('❌ Error searching diseases:', error);
        suggestionsContainer.style.display = 'none';
    }
}

/**
 * เลือกโรคจาก autocomplete
 */
function selectDisease(disease) {
    const diseaseInput = document.getElementById('disease');
    const diseaseCodeInput = document.getElementById('diseaseCode');
    const suggestionsContainer = document.getElementById('diseaseSuggestionsContainer');
    
    if (diseaseInput) diseaseInput.value = disease.Name;
    if (diseaseCodeInput) diseaseCodeInput.value = disease.Code;
    
    selectedDiseaseCode = disease.Code;
    
    if (suggestionsContainer) {
        suggestionsContainer.style.display = 'none';
    }
    
    console.log('✅ เลือกโรค:', disease);
}

/**
 * ซ่อน suggestions
 */
function hideSuggestions() {
    const suggestionsContainer = document.getElementById('diseaseSuggestionsContainer');
    if (suggestionsContainer) {
        setTimeout(() => {
            suggestionsContainer.style.display = 'none';
        }, 200);
    }
}

// ***************************************************************
// 4. Patient CRUD Operations
// ***************************************************************

/**
 * บันทึกข้อมูลผู้ป่วย (เพิ่มใหม่/แก้ไข)
 */
async function savePatient(e) {
    e.preventDefault();
    
    const user = await getCurrentUser();
    if (!user || !user.token) {
        showResultPopup('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อนดำเนินการ');
        return;
    }

    const name = document.getElementById('name').value;
    const age = document.getElementById('age').value;
    const weight = document.getElementById('weight').value;
    const disease = document.getElementById('disease').value;
    const diseaseCode = document.getElementById('diseaseCode').value || selectedDiseaseCode;

    const data = {
        name: name,
        age: age,
        weight: weight,
        disease: disease,
        diseaseCode: diseaseCode
    };

    console.log('📋 Data to save:', data);
    
    if (!data.name || data.name.trim() === '') {
        showResultPopup('ข้อผิดพลาด', 'กรุณากรอกชื่อผู้ป่วย');
        return;
    }
    
    const form = document.getElementById('patientForm');
    const isEditMode = form.getAttribute('data-mode') === 'edit';
    const patientId = form.getAttribute('data-id');

    const method = isEditMode ? 'PUT' : 'POST';
    const url = isEditMode ? `${API_BASE}/api/patients/${patientId}` : `${API_BASE}/api/patients`;
    
    showWarningPopup('กำลังดำเนินการ', 'กำลังบันทึกข้อมูลผู้ป่วย...');

    try {
        const response = await fetch(url, {
            method: method,
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        if (response.status === 401) {
            handleAuthError();
            return;
        }
        
        const result = await response.json();
        closeWarningPopup();

        console.log('✅ Server response:', result);

        if (result.success) {
            showResultPopup('สำเร็จ', isEditMode ? 'แก้ไขข้อมูลผู้ป่วยสำเร็จ!' : 'บันทึกข้อมูลผู้ป่วยสำเร็จ!');
            setTimeout(() => {
                window.location.href = 'patientlist.html';
            }, 1000);
        } else {
            showResultPopup('ข้อผิดพลาด', result.error || 'ไม่สามารถบันทึกข้อมูลผู้ป่วยได้');
        }

    } catch (error) {
        closeWarningPopup();
        console.error('❌ Save Patient Error:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }
}

/**
 * โหลดข้อมูลผู้ป่วยสำหรับการแก้ไข
 */
async function loadPatientDataForEdit(patientId) {
    const user = await getCurrentUser();
    if (!user || !user.token) {
        showResultPopup('ข้อผิดพลาด', 'กรุณาเข้าสู่ระบบก่อนดำเนินการ');
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/patients/${patientId}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${user.token}`
            }
        });

        if (response.status === 401) {
            handleAuthError();
            return;
        }
        
        const data = await response.json();

        if (data.success && data.patient) {
            const patient = data.patient;
            
            const form = document.getElementById('patientForm');
            
            if (form) {
                form.setAttribute('data-mode', 'edit');
                form.setAttribute('data-id', patient.PatientID);
            }
            
            // Fill form fields
            document.getElementById('name').value = patient.PatientName || '';
            document.getElementById('age').value = patient.Age || '';
            document.getElementById('weight').value = patient.Weight || '';
            document.getElementById('disease').value = patient.Disease || '';
            document.getElementById('diseaseCode').value = patient.DiseaseCode || '';
            selectedDiseaseCode = patient.DiseaseCode;

        } else {
            showResultPopup('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ป่วยที่ต้องการแก้ไข');
            setTimeout(() => {
                window.location.href = 'patientlist.html';
            }, 1500);
        }
    } catch (error) {
        console.error('❌ Load Patient Error:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลผู้ป่วยได้');
    }
}

// ***************************************************************
// 5. UI Update Functions
// ***************************************************************

async function updateUIForLoggedInUser() {
    const user = await getCurrentUser();
    const authSection = document.getElementById('authSection');
    
    if (!authSection) {
        console.warn('⚠️ ไม่พบ element #authSection');
        return;
    }

    if (user) {
        console.log('✅ Displaying user menu for:', user.FirstName || user.Username);
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
        console.log('❌ No user logged in, showing login button');
        authSection.innerHTML = `
            <a href="login.html" class="login-btn">เข้าสู่ระบบ</a>
        `;
    }
}
window.updateUIForLoggedInUser = updateUIForLoggedInUser;

function toggleUserDropdown() {
    const dropdown = document.getElementById('userDropdown');
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}
window.toggleUserDropdown = toggleUserDropdown;

// ***************************************************************
// 6. Initialization
// ***************************************************************

document.addEventListener('DOMContentLoaded', async function() {
    console.log('🚀 Initializing managepatientdata.js');
    
    try {
        // Check if user is logged in first
        const user = await getCurrentUser();
        if (!user) {
            showResultPopup('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่');
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 1500);
            return;
        }
        
        // อัพเดต UI
        updateUIForLoggedInUser();
        
        // ตรวจสอบว่าเป็นโหมดแก้ไขหรือไม่
        const patientId = getUrlParameter('id');
        if (patientId) {
            await loadPatientDataForEdit(patientId);
        } else {
            const form = document.getElementById('patientForm');
            if (form) form.setAttribute('data-mode', 'add');
        }

        // โหลดข้อมูลโรค
        await loadAllDiseases();

        // ผูก Event Handlers
        const patientForm = document.getElementById('patientForm');
        if (patientForm) {
            patientForm.addEventListener('submit', savePatient);
        }
        
        // Autocomplete สำหรับโรค
        const diseaseInput = document.getElementById('disease');
        if (diseaseInput) {
            diseaseInput.addEventListener('input', (e) => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    searchDiseases(e.target.value);
                }, 300);
            });
            
            diseaseInput.addEventListener('blur', hideSuggestions);
        }
        
        // ปิด dropdown เมื่อคลิกข้างนอก
        document.addEventListener('click', (e) => {
            const userDropdown = document.getElementById('userDropdown');
            if (userDropdown && !e.target.closest('.user-menu')) {
                userDropdown.classList.remove('show');
            }
        });
        
        console.log('✅ Initialization complete');
    } catch (error) {
        console.error('❌ Error during initialization:', error);
        showResultPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการโหลดหน้า');
    }
});

// Export functions
window.savePatient = savePatient;
window.loadPatientDataForEdit = loadPatientDataForEdit;
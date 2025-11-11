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

function showWarningPopup(title, msg) {
    const popup = document.getElementById('warningPopup');
    if (popup) {
        const titleEl = document.getElementById('warningTitle');
        const msgEl = document.getElementById('warningMsg');
        if (titleEl) titleEl.innerText = title;
        if (msgEl) msgEl.innerText = msg;
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
// 3. State Variables
// ***************************************************************

let allPatients = [];
let patientIdToDelete = null; 
let allDiseases = [];
let selectedDiseaseCode = '';

// ***************************************************************
// 4. Disease Autocomplete Functions
// ***************************************************************

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
                
                item.onclick = () => selectDiseaseForEdit(disease);
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

function selectDiseaseForEdit(disease) {
    const diseaseInput = document.getElementById('editDisease');
    const diseaseCodeInput = document.getElementById('selectedDiseaseName');
    const suggestionsContainer = document.getElementById('diseaseSuggestionsContainer');
    
    if (diseaseInput) diseaseInput.value = disease.Name;
    if (diseaseCodeInput) diseaseCodeInput.value = disease.Code;
    
    selectedDiseaseCode = disease.Code;
    
    if (suggestionsContainer) {
        suggestionsContainer.style.display = 'none';
    }
    
    console.log('✅ เลือกโรค:', disease);
}

function hideDiseaseDropdown() {
    const suggestionsContainer = document.getElementById('diseaseSuggestionsContainer');
    if (suggestionsContainer) {
        setTimeout(() => {
            suggestionsContainer.style.display = 'none';
        }, 200);
    }
}
window.hideDiseaseDropdown = hideDiseaseDropdown;

// ***************************************************************
// 5. Patient Data Functions (API Calls)
// ***************************************************************

async function loadPatients() {
    const user = await getCurrentUser();
    if (!user || !user.token) {
        return; 
    }

    try {
        const response = await fetch(`${API_BASE}/api/patients`, {
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
        
        if (data.success && data.patients) {
            allPatients = data.patients;
            renderPatientList(allPatients);
            console.log(`✅ โหลดข้อมูลผู้ป่วย: ${allPatients.length} รายการ`);
        } else {
            allPatients = [];
            renderPatientList(allPatients);
            console.log('⚠️ ไม่พบข้อมูลผู้ป่วย');
        }
    } catch (error) {
        console.error('❌ Error loading patients:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลผู้ป่วยได้');
    }
}
window.loadPatients = loadPatients;

async function loadPatientForEdit(patientId) {
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
            const modal = document.getElementById('editModal');
            
            if (modal) {
                modal.dataset.patientId = patient.PatientID;
                modal.style.display = 'flex';
            }
            
            document.getElementById('editName').value = patient.PatientName || '';
            document.getElementById('editAge').value = patient.Age || '';
            document.getElementById('editWeight').value = patient.Weight || '';
            document.getElementById('editDisease').value = patient.Disease || '';
            document.getElementById('selectedDiseaseName').value = patient.DiseaseCode || '';
            selectedDiseaseCode = patient.DiseaseCode;

            console.log('✅ โหลดข้อมูลผู้ป่วยสำหรับแก้ไข:', patient);

        } else {
            showResultPopup('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ป่วยที่ต้องการแก้ไข');
        }
    } catch (error) {
        console.error('❌ Load Patient Error:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลผู้ป่วยได้');
    }
}
window.loadPatientForEdit = loadPatientForEdit;

async function saveEdit() {
    const user = await getCurrentUser();
    if (!user || !user.token) {
        handleAuthError();
        return;
    }

    const modal = document.getElementById('editModal');
    const patientId = modal.dataset.patientId;
    const name = document.getElementById('editName').value.trim();
    const age = document.getElementById('editAge').value;
    const weight = document.getElementById('editWeight').value;
    const disease = document.getElementById('editDisease').value;
    const diseaseCode = document.getElementById('selectedDiseaseName').value;

    if (!name) {
        showResultPopup('ข้อผิดพลาด', 'กรุณากรอกชื่อผู้ป่วย');
        return;
    }

    const patientData = {
        name: name,
        age: age || null,
        weight: weight || null,
        disease: disease || 'ไม่ระบุ',
        diseaseCode: diseaseCode || null
    };

    try {
        const response = await fetch(`${API_BASE}/api/patients/${patientId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(patientData)
        });

        if (response.status === 401) {
            handleAuthError();
            return;
        }

        const result = await response.json();
        
        if (result.success) {
            closeModal();
            showResultPopup('สำเร็จ', 'แก้ไขข้อมูลผู้ป่วยสำเร็จ');
            loadPatients();
        } else {
            showResultPopup('ข้อผิดพลาด', result.message || 'ไม่สามารถแก้ไขข้อมูลได้');
        }
    } catch (error) {
        console.error('❌ Update Patient Error:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }
}
window.saveEdit = saveEdit;

async function confirmDelete() {
    closeDeleteModal();
    const user = await getCurrentUser();
    if (!user || !user.token) {
        showResultPopup('ข้อผิดพลาด', 'ไม่ได้รับอนุญาตให้ลบ');
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/api/patients/${patientIdToDelete}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${user.token}`
            }
        });

        if (response.status === 401) {
            handleAuthError();
            return;
        }
        
        const result = await response.json();
        
        if (result.success) {
             showResultPopup('สำเร็จ', 'ลบผู้ป่วยสำเร็จ');
             loadPatients();
        } else {
             showResultPopup('ข้อผิดพลาด', result.message || 'ไม่สามารถลบผู้ป่วยได้');
        }

    } catch (error) {
        console.error('❌ Delete Patient Error:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์เพื่อลบข้อมูลได้');
    }
}
window.confirmDelete = confirmDelete;

// ***************************************************************
// 6. UI Rendering Functions
// ***************************************************************

function renderPatientList(patients) {
    const list = document.getElementById('list');
    if (!list) return;

    list.innerHTML = '';
    
    if (patients.length === 0) {
        list.innerHTML = `<p style="text-align:center; padding:20px; color:#666;">ไม่พบข้อมูลผู้ป่วย</p>`;
        return;
    }

    patients.forEach(patient => {
        const item = document.createElement('div');
        item.className = 'patient';
        item.innerHTML = `
            <div class="patient-info">
                <div><strong>ชื่อ:</strong> ${escapeHtml(patient.PatientName)}</div>
                <strong>อายุ:</strong> ${patient.Age || '-'} ปี <bold>|</bold> 
                <strong>น้ำหนัก:</strong> ${patient.Weight || '-'} ก. <bold>|</bold> 
                <strong>โรค:</strong> ${escapeHtml(patient.Disease || 'ไม่ระบุ')}
            </div>
            <div class="patient-actions">
                <button class="btn-edit" onclick="openEditModal(${patient.PatientID})">
                    <i class="fa fa-edit"></i> แก้ไข
                </button>
                <button class="btn-delete" onclick="showDeleteModal(${patient.PatientID}, '${escapeHtml(patient.PatientName)}')">
                    <i class="fa fa-trash"></i> ลบ
                </button>
            </div>
        `;
        list.appendChild(item);
    });
}

function handleSearch() {
    const searchInput = document.getElementById('search');
    if (!searchInput) return;
    
    const query = searchInput.value.toLowerCase();
    const filtered = allPatients.filter(p => 
        p.PatientName.toLowerCase().includes(query) ||
        (p.Disease && p.Disease.toLowerCase().includes(query))
    );
    renderPatientList(filtered);
}

function openEditModal(patientId) {
    loadPatientForEdit(patientId);
}
window.openEditModal = openEditModal;

function closeModal() {
    const modal = document.getElementById('editModal');
    if (modal) {
        modal.style.display = 'none';
        document.getElementById('editName').value = '';
        document.getElementById('editAge').value = '';
        document.getElementById('editWeight').value = '';
        document.getElementById('editDisease').value = '';
        document.getElementById('selectedDiseaseName').value = '';
        
        const suggestions = document.getElementById('diseaseSuggestionsContainer');
        if (suggestions) suggestions.style.display = 'none';
    }
}
window.closeModal = closeModal;

function showDeleteModal(patientId, patientName) {
    patientIdToDelete = patientId;
    const modal = document.getElementById('deleteModal');
    const modalText = document.getElementById('deleteModalText');
    
    if (!modal || !modalText) return;
    
    modalText.innerHTML = `คุณแน่ใจหรือไม่ว่าต้องการลบผู้ป่วย <strong>${escapeHtml(patientName)}</strong>`;
    modal.style.display = 'flex';
}
window.showDeleteModal = showDeleteModal;

function closeDeleteModal() {
    const modal = document.getElementById('deleteModal');
    if (modal) {
        modal.style.display = 'none';
    }
    patientIdToDelete = null;
}
window.closeDeleteModal = closeDeleteModal;

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ***************************************************************
// 7. User Menu Functions
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
// 8. Initialization
// ***************************************************************

document.addEventListener('DOMContentLoaded', async function() {
    console.log('🚀 Initializing patientlist.js');
    
    try {
        const user = await getCurrentUser();
        if (!user) {
            showResultPopup('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่');
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 1500);
            return;
        }
    
        await updateUIForLoggedInUser();
        await loadAllDiseases();
        await loadPatients();
        
        const searchInput = document.getElementById('search');
        if (searchInput) {
            searchInput.addEventListener('input', handleSearch);
        }

        const diseaseInput = document.getElementById('editDisease');
        if (diseaseInput) {
            diseaseInput.addEventListener('input', (e) => {
                searchDiseases(e.target.value);
            });
        }

        document.addEventListener('click', function(e) {
            const userMenu = document.querySelector('.user-menu');
            const dropdown = document.getElementById('userDropdown');
            
            if (dropdown && userMenu && !userMenu.contains(e.target)) {
                dropdown.classList.remove('show');
            }

            const diseaseContainer = document.getElementById('diseaseSuggestionsContainer');
            const diseaseInput = document.getElementById('editDisease');
            if (diseaseContainer && diseaseInput && 
                !diseaseInput.contains(e.target) && 
                !diseaseContainer.contains(e.target)) {
                hideDiseaseDropdown();
            }
        });
        
        console.log('✅ Initialization complete');
    } catch (error) {
        console.error('❌ Error during initialization:', error);
        showResultPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการโหลดหน้า');
    }
});
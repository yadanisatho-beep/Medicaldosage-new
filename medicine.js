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

function showResultPopup(title, msg, type = 'success') {
    const popup = document.getElementById('resultPopup');
    if (popup) {
        document.getElementById('resultTitle').innerText = title;
        document.getElementById('resultMsg').innerText = msg;
        
        const icon = popup.querySelector('.popup-icon');
        if (icon) {
            icon.className = 'popup-icon ' + type;
            if (type === 'success') {
                icon.innerHTML = '<i class="fas fa-check"></i>';
            } else if (type === 'error') {
                icon.innerHTML = '<i class="fas fa-times"></i>';
            } else if (type === 'warning') {
                icon.innerHTML = '<i class="fas fa-exclamation-triangle"></i>';
            }
        }
        
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
// 3. State Variables
// ***************************************************************

let allMedicines = [];
let selectedMedicineForFactors = null;

// ***************************************************************
// 4. Medicine Data Loading
// ***************************************************************

async function loadMedicineList() {
    const user = await getCurrentUser();
    const listContainer = document.getElementById('drugsList');
    
    if (!user || !user.token) {
        if(listContainer) listContainer.innerHTML = `<p class="alert alert-danger">กรุณาเข้าสู่ระบบเพื่อดูรายการยา</p>`;
        return;
    }
    
    if(listContainer) listContainer.innerHTML = `<div class="text-center p-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>`;
    
    try {
        // โหลดรายการยาทั้งหมด
        const response = await fetch(`${API_BASE}/api/medicines`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (response.status === 401) {
            handleAuthError();
            return;
        }

        const data = await response.json();
        
        if (data.success) {
            allMedicines = data.medicines || [];
            
            // โหลดยาที่มี factors จาก user_medicine_factors
            const factorsResponse = await fetch(`${API_BASE}/api/user-medicine-factors/all`, {
                headers: {
                    'Authorization': `Bearer ${user.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            let configuredMedicines = [];
            if (factorsResponse.ok) {
                const factorsData = await factorsResponse.json();
                if (factorsData.success) {
                    configuredMedicines = factorsData.medicines || [];
                }
            }
            
            console.log('✅ โหลดยาสำเร็จ:', allMedicines.length, 'รายการ');
            console.log('✅ ยาที่กรอกปัจจัยแล้ว:', configuredMedicines.length, 'รายการ');
            
            renderMedicineList(allMedicines, configuredMedicines);
        } else {
             showResultPopup('ข้อผิดพลาด', data.message || 'ไม่สามารถโหลดข้อมูลยาได้', 'error');
             if(listContainer) listContainer.innerHTML = `<p style="text-align:center;padding:40px;color:#666;">ไม่สามารถโหลดข้อมูลยาได้</p>`;
        }
    } catch (error) {
        console.error('❌ Load Medicines Error:', error);
        if(listContainer) listContainer.innerHTML = `<p style="text-align:center;padding:40px;color:#e74c3c;">ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้</p>`;
    }
}

function renderMedicineList(medicines, configuredMedicines = []) {
    const list = document.getElementById('drugsList');
    const noResults = document.getElementById('noResults');
    
    if (!list) return;

    list.innerHTML = '';
    
    if (medicines.length === 0) {
        list.style.display = 'none';
        if (noResults) noResults.style.display = 'block';
        return;
    }

    list.style.display = 'flex';
    if (noResults) noResults.style.display = 'none';

    // สร้าง Set ของ drug_id ที่กรอกปัจจัยแล้ว
    const configuredDrugIds = new Set(configuredMedicines.map(m => m.drug_id));

    medicines.forEach(med => {
        const card = document.createElement('div');
        const drugId = med.MedicineID || med.drug_id;
        const isConfigured = configuredDrugIds.has(drugId);
        
        card.className = 'drug-card' + (isConfigured ? ' configured' : '');
        
        // แปลง Indication เป็นรายการ
        let indicationHtml = '';
        if (med.Indication) {
            const indications = med.Indication
                .split(/(?=\d+[.)]\s)/)
                .map(i => i.trim())
                .filter(i => i.length > 0)
                .map(i => i.replace(/^\d+[.)]\s*/, ''));
            
            if (indications.length > 0) {
                indicationHtml = `
                    <div style="margin-top: 10px; padding: 12px; background: #e3f2fd; border-radius: 8px; border-left: 4px solid #1976d2;">
                        <strong style="color: #1976d2; font-size: 15px;">เงื่อนไขการใช้ยา:</strong>
                        <ol style="margin: 8px 0 0 0; padding-left: 20px; color: #424242; line-height: 1.8;">
                            ${indications.map(i => `<li style="margin-bottom: 8px;">${i}</li>`).join('')}
                        </ol>
                    </div>
                `;
            }
        }
        
        // แปลง Warning เป็นรายการ
        let warningHtml = '';
        if (med.Warning) {
            const warnings = med.Warning
                .split(/[,;]|\n/)
                .map(w => w.trim())
                .filter(w => w.length > 0);
            
            if (warnings.length > 0) {
                warningHtml = `
                    <div class="contraindication-info" style="margin-top: 10px; padding: 12px; background: #ffebee; border-radius: 8px; border-left: 4px solid #e74c3c;">
                        <strong style="color: #c62828; font-size: 15px;">⚠️ ข้อควรระวัง:</strong>
                        <ul style="margin: 8px 0 0 0; padding-left: 20px; color: #c62828; line-height: 1.8;">
                            ${warnings.map(w => `<li style="margin-bottom: 6px;">${w}</li>`).join('')}
                        </ul>
                    </div>
                `;
            }
        }
        
        // สถานะการกรอกปัจจัย
        const configureStatusHtml = isConfigured 
            ? `<div class="configure-status configured">
                <i class="fas fa-check-circle"></i>
                <span>กรอกปัจจัยการคำนวณแล้ว</span>
               </div>`
            : `<div class="configure-status">
                <i class="fas fa-exclamation-circle"></i>
                <span>ยังไม่ได้กรอกปัจจัยการคำนวณ</span>
               </div>`;
        
        // Badge แสดงสถานะ
        const badgeHtml = isConfigured 
            ? `<div class="configured-badge">
                <i class="fas fa-check"></i> กรอกปัจจัยแล้ว
               </div>`
            : '';
        
        // สร้าง HTML การ์ด
        card.innerHTML = `
            ${badgeHtml}
            <div class="drug-header">
                <div>
                    <div class="drug-name">${med.GenericName || 'ไม่ระบุชื่อยา'}</div>
                    ${med.Type ? `
                        <div class="drug-type">
                            <i class="fas fa-capsules" style="color: #39AC95;"></i> 
                            ${med.Type}
                        </div>
                    ` : ''}
                </div>
                <div style="display: flex; gap: 8px; align-items: center;">
                    <button class="select-medicine-btn" onclick='openMedicineFactorsModal(${JSON.stringify(med).replace(/'/g, "&apos;")})' title="กรอก/แก้ไขปัจจัยการคำนวณ">
                        <i class="fas fa-cog"></i> ${isConfigured ? 'แก้ไขปัจจัย' : 'กรอกปัจจัย'}
                    </button>
                </div>
            </div>
            
            <div class="drug-details">
                ${med.Dosage ? `
                    <div class="dosage-info" style="padding: 10px; background: #e8f5e9; border-radius: 8px; border-left: 4px solid #27ae60;">
                        <strong style="color: #27ae60; font-size: 15px;">รูปแบบยา:</strong><br>
                        <span style="color: #2c3e50; margin-top: 5px; display: inline-block;">${med.Dosage}</span>
                    </div>
                ` : ''}
                
                ${indicationHtml}
                
                ${warningHtml}
                
                ${configureStatusHtml}
            </div>
        `;
        
        list.appendChild(card);
    });
}

// ฟังก์ชันค้นหายา
function searchMedicine(e) {
    const query = e.target.value.toLowerCase().trim();
    
    if (!query) {
        // โหลดใหม่เพื่อให้แสดงสถานะ configured
        loadMedicineList();
        return;
    }
    
    const filtered = allMedicines.filter(med => {
        const genericName = (med.GenericName || '').toLowerCase();
        const type = (med.Type || '').toLowerCase();
        const dosage = (med.Dosage || '').toLowerCase();
        const indication = (med.Indication || '').toLowerCase();
        
        return genericName.includes(query) || 
               type.includes(query) || 
               dosage.includes(query) ||
               indication.includes(query);
    });
    
    // ใช้ renderMedicineList แต่ไม่ส่ง configured ไปเพราะยังไม่โหลด
    renderMedicineList(filtered, []);
}

// ***************************************************************
// 5. MEDICINE FACTORS MODAL FUNCTIONS
// ***************************************************************

// เปิด Modal กรอกปัจจัยยา
function openMedicineFactorsModal(medicine) {
    selectedMedicineForFactors = medicine;
    
    const modal = document.getElementById('medicineFactorsModal');
    const drugId = medicine.MedicineID || medicine.drug_id;
    
    // แสดงชื่อยาที่เลือก
    document.getElementById('displaySelectedMedicine').textContent = medicine.GenericName || 'ไม่ระบุชื่อ';
    document.getElementById('displaySelectedType').textContent = medicine.Type || '-';
    
    // เก็บ ID ไว้ใน hidden field
    document.getElementById('selectedDrugId').value = drugId;
    document.getElementById('selectedMedicineName').value = medicine.GenericName;
    document.getElementById('selectedMedicineType').value = medicine.Type || '';
    
    // โหลดข้อมูลที่กรอกไว้ (ถ้ามี)
    loadExistingMedicineFactors(drugId);
    
    modal.classList.add('show');
}
window.openMedicineFactorsModal = openMedicineFactorsModal;

// ปิด Modal
function closeMedicineFactorsModal() {
    const modal = document.getElementById('medicineFactorsModal');
    modal.classList.remove('show');
    document.getElementById('medicineFactorsForm').reset();
}
window.closeMedicineFactorsModal = closeMedicineFactorsModal;

// โหลดข้อมูลที่กรอกไว้แล้ว
async function loadExistingMedicineFactors(drugId) {
    try {
        const user = await getCurrentUser();
        if (!user) return;
        
        const response = await fetch(`${API_BASE}/api/user-medicine-factors/${drugId}`, {
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            }
        });
        
        const data = await response.json();
        
        if (data.success && data.medicine) {
            const med = data.medicine;
            
            // กรอกข้อมูลเดิมลงในฟอร์ม
            document.getElementById('standardDosePerKg').value = med.standard_dose_per_kg || '';
            document.getElementById('standardDosePerM2').value = med.standard_dose_per_m2 || '';
            document.getElementById('standardFrequency').value = med.standard_frequency || '';
            document.getElementById('standardFrequencyInt').value = med.standard_frequency_int || '';
            document.getElementById('eliminationRoute').value = med.elimination_route || '';
            document.getElementById('halfLifeHours').value = med.half_life_hours || '';
            document.getElementById('maxDosePerUnit').value = med.max_dose_per_unit || '';
            document.getElementById('maxDailyDose').value = med.max_daily_dose || '';
            
            // Renal Adjustment
            document.getElementById('requiresRenalAdjustment').checked = med.requires_renal_adjustment;
            document.getElementById('crclThresholdMild').value = med.crcl_threshold_mild || '';
            document.getElementById('crclThresholdModerate').value = med.crcl_threshold_moderate || '';
            document.getElementById('crclThresholdSevere').value = med.crcl_threshold_severe || '';
            document.getElementById('renalAdjustmentMild').value = med.renal_adjustment_mild || '';
            document.getElementById('renalAdjustmentModerate').value = med.renal_adjustment_moderate || '';
            document.getElementById('renalAdjustmentSevere').value = med.renal_adjustment_severe || '';
            
            // Hepatic Adjustment
            document.getElementById('requiresHepaticAdjustment').checked = med.requires_hepatic_adjustment;
            document.getElementById('childPughAFactor').value = med.child_pugh_a_factor || '1.0';
            document.getElementById('childPughBFactor').value = med.child_pugh_b_factor || '';
            document.getElementById('childPughCFactor').value = med.child_pugh_c_factor || '';
            
            // Notes
            document.getElementById('notes').value = med.notes || '';
            
            // แสดง/ซ่อน sections ตามการตั้งค่า
            toggleAdjustmentSections();
            toggleRenalFields();
            toggleHepaticFields();
        }
    } catch (error) {
        console.error('Error loading medicine factors:', error);
    }
}

// อัปเดตความถี่อัตโนมัติ
function updateFrequencyInt() {
    const freqText = document.getElementById('standardFrequency').value;
    const freqIntInput = document.getElementById('standardFrequencyInt');
    
    const freqMap = {
        'OD': 1,
        'BID': 2,
        'TID': 3,
        'QID': 4,
        'Q8H': 3,
        'Q6H': 4
    };
    
    freqIntInput.value = freqMap[freqText] || '';
}
window.updateFrequencyInt = updateFrequencyInt;

// แสดง/ซ่อน sections ตามเส้นทางการกำจัด
function toggleAdjustmentSections() {
    const route = document.getElementById('eliminationRoute').value;
    const renalSection = document.getElementById('renalAdjustmentSection');
    const hepaticSection = document.getElementById('hepaticAdjustmentSection');
    
    if (route === 'Renal' || route === 'Both') {
        renalSection.style.display = 'block';
    } else {
        renalSection.style.display = 'none';
    }
    
    if (route === 'Hepatic' || route === 'Both') {
        hepaticSection.style.display = 'block';
    } else {
        hepaticSection.style.display = 'none';
    }
}
window.toggleAdjustmentSections = toggleAdjustmentSections;

// แสดง/ซ่อน Renal Fields
function toggleRenalFields() {
    const checkbox = document.getElementById('requiresRenalAdjustment');
    const fields = document.getElementById('renalFields');
    fields.style.display = checkbox.checked ? 'block' : 'none';
}
window.toggleRenalFields = toggleRenalFields;

// แสดง/ซ่อน Hepatic Fields
function toggleHepaticFields() {
    const checkbox = document.getElementById('requiresHepaticAdjustment');
    const fields = document.getElementById('hepaticFields');
    fields.style.display = checkbox.checked ? 'block' : 'none';
}
window.toggleHepaticFields = toggleHepaticFields;

// ***************************************************************
// 6. User Menu Functions
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
// 7. Initialization
// ***************************************************************

document.addEventListener('DOMContentLoaded', async function() {
    console.log('🚀 Initializing medicine.js');
    
    try {
        // Check if user is logged in first
        const user = await getCurrentUser();
        if (!user) {
            showResultPopup('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่', 'error');
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 1500);
            return;
        }
    
        await updateUIForLoggedInUser();
        await loadMedicineList();
        
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', searchMedicine);
        }
        
        // Close dropdowns when clicking outside
        document.addEventListener('click', function(e) {
            const userMenu = document.querySelector('.user-menu');
            const dropdown = document.getElementById('userDropdown');
            
            if (dropdown && userMenu && !userMenu.contains(e.target)) {
                dropdown.classList.remove('show');
            }
        });
        
        // Form Submit Handler
        const form = document.getElementById('medicineFactorsForm');
        if (form) {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                await saveMedicineFactors();
            });
        }
        
        console.log('✅ Initialization complete');
    } catch (error) {
        console.error('❌ Error during initialization:', error);
        showResultPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการโหลดหน้า', 'error');
    }
});

// ***************************************************************
// 8. Save Medicine Factors Function
// ***************************************************************

async function saveMedicineFactors() {
    const user = await getCurrentUser();
    if (!user) {
        showResultPopup('กรุณาเข้าสู่ระบบ', 'คุณต้องเข้าสู่ระบบก่อนบันทึกข้อมูล', 'warning');
        return;
    }
    
    const drugId = document.getElementById('selectedDrugId').value;
    
    const payload = {
        drugId: parseInt(drugId),
        standardDosePerKg: parseFloat(document.getElementById('standardDosePerKg').value),
        standardDosePerM2: document.getElementById('standardDosePerM2').value ? 
            parseFloat(document.getElementById('standardDosePerM2').value) : null,
        eliminationRoute: document.getElementById('eliminationRoute').value,
        halfLifeHours: document.getElementById('halfLifeHours').value ? 
            parseFloat(document.getElementById('halfLifeHours').value) : null,
        standardFrequency: document.getElementById('standardFrequency').value,
        standardFrequencyInt: parseInt(document.getElementById('standardFrequencyInt').value),
        maxDosePerUnit: parseFloat(document.getElementById('maxDosePerUnit').value),
        maxDailyDose: parseFloat(document.getElementById('maxDailyDose').value),
        
        requiresRenalAdjustment: document.getElementById('requiresRenalAdjustment').checked,
        crclThresholdMild: document.getElementById('crclThresholdMild').value ? 
            parseFloat(document.getElementById('crclThresholdMild').value) : null,
        crclThresholdModerate: document.getElementById('crclThresholdModerate').value ? 
            parseFloat(document.getElementById('crclThresholdModerate').value) : null,
        crclThresholdSevere: document.getElementById('crclThresholdSevere').value ? 
            parseFloat(document.getElementById('crclThresholdSevere').value) : null,
        renalAdjustmentMild: document.getElementById('renalAdjustmentMild').value ? 
            parseFloat(document.getElementById('renalAdjustmentMild').value) : null,
        renalAdjustmentModerate: document.getElementById('renalAdjustmentModerate').value ? 
            parseFloat(document.getElementById('renalAdjustmentModerate').value) : null,
        renalAdjustmentSevere: document.getElementById('renalAdjustmentSevere').value ? 
            parseFloat(document.getElementById('renalAdjustmentSevere').value) : null,
        
        requiresHepaticAdjustment: document.getElementById('requiresHepaticAdjustment').checked,
        childPughAFactor: document.getElementById('childPughAFactor').value ? 
            parseFloat(document.getElementById('childPughAFactor').value) : null,
        childPughBFactor: document.getElementById('childPughBFactor').value ? 
            parseFloat(document.getElementById('childPughBFactor').value) : null,
        childPughCFactor: document.getElementById('childPughCFactor').value ? 
            parseFloat(document.getElementById('childPughCFactor').value) : null,
        
        notes: document.getElementById('notes').value || null
    };
    
    try {
        const response = await fetch(`${API_BASE}/api/user-medicine-factors`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });
        
        const data = await response.json();
        
        if (data.success) {
            showResultPopup('บันทึกสำเร็จ', 'บันทึกปัจจัยการคำนวณยาเรียบร้อยแล้ว', 'success');
            closeMedicineFactorsModal();
            
            // โหลดรายการยาใหม่เพื่ออัปเดตสถานะ
            await loadMedicineList();
        } else {
            showResultPopup('ข้อผิดพลาด', data.message || 'ไม่สามารถบันทึกข้อมูลได้', 'error');
        }
    } catch (error) {
        console.error('Error saving medicine factors:', error);
        showResultPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการบันทึกข้อมูล', 'error');
    }
}

// ***************************************************************
// 9. Export Functions to Window
// ***************************************************************

window.getCurrentUser = getCurrentUser;
window.handleAuthError = handleAuthError;
window.confirmLogout = confirmLogout;
window.showResultPopup = showResultPopup;
window.closeResultPopup = closeResultPopup;
window.showWarningPopup = showWarningPopup;
window.closeWarningPopup = closeWarningPopup;
window.showLogoutPopup = showLogoutPopup;
window.closeLogoutPopup = closeLogoutPopup;
window.updateUIForLoggedInUser = updateUIForLoggedInUser;
window.toggleUserDropdown = toggleUserDropdown;
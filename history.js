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
// 2. UI Helper Functions
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
// 2.5  Date/Time Conversion Helper (แก้ไข: ใช้เวลาที่มีโดยไม่แปลง Timezone)
// ***************************************************************

/**
 * แปลง datetime จาก database เป็นรูปแบบที่อ่านง่าย (ไม่แปลง Timezone)
 * @param {string} dateString - datetime string จาก database
 * @returns {object} { dateStr, timeStr, fullDateTime }
 */
function convertToThaiTime(dateString) {
    if (!dateString) {
        return { dateStr: '-', timeStr: '-', fullDateTime: '-' };
    }

    try {
        // วิธีนี้จะไม่มีการแปลง Timezone ซ้ำซ้อน
        const dateOnly = dateString.split('T')[0] || dateString.split(' ')[0];
        const timeOnly = dateString.split('T')[1]?.split('.')[0] || dateString.split(' ')[1] || '00:00:00';
        
        // สร้าง Date object โดยถือว่าเป็นเวลาไทยอยู่แล้ว
        const [year, month, day] = dateOnly.split('-').map(Number);
        const [hour, minute, second] = timeOnly.split(':').map(Number);
        
        // แปลง ค.ศ. เป็น พ.ศ.
        const yearBE = year + 543;
        
        // ฟอร์แมตวันที่เป็น dd/mm/yyyy (พ.ศ.)
        const dateStr = `${String(day).padStart(2, '0')}/${String(month).padStart(2, '0')}/${yearBE}`;
        
        // ฟอร์แมตเวลาเป็น hh:mm:ss
        const timeStr = `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}:${String(second).padStart(2, '0')}`;
        
        const fullDateTime = `${dateStr} ${timeStr}`;
        
        return { dateStr, timeStr, fullDateTime };
    } catch (error) {
        console.error('Error converting to Thai time:', error);
        return { dateStr: '-', timeStr: '-', fullDateTime: '-' };
    }
}

// ***************************************************************
// 3. State Variables and Data Fetching
// ***************************************************************

let currentDisplayData = []; 

/**
 * ดึงประวัติการคำนวณจาก API (calculations table)
 */
async function loadHistoryData() {
  const user = await getCurrentUser();
  const historyTableBody = document.getElementById('historyTableBody');
  const loadingIndicator = document.getElementById('loadingIndicator');

  if(loadingIndicator) loadingIndicator.style.display = 'block';
  if(historyTableBody) historyTableBody.innerHTML = '';

  if (!user || !user.token) {
    if(loadingIndicator) loadingIndicator.style.display = 'none';
    if(historyTableBody) {
        historyTableBody.innerHTML = `
            <div class="no-data">
                <i class="fa fa-history" style="font-size: 48px; color: #ccc; margin-bottom: 15px;"></i>
                <div>กรุณาเข้าสู่ระบบเพื่อดูประวัติการคำนวณ</div>
            </div>
        `;
    }
    return [];
  }
  
  try {
    const response = await fetch(`${API_BASE}/api/history`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${user.token}`,
        'Content-Type': 'application/json'
      }
    });

    if (response.status === 401) {
        handleAuthError();
        return [];
    }

    const data = await response.json();
    
    if (data.success) {
      currentDisplayData = data.history || [];
      updateStats(currentDisplayData);
      renderHistory(currentDisplayData); 
      return currentDisplayData;
    } else {
      throw new Error(data.error || 'Failed to fetch history');
    }
  } catch (error) {
    console.error('❌ Error loading history:', error);
    if(historyTableBody) {
        historyTableBody.innerHTML = `
            <div class="no-data">
                <i class="fa fa-exclamation-triangle" style="font-size: 48px; color: #dc3545; margin-bottom: 15px;"></i>
                <div>ไม่สามารถดึงประวัติการคำนวณจากเซิร์ฟเวอร์ได้</div>
            </div>
        `;
    }
    return [];
  } finally {
    if(loadingIndicator) loadingIndicator.style.display = 'none';
  }
}

// ***************************************************************
// 4. Statistics Update
// ***************************************************************

function updateStats(history) {
    // รายการทั้งหมด
    const totalRecords = history.length;
    document.getElementById('totalRecords').textContent = totalRecords;
    document.getElementById('totalRecordsText').textContent = totalRecords;
    
    // วันนี้ (ใช้เวลาไทย)
    const now = new Date();
    const todayFormatter = new Intl.DateTimeFormat('en-CA', {
        timeZone: 'Asia/Bangkok',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
    const todayThai = todayFormatter.format(now); // Format: YYYY-MM-DD
    
    const todayRecords = history.filter(record => {
        const thaiDateTime = convertToThaiTime(record.calculated_at);
        const dateParts = thaiDateTime.dateStr.split('/');
        if (dateParts.length === 3) {
            const day = dateParts[0];
            const month = dateParts[1];
            const year = dateParts[2];
            // แปลง พ.ศ. เป็น ค.ศ. สำหรับเปรียบเทียบ
            const yearAD = String(parseInt(year) - 543);
            const recordDate = `${yearAD}-${month}-${day}`;
            return recordDate === todayThai;
        }
        return false;
    }).length;
    
    document.getElementById('todayRecords').textContent = todayRecords;
    
    // ผู้ป่วยไม่ซ้ำ
    const uniquePatients = new Set(history.map(r => r.patient_name)).size;
    document.getElementById('uniquePatients').textContent = uniquePatients;
    
    // ยาไม่ซ้ำ
    const uniqueMedicines = new Set(history.map(r => r.medicine_name)).size;
    document.getElementById('uniqueMedicines').textContent = uniqueMedicines;
}

// ***************************************************************
// 5. Delete Logic
// ***************************************************************

let deleteRecordId = null; 
let deleteType = null;

function showDeleteModal(id, type) {
    deleteRecordId = id;
    deleteType = type;
    const modal = document.getElementById('deleteModal');
    const modalText = document.getElementById('deleteModalBody');
    
    if (!modal || !modalText) {
        console.error('❌ Modal elements not found');
        return;
    }
    
    console.log(`🗑️ Show delete modal - ID: ${id}, Type: ${type}`);
    
    if (type === 'all') {
        modalText.textContent = 'คุณแน่ใจหรือไม่ว่าต้องการลบประวัติการคำนวณยาทั้งหมด? การดำเนินการนี้ไม่สามารถยกเลิกได้';
    } else {
        modalText.textContent = 'คุณแน่ใจหรือไม่ว่าต้องการลบประวัติการคำนวณยารายการนี้?';
    }
    
    modal.classList.add('show');
    modal.style.display = 'flex';
}

async function confirmDelete() {
    const user = await getCurrentUser();
    if (!user || !user.token) {
        showResultPopup('ข้อผิดพลาด', 'ไม่ได้รับอนุญาตให้ลบ');
        closeDeleteModal();
        return;
    }
    
    console.log(`🗑️ Confirm delete - Type: ${deleteType}, ID: ${deleteRecordId}`);

    try {
        let endpoint;

        if (deleteType === 'all') {
            endpoint = `${API_BASE}/api/history/all`;
        } else if (deleteType === 'single' && deleteRecordId) {
            endpoint = `${API_BASE}/api/history/${deleteRecordId}`;
        } else {
            showResultPopup('ข้อผิดพลาด', 'ไม่สามารถระบุรายการที่ต้องการลบได้');
            closeDeleteModal();
            return;
        }

        console.log(`Sending DELETE request to: ${endpoint}`);

        const response = await fetch(endpoint, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            }
        });

        const data = await response.json();
        console.log('Delete response:', data);

        if (!response.ok) {
            console.error('Delete failed:', response.status, data);
            showResultPopup('ข้อผิดพลาด', data.message || data.error || 'ไม่สามารถลบได้');
            closeDeleteModal();
            return;
        }

        if (data.success) {
            const message = deleteType === 'all' 
                ? `ลบประวัติทั้งหมดสำเร็จ (${data.deletedCount || 0} รายการ)` 
                : 'ลบประวัติสำเร็จแล้ว';
            showResultPopup('สำเร็จ', message);
            closeDeleteModal();
            await loadHistoryData();
        } else {
            showResultPopup('ข้อผิดพลาด', data.message || 'ไม่สามารถลบได้');
            closeDeleteModal();
        }

    } catch (error) {
        console.error('Delete Error:', error);
        showResultPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์');
        closeDeleteModal();
    }
}

function deleteAllHistory() {
    console.log('🗑️ Delete all history clicked');
    showDeleteModal(null, 'all');
}

function closeDeleteModal() {
    const modal = document.getElementById('deleteModal');
    if (modal) {
        modal.classList.remove('show');
        modal.style.display = 'none';
    }
    deleteRecordId = null;
    deleteType = null;
}
window.closeDeleteModal = closeDeleteModal;

// ***************************************************************
// 6. UI and Search/Filter
// ***************************************************************

function renderHistory(history) {
    const tableBody = document.getElementById('historyTableBody');
    if (!tableBody) return;

    tableBody.innerHTML = '';

    if (history.length === 0) {
        tableBody.innerHTML = `
            <div class="no-data">
                <i class="fa fa-history" style="font-size: 48px; color: #ccc; margin-bottom: 15px;"></i>
                <div>ไม่มีข้อมูลประวัติการคำนวณ</div>
                <div style="font-size: 14px; color: #999; margin-top: 5px;">ข้อมูลจะแสดงหลังจากทำการคำนวณปริมาณยา</div>
            </div>
        `;
        return;
    }

    history.forEach(record => {
        const thaiDateTime = convertToThaiTime(record.calculated_at);

        const row = document.createElement('div');
        row.className = 'table-row';
        row.style.cursor = 'pointer';
        row.innerHTML = `
            <div>${thaiDateTime.dateStr}<br><small style="color: #666;">${thaiDateTime.timeStr}</small></div>
            <div>${record.patient_name || '-'}</div>
            <div>${record.medicine_name || '-'}</div>
            <div>${record.dosage_per_time || '-'} mg/${record.frequency || '-'} ครั้ง</div>
            <div>${record.frequency || '-'} ครั้ง/วัน</div>
            <div onclick="event.stopPropagation()">
                <button class="delete-btn" onclick="showDeleteModal(${record.id}, 'single')" title="ลบรายการนี้">
                    <i class="fa fa-trash"></i> ลบ
                </button>
            </div>
        `;
        
        // เพิ่ม click event เพื่อแสดงรายละเอียด
        row.addEventListener('click', () => showHistoryDetail(record));
        
        tableBody.appendChild(row);
    });
}

function handleSearch() {
    const searchInput = document.getElementById('searchInput').value.toLowerCase();
    const dateInput = document.getElementById('dateInput').value;

    const filtered = currentDisplayData.filter(record => {
        const patientName = record.patient_name || '';
        const medicineName = record.medicine_name || '';
        const searchMatch = patientName.toLowerCase().includes(searchInput) || 
                          medicineName.toLowerCase().includes(searchInput);

        if (!dateInput) return searchMatch;

        const thaiDateTime = convertToThaiTime(record.calculated_at);
        const dateParts = thaiDateTime.dateStr.split('/');
        
        if (dateParts.length === 3) {
            const day = dateParts[0];
            const month = dateParts[1];
            const year = dateParts[2];
            // แปลง พ.ศ. เป็น ค.ศ. สำหรับเปรียบเทียบ
            const yearAD = String(parseInt(year) - 543);
            const recordDate = `${yearAD}-${month}-${day}`;
            
            return searchMatch && recordDate === dateInput;
        }
        
        return searchMatch;
    });

    updateStats(filtered);
    renderHistory(filtered);
}

function searchHistory() {
    handleSearch();
}

// ***************************************************************
// 7. UI Function
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
              <a href="javascript:void(0)" onclick="showLogoutPopup()">
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
// 8. SHOW HISTORY DETAIL
// ***************************************************************

async function showHistoryDetail(record) {
    console.log('📋 Showing detail for record:', record);
    
    // ดึงข้อมูลหมอจาก token
    const user = await getCurrentUser();
    const doctorName = user ? `${user.FirstName} ${user.LastName}` : 'ไม่ระบุ';
    
    const thaiDateTime = convertToThaiTime(record.calculated_at);
    
    const modal = document.getElementById('detailModal');
    if (!modal) return;
    
    // สร้างเนื้อหาในโมดัล
    const detailContent = document.getElementById('detailContent');
    if (!detailContent) return;
    
    detailContent.innerHTML = `
        <div class="detail-section">
            <h3><i class="fas fa-user-md"></i> ข้อมูลแพทย์</h3>
            <div class="detail-row">
                <span class="detail-label">ชื่อ-นามสกุล:</span>
                <span class="detail-value">${record.override_doctor_name || doctorName}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">วันที่คำนวณ:</span>
                <span class="detail-value">${thaiDateTime.fullDateTime}</span>
            </div>
        </div>
        
        <div class="detail-section">
            <h3><i class="fas fa-user-injured"></i> ข้อมูลผู้ป่วย</h3>
            <div class="detail-row">
                <span class="detail-label">ชื่อผู้ป่วย:</span>
                <span class="detail-value">${record.patient_name || '-'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">อายุ:</span>
                <span class="detail-value">${record.patient_age ? record.patient_age + ' ปี' : '-'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">น้ำหนัก:</span>
                <span class="detail-value">${record.patient_weight ? record.patient_weight + ' kg' : '-'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">โรค:</span>
                <span class="detail-value">${record.patient_disease || '-'}</span>
            </div>
        </div>
        
        <div class="detail-section">
            <h3><i class="fas fa-pills"></i> ข้อมูลยา</h3>
            <div class="detail-row">
                <span class="detail-label">ชื่อยา:</span>
                <span class="detail-value">${record.medicine_name || '-'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">ชนิดยา:</span>
                <span class="detail-value">${record.medicine_type || '-'}</span>
            </div>
        </div>
        
        <div class="detail-section">
            <h3><i class="fas fa-calculator"></i> ข้อมูลการคำนวณ</h3>
            <div class="detail-row">
                <span class="detail-label">ปริมาณต่อครั้ง:</span>
                <span class="detail-value highlight">${record.dosage_per_time || '-'} mg</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">ความถี่:</span>
                <span class="detail-value highlight">${record.frequency || '-'} ครั้ง/วัน</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">ปริมาณรวมต่อวัน:</span>
                <span class="detail-value">${record.total_daily_dose || '-'} mg</span>
            </div>
            ${record.recommended_min_dose ? `
                <div class="detail-row">
                    <span class="detail-label">ปริมาณที่แนะนำ:</span>
                    <span class="detail-value">${record.recommended_min_dose} mg (${record.recommended_frequency || '-'} ครั้ง/วัน)</span>
                </div>
            ` : ''}
        </div>
        
        ${record.is_override && record.override_reason ? `
            <div class="detail-section override-section">
                <h3><i class="fas fa-exclamation-triangle"></i> เหตุผลที่ Override</h3>
                <div class="override-reason">
                    ${record.override_reason}
                </div>
            </div>
        ` : ''}
    `;
    
    modal.classList.add('show');
    modal.style.display = 'flex';
}

function closeDetailModal() {
    const modal = document.getElementById('detailModal');
    if (modal) {
        modal.classList.remove('show');
        modal.style.display = 'none';
    }
}
window.closeDetailModal = closeDetailModal;

// ***************************************************************
// 9. Initialization
// ***************************************************************

document.addEventListener('DOMContentLoaded', async function() {
  console.log('📄 History page initialized');
  await updateUIForLoggedInUser();
  await loadHistoryData();
  
  const searchInput = document.getElementById('searchInput');
  const dateInput = document.getElementById('dateInput');
  
  if (searchInput) searchInput.addEventListener('input', handleSearch);
  if (dateInput) dateInput.addEventListener('change', handleSearch);
  
  const deleteModal = document.getElementById('deleteModal');
  if (deleteModal) {
    deleteModal.addEventListener('click', function(e) {
      // ปิด modal เมื่อคลิกพื้นหลังดำ
      if (e.target === deleteModal) {
        closeDeleteModal();
      }
    });
  }
  
  const detailModal = document.getElementById('detailModal');
  if (detailModal) {
    detailModal.addEventListener('click', function(e) {
      if (e.target === detailModal) {
        closeDetailModal();
      }
    });
  }
  
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
window.showDeleteModal = showDeleteModal;
window.confirmDelete = confirmDelete;
window.deleteAllHistory = deleteAllHistory;
window.handleSearch = handleSearch;
window.searchHistory = searchHistory;
window.convertToThaiTime = convertToThaiTime;
window.showHistoryDetail = showHistoryDetail;
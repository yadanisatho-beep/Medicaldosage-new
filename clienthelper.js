// ===============================================
// CLIENT-SIDE COMMON HELPERS
// ✅ Auto-detect API Base URL (localhost or ngrok)
// ===============================================

/**
 * 🔥 SMART API_BASE DETECTION
 * - ใช้ localhost เมื่อเปิดจาก localhost
 * - ใช้ ngrok URL เมื่อเปิดจาก ngrok
 */
function getApiBase() {
    const hostname = window.location.hostname;
    const protocol = window.location.protocol;
    
    console.log('🌐 Detecting API Base...');
    console.log('  - Current hostname:', hostname);
    console.log('  - Current protocol:', protocol);
    
    if (hostname.includes('ngrok-free.dev') || 
        hostname.includes('ngrok-free.app') || 
        hostname.includes('ngrok.io') ||
        hostname.includes('ngrok.app')) {
        const apiBase = `${protocol}//${hostname}`;
        console.log('✅ Using ngrok URL:', apiBase);
        return apiBase;
    }
    
    // ถ้าเปิดจาก localhost
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
        const apiBase = 'http://localhost:3000';
        console.log('✅ Using localhost:', apiBase);
        return apiBase;
    }
    
    // Fallback: ใช้ origin ปัจจุบัน
    const apiBase = window.location.origin;
    console.log('⚠️ Using current origin:', apiBase);
    return apiBase;
}

const API_BASE = getApiBase();
window.API_BASE = API_BASE; // Export to global scope

console.log('🎯 Final API_BASE:', API_BASE);

/**
 * 💡 UPDATED: ดึงข้อมูลผู้ใช้จาก Database ผ่าน API
 */
async function getCurrentUser() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        console.log('❌ No auth token found');
        return null;
    }

    try {
        console.log('🔄 Fetching user profile from database...');
        const response = await fetch(`${API_BASE}/api/user/profile`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
                'ngrok-skip-browser-warning': 'true'
            }
        });

        if (!response.ok) {
            if (response.status === 401) {
                console.log('❌ Token invalid or expired');
                sessionStorage.removeItem('authToken');
                localStorage.removeItem('authToken');
            }
            return null;
        }

        const data = await response.json();
        
        if (data.success && data.user) {
            console.log('✅ User profile fetched from database:', data.user);
            data.user.token = token;
            return data.user;
        }
        
        return null;
    } catch (error) {
        console.error('❌ Error fetching user from database:', error);
        return null;
    }
}
window.getCurrentUser = getCurrentUser;

/**
 * 💡 ฟังก์ชัน Synchronous สำหรับดึง User แบบรวดเร็ว
 */
function hasAuthToken() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    return !!token;
}
window.hasAuthToken = hasAuthToken;

/**
 * 💡 จัดการเมื่อ Token หมดอายุหรือ Invalid
 */
function handleAuthError() {
    sessionStorage.clear();
    localStorage.clear();
    console.error('❌ Authentication Failed: Redirecting to login.');
    if (typeof showResultPopup === 'function') {
        showResultPopup('หมดอายุ', 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง');
    }
    setTimeout(() => {
        window.location.href = 'login.html';
    }, 1500);
}
window.handleAuthError = handleAuthError;

/**
 * 💡 ยืนยันการออกจากระบบ
 */
function confirmLogout() {
    sessionStorage.removeItem('authToken');
    localStorage.removeItem('authToken');
    localStorage.removeItem('rememberMedicalUser');
    sessionStorage.removeItem('currentMedicalUser');
    
    console.log('✅ Cleared all tokens and user data');
    
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

/**
 * 💡 UI Helpers
 */
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

/**
 * แสดง Custom Popup สำหรับแจ้งเตือน
 */
function showCustomPopup(title, msg, type = 'success') {
    const popup = document.getElementById('customPopup');
    if (popup) {
        const iconContainer = document.getElementById('popupIcon');
        const iconSymbol = document.getElementById('popupIconSymbol');

        iconContainer.classList.remove('success', 'error', 'warning');
        iconSymbol.className = 'fas'; 

        if (type === 'error') {
            iconContainer.classList.add('error');
            iconSymbol.classList.add('fa-times');
        } else if (type === 'warning') {
            iconContainer.classList.add('warning');
            iconSymbol.classList.add('fa-exclamation-triangle');
        } else {
            iconContainer.classList.add('success');
            iconSymbol.classList.add('fa-check');
        }

        document.getElementById('popupTitle').innerText = title;
        document.getElementById('popupMessage').innerText = msg;
        popup.classList.add('show');
    }
}
window.showCustomPopup = showCustomPopup;

function closeCustomPopup() {
    const popup = document.getElementById('customPopup');
    if (popup) popup.classList.remove('show');
}
window.closeCustomPopup = closeCustomPopup;

/**
 * 💡 HELPER: Toggle User Dropdown Menu
 */
function toggleUserDropdown() {
    const dropdown = document.getElementById('userDropdown');
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}
window.toggleUserDropdown = toggleUserDropdown;

// ปิด dropdown เมื่อคลิกข้างนอก
document.addEventListener('click', function(e) {
    const userMenu = document.querySelector('.user-menu');
    const dropdown = document.getElementById('userDropdown');
    
    if (dropdown && userMenu && !userMenu.contains(e.target)) {
        dropdown.classList.remove('show');
    }
});

/**
 * HELPER: Escape HTML for XSS Protection
 */
function escapeHtml(str) {
    if (typeof str !== 'string') return str;
    return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')
              .replace(/'/g, '&#039;');
}
window.escapeHtml = escapeHtml;
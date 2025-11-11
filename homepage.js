// ***************************************************************
// 1. SHARED getCurrentUser() - ใช้ร่วมกันในทุกไฟล์
// ***************************************************************

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
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.log('❌ Token invalid or expired');
            sessionStorage.removeItem('authToken');
            localStorage.removeItem('authToken');
            return null;
        }

        const data = await response.json();
        console.log('✅ User profile fetched:', data.user);
        
        // เพิ่ม token เข้าไปใน user object เพื่อให้ไฟล์อื่นใช้งานได้
        data.user.token = token;
        
        return data.user;
    } catch (error) {
        console.error('❌ Error fetching user:', error);
        return null;
    }
}
window.getCurrentUser = getCurrentUser;

// Helper function สำหรับจัดการ Auth Error
function handleAuthError() {
    console.warn('⚠️ Authentication failed - redirecting to login');
    sessionStorage.removeItem('authToken');
    localStorage.removeItem('authToken');
    
    if (typeof showResultPopup === 'function') {
        showResultPopup('Session หมดอายุ', 'กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 1500);
    } else {
        window.location.href = 'login.html';
    }
}
window.handleAuthError = handleAuthError;

async function getUserStats() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    
    if (!token) {
        return null;
    }

    try {
        console.log('📊 Fetching user stats...');
        const response = await fetch(`${API_BASE}/api/user/stats`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.log('❌ Failed to fetch stats');
            return null;
        }

        const data = await response.json();
        console.log('✅ User stats fetched:', data.stats);
        return data.stats;
    } catch (error) {
        console.error('❌ Error fetching stats:', error);
        return null;
    }
}
window.getUserStats = getUserStats;

function confirmLogout() {
    sessionStorage.removeItem('authToken');
    localStorage.removeItem('authToken');
    console.log('✅ Logged out successfully');
    
    closeLogoutPopup();
    
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
// 2. UI Update Logic
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
        
        // 🆕 แสดงข้อมูลเพิ่มเติมใน UI
        displayUserInfo(user);
        
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

// 🆕 ฟังก์ชันแสดงข้อมูล User ใน Homepage
async function displayUserInfo(user) {
    // แสดงชื่อหมอในหน้า homepage
    const welcomeSection = document.getElementById('welcomeSection');
    if (welcomeSection) {
        welcomeSection.innerHTML = `
            <h2>สวัสดี, ${user.FirstName} ${user.LastName}</h2>
            <p>โรงพยาบาล: ${user.Hospital || 'ไม่ระบุ'}</p>
        `;
    }
    
    // ดึงและแสดงสถิติการใช้งาน (ถ้ามี)
    const stats = await getUserStats();
    if (stats) {
        const statsSection = document.getElementById('statsSection');
        if (statsSection) {
            statsSection.innerHTML = `
                <div class="stats-grid">
                    <div class="stat-card">
                        <i class="fas fa-calculator"></i>
                        <h3>${stats.totalCalculations || 0}</h3>
                        <p>การคำนวณทั้งหมด</p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-users"></i>
                        <h3>${stats.totalPatients || 0}</h3>
                        <p>ผู้ป่วยทั้งหมด</p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-history"></i>
                        <h3>${stats.recentCalculations || 0}</h3>
                        <p>คำนวณวันนี้</p>
                    </div>
                </div>
            `;
        }
    }
}
window.displayUserInfo = displayUserInfo;

function toggleUserDropdown() {
    const dropdown = document.getElementById('userDropdown');
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}
window.toggleUserDropdown = toggleUserDropdown;

// ปิด dropdown เมื่อคลิกนอกเมนู
document.addEventListener('click', function(e) {
    const userMenu = document.querySelector('.user-menu');
    const dropdown = document.getElementById('userDropdown');
    
    if (dropdown && userMenu && !userMenu.contains(e.target)) {
        dropdown.classList.remove('show');
    }
});

// ***************************************************************
// 3. Popup & Navigation Logic
// ***************************************************************

function showLogoutPopup() {
    const popup = document.getElementById('logoutPopup');
    if (popup) {
        popup.classList.add('show');
    }
}
window.showLogoutPopup = showLogoutPopup;

function closeLogoutPopup() {
    const popup = document.getElementById('logoutPopup');
    if (popup) {
        popup.classList.remove('show');
    }
}
window.closeLogoutPopup = closeLogoutPopup;

function closeResultPopup() {
    const popup = document.getElementById('resultPopup');
    if (popup) {
        popup.classList.remove('show');
    }
}
window.closeResultPopup = closeResultPopup;

function showResultPopup(title, message) {
    const popup = document.getElementById('resultPopup');
    const titleElement = document.getElementById('resultTitle');
    const msgElement = document.getElementById('resultMsg');
    
    if (popup && titleElement && msgElement) {
        titleElement.textContent = title;
        msgElement.textContent = message;
        popup.classList.add('show');
    }
}
window.showResultPopup = showResultPopup;

async function showProfile() {
    const user = await getCurrentUser();
    if (!user) {
        if (typeof showResultPopup === 'function') { 
             showResultPopup('เข้าสู่ระบบ', 'กรุณาเข้าสู่ระบบก่อน');
        } else {
            alert('กรุณาเข้าสู่ระบบก่อน');
        }
        return;
    }
    window.location.href = 'personalinfo.html';
}
window.showProfile = showProfile;

async function requireAuth() {
    const user = await getCurrentUser();
    if (!user) {
        alert('กรุณาเข้าสู่ระบบก่อนใช้งานฟีเจอร์นี้');
        window.location.href = 'login.html';
        return false;
    }
    return true;
}
window.requireAuth = requireAuth;

// ***************************************************************
// 4. Initialization
// ***************************************************************
document.addEventListener('DOMContentLoaded', async function() {
    console.log("📄 Homepage script loaded. Initializing UI...");
    
    // อัพเดท UI สำหรับผู้ใช้ที่ล็อกอิน
    await updateUIForLoggedInUser();
    
    // ตรวจสอบและแสดง Welcome Message
    const user = await getCurrentUser();
    if (user) {
        console.log(`👋 Welcome back, ${user.FirstName}!`);
    }
});
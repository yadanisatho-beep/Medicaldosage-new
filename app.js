// ***************************************************************
// 1. DOM Helper
// ***************************************************************
function getElements() {
  return {
    registerForm: document.getElementById('registerForm'),
    loginForm: document.getElementById('loginForm'),
    registerFormElement: document.getElementById('registerFormElement'),
    loginFormElement: document.getElementById('loginFormElement'),
    formContainer: document.getElementById('authForm'),
    hospitalInput: document.getElementById('registerHospital'), 
    hospitalSuggestions: document.getElementById('hospitalSuggestions'),
    registerBtn: document.getElementById('registerBtn'), 
  };
}

// ***************************************************************
// 2. Switch Forms
// ***************************************************************
function switchForm(formType) {
  const { registerForm, loginForm, registerFormElement, loginFormElement } = getElements();

  if (!registerForm || !loginForm || !registerFormElement || !loginFormElement) {
    console.error("❌ ไม่พบ element ของฟอร์มใน DOM");
    return;
  }

  if (formType === 'register') {
    registerForm.classList.add('active');
    loginForm.classList.remove('active');
    loginFormElement.reset();
  } else if (formType === 'login') {
    loginForm.classList.add('active');
    registerForm.classList.remove('active');
    registerFormElement.reset();
  }
}

function showRegisterForm() { switchForm('register'); }
function showLoginForm() { switchForm('login'); }

// ***************************************************************
// 3. Validation
// ***************************************************************
// ✅ EXPOSE TO WINDOW FOR DEBUGGING
window.validLicenses = []; 

async function loadValidLicenses() {
    try {
        const response = await fetch(`${API_BASE}/api/licenses`);
        const data = await response.json();
        if (data.success) {
            window.validLicenses = data.licenses.map(item => item.licenseNumber) || [];
            console.log(`✅ โหลดทะเบียนแพทย์สำเร็จ: ${window.validLicenses.length} รายการ`);
        } else {
            console.error('❌ ไม่สามารถโหลดทะเบียนแพทย์ได้');
        }
    } catch (error) {
        console.error('❌ Error loading licenses:', error);
    }
}

function validateForm() {
    const { registerBtn, registerFormElement } = getElements();

    if (!registerBtn || !registerFormElement) return;

    const inputs = registerFormElement.querySelectorAll('input[required]');
    let allFilled = true;

    inputs.forEach(input => {
        if (!input.value.trim()) {
            allFilled = false;
        }
    });
    
    if (!registerFormElement.dataset.licenseValid) {
        registerFormElement.dataset.licenseValid = 'false';
    }
    
    const isLicenseValid = registerFormElement.dataset.licenseValid === 'true'; 
    const registerPassword = document.getElementById('registerPassword')?.value || '';
    const confirmPassword = document.getElementById('confirmPassword')?.value || '';
    
    const passwordsMatch = registerPassword === confirmPassword;
    const passwordLengthValid = registerPassword.length >= 6;

    const formValid = allFilled && isLicenseValid && passwordsMatch && passwordLengthValid;

    registerBtn.disabled = !formValid;
}

function validateLicenseNumber() {
    const licenseInput = document.getElementById('licenseNumber');
    const registerFormElement = document.getElementById('registerFormElement');
    
    if (!licenseInput || !registerFormElement) return;
    
    const license = licenseInput.value.trim().toUpperCase();
    licenseInput.value = license;
    
    const isValid = window.validLicenses.includes(license);
    const errorMsg = document.getElementById('licenseError');
    const messageDiv = document.getElementById('licenseNumber-message');

    if (license === '') {
        licenseInput.classList.remove('is-invalid', 'is-valid');
        if (errorMsg) errorMsg.textContent = '';
        if (messageDiv) messageDiv.textContent = '';
        registerFormElement.dataset.licenseValid = 'false'; 
        validateForm(); 
        return false; 
    }

    if (isValid) {
        licenseInput.classList.add('is-valid');
        licenseInput.classList.remove('is-invalid');
        if (errorMsg) errorMsg.textContent = '';
        if (messageDiv) {
            messageDiv.textContent = '✓ เลขใบอนุญาตถูกต้อง';
            messageDiv.style.color = '#27ae60';
            messageDiv.style.fontWeight = '600';
        }
        registerFormElement.dataset.licenseValid = 'true'; 
    } else {
        licenseInput.classList.add('is-invalid');
        licenseInput.classList.remove('is-valid');
        if (errorMsg) errorMsg.textContent = 'ไม่พบเลขใบอนุญาตนี้ในระบบ';
        if (messageDiv) {
            messageDiv.textContent = '✗ เลขใบอนุญาตไม่ถูกต้อง';
            messageDiv.style.color = '#e74c3c';
            messageDiv.style.fontWeight = '600';
        }
        registerFormElement.dataset.licenseValid = 'false'; 
    }
    
    validateForm(); 
    return isValid;
}

function setupLicenseValidation() {
    const licenseInput = document.getElementById('licenseNumber');
    if (licenseInput) {
        licenseInput.addEventListener('input', validateLicenseNumber);
        licenseInput.addEventListener('blur', validateLicenseNumber);
    }
}

// ***************************************************************
// 4. Hospital Autocomplete
// ***************************************************************
// ✅ EXPOSE TO WINDOW FOR DEBUGGING
window.hospitalData = [];
window.isHospitalDataLoaded = false;

async function loadHospitalData() {
    try {
        console.log("🔄 Loading hospital data from API...");
        const response = await fetch(`${API_BASE}/api/hospitals`); 
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        console.log("📦 API Response:", data);
        
        if (data.success && Array.isArray(data.hospitals)) {
            window.hospitalData = data.hospitals;
            window.isHospitalDataLoaded = true;
            console.log(`✅ โหลดข้อมูลโรงพยาบาลสำเร็จ: ${window.hospitalData.length} แห่ง`);
            console.log("📋 Sample data:", window.hospitalData.slice(0, 3));
        } else {
            console.error('❌ API ไม่ส่งข้อมูลที่ถูกต้อง:', data);
            window.isHospitalDataLoaded = false;
        }
    } catch (error) {
        console.error('❌ Error loading hospitals:', error);
        window.isHospitalDataLoaded = false;
        
        if (typeof showCustomPopup === 'function') {
            showCustomPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลโรงพยาบาลได้ กรุณาลองอีกครั้ง', 'error');
        }
    }
}

function searchHospitals(query) {
    const { hospitalInput, hospitalSuggestions } = getElements();
    
    console.log("🔍 Search called with:", query);
    console.log("📊 Hospital data status:", {
        loaded: window.isHospitalDataLoaded,
        count: window.hospitalData.length
    });
    
    if (!hospitalInput || !hospitalSuggestions) {
        console.error("❌ Elements not found!");
        return;
    }
    
    hospitalSuggestions.innerHTML = '';
    
    if (query.length < 2) {
        hospitalSuggestions.style.display = 'none';
        return;
    }
    
    if (!window.isHospitalDataLoaded || window.hospitalData.length === 0) {
        const div = document.createElement('div');
        div.className = 'hospital-item';
        div.style.color = '#e67e22';
        div.style.fontWeight = 'bold';
        div.innerHTML = `
            <div class="hospital-name">
                <i class="fas fa-spinner fa-spin"></i> กำลังโหลดข้อมูล...
            </div>
        `;
        hospitalSuggestions.appendChild(div);
        hospitalSuggestions.style.display = 'block';
        
        loadHospitalData();
        return;
    }
    
    const filtered = window.hospitalData.filter(h => 
        h.name && h.name.toLowerCase().includes(query.toLowerCase())
    ).slice(0, 10);

    console.log(`✅ Found ${filtered.length} matches for "${query}"`);

    if (filtered.length > 0) {
        filtered.forEach(h => {
            const div = document.createElement('div');
            div.className = 'hospital-item';
            div.innerHTML = `
                <div class="hospital-name">${h.name || 'ไม่ระบุชื่อ'}</div>
                <div class="hospital-info">
                    <span class="hospital-province">
                        <i class="fas fa-map-marker-alt"></i> ${h.province || 'ไม่ระบุจังหวัด'}
                    </span>
                    <span class="hospital-type">${h.type || 'โรงพยาบาล'}</span>
                </div>
            `;
            div.addEventListener('click', () => {
                console.log("✅ Selected:", h.name);
                hospitalInput.value = h.name;
                hospitalSuggestions.style.display = 'none';
                validateForm();
            });
            hospitalSuggestions.appendChild(div);
        });
        hospitalSuggestions.style.display = 'block';
        console.log("✅ Dropdown displayed");
    } else {
        const div = document.createElement('div');
        div.className = 'hospital-item';
        div.style.color = '#7f8c8d';
        div.style.fontStyle = 'italic';
        div.innerHTML = `<div class="hospital-name">ไม่พบโรงพยาบาลที่ค้นหา</div>`;
        hospitalSuggestions.appendChild(div);
        hospitalSuggestions.style.display = 'block';
    }
}

function clearHospitalSuggestions() {
    const { hospitalSuggestions } = getElements();
    if (hospitalSuggestions) hospitalSuggestions.style.display = 'none';
}

// ***************************************************************
// 5. User State Management
// ***************************************************************
function saveAuthData(token, user, rememberMe) {
    sessionStorage.setItem('authToken', token);
    sessionStorage.setItem('currentMedicalUser', JSON.stringify(user));
    
    if (rememberMe) {
        localStorage.setItem('authToken', token);
        localStorage.setItem('rememberMedicalUser', JSON.stringify(user));
    } else {
        localStorage.removeItem('authToken');
        localStorage.removeItem('rememberMedicalUser');
    }
}

// ***************************************************************
// 6. Login & Register Handlers
// ***************************************************************
async function handleRegister(e) {
  e.preventDefault();
  const registerForm = e.target;
  const formData = new FormData(registerForm);
  const data = Object.fromEntries(formData.entries());

  if (data.password !== data.confirmPassword) {
    showCustomPopup('ข้อผิดพลาด', 'รหัสผ่านไม่ตรงกัน', 'error');
    return;
  }

  if (data.licenseNumber && !validateLicenseNumber()) {
    showCustomPopup('ข้อผิดพลาด', 'เลขใบอนุญาตไม่ถูกต้อง', 'error');
    return;
  }

  delete data.confirmPassword;
  if (data.licenseNumber) data.licenseNumber = data.licenseNumber.toUpperCase();

  if (data.hospitalName) {
    data.hospital = data.hospitalName;
    delete data.hospitalName;
  }

  showWarningPopup('กำลังดำเนินการ', 'กำลังลงทะเบียน...');

  try {
    const response = await fetch(`${API_BASE}/api/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    let result = {};
    try {
      result = await response.json();
    } catch {
      console.error('⚠️ Server did not return JSON.');
      showCustomPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (500)', 'error');
      return;
    }

    closeWarningPopup();

    if (result.success) {
      showCustomPopup('สำเร็จ', 'ลงทะเบียนสำเร็จแล้ว! กรุณาเข้าสู่ระบบ', 'success');
      showLoginForm();
    } else {
      let errorMessage = result.error || 'ลงทะเบียนไม่สำเร็จ';
      if (response.status === 409) {
        switch (result.code) {
          case 'DUPLICATE_USERNAME':
            errorMessage = 'ชื่อผู้ใช้นี้ถูกใช้งานแล้ว กรุณาเลือกชื่ออื่น';
            break;
          case 'DUPLICATE_LICENSE':
            errorMessage = 'เลขใบอนุญาตนี้ถูกลงทะเบียนแล้ว';
            break;
          case 'DUPLICATE_EMAIL':
            errorMessage = 'อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่นหรือเข้าสู่ระบบ';
            break;
          default:
            errorMessage = 'ข้อมูลซ้ำในระบบ กรุณาตรวจสอบข้อมูลของคุณ';
        }
      }

      showCustomPopup('ข้อผิดพลาด', errorMessage, 'error');
    }
  } catch (error) {
    closeWarningPopup();
    console.error('❌ Register Error:', error);
    showCustomPopup('ข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', 'error');
  }
}

async function handleLogin(e) {
  e.preventDefault();
  const form = e.target;
  const username = form.elements.username.value.trim();
  const password = form.elements.password.value;
  const rememberMeElement = form.elements.rememberMe;
  const rememberMe = rememberMeElement ? rememberMeElement.checked : false;

  const data = { username, password };
  
  showWarningPopup('กำลังดำเนินการ', 'กำลังเข้าสู่ระบบ...');

  try {
    const response = await fetch(`${API_BASE}/api/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    let result = {};
    try {
      result = await response.json();
    } catch {
      console.error('⚠️ Server did not return JSON.');
      showCustomPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (500)', 'error');
      return;
    }

    if (result.success) {
      saveAuthData(result.token, result.user, rememberMe);

      const firstName = result.user?.FirstName || '';
    
      showCustomPopup('สำเร็จ', `เข้าสู่ระบบสำเร็จ! ยินดีต้อนรับคุณหมอ${firstName}`, 'success');
    
      setTimeout(() => {
        window.location.href = 'homepage.html';
      }, 1500);
      
    } else {
      let msg = result.error || 'เข้าสู่ระบบไม่สำเร็จ';

      switch (result.code) {
        case 'INVALID_CREDENTIALS':
          msg = 'ไม่รู้จักชื่อผู้ใช้นี้หรือรหัสผ่านไม่ถูกต้อง กรุณาตรวจสอบข้อมูลของคุณ';
          break;
        case 'MISSING_FIELDS':
          msg = 'กรุณากรอกชื่อผู้ใช้และรหัสผ่านให้ครบถ้วน';
          break;
        default:
          msg = 'เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบข้อมูลของคุณ';
      }

      showCustomPopup('เข้าสู่ระบบไม่สำเร็จ', msg, 'error');
    }
  } catch (error) {
    closeWarningPopup();
    console.error('❌ Login Error:', error);
    showCustomPopup('ข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', 'error');
  }
}

// ***************************************************************
// 7. Initialization
// ***************************************************************
window.addEventListener("DOMContentLoaded", async () => {
  console.log("🔄 DOM loaded, initializing...");

  console.log("📡 Loading essential data...");
  await Promise.all([
    loadValidLicenses(),
    loadHospitalData()
  ]);
  console.log("✅ Data loading completed");

  const isLoginPage = window.location.pathname.endsWith('login.html');
  
  if (isLoginPage) {
      console.log("✅ Running Login/Register Initialization...");
      
      const { registerFormElement, loginFormElement, hospitalInput } = getElements();

      if (registerFormElement) {
        registerFormElement.dataset.licenseValid = 'false';
        
        registerFormElement.addEventListener("submit", handleRegister); 
        const switchToLoginBtn = document.getElementById("switch-to-login");
        if (switchToLoginBtn) {
          switchToLoginBtn.addEventListener("click", showLoginForm);
        }
        registerFormElement.addEventListener('input', validateForm);
        
        validateForm(); 
      }
      
      if (loginFormElement) {
        loginFormElement.addEventListener("submit", handleLogin);
        const switchToRegisterBtn = document.getElementById("switch-to-register");
        if (switchToRegisterBtn) {
          switchToRegisterBtn.addEventListener("click", showRegisterForm);
        }
      }

      setupLicenseValidation();
      
      if (hospitalInput) {
        console.log("✅ Setting up hospital autocomplete...");
        
        let searchTimeout;
        hospitalInput.addEventListener('input', (e) => {
          clearTimeout(searchTimeout);
          searchTimeout = setTimeout(() => {
            console.log("🔍 Searching for:", e.target.value);
            searchHospitals(e.target.value);
          }, 300); 
        });
        
        document.addEventListener('click', (e) => {
          const { hospitalInput, hospitalSuggestions } = getElements();
          if (hospitalInput && hospitalSuggestions && 
              !hospitalInput.contains(e.target) && 
              !hospitalSuggestions.contains(e.target)) {
            clearHospitalSuggestions();
          }
        });
      } else {
        console.error("❌ Hospital input not found!");
      }

  } else {
    console.log("⏭ Skipping Login/Register initialization as this is not login.html");
  }
});
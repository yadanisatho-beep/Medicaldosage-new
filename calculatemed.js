// ***************************************************************
// 1. Authentication & Global State
// ***************************************************************
let currentUser = null; 
let allPatients = []; 
let allMedicines = []; 
let selectedPatient = null; 
let selectedMedicine = null; 
let dosageResult = null; 
const ADJUSTMENT_THRESHOLD = 0.20;

// ***************************************************************
// 2. State/UI Reset
// ***************************************************************
function resetCalculationState() {
    selectedMedicine = null;
    dosageResult = null;
    
    document.getElementById('selectedMedicineName').textContent = 'N/A';
    document.getElementById('selectedMedicineType').textContent = 'N/A';
    
    const actualDosageInput = document.getElementById('actualDosage');
    const actualFrequencySelect = document.getElementById('actualFrequencyText');
    const overrideReasonInput = document.getElementById('overrideReason');
    const medicineInput = document.getElementById('medicineInput');

    if (actualDosageInput) actualDosageInput.value = '';
    if (actualFrequencySelect) actualFrequencySelect.value = ''; 
    if (overrideReasonInput) overrideReasonInput.value = '';
    if (medicineInput) medicineInput.value = '';

    const resultSection = document.getElementById('dosageCalculationResult');
    if (resultSection) {
        resultSection.style.display = 'none';
        const oldWarnings = resultSection.querySelector('#dynamicWarningMessages');
        if (oldWarnings) oldWarnings.innerHTML = '';
        const guidelineTextEl = resultSection.querySelector('#displayGuidelineText');
        if (guidelineTextEl) guidelineTextEl.innerHTML = '<strong>แนวทาง:</strong> N/A';
    }

    const adjustmentReasonGroup = document.getElementById('adjustmentReasonGroup');
    const reasonWarning = document.getElementById('reasonWarning');
    if (adjustmentReasonGroup) adjustmentReasonGroup.style.display = 'none';
    if (reasonWarning) reasonWarning.style.display = 'none';

    const recommendedMinDoseEl = document.getElementById('recommendedMinDose');
    const recommendedMaxDoseEl = document.getElementById('recommendedMaxDose');
    const recommendedFrequencyTextEl = document.getElementById('recommendedFrequencyText');
    const recommendedFrequencyIntEl = document.getElementById('recommendedFrequencyInt');
    
    if (recommendedMinDoseEl) recommendedMinDoseEl.value = '';
    if (recommendedMaxDoseEl) recommendedMaxDoseEl.value = '';
    if (recommendedFrequencyTextEl) recommendedFrequencyTextEl.value = '';
    if (recommendedFrequencyIntEl) recommendedFrequencyIntEl.value = '';

    if (document.getElementById('input_crcl')) document.getElementById('input_crcl').value = '';
    if (document.getElementById('input_childpugh')) document.getElementById('input_childpugh').value = '';
    if (document.getElementById('input_adjbw')) document.getElementById('input_adjbw').value = '';
    if (document.getElementById('input_bsa')) document.getElementById('input_bsa').value = '';
    
    const calcBtn = document.getElementById('triggerCalculationBtn');
    const proceedBtn = document.getElementById('proceedToResultBtn');
    if (calcBtn) calcBtn.style.display = 'block';
    if (proceedBtn) proceedBtn.style.display = 'none';
    
    const diseaseFactorsContainer = document.getElementById('diseaseFactors');
    if (diseaseFactorsContainer) diseaseFactorsContainer.style.display = 'none';

    console.log('✅ Calculation state and UI successfully reset.');
}
window.resetCalculationState = resetCalculationState;

// ***************************************************************
// 3. ✅ NEW: Data Loading - โหลดเฉพาะยาที่กรอกปัจจัยแล้ว
// ***************************************************************
async function loadMedicinesFromAPI() {
    const user = await getCurrentUser(); 
    if (!user || !user.token) {
        console.warn('⚠️ No user token - cannot load medicines');
        return;
    }

    try {
        console.log('🔄 Loading configured medicines from API...');
        
        const response = await fetch(`${API_BASE}/api/medicines/configured`, {
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.status === 401) { 
            handleAuthError(); 
            return; 
        }
        
        if (!response.ok) {
            throw new Error('Failed to fetch configured medicines');
        }

        const data = await response.json();
        
        if (data.success) {
            allMedicines = data.medicines || [];
            console.log('✅ โหลดยาที่กรอกปัจจัยแล้ว:', allMedicines.length, 'รายการ');
            console.log('📊 Medicine data:', allMedicines);
            
            if (allMedicines.length === 0) {
                console.warn('⚠️ ยังไม่มียาที่กรอกปัจจัยการคำนวณ กรุณาไปกรอกที่หน้า "ข้อมูลยา" ก่อน');
            }
        }
    } catch (error) {
        console.error('❌ Error loading configured medicines:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดรายชื่อยาได้', 'error');
    }
}
window.loadMedicinesFromAPI = loadMedicinesFromAPI;

// ***************************************************************
// 4. ✅ NEW: Medicine Selection Modal
// ***************************************************************
function openMedicineModal() {
    console.log('🔍 Opening medicine modal...');
    console.log('📊 Available medicines:', allMedicines.length);
    
    const modal = document.getElementById('medicineModal');
    if (!modal) {
        console.error('❌ medicineModal element not found!');
        showResultPopup('ข้อผิดพลาด', 'ไม่พบ Modal สำหรับเลือกยา', 'error');
        return;
    }
    
    modal.style.display = 'flex';
    displayMedicineList(allMedicines);
}
window.openMedicineModal = openMedicineModal;

function closeMedicineModal() {
    const modal = document.getElementById('medicineModal');
    if (modal) {
        modal.style.display = 'none';
    }
}
window.closeMedicineModal = closeMedicineModal;

function displayMedicineList(medicines) {
    const list = document.getElementById('medicineList');
    if (!list) {
        console.error('❌ medicineList element not found!');
        return;
    }

    list.innerHTML = '';
    
    console.log('📋 Displaying medicines:', medicines.length);
    
    if (medicines.length === 0) {
        list.innerHTML = `
            <p class="no-data-message">
                <i class="fas fa-pills"></i><br>
                ยังไม่มียาที่กรอกปัจจัยการคำนวณ<br>
                <small>กรุณาไป<a href="medicine.html" style="color: #39AC95;">กรอกข้อมูลยา</a>ก่อน</small>
            </p>
        `;
        return;
    }

    medicines.forEach(med => {
        const item = document.createElement('div');
        item.className = 'medicine-list-item';
        
        const medicineName = med.medicine_name || 'ไม่ระบุชื่อ';
        const medicineType = med.medicine_type || '-';
        const eliminationRoute = med.elimination_route || '-';
        const standardDose = med.standard_dose_per_kg || '-';
        
        item.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: start;">
                <div style="flex: 1;">
                    <h5 style="margin: 0 0 5px 0; color: #2c3e50;">
                        <i class="fas fa-pills" style="color: #39AC95; margin-right: 8px;"></i>
                        ${medicineName}
                    </h5>
                    <div style="font-size: 13px; color: #7f8c8d; margin-bottom: 8px;">
                        <i class="fas fa-capsules"></i> ${medicineType}
                    </div>
                    <div style="display: flex; gap: 15px; font-size: 12px; color: #34495e;">
                        <span><strong>ขนาดมาตรฐาน:</strong> ${standardDose} mg/kg</span>
                        <span><strong>เส้นทางขับ:</strong> ${eliminationRoute}</span>
                    </div>
                </div>
                <span style="background: #27ae60; color: white; padding: 4px 10px; border-radius: 12px; font-size: 11px; white-space: nowrap;">
                    <i class="fas fa-check-circle"></i> พร้อมใช้งาน
                </span>
            </div>
        `;
        
        item.onclick = async () => {
            console.log('✅ Selected medicine:', medicineName);
            await selectMedicineFromModal(med);
            closeMedicineModal();
        };
        
        list.appendChild(item);
    });
}

async function selectMedicineFromModal(medicine) {
    try {
        // โหลดข้อมูลเต็มรูปแบบจาก backend
        const user = await getCurrentUser();
        if (!user) return;
        
        const response = await fetch(`${API_BASE}/api/user-medicine-factors/${medicine.drug_id}`, {
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            }
        });
        
        const data = await response.json();
        
        if (data.success && data.medicine) {
            selectedMedicine = data.medicine;
            
            // รีเซ็ต UI
            const resultSection = document.getElementById('dosageCalculationResult');
            if (resultSection) resultSection.style.display = 'none';
            
            // ✅ ประกาศตัวแปรก่อนใช้งาน
            const medicineName = selectedMedicine.medicine_name || '-';
            const medicineType = selectedMedicine.medicine_type || '-';
            
            // ✅ แสดงชื่อยาใน input field
            const medicineInput = document.getElementById('medicineInput');
            if (medicineInput) {
                medicineInput.value = medicineName;
            }
            
            // แสดงข้อมูลในการ์ด
            document.getElementById('selectedMedicineName').textContent = medicineName;
            document.getElementById('selectedMedicineType').textContent = medicineType;
            
            // ✅ แสดง/ซ่อนช่องกรอกตามเส้นทางการขับยา
            updateDiseaseSpecificInputs();
            
            console.log('✅ เลือกยา:', medicineName);
            console.log('📊 ปัจจัยการคำนวณ:', {
                standardDosePerKg: selectedMedicine.standard_dose_per_kg,
                eliminationRoute: selectedMedicine.elimination_route,
                requiresRenalAdjustment: selectedMedicine.requires_renal_adjustment,
                requiresHepaticAdjustment: selectedMedicine.requires_hepatic_adjustment
            });
        } else {
            showResultPopup('ข้อผิดพลาด', 'ไม่พบข้อมูลปัจจัยสำหรับยานี้', 'warning');
        }
    } catch (error) {
        console.error('❌ Error selecting medicine:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลยาได้', 'error');
    }
}
window.selectMedicineFromModal = selectMedicineFromModal;

// ***************************************************************
// 5. ✅ UPDATED: Dynamic Disease-Specific Inputs
// ***************************************************************
function updateDiseaseSpecificInputs() {
    if (!selectedMedicine) return;
    
    const eliminationRoute = selectedMedicine.elimination_route;
    const requiresRenal = selectedMedicine.requires_renal_adjustment;
    const requiresHepatic = selectedMedicine.requires_hepatic_adjustment;
    
    const crclGroup = document.getElementById('factor-crcl');
    const childPughGroup = document.getElementById('factor-childpugh');
    const diseaseFactorsContainer = document.getElementById('diseaseFactors');
    const diseaseWarningBox = document.getElementById('diseaseWarningBox');
    
    // ซ่อนทั้งหมดก่อน
    [crclGroup, childPughGroup].forEach(el => {
        if (el) el.style.display = 'none';
    });
    
    let hasFactors = false;
    let warningHTML = '';
    
    if ((eliminationRoute === 'Renal' || eliminationRoute === 'Both') && requiresRenal) {
        if (crclGroup) {
            crclGroup.style.display = 'block';
            hasFactors = true;
        }
        warningHTML += `
            <div class="disease-warning" style="margin-bottom: 10px;">
                <i class="fas fa-exclamation-triangle" style="color: #e74c3c;"></i>
                <strong>ยานี้ต้องปรับขนาดตามการทำงานของไต</strong>
                <ul style="margin: 5px 0 0 20px; font-size: 13px;">
                    <li>กรุณากรอกค่า CrCl (Creatinine Clearance)</li>
                    <li>ระบบจะปรับขนาดยาอัตโนมัติตามระดับการทำงานของไต</li>
                </ul>
            </div>
        `;
    }
    
    // ✅ แสดงช่อง Child-Pugh หากยาต้องปรับตามตับ
    if ((eliminationRoute === 'Hepatic' || eliminationRoute === 'Both') && requiresHepatic) {
        if (childPughGroup) {
            childPughGroup.style.display = 'block';
            hasFactors = true;
        }
        warningHTML += `
            <div class="disease-warning">
                <i class="fas fa-exclamation-triangle" style="color: #e74c3c;"></i>
                <strong>ยานี้ต้องปรับขนาดตามการทำงานของตับ</strong>
                <ul style="margin: 5px 0 0 20px; font-size: 13px;">
                    <li>กรุณาเลือก Child-Pugh Class (A/B/C)</li>
                    <li>ระบบจะปรับขนาดยาตาม Child-Pugh Class</li>
                </ul>
            </div>
        `;
    }
    
    if (diseaseFactorsContainer) {
        diseaseFactorsContainer.style.display = hasFactors ? 'block' : 'none';
    }
    
    if (diseaseWarningBox) {
        if (warningHTML) {
            diseaseWarningBox.innerHTML = warningHTML;
            diseaseWarningBox.style.display = 'block';
        } else {
            diseaseWarningBox.style.display = 'none';
        }
    }
}
window.updateDiseaseSpecificInputs = updateDiseaseSpecificInputs;

// ***************************************************************
//  NEW: Child-Pugh Class Selection Handler
// ***************************************************************
function selectChildPughClass(classType) {
    console.log('Selected Child-Pugh Class:', classType);
    
    // Update hidden input value
    const hiddenInput = document.getElementById('input_childpugh');
    if (hiddenInput) {
        hiddenInput.value = classType;
    }
    
    // Update visual selection state
    const allOptions = document.querySelectorAll('.childpugh-option');
    allOptions.forEach(option => option.classList.remove('selected'));
    
    // Add selected class to clicked option
    const selectedOption = document.querySelector(`.childpugh-option.class-${classType.toLowerCase()}`);
    if (selectedOption) {
        selectedOption.classList.add('selected');
    }
    
    console.log(`Child-Pugh Class set to: ${classType}`);
}
window.selectChildPughClass = selectChildPughClass;

// ***************************************************************
// 6. ✅ UPDATED: Main Calculation Logic
// ***************************************************************
async function triggerDosageCalculation(force = false) {
    const user = await getCurrentUser(); 
    
    if (!user || !selectedPatient || !selectedMedicine) {
        showResultPopup('ข้อมูลไม่ครบถ้วน', 'กรุณาเลือกผู้ป่วยและยา', 'warning');
        return;
    }

    // ✅ IMPROVED: Flexible dose validation - accept EITHER mg/kg OR mg/m²
    const hasDosePerKg = selectedMedicine.standard_dose_per_kg && 
                         selectedMedicine.standard_dose_per_kg > 0;
    const hasDosePerM2 = selectedMedicine.standard_dose_per_m2 && 
                         selectedMedicine.standard_dose_per_m2 > 0;
    
    if (!hasDosePerKg && !hasDosePerM2) {
        showResultPopup(
            'ข้อมูลยาไม่ครบถ้วน', 
            'ยานี้ต้องมีอย่างน้อยหนึ่งใน: ขนาดยาต่อน้ำหนัก (mg/kg) หรือขนาดยาต่อพื้นที่ผิวกาย (mg/m²)', 
            'warning'
        );
        return;
    }

    if (!selectedMedicine.medicine_name) {
        showResultPopup(
            'ข้อมูลยาไม่ครบถ้วน', 
            'ไม่พบชื่อยา กรุณาตรวจสอบข้อมูลยาอีกครั้ง', 
            'warning'
        );
        return;
    }

    // ✅ IMPROVED: Validate standardFrequencyInt and auto-calculate if missing
    if (!selectedMedicine.standard_frequency_int || selectedMedicine.standard_frequency_int === 0) {
        // Auto-calculate from standardFrequency text
        const frequencyMap = {
            'OD': 1, 'QD': 1,
            'BID': 2,
            'TID': 3,
            'QID': 4,
            'Q6H': 4,
            'Q8H': 3,
            'Q12H': 2,
            'PRN': 0
        };
        
        const freqText = (selectedMedicine.standard_frequency || '').toUpperCase();
        selectedMedicine.standard_frequency_int = frequencyMap[freqText] || 1; // Default to 1 if unknown
        
        console.log(`⚠️ Auto-calculated frequency_int: ${freqText} → ${selectedMedicine.standard_frequency_int}`);
    }

    // Validate patient data
    if (!selectedPatient.Age || !selectedPatient.Weight) {
        showResultPopup(
            'ข้อมูลผู้ป่วยไม่ครบถ้วน',
            'กรุณาตรวจสอบว่าผู้ป่วยมีข้อมูลอายุและน้ำหนักครบถ้วน',
            'warning'
        );
        return;
    }

    // ✅ Continue with existing validation for renal/hepatic factors...
    const eliminationRoute = selectedMedicine.elimination_route;
    const requiresRenal = selectedMedicine.requires_renal_adjustment;
    const requiresHepatic = selectedMedicine.requires_hepatic_adjustment;
    
    let missingFactors = [];
    
    if ((eliminationRoute === 'Renal' || eliminationRoute === 'Both') && requiresRenal) {
        const crcl = document.getElementById('input_crcl')?.value;
        if (!crcl || crcl.trim() === '') {
            missingFactors.push('CrCl (Creatinine Clearance) - ยานี้ขับทางไตและต้องปรับขนาด');
        }
    }
    
    if ((eliminationRoute === 'Hepatic' || eliminationRoute === 'Both') && requiresHepatic) {
        const childPughClass = document.getElementById('input_childpugh')?.value;
        if (!childPughClass || childPughClass.trim() === '') {
            missingFactors.push('Child-Pugh Class (A/B/C) - ยานี้เมแทบอไลซ์ที่ตับและต้องปรับขนาด');
        }
    }

    if (missingFactors.length > 0) {
        const factorList = missingFactors.map(f => `• ${f}`).join('\n');
        showResultPopup(
            'ข้อมูลไม่ครบถ้วน', 
            `ยานี้ต้องการข้อมูลเพิ่มเติมในการคำนวณ:\n\n${factorList}`, 
            'warning'
        );
        return;
    }

    const calculationPayload = {
    patientAge: parseInt(selectedPatient.Age),
    patientWeight: parseFloat(selectedPatient.Weight),
    patientDisease: selectedPatient.Disease, 
    medicineName: selectedMedicine.medicine_name,
    
    standardDosePerKg: selectedMedicine.standard_dose_per_kg || null,
    standardDosePerM2: selectedMedicine.standard_dose_per_m2 || null,
    eliminationRoute: selectedMedicine.elimination_route,
    halfLifeHours: selectedMedicine.half_life_hours,
    standardFrequency: selectedMedicine.standard_frequency,
    standardFrequencyInt: selectedMedicine.standard_frequency_int,
    maxDosePerUnit: selectedMedicine.max_dose_per_unit,
    maxDailyDose: selectedMedicine.max_daily_dose,
    
    requiresRenalAdjustment: selectedMedicine.requires_renal_adjustment,
    crclThresholdMild: selectedMedicine.crcl_threshold_mild,
    crclThresholdModerate: selectedMedicine.crcl_threshold_moderate,
    crclThresholdSevere: selectedMedicine.crcl_threshold_severe,
    renalAdjustmentMild: selectedMedicine.renal_adjustment_mild,
    renalAdjustmentModerate: selectedMedicine.renal_adjustment_moderate,
    renalAdjustmentSevere: selectedMedicine.renal_adjustment_severe,
    
    requiresHepaticAdjustment: selectedMedicine.requires_hepatic_adjustment,
    childPughAFactor: selectedMedicine.child_pugh_a_factor,
    childPughBFactor: selectedMedicine.child_pugh_b_factor,
    childPughCFactor: selectedMedicine.child_pugh_c_factor,
    
    crcl: document.getElementById('input_crcl')?.value ? parseFloat(document.getElementById('input_crcl').value) : null,
    childPughClass: document.getElementById('input_childpugh')?.value || null,
    adjustedBodyWeight: document.getElementById('input_adjbw')?.value ? parseFloat(document.getElementById('input_adjbw').value) : null,
    bodySurfaceArea: document.getElementById('input_bsa')?.value ? parseFloat(document.getElementById('input_bsa').value) : null,
    
    requiresAgeAdjustment: selectedMedicine.requires_age_adjustment !== false,
    neonateDoseFactor: selectedMedicine.neonate_dose_factor || null,
    pediatricDoseFactor: selectedMedicine.pediatric_dose_factor || null,
    adolescentDoseFactor: selectedMedicine.adolescent_dose_factor || null,
    adultDoseFactor: selectedMedicine.adult_dose_factor || 1.0,
    elderlyDoseFactor: selectedMedicine.elderly_dose_factor || null,
    pediatricMaxDose: selectedMedicine.pediatric_max_dose || null,
    pediatricMaxDailyDose: selectedMedicine.pediatric_max_daily_dose || null,
};
    
    console.log('📤 Calculation Payload:', calculationPayload);
    
    try {
        const response = await fetch(`${API_BASE}/api/calculate-dosage-advanced`, { 
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(calculationPayload)
        });

        const contentType = response.headers.get('content-type');
        let data;
        
        if (contentType && contentType.includes('application/json')) {
            data = await response.json();
        } else {
            throw new Error('Server Error: API ไม่ตอบกลับด้วยข้อมูลที่ถูกต้อง');
        }
        
        if (response.status === 401) { 
            handleAuthError(); 
            return; 
        }

        if (!response.ok) {
            throw new Error(data.message || 'การคำนวณขนาดยาล้มเหลว');
        }

        dosageResult = data;
        updateResultUI(data); 
        
        console.log('✅ การคำนวณสำเร็จ:', data);
        
    } catch (error) {
        console.error('❌ Error during calculation:', error);
        showResultPopup('ข้อผิดพลาดในการคำนวณ', error.message || 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ', 'error');
    }
}
window.triggerDosageCalculation = triggerDosageCalculation;

// ***************************************************************
// 7. Update Result UI
// ***************************************************************
function updateResultUI(data) {
    const displayGuidelineDoseEl = document.getElementById('displayGuidelineDose');
    const displayGuidelineFreqEl = document.getElementById('displayGuidelineFreq');
    const displayGuidelineTextEl = document.getElementById('displayGuidelineText'); 
    const warningContainer = document.getElementById('dynamicWarningMessages');
    const resultSection = document.getElementById('dosageCalculationResult');

    
    if (!data || !resultSection) return;

    const minDose = data.recommended_min_dose;
    const maxDose = data.recommended_max_dose;
    const freqText = data.recommended_frequency_text;
    const guidelineText = data.guideline_text; 
    const warningMessages = data.warning_messages || []; 
    const unit = data.unit || 'mg';
    
    const intervalSuggestion = data.interval_extension_suggestion;
    

    // แสดงขนาดยาที่แนะนำ
    if (displayGuidelineDoseEl) {
        displayGuidelineDoseEl.textContent = `${minDose || '-'} - ${maxDose || '-'} ${unit}`;
    }
    if (displayGuidelineFreqEl) {
        displayGuidelineFreqEl.textContent = freqText || '-';
    }

    // แสดงคำแนะนำหลัก
    if (displayGuidelineTextEl) { 
        let guidelineHTML = `<strong>แนวทาง (Dose Reduction):</strong> ${guidelineText || 'N/A'}`;
        
        // ✅ เพิ่มการแสดง Interval Extension ถ้ามี
        if (intervalSuggestion) {
            guidelineHTML += `
                <div class="interval-extension-box" style="
                    margin-top: 15px; 
                    padding: 12px; 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border-left: 4px solid #5a67d8;
                    border-radius: 8px;
                    box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
                ">
                    <div style="display: flex; align-items: center; margin-bottom: 8px;">
                        <i class="fas fa-clock" style="color: #fff; font-size: 18px; margin-right: 10px;"></i>
                        <strong style="color: #fff; font-size: 14px;">ทางเลือก: Interval Extension Method</strong>
                    </div>
                    <div style="color: #f0f0f0; font-size: 13px; line-height: 1.6;">
                        <p style="margin: 5px 0;">
                            <i class="fas fa-pills" style="color: #ffd700;"></i> 
                            <strong>ขนาดยา:</strong> ${minDose} ${unit} (ขนาดเต็ม - ไม่ลด)
                        </p>
                        <p style="margin: 5px 0;">
                            <i class="fas fa-calendar-alt" style="color: #ffd700;"></i> 
                            <strong>ความถี่:</strong> ทุก ${intervalSuggestion.intervalHours} ชั่วโมง 
                            (${intervalSuggestion.extendedFrequency}x/วัน)
                        </p>
                        <p style="margin: 8px 0 0 0; font-size: 12px; color: #e0e0e0;">
                            <i class="fas fa-info-circle"></i> 
                            วิธีนี้เหมาะสำหรับยาที่มีครึ่งชีวิตยาว - ให้ยาขนาดเต็มแต่ลดความถี่
                        </p>
                    </div>
                </div>
            `;
        }
        
        displayGuidelineTextEl.innerHTML = guidelineHTML;
    }
    
    // แสดงคำเตือน
    if (warningContainer) {
        warningContainer.innerHTML = '';
        
        if (warningMessages.length > 0) {
            // ✅ แยก Warning ธรรมดา กับ Interval Extension Suggestion
            const regularWarnings = warningMessages.filter(msg => !msg.includes('💡'));
            const intervalWarnings = warningMessages.filter(msg => msg.includes('💡'));
            
            // แสดง Regular Warnings
            regularWarnings.forEach(msg => {
                const p = document.createElement('p');
                p.className = 'warning-message-item';
                p.style.cssText = 'margin: 8px 0; padding: 10px; background: #fff3cd; border-left: 4px solid #ffc107; border-radius: 4px;';
                p.innerHTML = `<i class="fas fa-exclamation-triangle" style="color: #ff6b6b; margin-right: 8px;"></i> ${msg}`;
                warningContainer.appendChild(p);
            });
            
            // แสดง Interval Extension Suggestions (ถ้ามี)
            if (intervalWarnings.length > 0) {
                const suggestionBox = document.createElement('div');
                suggestionBox.className = 'interval-suggestion-box';
                suggestionBox.style.cssText = `
                    margin: 12px 0; 
                    padding: 12px; 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border-radius: 8px;
                    box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
                `;
                
                intervalWarnings.forEach(msg => {
                    const p = document.createElement('p');
                    p.style.cssText = 'margin: 5px 0; color: #fff; font-size: 13px;';
                    p.innerHTML = msg.replace('💡', '<i class="fas fa-lightbulb" style="color: #ffd700; margin-right: 8px;"></i>');
                    suggestionBox.appendChild(p);
                });
                
                warningContainer.appendChild(suggestionBox);
            }
            
            warningContainer.style.display = 'block';
        } else {
            warningContainer.style.display = 'none';
        }
    }

    // เก็บค่าที่แนะนำใน hidden fields
    document.getElementById('recommendedMinDose').value = minDose;
    document.getElementById('recommendedMaxDose').value = maxDose;
    document.getElementById('recommendedFrequencyText').value = freqText;
    document.getElementById('recommendedFrequencyInt').value = data.recommended_frequency_int;

    // ✅ เก็บ Interval Suggestion ใน hidden field (optional)
    if (intervalSuggestion) {
        const hiddenField = document.getElementById('intervalExtensionData') || 
                           document.createElement('input');
        hiddenField.type = 'hidden';
        hiddenField.id = 'intervalExtensionData';
        hiddenField.value = JSON.stringify(intervalSuggestion);
        
        if (!document.getElementById('intervalExtensionData')) {
            resultSection.appendChild(hiddenField);
        }
        
        console.log('💡 Interval Extension Data stored:', intervalSuggestion);
    }

    resultSection.style.display = 'block';

    const calcBtn = document.getElementById('triggerCalculationBtn');
    const proceedBtn = document.getElementById('proceedToResultBtn');
    if (calcBtn) calcBtn.style.display = 'none';
    if (proceedBtn) proceedBtn.style.display = 'block';
    
    checkAdjustmentDeviation();
}
window.updateResultUI = updateResultUI;

// ========================================================================
// ✅ OPTIONAL: Add Helper Function to Apply Interval Extension
// แพทย์สามารถคลิกเพื่อใช้ Interval Extension แทน Dose Reduction
// ========================================================================

function applyIntervalExtension() {
    const intervalData = document.getElementById('intervalExtensionData');
    
    if (!intervalData) {
        console.warn('⚠️ No interval extension data available');
        return;
    }
    
    try {
        const suggestion = JSON.parse(intervalData.value);
        
        // อัปเดต UI ให้ใช้ Interval Extension
        const actualDosageInput = document.getElementById('actualDosage');
        const actualFrequencySelect = document.getElementById('actualFrequencyText');
        const recommendedMinDose = document.getElementById('recommendedMinDose').value;
        
        if (actualDosageInput) {
            // ใช้ขนาดยาเต็ม (ไม่ลด)
            actualDosageInput.value = recommendedMinDose;
        }
        
        if (actualFrequencySelect) {
            // แปลง intervalHours เป็น frequency text
            const hourToFreq = {
                6: 'QID',
                8: 'TID',
                12: 'BID',
                24: 'OD',
                48: 'Q2D'
            };
            
            const newFreq = hourToFreq[suggestion.intervalHours] || 'OD';
            actualFrequencySelect.value = newFreq;
        }
        
        // แจ้งเตือนแพทย์
        showResultPopup(
            '✅ ใช้ Interval Extension', 
            `ปรับเป็น: ขนาดยาเต็ม ทุก ${suggestion.intervalHours} ชั่วโมง`, 
            'success'
        );
        
        console.log('✅ Interval Extension Applied:', suggestion);
        
        // Trigger deviation check
        checkAdjustmentDeviation();
        
    } catch (error) {
        console.error('❌ Error applying interval extension:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถใช้ Interval Extension ได้', 'error');
    }
}
window.applyIntervalExtension = applyIntervalExtension;

// ***************************************************************
// 8. Deviation Check & Override Logic
// ***************************************************************
function checkAdjustmentDeviation() {
    const recommendedMinDoseEl = document.getElementById('recommendedMinDose');
    const recommendedMaxDoseEl = document.getElementById('recommendedMaxDose');
    const actualDosageEl = document.getElementById('actualDosage');
    const recommendedFrequencyTextEl = document.getElementById('recommendedFrequencyText');
    const actualFrequencyTextEl = document.getElementById('actualFrequencyText');
    
    if (!recommendedMinDoseEl || !actualDosageEl || !recommendedFrequencyTextEl || !actualFrequencyTextEl) {
        return;
    }

    const recommendedMinDose = parseFloat(recommendedMinDoseEl.value);
    const recommendedMaxDose = parseFloat(recommendedMaxDoseEl?.value || recommendedMinDose);
    const actualDosage = parseFloat(actualDosageEl.value);
    const recommendedFrequencyText = recommendedFrequencyTextEl.value;
    const actualFrequencyText = actualFrequencyTextEl.value;

    const adjustmentReasonGroup = document.getElementById('adjustmentReasonGroup');
    const reasonWarning = document.getElementById('reasonWarning');
    const overrideReasonInput = document.getElementById('overrideReason');
    
    if (!adjustmentReasonGroup || !reasonWarning || !overrideReasonInput) {
        return;
    }

    let isOverride = false;
    let isSignificantDeviation = false;
    let deviationPercentage = 0;
    
    // ✅ IMPROVED: More accurate deviation calculation using recommended range
    if (!isNaN(recommendedMinDose) && !isNaN(actualDosage) && recommendedMinDose > 0) {
        // Calculate deviation from the MIDPOINT of recommended range
        const recommendedMidpoint = (recommendedMinDose + recommendedMaxDose) / 2;
        const absoluteDeviation = Math.abs(recommendedMidpoint - actualDosage);
        deviationPercentage = absoluteDeviation / recommendedMidpoint;
        
        if (deviationPercentage > ADJUSTMENT_THRESHOLD) {
            isSignificantDeviation = true;
            isOverride = true;
            
            console.log(`⚠️ Significant Deviation Detected:
            - Recommended Range: ${recommendedMinDose}-${recommendedMaxDose} mg
            - Recommended Midpoint: ${recommendedMidpoint.toFixed(2)} mg
            - Actual Dosage: ${actualDosage} mg
            - Deviation: ${(deviationPercentage * 100).toFixed(1)}%`);
        }
    }

    // Check frequency change
    if (actualFrequencyText !== recommendedFrequencyText && actualFrequencyText !== "") {
        isOverride = true;
        console.log(`⚠️ Frequency Override: ${recommendedFrequencyText} → ${actualFrequencyText}`);
    }
    
    // ✅ IMPROVED: Show detailed deviation information
    if (isOverride) {
        adjustmentReasonGroup.style.display = 'block';
        
        if (isSignificantDeviation) {
            reasonWarning.style.display = 'block';
            
            // Add deviation percentage to warning message
            const deviationText = reasonWarning.querySelector('.deviation-percentage');
            if (deviationText) {
                deviationText.textContent = `(เบี่ยงเบน ${(deviationPercentage * 100).toFixed(1)}% จากค่าแนะนำ)`;
            }
        } else {
            reasonWarning.style.display = 'none';
        }
    } else {
        adjustmentReasonGroup.style.display = 'none';
        reasonWarning.style.display = 'none';
        overrideReasonInput.value = '';
    }
}
window.checkAdjustmentDeviation = checkAdjustmentDeviation;

// ***************************************************************
// 9. Proceed to Result and Save to Database
// ***************************************************************
async function proceedToResult() {
    const user = await getCurrentUser();
    
    if (!user || !selectedPatient || !selectedMedicine || !dosageResult) {
        showResultPopup('ข้อมูลไม่ครบ', 'กรุณาตรวจสอบข้อมูลผู้ป่วย และผลการคำนวณ', 'warning');
        return;
    }

    const actualDosageInput = document.getElementById('actualDosage');
    const actualFrequencySelect = document.getElementById('actualFrequencyText');
    const overrideReasonInput = document.getElementById('overrideReason');
    const adjustmentReasonGroup = document.getElementById('adjustmentReasonGroup');

    const actualDosage = parseFloat(actualDosageInput.value);
    const actualFrequencyText = actualFrequencySelect.value;
    const overrideReason = overrideReasonInput.value.trim();

    if (!actualDosage || actualDosage <= 0) {
        showResultPopup('ข้อมูลไม่ครบ', 'กรุณาระบุขนาดยาที่ใช้ (ต้องมากกว่า 0)', 'warning');
        actualDosageInput.focus();
        return;
    }

    if (!actualFrequencyText) {
        showResultPopup('ข้อมูลไม่ครบ', 'กรุณาเลือกความถี่ในการใช้ยา', 'warning');
        actualFrequencySelect.focus();
        return;
    }

    const recommendedMinDose = parseFloat(document.getElementById('recommendedMinDose').value);
    const recommendedMaxDose = parseFloat(document.getElementById('recommendedMaxDose').value);
    
    if (recommendedMinDose > 0) {
        if (actualDosage > (recommendedMaxDose * 2)) {
            const confirmed = confirm(
                `⚠️ คำเตือนสำคัญ!\n\n` +
                `ขนาดยาที่ระบุ (${actualDosage} mg) สูงกว่าขนาดที่แนะนำมากกว่า 200%\n` +
                `ขนาดที่แนะนำ: ${recommendedMinDose}-${recommendedMaxDose} mg\n\n` +
                `การใช้ยาเกินขนาดอาจเป็นอันตรายต่อผู้ป่วย\n\n` +
                `คุณแน่ใจหรือไม่ว่าต้องการดำเนินการต่อ?`
            );
            
            if (!confirmed) {
                console.log('❌ User cancelled - dosage too high');
                return;
            }
        }
        
        if (actualDosage < (recommendedMinDose * 0.25)) {
            const confirmed = confirm(
                `⚠️ คำเตือน!\n\n` +
                `ขนาดยาที่ระบุ (${actualDosage} mg) ต่ำกว่าขนาดที่แนะนำมาก\n` +
                `ขนาดที่แนะนำ: ${recommendedMinDose}-${recommendedMaxDose} mg\n\n` +
                `ขนาดยาที่ต่ำเกินไปอาจไม่ได้ผลทางการรักษา\n\n` +
                `คุณแน่ใจหรือไม่ว่าต้องการดำเนินการต่อ?`
            );
            
            if (!confirmed) {
                console.log('❌ User cancelled - dosage too low');
                return;
            }
        }
    }

    const isOverrideVisible = adjustmentReasonGroup && adjustmentReasonGroup.style.display !== 'none';
    if (isOverrideVisible && !overrideReason) {
        showResultPopup(
            'กรุณาระบุเหตุผล', 
            `การปรับแก้มากกว่า ${ADJUSTMENT_THRESHOLD * 100}% ต้องระบุเหตุผลเพื่อความปลอดภัยของผู้ป่วย`, 
            'warning'
        );
        overrideReasonInput.focus();
        return;
    }

    const frequencyMap = {
        'OD': 1, 'QD': 1,
        'BID': 2,
        'TID': 3,
        'QID': 4,
        'PRN': 0
    };
    const actualFrequencyInt = frequencyMap[actualFrequencyText] || 0;

    const ageCategory = dosageResult.calculation_details?.age_adjustment?.age_category || 'adult';
    const ageAdjustmentFactor = dosageResult.calculation_details?.age_adjustment?.age_factor || 1.0;
    const baseDose = dosageResult.calculation_details?.base_dose || 0;

    const calculationData = {
        patientId: selectedPatient.PatientID,
        patientName: selectedPatient.PatientName,
        patientAge: selectedPatient.Age,
        patientWeight: selectedPatient.Weight,
        patientDisease: selectedPatient.Disease,
        
        drugId: selectedMedicine.drug_id || selectedMedicine.MedicineID,
        medicineName: selectedMedicine.medicine_name || selectedMedicine.GenericName,
        medicineType: selectedMedicine.medicine_type || selectedMedicine.Type,
        
        recommendedMinDose: dosageResult.recommended_min_dose,
        recommendedMaxDose: dosageResult.recommended_max_dose,
        recommendedFrequencyInt: dosageResult.recommended_frequency_int,
        
        actualDosage: actualDosage,
        actualFrequencyInt: actualFrequencyInt,
        
        isOverride: isOverrideVisible,
        overrideReason: overrideReason || null,
        overrideDoctorName: user.FirstName && user.LastName 
            ? `${user.FirstName} ${user.LastName}` 
            : user.Username || 'ไม่ระบุ',
        
        // 🆕 Age Adjustment Data
        baseDose: baseDose,
        ageCategory: ageCategory,
        ageAdjustmentFactor: ageAdjustmentFactor
    };

    try {
        const proceedBtn = document.getElementById('proceedToResultBtn');
        const originalText = proceedBtn.innerHTML;
        proceedBtn.disabled = true;
        proceedBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> กำลังบันทึก...';

        const response = await fetch(`${API_BASE}/api/calculations`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(calculationData)
        });

        if (response.status === 401) {
            handleAuthError();
            return;
        }

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message || 'ไม่สามารถบันทึกข้อมูลได้');
        }

        if (data.success) {
            showResultPopup(
                'บันทึกสำเร็จ', 
                'บันทึกการคำนวณปริมาณยาเรียบร้อยแล้ว', 
                'success'
            );
            
            setTimeout(() => {
                window.location.href = 'resultmed.html';
            }, 1500);
        } else {
            throw new Error(data.message || 'บันทึกไม่สำเร็จ');
        }

    } catch (error) {
        console.error('❌ Error saving calculation:', error);
        
        const proceedBtn = document.getElementById('proceedToResultBtn');
        proceedBtn.disabled = false;
        proceedBtn.innerHTML = '<i class="fas fa-check-circle"></i> บันทึก และไปหน้าสรุปผล';
        
        showResultPopup(
            'เกิดข้อผิดพลาด', 
            error.message || 'ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง', 
            'error'
        );
    }
}
window.proceedToResult = proceedToResult;

// ***************************************************************
// 10. Patient Loading
// ***************************************************************
async function loadPatientsFromAPI() {
    const user = await getCurrentUser(); 
    if (!user || !user.token) return;

    try {
        const response = await fetch(`${API_BASE}/api/patients`, {
            headers: {
                'Authorization': `Bearer ${user.token}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.status === 401) { handleAuthError(); return; }
        if (!response.ok) throw new Error('Failed to fetch patient list');

        const data = await response.json();
        if (data.success) {
            allPatients = data.patients || [];
            console.log('✅ โหลดผู้ป่วย:', allPatients.length, 'คน');
        }
    } catch (error) {
        console.error('❌ Error loading patients:', error);
        showResultPopup('ข้อผิดพลาด', 'ไม่สามารถโหลดรายชื่อผู้ป่วยได้', 'error');
    }
}
window.loadPatientsFromAPI = loadPatientsFromAPI;

// ***************************************************************
// 11. Patient Modal Functions
// ***************************************************************
function openPatientModal() {
    document.getElementById('patientModal').style.display = 'flex';
    displayPatientList(allPatients);
}
window.openPatientModal = openPatientModal;

function closePatientModal() {
    document.getElementById('patientModal').style.display = 'none';
}
window.closePatientModal = closePatientModal;

function displayPatientList(patients) {
    const list = document.getElementById('patientList');
    if (!list) return;

    list.innerHTML = '';
    if (patients.length === 0) {
        list.innerHTML = '<p class="no-data-message"><i class="fas fa-user-slash"></i><br>ไม่พบข้อมูลผู้ป่วย</p>';
        return;
    }

    patients.forEach(patient => {
        const item = document.createElement('div');
        item.className = 'patient-list-item';
        item.innerHTML = `
            <h5>${patient.PatientName || 'N/A'}</h5>
            <p>อายุ: ${patient.Age || '-'} ปี | โรค: ${patient.Disease || 'ไม่ระบุ'}</p>
        `;
        item.onclick = () => selectPatient(patient.PatientID);
        list.appendChild(item);
    });
}

function selectPatient(patientId) {
    resetCalculationState();
    
    selectedPatient = allPatients.find(p => p.PatientID === patientId);
    
    const patientNameInput = document.getElementById('patientName'); 

    if (selectedPatient) {
        if (patientNameInput) {
            patientNameInput.value = selectedPatient.PatientName || '-'; 
        }
        document.getElementById('displayName').textContent = selectedPatient.PatientName || '-';
        document.getElementById('displayAge').textContent = `${selectedPatient.Age || '-'} ปี`;
        document.getElementById('displayWeight').textContent = `${selectedPatient.Weight || '-'} kg.`;
        document.getElementById('displayDisease').textContent = selectedPatient.Disease || '-';
        
        closePatientModal();
    }
}
window.selectPatient = selectPatient;

// ***************************************************************
// 12. UI Update Helper
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
        authSection.innerHTML = `
            <a href="login.html" class="login-btn">เข้าสู่ระบบ</a>
        `;
    }
}
window.updateUIForLoggedInUser = updateUIForLoggedInUser;

// ***************************************************************
// 13. Initialization and Event Listeners
// ***************************************************************
document.addEventListener('DOMContentLoaded', async () => {
    try {
        const user = await getCurrentUser();

        if (!user) {
            if (typeof showResultPopup === 'function') {
                showResultPopup('Session หมดอายุ', 'กรุณาเข้าสู่ระบบใหม่', 'error');
            }
            setTimeout(() => window.location.href = 'login.html', 1500);
            return;
        }
            
        await updateUIForLoggedInUser();
        await loadMedicinesFromAPI(); // ✅ โหลดเฉพาะยาที่กรอกปัจจัยแล้ว
        await loadPatientsFromAPI();
        
        const actualDosageInput = document.getElementById('actualDosage');
        const actualFrequencySelect = document.getElementById('actualFrequencyText');
        
        if (actualDosageInput) {
            actualDosageInput.addEventListener('input', checkAdjustmentDeviation);
        }
        if (actualFrequencySelect) {
            actualFrequencySelect.addEventListener('change', checkAdjustmentDeviation);
        }

        const urlParams = new URLSearchParams(window.location.search);
        const patientId = urlParams.get('id'); 
        if (patientId) {
            const interval = setInterval(() => {
                if (allPatients.length > 0) {
                    clearInterval(interval);
                    selectPatient(patientId);
                }
            }, 100);
        }
        
        console.log('✅ Initialization complete');
    } catch (error) {
        console.error('❌ Error during initialization:', error);
        showResultPopup('ข้อผิดพลาด', 'เกิดข้อผิดพลาดในการโหลดหน้า');
    }
});

// ***************************************************************
// 14. Global Exports (Required for inline HTML calls)
// ***************************************************************
window.resetCalculationState = resetCalculationState;
window.loadPatientsFromAPI = loadPatientsFromAPI;
window.loadMedicinesFromAPI = loadMedicinesFromAPI;
window.openPatientModal = openPatientModal; 
window.closePatientModal = closePatientModal;
window.selectPatient = selectPatient;
window.openMedicineModal = openMedicineModal;
window.closeMedicineModal = closeMedicineModal;
window.selectMedicineFromModal = selectMedicineFromModal;
window.updateDiseaseSpecificInputs = updateDiseaseSpecificInputs;
window.triggerDosageCalculation = triggerDosageCalculation;
window.checkAdjustmentDeviation = checkAdjustmentDeviation;
window.proceedToResult = proceedToResult;
window.updateUIForLoggedInUser = updateUIForLoggedInUser;
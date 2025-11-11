USE medicaldosagedb;
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserMedicineFactors_Drug')
BEGIN
    ALTER TABLE user_medicine_factors DROP CONSTRAINT FK_UserMedicineFactors_Drug;
    PRINT '✅ ลบ Foreign Key สำเร็จ';
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[drugs]') AND type in (N'U'))
BEGIN
    DROP TABLE drugs;
    PRINT '✅ ลบตาราง drugs เดิมสำเร็จ';
END
GO

CREATE TABLE drugs (
    drug_id INT IDENTITY(1,1) PRIMARY KEY,  
    generic_name NVARCHAR(500),      
    type NVARCHAR(100),
    dosage NVARCHAR(MAX),
    condition NVARCHAR(MAX),
    caution NVARCHAR(MAX)
);
GO

PRINT '✅ สร้างตาราง drugs สำเร็จ';
GO

INSERT INTO drugs (generic_name, type, dosage, condition, caution) VALUES
  (
     'Aluminium hydroxide + Magnesium hydroxide',
     '',
     'chewable tab, tab, susp, susp (hosp)',
     '',
     ''
  ),
  (
     'Simeticone',
     '',
     'chewable tab, susp',
     '',
     ''
  ),
  (
     'Aluminium hydroxide + Magnesium hydroxide + Simeticone 25-50 mg',
     '',
     'chewable tab, tab, susp',
     '',
     ''
  ),
  (
     'Compound Cardamom Mixture เฉพาะสูตรที่ไม่มี sodium bicarbonate',
     '',
     'mixt, mixt (hosp)',
     '',
     ''
  ),
  (
     'Aluminium hydroxide',
     '',
     'chewable tab, tab, susp, susp (hosp)',
     '',
     ''
  ),
  (
     'Dicycloverine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Domperidone',
     '',
     'tab (as base/maleate), susp (as base/maleate)',
     '',
     '1. ควรใช้ด้วยความระมัดระวังในผู้ป่วยอายุมากกว่า 80 ปี และไม่ใช้ยาขนาดเกินกว่า 30 mg ต่อวัน ในผู้ใหญ่ และไม่เกิน 0.75 มิลลิกรัมต่อกิโลกรัมต่อวัน ในเด็ก 2. ห้ามใช้ในผู้ป่วยที่มีภาวะ prolonged QT และห้ามใช้ร่วมกับยาที่มีผลทำให้เกิด prolonged QT'
  ),
  (
     'Hyoscine butylbromide',
     '',
     'tab, syr, sterile sol',
     '',
     ''
  ),
  (
     'Metoclopramide',
     '',
     'tab, syr, sterile sol',
     '',
     'ไม่ควรใช้ยาดังกล่าวระยะยาวในเด็ก'
  ),
  (
     'Mebeverine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Omeprazole',
     '',
     'EC cap (as base)',
     '',
     ''
  ),
  (
     'Famotidine',
     '',
     'tab (เฉพาะ 20 mg)',
     '',
     ''
  ),
  (
     'Omeprazole sodium',
     '',
     'sterile pwdr',
     '',
     'ห้ามให้ทางหลอดเลือดดำนานเกินกว่า 30 นาที'
  ),
  (
     'Pantoprazole sodium',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Sucralfate',
     '',
     'tab, susp',
     'ใช้เฉพาะกรณีหญิงตั้งครรภ์',
     ''
  ),
  (
     'Bismuth  subsalicylate',
     '',
     'tab',
     '1. ใช้เป็น second-line drug  ในการกำจัด H.pyroli2. ห้ามใช้ในเด็กอายุน้อยกว่า 12 ปี',
     ''
  ),
  (
     'Lansoprazole',
     '',
     'orodispersible tab (เฉพาะ 15 mg)',
     'ใช้สำหรับโรคแผลในกระเพาะอาหารในเด็กเล็กอายุต่ำกว่า 6 ปี ที่ไม่สามารถกลืนยาแคปซูลได้ ในกรณีข้อใดข้อหนึ่ง ดังนี้1. โรคแผลในกระเพาะอาหาร ที่ได้รับการวินิจฉัยโดยการส่องกล้องทางเดินอาหาร โดยให้การรักษาด้วยยา lansoprazole เป็นเวลานาน 4 ถึง 8 สัปดาห์ ทั้งนี้จะต้องรักษาสาเหตุของแผลในกระเพาะอาหารไปพร้อมกันด้วย- ขนาดยาสำหรับเด็กอายุไม่เกิน 1 ปี: 1-2 มิลลิกรัมต่อกิโลกรัมต่อวัน วันละ 1 ครั้ง - ขนาดยาสำหรับเด็กอายุมากกว่า 1 ปี ถึง 6 ปี: 15 มิลลิกรัมต่อวัน วันละ 1 ครั้ง- ระยะเวลาการรักษา: 4 สัปดาห์ใน duodenal ulcer และ 8 สัปดาห์ใน gastric ulcer 2. โรคติดเชื้อ H.pylori ที่ได้รับการวินิจฉัยโดยการส่องกล้องทางเดินอาหารและพบแผลในกระเพาะอาหารหรือดูโอดีนัม ให้การรักษาด้วยยา lansoprazole ร่วมกับยาปฏิชีวนะ ตามมาตรฐานการรักษาเป็นเวลา 14 วัน- ขนาดยาสำหรับเด็กอายุมากกว่า 1 ปี ถึง 6 ปี: 15 มิลลิกรัม วันละ 2 ครั้ง- ระยะเวลาการรักษา: 14 วัน3. ผู้ป่วยเด็กอายุต่ำกว่า 6 ปีที่มีอาการ upper GI bleeding ที่สงสัยเกิดจากแผลในกระเพาะอาหารหรือกระเพาะอาหารอักเสบรุนแรง ควรปรึกษาแพทย์โรคระบบทางเดินอาหารเพื่อพิจารณาการส่องกล้องทางเดินอาหาร หากไม่สามารถส่งต่อได้ แนะนำให้การรักษาด้วยยา lansoprazole ชนิดรับประทาน ในระยะเปลี่ยนจาก proton pump inhibitor ชนิดฉีด โดยระยะเวลาการรักษารวมกันไม่เกิน 4 ถึง 8 สัปดาห์กรณีไม่ได้ส่องกล้อง- ขนาดยาสำหรับเด็กอายุไม่เกิน 1 ปี: 1-2 มิลลิกรัมต่อกิโลกรัมต่อวัน วันละ 1 ครั้ง*- ขนาดยาสำหรับเด็กอายุมากกว่า 1 ปี ถึง 6 ปี: 15 มิลลิกรัมต่อวัน วันละ 1 ครั้ง*หมายเหตุ1. * หากส่องกล้องพบว่า เป็นแผลที่มีความเสี่ยงสูง ให้เพิ่มยาเป็นวันละ 2 ครั้ง ในช่วง 14 วันแรก2. ระยะเวลาการรักษารวมทั้งสิ้น: 4 สัปดาห์ใน duodenal ulcer และ 8 สัปดาห์ใน gastric ulcer',
     ''
  ),
  (
     'Lauromacrogol 400',
     '',
     'sterile sol',
     '1. ใช้ช่วยห้าม variceal bleeding ผ่านทาง endoscopy และใช้สำหรับ sclerotherapy2. ใช้สำหรับ varicose vein และ hemorrhoid',
     ''
  ),
  (
     'Octreotide acetate',
     '',
     'sterile sol (เฉพาะ 0.1 mg/ 1 ml ) ยกเว้นชนิดออกฤทธิ์นาน',
     '1.  ใช้สำหรับ high output pancreatic fistula2.  ใช้สำหรับ variceal bleeding โดยใช้ร่วมกับ therapeutic endoscopic intervention3.  ใช้ในกรณี bleeding ที่มีหลักฐานว่าเป็นภาวะเลือดออกจาก portal hypertensive gastropathy4.  ใช้สำหรับ neuroendocrine tumors',
     ''
  ),
  (
     'Oral rehydration salts',
     '',
     'oral pwdr, oral pwdr (hosp)',
     '',
     ''
  ),
  (
     'Zinc sulfate',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Loperamide hydrochloride',
     '',
     'cap, tab',
     'ไม่ใช้กับเด็กอายุน้อยกว่า 12 ปี',
     ''
  ),
  (
     'Mesalazine',
     '',
     'EC tab, SR tab, enema, rectal supp',
     '1. ชนิดเม็ด ใช้เป็นทางเลือกของ sulfasalazine ในกรณีผู้ป่วยแพ้ยากลุ่มซัลฟา หรือต้องการลดอาการข้างเคียงจากการใช้ยา2.  ชนิดเหน็บทวารหนัก (suppository) ใช้สำหรับ mild to moderate ulcerative proctitis และ radiation  proctitis3. ชนิดสวนทวารหนัก (enema) ใช้สำหรับ mild to moderate ulcerative colitis บริเวณ left-sided colon',
     ''
  ),
  (
     'Sulfasalazine',
     '',
     'tab, EC tab',
     'ใช้สำหรับ chronic inflammatory bowel disease',
     ''
  ),
  (
     'Infliximab',
     '',
     'sterile pwdr (เฉพาะ 100 mg)',
     '1.ใช้สำหรับผู้ป่วย Crohns disease (CD) ในผู้ใหญ่หรือเด็ก ที่รักษาด้วยยาพื้นฐานไม่ได้ 2.ใช้สำหรับผู้ป่วย ulcerative colitis (UC) ในผู้ใหญ่หรือเด็ก ที่รักษาด้วยยาพื้นฐานไม่ได้ ',
     ''
  ),
  (
     'Bisacodyl',
     '',
     'EC tab, rectal supp',
     '',
     ''
  ),
  (
     'Castor oil',
     '',
     'oil',
     '',
     ''
  ),
  (
     'Glycerol',
     '',
     'rectal supp',
     '',
     ''
  ),
  (
     'Ispaghula Husk (Psyllium Husk)',
     '',
     'powder for oral suspension, granules for oral suspension',
     '',
     ''
  ),
  (
     'Magnesium hydroxide',
     '',
     'tab, susp, susp (hosp)',
     '',
     ''
  ),
  (
     'Magnesium sulfate',
     '',
     'mixt, mixt (hosp), sol, sol (hosp)',
     '',
     ''
  ),
  (
     'Senna',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Sodium phosphates',
     '',
     'enema',
     '',
     ''
  ),
  (
     'Lactulose',
     '',
     'syr',
     '1. ใช้สาหรับ hepatic encephalopathy2. ใช้สาหรับ chronic constipation ในเด็กอายุน้อยกว่า 6 ปี3. ใช้เป็นทางเลือกในหญิงตั้งครรภ์ที่ใช้ยาระบายอื่นไม่ได้4. ใช้เป็นทางเลือกในผู้ป่วยที่มีข้อห้ามใช้ magnesium',
     ''
  ),
  (
     'Macrogols with electrolytes',
     '',
     'oral pwdr (hosp)',
     'ใช้สำหรับเตรียมลำไส้ใหญ่ก่อนการผ่าตัดหรือตรวจลำไส้',
     ''
  ),
  (
     'Sodium phosphates',
     '',
     'oral sol',
     '1. ใช้สำหรับเตรียมลำไส้ใหญ่ก่อนการผ่าตัดหรือตรวจลำไส้  2. ไม่ใช้ยานี้เพื่อทดแทนการขาดฟอสเฟต หรือใช้เป็นยาระบายหรือยาถ่าย',
     '1. รับประทานไม่เกินครั้งละ 45 มิลลิลิตร และไม่เกิน 90 มิลลิลิตร ภายใน 24 ชั่วโมง2. ให้ระวังในผู้ป่วยสูงอายุ ผู้ป่วยโรคไตวาย และผู้ป่วยโรคหัวใจล้มเหลว'
  ),
  (
     'Local anesthetic + Corticosteroid with/without astringent',
     '',
     'cream, oint, rectal supp',
     '1. หนึ่งรูปแบบให้เลือก 1 สูตร 2. ใช้ไม่เกิน 7 วัน',
     ''
  ),
  (
     'Colestyramine',
     '',
     'oral pwdr',
     'ใช้สำหรับ bile-acid diarrhea และ short bowel syndrome',
     ''
  ),
  (
     'Pancreatic enzymes',
     '',
     'cap, tab , EC cap , EC tab',
     'ใช้เฉพาะผู้ป่วยที่เป็น pancreatic insufficiency เท่านั้น',
     ''
  ),
  (
     'Ursodeoxycholic acid',
     '',
     'cap',
     'ใช้สำหรับ cholestatic liver disease',
     ''
  ),
  (
     'Digoxin',
     '',
     'tab, elixir, sterile sol',
     '',
     ''
  ),
  (
     'Milrinone lactate',
     '',
     'sterile sol',
     '1. ใช้เพิ่มการบีบตัวของหัวใจในผู้ป่วยหลังการผ่าตัดหัวใจ2. ใช้ทดแทนหรือเสริม dopamine หรือ dobutamine ใน advanced heart failure3. ใช้เพื่อเพิ่มการบีบตัวของหัวใจในผู้ป่วย advanced heart failure ที่เคยใช้ beta blocker มาก่อน',
     ''
  ),
  (
     'Furosemide',
     '',
     'tab, sterile sol',
     '',
     ''
  ),
  (
     'Hydrochlorothiazide',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Mannitol',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Spironolactone',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Amiloride hydrochloride + Hydrochlorothiazide (HCTZ)',
     '',
     'tab (เฉพาะ 5 + 50 mg)',
     '',
     ''
  ),
  (
     'Adenosine',
     '',
     'sterile sol',
     '1.  ใช้สำหรับรักษา supraventricular tachycardia2.  ใช้ฉีดเข้าหลอดเลือดหัวใจเพื่อรักษาภาวะ no reflow ในผู้ป่วยที่ได้รับการทำ Percutaneous Coronary Intervention (PCI) เมื่อมีข้อห้ามใช้ยา verapamil หรือไม่มียา verapamil ให้ใช้3.  ใช้สำหรับการตรวจพิเศษทางหัวใจ',
     ''
  ),
  (
     'Atropine sulfate',
     '',
     'sterile sol',
     'ใช้สำหรับ symptomatic bradycardia และการตรวจพิเศษทางหัวใจ',
     ''
  ),
  (
     'Lidocaine hydrochloride (preservative free)',
     'ยากำพร้า',
     'sterile sol (เฉพาะ 1% และ 2%),sterile sol (hosp)',
     'ใช้สำหรับ ventricular arrhythmias',
     ''
  ),
  (
     'Magnesium sulfate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Verapamil',
     '',
     'sterile sol',
     '1.   ใช้สำหรับ supraventricular tachyarrhythmias ซึ่งรวมทั้ง atrial fibrillation ที่ต้องการฤทธิ์ของยานาน 4-6 ชั่วโมง และไม่มีข้อห้ามใช้ calcium channel blockers2.  ใช้ฉีดเข้าหลอดเลือดหัวใจเพื่อรักษาภาวะ no reflow ในผู้ป่วยที่ได้รับการทำ Percutaneous Coronary Intervention (PCI)',
     ''
  ),
  (
     'Amiodarone hydrochloride',
     '',
     'tab, sterile sol',
     'ใช้สำหรับ supraventricular และ ventricular arrhythmias',
     ''
  ),
  (
     'Flecainide acetate',
     '',
     'tab',
     'ใช้กับผู้ป่วยที่ใช้ยาอื่นควบคุมจังหวะการเต้นผิดปกติของหัวใจไม่ได้หรือไม่ได้ผล',
     ''
  ),
  (
     'Propafenone hydrochloride',
     '',
     'tab',
     'ใช้กับผู้ป่วยที่ใช้ยาอื่นควบคุมจังหวะการเต้นผิดปกติของหัวใจไม่ได้หรือไม่ได้ผล',
     ''
  ),
  (
     'Atenolol',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Metoprolol tartrate',
     '',
     'immediate release tab',
     '',
     ''
  ),
  (
     'Propranolol hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Carvedilol',
     '',
     'tab',
     'ใช้สำหรับ heart failure with reduced ejection fraction',
     ''
  ),
  (
     'Labetalol hydrochloride',
     '',
     'sterile sol',
     'ใช้สำหรับ hypertensive emergencies',
     ''
  ),
  (
     'Esmolol hydrochloride',
     '',
     'sterile sol',
     '1.ใช้สำหรับรักษาภาวะที่หัวใจมีการเต้นเร็วผิดปกติ (supraventricular tachycardia, non-compensatory sinus tachycardia) ในผู้ป่วยที่มีความเสี่ยงต่อการเกิดภาวะแทรกซ้อนของหัวใจและหลอดเลือด ทั้งในระหว่างและหลังการผ่าตัด2.ใช้สำหรับควบคุมการเต้นของหัวใจให้ช้ากว่าปกติ หรือไม่ให้เต้นเร็ว ทั้งในระหว่างและหลังการผ่าตัด หรือในระหว่างการระงับความรู้สึก หรือ ทำหัตถการ เช่น การตรวจวินิจฉัย computed tomography (CT) heart เป็นต้น3.สั่งใช้โดยแพทย์ผู้เชี่ยวชาญ สาขาวิสัญญีวิทยา สาขาอายุรศาสตร์ สาขาศัลยศาสตร์ทรวงอก และสาขาศัลยศาสตร์หลอดเลือด',
     ''
  ),
  (
     'Hydralazine hydrochloride',
     'ยากำพร้าเฉพาะรูปแบบ sterile pwdr',
     'tab, sterile pwdr',
     'ชนิดฉีดใช้สำหรับ hypertensive emergencies ในหญิงตั้งครรภ์',
     ''
  ),
  (
     'Sodium nitroprusside',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้เป็นมาตรฐานการรักษาใน hypertensive emergencies (ยกเว้นในหญิงตั้งครรภ์)',
     ''
  ),
  (
     'Methyldopa',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Prazosin hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Doxazosin mesilate',
     '',
     'immediate release tab',
     '',
     ''
  ),
  (
     'Enalapril maleate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Captopril',
     '',
     'tab',
     'ใช้สำหรับ hypertensive urgency',
     ''
  ),
  (
     'Lisinopril',
     '',
     'tab',
     'ใช้สำหรับ post myocardial infarction',
     ''
  ),
  (
     'Losartan potassium',
     '',
     'tab (เฉพาะ 50 และ 100 mg)',
     'ใช้กับผู้ป่วยที่ใช้ยาในกลุ่ม Angiotensin-converting enzyme inhibitors ไม่ได้ เนื่องจากเกิดอาการไม่พึงประสงค์จากการใช้ยาในกลุ่มดังกล่าว',
     ''
  ),
  (
     'Glyceryl trinitrate',
     '',
     'sterile sol',
     'ใช้สำหรับ hypertensive emergencies ในกรณีที่มี coronary ischemia',
     ''
  ),
  (
     'Isosorbide dinitrate',
     '',
     'tab, sublingual tab',
     '',
     ''
  ),
  (
     'Isosorbide mononitrate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Amlodipine besilate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Diltiazem hydrochloride',
     '',
     'SR cap/SR tab (เฉพาะ 120 mg) ไม่รวมชนิด controlled release',
     'ใช้สำหรับ ischemic heart disease (IHD)',
     ''
  ),
  (
     'Verapamil hydrochloride',
     '',
     'tab, SR tab (เฉพาะ 240 mg)',
     '1. ใช้สำหรับ ischemic heart disease (IHD)2. ใช้สำหรับ essential hypertension',
     ''
  ),
  (
     'Diltiazem hydrochloride',
     '',
     'immediate release tab',
     'ใช้สำหรับ ischemic heart disease (IHD) ไม่แนะนำให้ใช้ในการรักษา essential hypertension',
     ''
  ),
  (
     'Lercanidipine hydrochloride',
     '',
     'tab (เฉพาะ 20 mg)',
     'ใช้สำหรับเป็นทางเลือกในการรักษาผู้ป่วยที่ทนต่อผลข้างเคียงของยา Amlodipine ไม่ได้',
     ''
  ),
  (
     'Manidipine hydrochloride',
     '',
     'tab (เฉพาะ 20 mg)',
     'ใช้สำหรับเป็นทางเลือกในการรักษาผู้ป่วยที่ทนต่อผลข้างเคียงของยา Amlodipine ไม่ได้',
     ''
  ),
  (
     'Nicardipine hydrochloride',
     '',
     'sterile sol',
     '1. ใช้กับผู้ป่วย hypertensive  emergencies ที่ไม่มีภาวะแทรกซ้อนทางหัวใจ 2. ใช้เป็นยาแทน (alternative drug) ในกรณีที่ไม่สามารถใช้ยา sodium nitroprusside หรือ glyceryl trinitrate (nitroglycerin) ได้',
     ''
  ),
  (
     'Nifedipine',
     '',
     'SR cap/SR tab (เฉพาะ 20 mg)',
     '1. ใช้สำหรับความดันเลือดสูงในหญิงตั้งครรภ์ที่ใช้ methyldopa และ hydralazine แล้วไม่ได้ผล2. ใช้สำหรับ intractable Raynauds phenomenon',
     ''
  ),
  (
     'Nimodipine',
     '',
     'tab, sterile sol',
     'ใช้โดยแพทย์ผู้เชี่ยวชาญด้านประสาทวิทยาและประสาทศัลยศาสตร์สำหรับป้องกันพยาธิสภาพของระบบประสาทที่อาจดำเนินต่อไปจากการหดตัวของหลอดเลือด ภายหลังการเกิด subarachnoid hemorrhage',
     ''
  ),
  (
     'Sildenafil (as citrate)',
     '',
     'tab',
     '1. ใช้สำหรับผู้ป่วยภาวะ pulmonary arterial hypertension (PAH) ที่เกิดจากโรคหัวใจแต่กำเนิด (CHD) ชนิด  systemic-to-pulmonary shunt หรือโรค idiopathic pulmonary arterial hypertension (IPAH) หรือ  PAH associated with connective tissue disease (CNTD) และ2. อยู่ใน WHO functional classification of PAH  II และ3. ได้รับการตรวจวินิจฉัยตามขั้นตอนวิธีที่ปรากฏในแนวทางเวชปฏิบัติ 4. แนะนำให้หยุดยาเมื่อผลการประเมินทุก 3 เดือนมีอาการทรุดลงอย่างต่อเนื่องอย่างน้อย 2 รอบการประเมินเกณฑ์อาการทรุดลงหมายถึงการตรวจพบอย่างน้อย 2 ข้อต่อไปนี้คือ     4.1 ตรวจร่างกายมีอาการแสดงของ progressive right heart failure     4.2 WHO functional classification เพิ่มขึ้นกว่าเดิม     4.3 6MWT ลดลงกว่าเดิม 25%     4.4 Echocardiography พบลักษณะที่บ่งชี้ว่าอาการทรุดลงเช่น right atrium และ right ventricle โตขึ้นกว่าเดิม, right ventricular systolic pressure (RVSP) สูงขึ้นกว่าเดิม, RV dysfunction, TAPSE < 1.5 cm, RAP > 15 mmHg, CI  2 L/min/m2, pericardial effusion',
     ''
  ),
  (
     'Dopamine hydrochloride',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Isoprenaline hydrochloride',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Dobutamine hydrochloride',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Norepinephrine',
     '',
     'sterile sol (as bitartrate or hydrochloride)',
     '',
     ''
  ),
  (
     'Ephedrine hydrochloride',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'sterile sol',
     '',
     ''
  ),
  (
     'Midodrine Hydrochloride',
     'ยากำพร้า',
     'tab',
     'ใช้สำหรับลดอาการ orthostatic hypotension ในผู้ป่วยโรคพาร์กินสัน',
     ''
  ),
  (
     'Phenylephrine hydrochloride',
     '',
     'sterile sol (50 mcg/ml)',
     '1. ผู้ป่วยผ่าตัดคลอดที่ได้รับ spinal anesthesia ที่มีภาวะความดันโลหิตต่ำ และหัวใจเต้นเร็ว2. ผู้ป่วยโรคหัวใจและหลอดเลือดที่อาจเกิดผลเสียจากการลดลงของความต้านทานหลอดเลือดส่วนปลาย (systemic vascular resistance; SVR) ขณะให้การระงับความรู้สึก อาทิเช่น aortic stenosis, hypertrophic obstructive cardiomyopathy (HOCM)3. ใช้เพิ่มความดันโลหิตของผู้ป่วยขณะที่อยู่ในเครื่องปอดหัวใจเทียมระหว่างการทำผ่าตัดหัวใจ4. ใช้รักษาภาวะเขียวเฉียบพลัน (cyanotic spell) ในผู้ป่วยโรค Tetralogy of Fallot (โดยไม่จำเป็นต้องมีภาวะความดันโลหิตต่ำ)',
     ''
  ),
  (
     'Epinephrine',
     '',
     'sterile sol, sterile sol (hosp)',
     '',
     ''
  ),
  (
     'Warfarin sodium',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Heparin sodium',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Enoxaparin sodium',
     '',
     'sterile sol',
     '1. ใช้สำหรับ deep vein thrombosis และ pulmonary embolism2. ใช้สำหรับ venous stroke และ cardioembolic stroke3. ใช้กับผู้ป่วย acute coronary syndrome (ACS) ที่ต้องรับการรักษาด้วยวิธี Percutaneous Coronary Intervention',
     ''
  ),
  (
     'Fondaparinux sodium',
     '',
     'sterile sol (2.5 mg/0.5 ml)',
     'ใช้สำหรับ acute coronary syndrome ที่ไม่ต้องทำ Percutaneous Coronary Intervention (conservative management)',
     ''
  ),
  (
     'Aspirin',
     '',
     'tab/EC tab (เฉพาะ 75-325 mg)',
     '',
     ''
  ),
  (
     'Clopidogrel bisulfate',
     '',
     'tab',
     '1.  ใช้กับผู้ป่วยที่ใช้ aspirin ไม่ได้ หรือไม่ได้ผล (aspirin failure) เฉพาะกรณีที่ใช้ป้องกันโรคเกี่ยวกับหลอดเลือดหัวใจหรือสมองแบบทุติยภูมิ (secondary prevention)2.  ให้ร่วมกับ aspirin หลังการใส่ขดลวดค้ำยันผนังหลอดเลือด (stent) เป็นระยะเวลาไม่เกิน 1 ปี3.  ใช้ในกรณีผู้ป่วยโรคหลอดเลือดหัวใจที่ได้รับ aspirin แล้วยังเกิด acute coronary syndrome หรือ  recurrent thrombotic events4.  ในกรณีที่ได้รับการวินิจฉัยอย่างชัดเจนแล้วว่าเป็น non-ST elevated acute coronary syndrome ให้ใช้ clopidogrel ร่วมกับ aspirin เป็นระยะเวลาไม่เกิน 1 ปี',
     ''
  ),
  (
     'Dipyridamole',
     '',
     'sterile sol',
     'ใช้สำหรับการตรวจวินิจฉัยเท่านั้น',
     ''
  ),
  (
     'Eptifibatide',
     '',
     'sterile sol',
     'ใช้ร่วมกับการรักษาด้วยสายสวนขยายหลอดเลือดหัวใจเท่านั้น',
     ''
  ),
  (
     'Ticagrelor',
     '',
     'tab (เฉพาะ 90 mg)',
     'ใช้ ticagrelor ร่วมกับ aspirin ขนาด 75-100 มก. โดยให้ใช้ ticagrelor เป็นเวลาไม่เกิน 1 ปี ในผู้ป่วย high-risk acute coronary syndrome (ACS) ที่รักษาด้วยวิธี Percutaneous Coronary Intervention (PCI) และเป็นไปตามเกณฑ์อย่างน้อยหนึ่งข้อ ดังต่อไปนี้ 1.    ผู้ป่วย ST-Elevation Myocardial Infarction (STEMI) ที่ได้รับการทำ Primary PCI2.    ผู้ป่วย NSTE-ACS ที่มี Grace risk score มากกว่า 1403.    ผู้ป่วยที่แพ้หรือไม่ตอบสนองต่อ clopidogrel เช่น เกิด ACS หรือ stent thrombosis ในขณะที่ได้รับยา aspirin ร่วมกับ clopidogrel',
     ''
  ),
  (
     'Streptokinase',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Alteplase',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับภาวะหลอดเลือดแดงส่วนปลายอุดตันที่เกิดจากลิ่มเลือด ในกรณีที่ผู้ป่วยแพ้ streptokinase หรือเคยได้รับ streptokinase ภายใน 6 เดือน2. ใช้สำหรับ acute arterial ischemic stroke โดยแพทย์ผู้เชี่ยวชาญด้านประสาทวิทยา หรือ ประสาทศัลยแพทย์ หรือ แพทย์เวชศาสตร์ฉุกเฉิน สำหรับอายุรแพทย์ทั่วไปและแพทย์ทั่วไป สามารถสั่งได้ในโรงพยาบาลที่มีstroke unit ที่ได้รับการรับรองโดยสถาบันรับรองคุณภาพสถานพยาบาล (องค์การมหาชน) หรือ สถาบันประสาทวิทยา กรมการแพทย์ กระทรวงสาธารณสุข และได้รับการฝึกอบรมหรืออยู่ภายใต้เครือข่ายในการดูแลผู้ป่วยโรคหลอดเลือดสมองเท่านั้น3. ใช้ในกรณีผู้ป่วยโรคหลอดเลือดหัวใจที่ได้รับ aspirin แล้วยังเกิด acute coronary syndrome หรือ recurrent  thrombotic events4. ในกรณีที่ได้รับการวินิจฉัยอย่างชัดเจนแล้วว่าเป็น non-ST elevated acute coronary syndrome  (NSTE-ACS) ให้ใช้ clopidogrel ร่วมกับ aspirin เป็นระยะเวลาไม่เกิน 1 ปี',
     ''
  ),
  (
     'Tenecteplase',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับ ST elevation myocardial infarction (STEMI) ในกรณีที่ผู้ป่วยมีประวัติแพ้ยา Streptokinase หรือเคยได้ Streptokinase มาภายใน 6 เดือน 2. ผู้ป่วยที่มีภาวะ anterior wall STEMI ร่วมกับมีภาวะ hemodynamic instability* ที่ไม่สามารถส่งทำ primary percutaneous coronary intervention (PCI) ภายใน 120 นาที *ภาวะ Hemodynamic instability หมายถึงข้อใดข้อหนึ่งดังต่อไปนี้1. Systolic blood pressure  90 mmHg หรือมีอาการ อาการแสดงของเลือดไปเลี้ยงอวัยวะส่วนต่างๆ ไม่เพียงพอ2. มีภาวะ acute decompensated heart failure ที่เกิดจาก extensive anterior wall myocardial infarction',
     ''
  ),
  (
     'Tranexamic acid',
     '',
     'sterile sol',
     '',
     'ใช้กับผู้ป่วยที่ประสบอุบัติเหตุและมีภาวะเลือดออกรุนแรง การให้ยาภายใน 3 ชั่วโมงมีประสิทธิผลในการลดอัตราการเสียชีวิต แต่การให้ยาหลังจาก 3 ชั่วโมงอาจเพิ่มอัตราการเสียชีวิตจากภาวะเลือดออก'
  ),
  (
     'Tranexamic acid',
     '',
     'cap',
     '',
     '1.  ใช้ในทางทันตกรรมเฉพาะกรณีห้ามเลือดด้วยวิธีปกติแล้วไม่ได้ผล2.  ใช้ก่อนทำหัตถการในช่องปากในผู้ป่วยที่มีแนวโน้มเลือดออกแล้วหยุดยาก3.  ใช้สำหรับภาวะระดูมากผิดปกติ (menorrhagia)'
  ),
  (
     'Human thrombin + Calcium chloride + Fibrinogen +Tranexamic acid',
     '',
     'sterile sol',
     '1.  ใช้สำหรับภาวะเลือดออกจากอุบัติเหตุ การถอนฟัน การผ่าตัดผู้ป่วยที่มีภาวะเลือดออกแล้วหยุดยาก เช่น hemophilia, thrombocytopenia, platelet dysfunction, von Willebrand''s disease และ congenital factor VII deficiency เป็นต้น2. ใช้กับผู้ป่วยที่ได้รับการผ่าตัดซึ่งไม่สามารถห้ามเลือดด้วยวิธีปกติได้ เช่น การผ่าตัดตับ การผ่าตัดหัวใจ การผ่าตัดปอด เป็นต้น',
     ''
  ),
  (
     'Activated prothrombin complex concentrate (APCC)',
     '',
     'sterile pwdr (เฉพาะ 500 IU)',
     'ใช้สำหรับภาวะเลือดออกรุนแรง ในผู้ป่วยฮีโมฟีเลียที่มี high-titer inhibitor ',
     ''
  ),
  (
     'Coagulation factor VIII',
     '',
     'sterile preparation for intravenous use',
     'ใช้สำหรับผู้ป่วยกลุ่มโรคเลือดออกง่ายฮีโมฟีเลีย ',
     ''
  ),
  (
     'Coagulation factor IX',
     '',
     'sterile preparation for intravenous use',
     'ใช้สำหรับผู้ป่วยกลุ่มโรคเลือดออกง่ายฮีโมฟีเลีย ',
     ''
  ),
  (
     'Factor IX complex (coagulation factors II, VII, IX, X) concentrate,  dried',
     '',
     'sterile preparation for intravenous use',
     'ใช้สำหรับผู้ป่วยกลุ่มโรคเลือดออกง่ายฮีโมฟีเลีย ',
     ''
  ),
  (
     'Gemfibrozil',
     '',
     'cap (เฉพาะ 300 และ 600 mg), tab (เฉพาะ 600 mg)',
     '',
     ''
  ),
  (
     'Nicotinic acid',
     '',
     'immediate release tab',
     '',
     ''
  ),
  (
     'Simvastatin',
     '',
     'tab (เฉพาะ 10, 20 และ 40 mg)',
     '',
     '1. กรณีผู้ป่วยรายใหม่ไม่ควรให้ยา simvastatin เกินวันละ 40 mg สำหรับผู้ป่วยที่เคยใช้มานานเกิน 1 ปี โดยไม่เกิดผลข้างเคียงให้ใช้ยาในขนาดเดิมต่อไปได้2. ห้ามใช้ยา simvastatin ร่วมกับ gemfibrozil, cyclosporine, danazol หรือ ยาในกลุ่ม strong CYP3A4 inhibitors เช่น itraconazole, ketoconazole, erythromycin, clarithromycin, telithromycin, HIV protease inhibitors เป็นต้น หากหลีกเลี่ยงไม่ได้ ให้หยุดยา simvastatin ระหว่างใช้ยาดังกล่าว3. หลีกเลี่ยงการใช้ยา simvastatin 3.1 ในขนาดเกินวันละ 20 mg เมื่อใช้ร่วมกับยา amlodipine หรือ amiodarone3.2 ในขนาดเกินวันละ 10 mg เมื่อใช้ร่วมกับยา diltiazem หรือ verapamil'
  ),
  (
     'Atorvastatin',
     '',
     'tab (เฉพาะ 40 mg)',
     '1. ใช้กับผู้ป่วยที่ใช้ยา simvastatin ในขนาด 40 mg ติดต่อกัน 6 เดือน แล้วยังไม่สามารถควบคุมระดับ LDL-C ได้ถึงค่าเป้าหมาย (ดูเงื่อนไข simvastatin) หรือ2. ใช้กับผู้ป่วยที่ไม่สามารถใช้ simvastatin ได้กล่าวคือมีผลข้างเคียง ได้แก่ มีค่า alanine aminotransferase (ALT) เพิ่มขึ้น 3 เท่าของค่าสูงสุดของค่าปกติ (upper limit of normal) หรือค่า Creatine phosphokinase (CPK) เพิ่มขึ้นมากกว่า 5 เท่าของค่าสูงสุดของค่าปกติ',
     '1.  หลีกเลี่ยงการใช้ยา atorvastatin ร่วมกับ cyclosporine, HIV protease inhibitor (tipranavir + ritonavir),   hepatitis C protease inhibitor (telaprevir)2.  หลีกเลี่ยงการใช้ยา atorvastatin  2.1  ในขนาดเกินวันละ 40 mg เมื่อใช้ร่วมกับยา nelfinavir 2.2  ในขนาดเกินวันละ 20 mg เมื่อใช้ร่วมกับยา clarithromycin, itraconazole, HIV protease inhibitor (saquinavir + ritonavir, darunavir + ritonavir, fosamprenavir, fosamprenavir + ritonavir)3.  ระมัดระวังการใช้ยา atorvastatin ร่วมกับยา lopinavir + ritonavir โดยให้ใช้ยา atorvastatin ในขนาดต่ำสุดเท่าที่จำเป็น'
  ),
  (
     'Colestyramine',
     '',
     'oral pwdr',
     '',
     ''
  ),
  (
     'Fenofibrate',
     '',
     'cap (เฉพาะ 100 และ 200 )',
     '',
     ''
  ),
  (
     'Ezetimibe',
     '',
     'tab (เฉพาะ 10 mg)',
     '1.ใช้เป็นยาขนานแรกของการรักษา (first-line treatment) สำหรับผู้ป่วยโรค sitosterolemia2.ใช้สำหรับผู้ที่มีความเสี่ยงทางด้าน cardiovascular disease สูงหรือสูงมาก ที่ใช้ยากลุ่ม statin เต็มที่แล้ว และยังไม่สามารถควบคุม LDL-C ลงมาถึงเป้าหมาย เช่น LDL-C มากกว่าหรือเท่ากับ 55 มิลลิกรัมต่อเดซิลิตร ในระยะ follow up 4-6 สัปดาห์ ภายหลัง acute coronary syndrome, LDL-C มากกว่าหรือเท่ากับ 70 มิลลิกรัมต่อเดซิลิตร สำหรับ chronic coronary disease',
     ''
  ),
  (
     'Procaterol hydrochloride',
     '',
     'syr',
     '',
     ''
  ),
  (
     'Salbutamol sulfate',
     '',
     'tab, aqueous sol, DPI, MDI, sol for nebulizer',
     '',
     ''
  ),
  (
     'Terbutaline sulfate',
     '',
     'tab, syr, sterile sol',
     '',
     ''
  ),
  (
     'Terbutaline sulfate',
     '',
     'sol for nebulizer',
     '',
     ''
  ),
  (
     'Procaterol hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Ipratropium bromide + Fenoterol hydrobromide',
     '',
     'MDI, sol for nebulizer',
     '',
     ''
  ),
  (
     'Tiotropium bromide',
     '',
     'DPI (เฉพาะ 18 mcg)',
     '',
     ''
  ),
  (
     'Vilanterol trifenatate + Umeclidinium bromide',
     '',
     'DPI (เฉพาะ 22+55 mcg/dose)',
     'ใช้สำหรับผู้ป่วยโรคปอดอุดกั้นเรื้อรัง group B (mMRC2 และ CAT score 10)',
     ''
  ),
  (
     'Olodaterol hydrochloride + Tiotropium bromide',
     '',
     'inhalation sol',
     'ใช้สำหรับผู้ป่วยโรคปอดอุดกั้นเรื้อรัง group B (mMRC2 และ CAT score 10) ที่เคยได้รับการรักษาด้วยยา tiotropium DPI (ขนาด 18 ไมโครกรัม) แต่ยังไม่สามารถควบคุมอาการได้',
     ''
  ),
  (
     'Aminophylline',
     '',
     'tab, sterile sol',
     '',
     ''
  ),
  (
     'Theophylline',
     '',
     'SR cap , SR tab',
     '',
     ''
  ),
  (
     'Theophylline + Glyceryl guaiacolate',
     '',
     'syr (50+30 mg in 5 ml)',
     '',
     ''
  ),
  (
     'Budesonide',
     '',
     'DPI, MDI, susp for nebulizer',
     '',
     ''
  ),
  (
     'Fluticasone propionate',
     '',
     'susp for nebulizer',
     '',
     ''
  ),
  (
     'Fluticasone propionate',
     '',
     'MDI',
     'ใช้เป็นยาทางเลือกกรณีต้องการใช้ยาที่มี potency สูงในการรักษา',
     ''
  ),
  (
     'Budesonide + Formoterol',
     '',
     'DPI',
     '',
     ''
  ),
  (
     'Fluticasone propionate + Salmeterol',
     '',
     'DPI, MDI',
     '',
     ''
  ),
  (
     'Montelukast sodium',
     '',
     'chewable tab (เฉพาะ 5 mg), film coated tab (เฉพาะ 10 mg), oral granules (เฉพาะ 4 mg)',
     'ใช้ยาชนิด oral granules กับเด็กอายุตั้งแต่ 6 เดือน ถึง 5 ปี',
     'ควรติดตามอาการไม่พึงประสงค์ทาง neuropsychiatric จากการใช้ยาอย่างต่อเนื่อง'
  ),
  (
     'Brompheniramine maleate',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Chlorpheniramine maleate',
     '',
     'cap, tab, syr, sterile sol',
     '',
     ''
  ),
  (
     'Diphenhydramine  hydrochloride',
     '',
     'cap, sterile sol',
     '',
     ''
  ),
  (
     'Hydroxyzine hydrochloride',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Cetirizine hydrochloride',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Loratadine',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Phospholipids (ชนิด Poractant alfa หรือ Beractant)',
     '',
     'sterile intratracheal susp',
     '1. ให้เลือกหนึ่งรายการที่จัดซื้อได้ถูกกว่าระหว่าง Poractant alfa กับ Beractant2. ใช้โดยผู้เชี่ยวชาญกุมารแพทย์',
     ''
  ),
  (
     'Dextromethorphan hydrobromide',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Opium and Glycyrrhiza Mixture Compound',
     '',
     'mixt (hosp)',
     '',
     ''
  ),
  (
     'Squill and Ammonia Mixture',
     '',
     'mixt (hosp)',
     '',
     ''
  ),
  (
     'Codeine phosphate + Glyceryl guaiacolate',
     '',
     'tab/cap (เฉพาะ 10+100 mg)',
     '',
     ''
  ),
  (
     'Ammonium carbonate and senega mixture',
     '',
     'mixt (hosp)',
     '',
     ''
  ),
  (
     'Glyceryl guaiacolate',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Pseudoephedrine  hydrochloride',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'tab, syr',
     '',
     ''
  ),
  (
     'Aromatic Ammonia Spirit',
     '',
     'spirit ,spirit (hosp)',
     '',
     ''
  ),
  (
     'Caffeine citrate',
     '',
     'oral sol (hosp)',
     'ใช้รักษาอาการหยุดหายใจขั้นปฐมภูมิ (primary apnea) ในทารกแรกเกิดก่อนกําหนด (premature newborns)',
     ''
  ),
  (
     'Chloral hydrate',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Chlordiazepoxide',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'cap,tab',
     '',
     ''
  ),
  (
     'Diazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'cap, tab, sterile sol',
     '',
     ''
  ),
  (
     'Lorazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'tab',
     '',
     ''
  ),
  (
     'Clonazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'tab',
     '',
     ''
  ),
  (
     'Dipotassium clorazepate',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'cap, tab',
     '',
     ''
  ),
  (
     'Hydroxyzine hydrochloride',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Chlorpromazine hydrochloride',
     '',
     'tab, sterile sol',
     '',
     ''
  ),
  (
     'Fluphenazine',
     '',
     'tab (as hydrochloride), sterile sol (as decanoate)',
     '',
     ''
  ),
  (
     'Haloperidol',
     '',
     'tab (as base), oral sol (as base), sterile sol (as base or decanoate)',
     '',
     ''
  ),
  (
     'Perphenazine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Trifluoperazine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Risperidone',
     '',
     'tab (ไม่รวมชนิดละลายในปาก) , oral sol, oral sol (hosp), syr (hosp)',
     '',
     'ไม่แนะนำให้ใช้ในเด็กอายุต่ำกว่า 5 ขวบ'
  ),
  (
     'Thioridazine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Clozapine',
     '',
     'tab',
     '1. ไม่ใช้เป็นยาตัวแรกในการรักษา  2. ควรได้รับการวินิจฉัย และการรักษาเบื้องต้นโดยแพทย์ผู้เชี่ยวชาญด้านจิตเวชศาสตร์',
     ''
  ),
  (
     'Flupentixol',
     '',
     'tab (as hydrochloride), sterile sol (as decanoate)',
     'ใช้ในกรณีใช้ยาอื่นไม่ได้ผล',
     ''
  ),
  (
     'Pimozide',
     '',
     'tab',
     '1. ไม่ใช้เป็นยาตัวแรกในการรักษา  2. ควรได้รับการวินิจฉัย และการรักษาเบื้องต้นโดยแพทย์ผู้เชี่ยวชาญด้านจิตเวชศาสตร์',
     ''
  ),
  (
     'Quetiapine fumarate',
     '',
     'immediate release tab (เฉพาะ 200 mg)',
     '1. ใช้สำหรับ schizophrenia ที่ไม่ตอบสนองหรือไม่สามารถใช้ยา risperidone หรือ clozapine ได้ 2. ใช้สำหรับ bipolar disorder ที่ไม่ตอบสนองต่อการรักษาอื่น',
     ''
  ),
  (
     'Aripiprazole',
     '',
     'Inj (ชนิดออกฤทธิ์นาน)',
     'ใช้สำหรับโครงการนำร่องและติดตามการใช้ยาในผู้ป่วยจิตเภท และผู้ป่วยโรคอารมณ์สองขั้ว กลุ่มที่มีความเสี่ยงสูงต่อการก่อความรุนแรง (Serious Mental illness with High Risk to Violence: SMI-V) ของกรมสุขภาพจิตและสำนักงานหลักประกันสุขภาพแห่งชาติ',
     ''
  ),
  (
     'Carbamazepine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Lithium carbonate',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Sodium valproate',
     '',
     'EC tab, oral sol',
     '',
     ''
  ),
  (
     'Carbamazepine',
     '',
     'SR tab',
     '',
     ''
  ),
  (
     'Sodium valproate',
     '',
     'SR tab',
     '',
     ''
  ),
  (
     'Lamotrigine',
     '',
     'tab (เฉพาะ 25, 50, 100 mg)',
     '1. ใช้สำหรับ rapid cycling mood disorder หรือ recurrent mood disorder ที่ไม่ตอบสนองต่อการรักษาอื่น2. ใช้ในกรณีป้องกัน depression ใน Bipolar disorder ที่ไม่ตอบสนองต่อการรักษาอื่น',
     ''
  ),
  (
     'Amitriptyline hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Fluoxetine hydrochloride',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Imipramine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Nortriptyline hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Sertraline',
     '',
     'tab(เฉพาะ 50 mg)',
     '',
     ''
  ),
  (
     'Mianserin hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Clomipramine hydrochloride',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Trazodone hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Methylphenidate',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'tab (เฉพาะ10 mg)',
     '1. ใช้สำหรับ Attention-Deficit Hyperactivity Disorder (ADHD)2. ใช้สำหรับ narcolepsy',
     ''
  ),
  (
     'Domperidone',
     '',
     'tab (as base/maleate), susp (as base/maleate)',
     '',
     ''
  ),
  (
     'Metoclopramide',
     '',
     'tab, syr, sterile sol',
     '',
     ''
  ),
  (
     'Ondansetron',
     '',
     'tab (as base or hydrochloride), sterile sol (hydrochloreide)',
     '',
     ''
  ),
  (
     'Olanzapine',
     '',
     'tab (เฉพาะ 5 และ 10 mg ไม่รวมชนิดเม็ดละลายในปาก)',
     '1. ใช้สำหรับป้องกันหรือรักษาการคลื่นไส้อาเจียนจากการได้รับยาเคมีบำบัดที่กระตุ้นให้อาเจียนสูง (highly emetogenic)2. ใช้สำหรับป้องกันหรือรักษาการคลื่นไส้อาเจียนจากการได้รับยาเคมีบำบัด กรณี resistance หรือ intractable nausea/ vomiting',
     ''
  ),
  (
     'Dimenhydrinate',
     '',
     'compressed tab, film coated tab, syr, sterile sol',
     '',
     ''
  ),
  (
     'Betahistine mesilate',
     '',
     'tab (เฉพาะ 6, 12 mg)',
     '',
     ''
  ),
  (
     'Paracetamol',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Aspirin',
     '',
     'compressed tab/film coated tab (เฉพาะขนาด 300 mg ขึ้นไป)',
     '',
     'ห้ามใช้ในเด็กและวัยรุ่นอายุต่ำกว่า 18 ปี สำหรับลดไข้ แก้ปวด เพราะเสี่ยงต่อการเกิด Reye''s syndrome'
  ),
  (
     'Ibuprofen',
     '',
     'film coated tab, susp',
     '',
     '1. ไม่ควรใช้ ibuprofen ระยะยาวในผู้ป่วยที่ใช้ low dose aspirin เนื่องจากอาจมีผลต่อต้านประสิทธิภาพในการป้องกันโรคหัวใจของยาแอสไพริน2. ใช้ในเด็กที่มีอายุ 3 เดือนขึ้นไปเท่านั้น3. ระมัดระวังการใช้ในผู้ป่วยที่มีเกล็ดเลือดต่ำ เช่น ไข้เลือดออก'
  ),
  (
     'Buprenorphine hydrochloride',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'sublingual tab, sterile sol',
     '',
     ''
  ),
  (
     'Codeine phosphate',
     'ยาเสพติดให้โทษประเภท 2',
     'tab',
     '',
     ''
  ),
  (
     'Fentanyl',
     'ยาเสพติดให้โทษประเภท 2',
     'sterile sol (as citrate), transdermal therapeutic system (as base)',
     'ใช้กับผู้ป่วยโรคมะเร็งที่มีความเจ็บปวดรุนแรง',
     ''
  ),
  (
     'Methadone hydrochloride',
     'ยาเสพติดให้โทษประเภท 2',
     'tab, oral sol',
     '',
     ''
  ),
  (
     'Morphine sulfate',
     'ยาเสพติดให้โทษประเภท 2',
     'cap, tab, SR cap, SR tab, oral sol, sterile sol',
     '',
     ''
  ),
  (
     'Nalbuphine hydrochloride',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Pethidine hydrochloride',
     'ยาเสพติดให้โทษประเภท 2',
     'sterile sol',
     '',
     ''
  ),
  (
     'Tramadol hydrochloride',
     '',
     'cap, tab, SR cap, SR tab, sterile sol',
     '',
     ''
  ),
  (
     'Amitriptyline hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Carbamazepine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Nortriptyline hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Carbamazepine',
     '',
     'SR tab',
     '',
     ''
  ),
  (
     'Gabapentin',
     '',
     'cap (เฉพาะ 100, 300, 400 mg), tab (เฉพาะ 600 mg)',
     'ใช้บรรเทาอาการปวดซึ่งเกิดจากความผิดปกติของเส้นประสาทเท่านั้น',
     ''
  ),
  (
     'Paracetamol',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Aspirin',
     '',
     'compressed tab/film coated tab (เฉพาะขนาด 300 mg ขึ้นไป)',
     '',
     'ดูรายละเอียดหัวข้อ 4.6 Analgesics and antipyretics'
  ),
  (
     'Ibuprofen',
     '',
     'film coated tab',
     '',
     ''
  ),
  (
     'Ergotamine tartrate + Caffeine',
     '',
     'compressed tab/film coated tab (เฉพาะ 1 + 100 mg)',
     '',
     ''
  ),
  (
     'Dihydroergotamine mesilate',
     'ยากำพร้า',
     'sterile sol  (เฉพาะ 1 mg/ml)',
     '1. ใช้สำหรับรักษาอาการปวดศีรษะไมเกรนเฉียบพลันชนิดรุนแรง (status migrainosus)2. ใช้สำหรับรักษาอาการปวดศีรษะจากการใช้ยา (medication overuse headache หรือ rebound headache) ที่ไม่ตอบสนองต่อการรักษามาตรฐาน3. ใช้โดยแพทย์ผู้เชี่ยวชาญด้านประสาทวิทยา',
     ''
  ),
  (
     'Amitriptyline hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Propranolol hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Cyproheptadine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Sodium valproate',
     '',
     'EC tab, SR tab',
     'ใช้โดยผู้เชี่ยวชาญด้านระบบประสาทเท่านั้น',
     ''
  ),
  (
     'Topiramate',
     '',
     'tab',
     '1. ห้ามใช้เป็นยาตัวแรกในการป้องกันไมเกรน  2. ใช้ในกรณีใช้ยาอื่นแล้วไม่ได้ผล',
     ''
  ),
  (
     'Carbamazepine',
     '',
     'tab, syr, susp',
     '',
     ''
  ),
  (
     'Magnesium sulfate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Phenobarbital',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'tab (as base), sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Phenytoin base',
     '',
     'chewable tab',
     '',
     ''
  ),
  (
     'Phenytoin sodium',
     '',
     'cap, SR cap, sterile sol',
     '',
     ''
  ),
  (
     'Sodium valproate',
     '',
     'EC tab, SR tab,  oral sol, sterile pwdr',
     '',
     ''
  ),
  (
     'Carbamazepine',
     '',
     'SR tab',
     '',
     ''
  ),
  (
     'Clonazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'tab',
     '',
     ''
  ),
  (
     'Lamotrigine',
     '',
     'tab (เฉพาะ 25, 50, 100 mg)',
     'ใช้กับผู้ป่วยที่ใช้ยาอื่นไม่ได้หรือไม่ได้ผล โดยแพทย์ผู้เชี่ยวชาญด้านระบบประสาท*',
     ''
  ),
  (
     'Levetiracetam',
     '',
     'tab (เฉพาะ 250 และ 500 mg), oral sol',
     '1.ใช้กับผู้ป่วยที่ใช้ยาอื่นไม่ได้หรือไม่ได้ผล2.ชนิดน้ำใช้ในผู้ป่วยเด็ก หรือผู้ป่วยที่ไม่สามารถกลืนยาเม็ดได้',
     ''
  ),
  (
     'Clobazam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'tab',
     '1.ใช้เป็นยากันชักแบบเสริม (adjunctive treatment) ในโรคลมชัก 2.สั่งใช้ยาโดยประสาทแพทย์ หรือกุมารแพทย์ระบบประสาท หรือประสาทศัลยแพทย์เท่านั้น',
     ''
  ),
  (
     'Nitrazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'tab',
     'ใช้สำหรับ epileptic spasms  โดยแพทย์ผู้เชี่ยวชาญด้านประสาทวิทยา',
     ''
  ),
  (
     'Topiramate',
     '',
     'cap, tab',
     'ใช้กับผู้ป่วยที่ใช้ยาอื่นไม่ได้หรือไม่ได้ผล โดยแพทย์ผู้เชี่ยวชาญด้านระบบประสาท*',
     ''
  ),
  (
     'Vigabatrin',
     '',
     'tab',
     '1. ใช้ในการควบคุมอาการชัก โดยแพทย์ผู้เชี่ยวชาญด้านระบบประสาท*2. ใช้สำหรับ epileptic spasms โดยแพทย์ผู้เชี่ยวชาญด้านกุมารประสาทวิทยา',
     ''
  ),
  (
     'Diazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'sterile sol',
     '',
     ''
  ),
  (
     'Lorazepam',
     'ยากำพร้า, วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'inj',
     '',
     ''
  ),
  (
     'Phenobarbital  sodium',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Phenytoin sodium',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Sodium valproate',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Levetiracetam',
     '',
     'concentrate for solution for infusion',
     '1. ไม่ใช้เป็นยาตัวแรกในการรักษาภาวะชักต่อเนื่อง ยกเว้นมีประวัติแพ้ยาหรือไม่ตอบสนองต่อยาในกลุ่ม first generation คือ diazepam, lorazepam, phenytoin sodium, phenobarbital sodium และ sodium valproate2. สั่งใช้โดยแพทย์ผู้เชี่ยวชาญ สาขาประสาทวิทยา สาขากุมารประสาทวิทยา และประสาทศัลยศาสตร์ เท่านั้น ในกรณีที่ไม่สามารถส่งต่อผู้ป่วยไปพบแพทย์ผู้เชี่ยวชาญดังกล่าวได้ และอยู่ในหอผู้ป่วยวิกฤต (ICU) อนุญาตให้อายุรแพทย์ และกุมารแพทย์รักษาได้',
     ''
  ),
  (
     'Midazolam hydrochloride',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'sterile sol',
     '1. ใช้สำหรับ refractory status epilepticus2. สั่งใช้โดยแพทย์ผู้เชี่ยวชาญ สาขาประสาทวิทยา สาขากุมารประสาทวิทยา และประสาทศัลยศาสตร์ เท่านั้น ในกรณีที่ไม่สามารถส่งต่อผู้ป่วยไปพบแพทย์ผู้เชี่ยวชาญดังกล่าวได้ และอยู่ในหอผู้ป่วยวิกฤต (ICU) อนุญาตให้อายุรแพทย์ และกุมารแพทย์รักษาได้',
     ''
  ),
  (
     'Lacosamide',
     '',
     'sterile sol',
     'ภาวะ refractory status epilepticus ที่ไม่ตอบสนองต่อยากันชักพื้นฐานอย่างน้อย 3 ชนิด ',
     ''
  ),
  (
     'Diazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'cap,tab',
     '',
     ''
  ),
  (
     'Levodopa + Benserazide as hydrochloride',
     '',
     'cap/tab (200+50 mg)',
     '',
     ''
  ),
  (
     'Levodopa + Carbidopa as monohydrate',
     '',
     'tab (100+25 mg, 250+25 mg)',
     '',
     ''
  ),
  (
     'Propranolol hydrochloride',
     '',
     'tab',
     'ใช้สำหรับ essential tremor',
     ''
  ),
  (
     'Trihexyphenidyl hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Baclofen',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Clonazepam',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'tab',
     '',
     ''
  ),
  (
     'Levodopa + Benserazide as hydrochloride',
     '',
     'CR cap/dispersible tab (100+25 mg)',
     '',
     ''
  ),
  (
     'Absolute alcohol',
     'ยากำพร้า',
     'inj',
     'ใช้สำหรับภาวะกล้ามเนื้อหดเกร็ง (spasticity) หรือ ภาวะ dystonia',
     ''
  ),
  (
     'Amantadine  hydrochloride',
     'ยากำพร้า',
     'tab (เฉพาะ 100 mg)',
     'ใช้สำหรับลดอาการของโรคพาร์กินสันและอาการ levodopa-induced dyskinesia',
     ''
  ),
  (
     'Entacapone',
     '',
     'tab',
     'ใช้โดยแพทย์ผู้เชี่ยวชาญในกรณีที่ใช้ยาอื่นไม่ได้ผล',
     ''
  ),
  (
     'Phenol',
     'ยากำพร้า',
     'inj',
     'ใช้สำหรับภาวะกล้ามเนื้อหดเกร็ง (spasticity)',
     ''
  ),
  (
     'Ropinirole',
     '',
     'SR tab',
     'ใช้ในผู้ป่วยโรคพาร์กินสัน กรณีที่ผู้ป่วยมีภาวะที่ตอบสนองต่อยา Levodopa ไม่สม่ำเสมอ และรบกวนต่อชีวิตประจำวัน โดยมี total disabling off time มากกว่า 3 ชั่วโมงต่อวัน',
     ''
  ),
  (
     'Tetrabenazine',
     'ยากำพร้า',
     'tab (เฉพาะ 12.5 mg, 25 mg)',
     'ใช้สำหรับ chorea ที่สัมพันธ์กับ Huntingtons disease',
     ''
  ),
  (
     'Botulinum A toxin',
     '',
     'sterile pwdr (เฉพาะ 100 และ 500 IU)',
     '1. ใช้สำหรับโรคคอบิด (cervical dystonia) ชนิดไม่ทราบสาเหตุ (idiopathic)  2. ใช้สำหรับโรคใบหน้ากระตุกครึ่งซีก (hemifacial spasm) ชนิดไม่ทราบสาเหตุ (idiopathic) 3.  ใช้สำหรับโรค spasmodic  dysphonia ',
     ''
  ),
  (
     'Acamprosate',
     'ยากำพร้า',
     'oral form',
     'ใช้สำหรับ alcohol dependence และ maintenance of abstinence',
     ''
  ),
  (
     'Naltrexone',
     'ยากำพร้า',
     'oral form',
     'ใช้สำหรับ alcohol dependence และ maintenance of abstinence ในกรณีที่ไม่สามารถใช้ยา acamprosate ได้ หรือมีการทำงานของไตที่ผิดปกติระดับรุนแรง',
     ''
  ),
  (
     'Nortriptyline hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Cytisinicline (Cytisine)',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Clonidine hydrochloride',
     '',
     'tab',
     'ใช้สำหรับ heroin withdrawal',
     ''
  ),
  (
     'Methadone hydrochloride',
     'ยาเสพติดให้โทษประเภท 2',
     'oral sol',
     'ใช้สำหรับผู้ป่วยติดเฮโรอีน',
     ''
  ),
  (
     'Donepezil hydrochloride',
     '',
     'tab (เฉพาะ 5 mg และ 10 mg), oral disintegration tab (เฉพาะ 5 mg และ 10 mg)',
     'ใช้สำหรับภาวะสมองเสื่อมจากโรคอัลไซเมอร์ที่มีระดับรุนแรงน้อยถึงปานกลาง',
     ''
  ),
  (
     'Amoxicillin trihydrate',
     '',
     'cap,dry syr',
     '',
     ''
  ),
  (
     'Ampicillin sodium',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Cloxacillin sodium',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Dicloxacillin sodium',
     '',
     'cap, dry syr',
     '',
     ''
  ),
  (
     'Phenoxymethylpenicillin potassium',
     '',
     'cap, tab, dry syr',
     '',
     ''
  ),
  (
     'Benzylpenicillin',
     '',
     'sterile pwdr (as sodium or potassium)',
     '',
     ''
  ),
  (
     'Benzathine benzylpenicillin',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Procaine benzylpenicillin',
     '',
     'sterile sol, sterile susp',
     '',
     ''
  ),
  (
     'Amoxicillin trihydrate + Potassium clavulanate',
     '',
     'tab (เฉพาะ 500 + 125, 875 + 125 mg), dry syr (เฉพาะ 400 + 57 mg)',
     '1. ใช้สำหรับการติดเชื้อที่สงสัยว่าอาจจะเกิดจากเชื้อ H. influenzae และ/หรือ M. catarrhalis ที่ดื้อต่อ ampicillin2. ใช้รักษาโรคติดเชื้อผสมระหว่างแบคทีเรียชนิด aerobes และ anaerobes3. ใช้ยาเม็ดเฉพาะความแรง 500+125 mg ในการรักษา melioidosis เพื่อใช้เป็นยาแทน (alternative drug) ของ  oral co-trimoxazole',
     ''
  ),
  (
     'Amoxicillin sodium + Potassium clavulanate',
     '',
     'sterile pwdr',
     '1. ใช้รักษาโรคติดเชื้อแบคทีเรียจำเพาะที่ดื้อต่อ ampicillin โดยเฉพาะที่ผลิตเอนไซม์ beta-lactamase2. ใช้รักษาโรคติดเชื้อผสมระหว่างแบคทีเรียชนิด aerobes และ anaerobes',
     ''
  ),
  (
     'Ampicillin sodium + Sulbactam sodium',
     '',
     'sterile pwdr',
     'เช่นเดียวกับ Co-amoxiclav sterile pwdr',
     ''
  ),
  (
     'Piperacillin sodium + Tazobactam sodium',
     '',
     'sterile pwdr',
     '1. ใช้ในกรณีที่ใช้ยากลุ่ม third generation cephalosporins ไม่ได้ โดยให้พิจารณาเลือกใช้ก่อนยากลุ่ม carbapenems ทั้งใน empiric และspecific therapy สำหรับ nosocomial infection เช่น pneumonia, complicated skin and soft tissue infection, intra-abdominal infection และ febrile neutropenia2. ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ',
     ''
  ),
  (
     'Cefalexin',
     '',
     'cap, dry syr',
     '',
     ''
  ),
  (
     'Cefazolin sodium',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Cefuroxime axetil',
     '',
     'tab, dry syr',
     '',
     ''
  ),
  (
     'Cefotaxime sodium',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับการติดเชื้อในทารกแรกเกิด เพื่อหลีกเลี่ยงการเกิด kernicterus จากการใช้ยา ceftriaxone2. ใช้สำหรับโรคติดเชื้อในระบบประสาทส่วนกลางที่เกิดจากแบคทีเรียกรัมลบ ในเด็กอายุน้อยกว่า 1 ปี3. ใช้เป็นยาแทน (alternative drug) ของ ceftriaxone แต่ต้องให้ยาบ่อยกว่า ceftriaxone',
     ''
  ),
  (
     'Ceftriaxone sodium',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับ serious community acquired bacterial infection ยกเว้นการติดเชื้อ Pseudomonas aeruginosa2. ใช้สำหรับ gram-negative meningitis ยกเว้นในเด็กอายุน้อยกว่า 1 ปี3. ใช้สำหรับการติดเชื้อ Penicillin Resistant Streptococcus pneumoniae (PRSP)4. ใช้สำหรับการติดเชื้อแบคทีเรียกรัมลบบางกรณี ในผู้ป่วยที่ไตทำงานบกพร่อง หรือมีข้อห้ามซึ่งไม่สามารถใช้ยากลุ่ม  aminoglycosides ได้5. ใช้สำหรับการติดเชื้อ Neisseria gonorrhoeae6. ใช้กับผู้ป่วยซิฟิลิสที่ไม่ได้ตั้งครรภ์ ซึ่งใช้ benzathine penicillin หรือ doxycycline ไม่ได้',
     ''
  ),
  (
     'Ceftazidime',
     '',
     'sterile pwdr',
     'ใช้เป็น empiric/specific therapy สำหรับการติดเชื้อ P. aeruginosa และ melioidosis',
     ''
  ),
  (
     'Cefixime',
     '',
     'cap, dry syr',
     '1. ใช้เป็น switch therapy ในการรักษาโรคติดเชื้อแบคทีเรียกรัมลบ2. ใช้รักษาหนองในแท้เฉพาะที่อวัยวะเพศและทวารหนัก เมื่อไม่สามารถใช้ยา Ceftriaxone ได้ 3. ใช้รักษาการติดเชื้อในระบบทางเดินปัสสาวะ ในกรณีที่ใช้ยากลุ่ม fluoroquinolone แล้วดื้อยาหรือไม่ได้ผล',
     ''
  ),
  (
     'Cefoperazone sodium + Sulbactam sodium',
     '',
     'sterile pwdr',
     'ใช้สำหรับ nosocomial infection จากเชื้อแบคทีเรียกรัมลบ โดยเฉพาะการติดเชื้อ Acinetobacter sp.',
     ''
  ),
  (
     'Cefoxitin sodium',
     '',
     'sterile pwdr',
     '1. ใช้เป็นยาแทน (alternative drug) ของยามาตรฐานในการป้องกันการติดเชื้อจากการผ่าตัดในช่องท้องซึ่งเป็นไปตามแนวทางการใช้ยาต้านจุลชีพ เพื่อป้องกันการติดเชื้อจากการผ่าตัด2. ใช้สำหรับการติดเชื้อ Non-tuberculosis Mycobacterium sp. (atypical mycobacterium) สำหรับกลุ่ม rapid growers เท่านั้น',
     ''
  ),
  (
     'Ertapenem sodium',
     '',
     'sterile pwdr',
     'ใช้เป็น documented therapy สำหรับเชื้อ Enterobacteriaceae ที่สร้าง Extended Spectrum Beta-Lactamase (ESBL) หรือเชื้อ Enterobacteriaceae ที่ดื้อต่อยา cephalosporins รุ่นที่ 3 (ceftriaxone, cefotaxime, ceftazidime) และไวต่อยากลุ่ม carbapenems',
     ''
  ),
  (
     'Imipenem + Cilastatin sodium',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับโรคติดเชื้อในโรงพยาบาลที่เกิดจากแบคทีเรียรูปแท่งกรัมลบที่ดื้อยาหลายชนิด (Multiple-Drug- Resistant, MDR) ซึ่งควรมีผลการทดสอบความไวทางห้องปฏิบัติการมายืนยัน2. ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ',
     ''
  ),
  (
     'Meropenem',
     '',
     'sterile pwdr',
     'เช่นเดียวกับ Imipenem+Cilastatin sodium',
     ''
  ),
  (
     'Ceftazidime + Avibactam',
     '',
     'sterile pwdr  (เฉพาะ 2 g + 500 mg)',
     'ใช้รักษาการติดเชื้อ carbapenem-resistant enterobacterales (CRE) ที่ไวต่อยา ceftazidime + avibactam ในผู้ป่วยที่ไม่สามารถใช้ colistimethate sodium ได้ ',
     ''
  ),
  (
     'Doxycycline hyclate',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Tetracycline hydrochloride',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Gentamicin sulfate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Amikacin sulfate',
     '',
     'sterile sol',
     'ใช้สำหรับการติดเชื้อแบคทีเรียกรัมลบชนิดที่ดื้อต่อ gentamicin และ/หรือ netilmicin',
     ''
  ),
  (
     'Netilmicin sulfate',
     '',
     'sterile sol',
     'ใช้เฉพาะการติดเชื้อแบคทีเรียกรัมลบที่ดื้อต่อยา gentamicin และ amikacin ซึ่งต้องมีผลการทดสอบความไวทางห้องปฏิบัติการมายืนยัน',
     ''
  ),
  (
     'Erythromycin estolate',
     '',
     'susp, dry syr',
     'ใช้กับเด็กอายุต่ำกว่า 6 ปี',
     ''
  ),
  (
     'Erythromycin stearate or succinate',
     '',
     'dry syr',
     '',
     ''
  ),
  (
     'Roxithromycin',
     '',
     'cap/tab (เฉพาะ 100 และ 150 mg)',
     '',
     ''
  ),
  (
     'Azithromycin',
     '',
     'cap (ไม่รวมชนิดออกฤทธิ์นาน) , dry syrup (ไม่รวมชนิดซองและชนิดออกฤทธิ์นาน)',
     '1.  ใช้สำหรับการติดเชื้อทางเดินหายใจส่วนล่าง กรณีที่ใช้ยาอื่นไม่ได้หรือไม่ได้ผล2.  ใช้รักษาการติดเชื้อ non-tuberculous mycobacterium (NTM)3. ยา azithromycin ขนาด 2 กรัม กินครั้งเดียว สำหรับรักษาผู้ป่วย early syphilis ที่ไม่สามารถใช้  ยา penicillin หรือ doxycycline หรือ ceftriaxone ได้4. ใช้สำหรับ non-severe rickettsiosis ที่ผู้ป่วยไม่สามารถทนผลข้างเคียงของยา doxycycline ได้ หรือผู้ป่วยมีข้อห้ามในการใช้ยา doxycycline',
     ''
  ),
  (
     'Azithromycin',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับการติดเชื้อของทางเดินหายใจส่วนล่างที่รุนแรงและอาจเกิดจาก atypical pathogen เช่น   legionellosis เป็นต้น2. ใช้สำหรับ severe rickettsiosis',
     ''
  ),
  (
     'Clarithromycin',
     '',
     'tab, dry syr',
     '1. ใช้สำหรับการติดเชื้อของทางเดินหายใจ ในกรณีที่ใช้ยาอื่นไม่ได้หรือไม่ได้ผล2. ใช้ในข้อบ่งใช้พิเศษสำหรับโรคติดเชื้อ non-tuberculous Mycobacterium sp. (atypical mycobacterium)3. ใช้ใน triple therapy หรือ quadruple therapy สำหรับกำจัดเชื้อ H. pylori หลังจากได้รับการตรวจยืนยันว่ามีเชื้อแล้ว',
     ''
  ),
  (
     'Norfloxacin',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Ofloxacin',
     '',
     'tab (เฉพาะ 100, 200 mg)',
     'ใช้เป็นยาแทน (alternative drug) ในการรักษาโรคติดเชื้อแบคทีเรียกรัมลบ',
     ''
  ),
  (
     'Ciprofloxacin hydrochloride',
     '',
     'tab',
     'ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ เช่น ใช้ต่อเนื่องจากยาฉีด (sequential therapy หรือ switch therapy)',
     ''
  ),
  (
     'Ciprofloxacin lactate',
     '',
     'sterile sol',
     'ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ เช่น1. ใช้สำหรับรักษาการติดเชื้อแบคทีเรียกรัมลบที่ไม่สามารถใช้ยากลุ่ม beta-lactam และ/หรือยากลุ่ม aminoglycoside ได้2. ใช้เป็น empiric therapy ใน 3 วันแรกของการรักษาร่วมกับยากลุ่ม beta-lactam และ/หรือ aminoglycoside ในการรักษา severe hospital-acquired pneumonia ในกรณีที่ไม่สามารถรับประทานยาได้',
     ''
  ),
  (
     'Levofloxacin hemihydrate',
     '',
     'tab (เฉพาะ 500 และ 750 mg)',
     'ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อหรือแพทย์ผู้เชี่ยวชาญด้านระบบทางเดินหายใจ เช่น ใช้รักษาแบบผู้ป่วยนอก ในกรณี moderate to severe community-acquired pneumonia และ lower respiratory tract  infection ที่สงสัย Drug-Resistant S. pneumoniae (DRSP) หรือ pathogen ที่ทำให้เกิด atypical pneumonia ที่ใช้ macrolide ไม่ได้หรือไม่ได้ผล หรือ ใช้ต่อเนื่องจากยาฉีด (sequential therapy)',
     ''
  ),
  (
     'Levofloxacin hemihydrate',
     '',
     'sterile sol',
     'ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อหรือแพทย์ผู้เชี่ยวชาญด้านระบบทางเดินหายใจ เช่น ใช้รักษาแบบผู้ป่วยใน ในกรณี moderate to severe community-acquired pneumonia และ lower respiratory tract infection ที่สงสัย Drug-Resistant S. pneumoniae (DRSP) หรือ pathogen ที่ทำให้เกิด atypical pneumonia',
     ''
  ),
  (
     'Chloramphenicol sodium succinate',
     '',
     'sterile pwdr',
     'ใช้รักษา rickettsiosis (scrub typhus, murine typhus) ที่ไม่สามารถใช้ยาฉีดอื่นได้',
     ''
  ),
  (
     'Metronidazole',
     '',
     'cap/tab (as base), susp (as benzoate), sterile sol (as base)',
     '',
     ''
  ),
  (
     'Clindamycin',
     '',
     'cap (as hydrochloride), sterile sol (as phosphate)',
     '1. ใช้สำหรับการติดเชื้อแบคทีเรียชนิด anaerobes, แบคทีเรียกรัมบวกชนิดรุนแรงในผู้ป่วยที่แพ้ยากลุ่ม beta-lactam แบบ type I (anaphylaxis หรือ urticaria) หรือการติดเชื้อผสมระหว่างแบคทีเรียกรัมบวก และ anaerobes2. ใช้เป็นยาแทน (alternative drug) ในการป้องกันหรือรักษา Pneumocystis jirovecii pneumonia (PCP) ในผู้ป่วยเอดส์3. ใช้เป็นยาแทน (alternative drug) ก่อนการผ่าตัดเพื่อป้องกันการติดเชื้อ (pre-operative prophylaxis) ในผู้ป่วยที่มีประวัติแพ้ยา penicillin หรือยากลุ่ม beta-lactam อย่างรุนแรง4. ไม่ควรใช้รักษาโรคติดเชื้อนอกเหนือไปจากข้อ 1 ถึงข้อ 3 เนื่องจากความเสี่ยงต่อการเกิด Antibiotics Associated Colitis (AAC)',
     ''
  ),
  (
     'Nitrofurantoin',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Colistimethate sodium',
     '',
     'sterile pwdr',
     'ใช้สำหรับการติดเชื้อกรัมลบที่ดื้อต่อยากลุ่ม carbapenems',
     ''
  ),
  (
     'Fosfomycin sodium',
     '',
     'sterile pwdr',
     'ใช้สำหรับการติดเชื้อ Methicillin Resistant S. aureus (MRSA) ที่มีอาการรุนแรงน้อยถึงปานกลาง โดยใช้ร่วมกับยาอื่นเพื่อป้องกันการดื้อยา',
     ''
  ),
  (
     'Sodium fusidate',
     '',
     'tab',
     'ใช้สำหรับการติดเชื้อ Methicillin Resistant S. aureus (MRSA) ที่มีอาการไม่รุนแรงถึงรุนแรงปานกลางหรือใช้เป็น switch therapy ต่อจากยาฉีด โดยใช้ร่วมกับยาอื่นเพื่อป้องกันการดื้อยา',
     ''
  ),
  (
     'Vancomycin hydrochloride',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับการติดเชื้อ Methicillin Resistant S. aureus (MRSA) ที่รุนแรง หรือการติดเชื้อ methicillin     resistant S. epidermidis (MRSE) 2. ใช้สำหรับโรค infective endocarditis (IE) กรณีแพ้ยา penicillin ชนิดรุนแรง',
     ''
  ),
  (
     'Linezolid',
     '',
     'tab',
     '1. ใช้สำหรับโรคติดเชื้อ Methicillin Resistant Staphylococcus aureus (MRSA)  2. ใช้สำหรับโรคติดเชื้อ Vancomycin Resistant Enterococci (VRE) ',
     ''
  ),
  (
     'Sulfamethoxazole + Trimethoprim',
     '',
     'cap, tab, susp, sterile sol',
     '',
     ''
  ),
  (
     'Trimethoprim',
     '',
     'tab',
     'ใช้รักษาโรคติดเชื้อที่อาจไวต่อ trimethoprim ในผู้ป่วยที่แพ้ยากลุ่ม sulfonamides',
     ''
  ),
  (
     'Ethambutol hydrochloride',
     '',
     'film coated tab',
     '',
     ''
  ),
  (
     'Isoniazid',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Pyrazinamide',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Rifampicin',
     '',
     'cap, tab, dry syr, syr, susp',
     '',
     ''
  ),
  (
     'Rifampicin',
     'ยากำพร้า',
     'oral form (for pediatric use)',
     '',
     ''
  ),
  (
     'Rifapentine',
     'ยากำพร้า',
     'oral form',
     'ใช้สำหรับการรักษาวัณโรคระยะแฝง และผู้ที่มีความเสี่ยงสูงต่อวัณโรคระยะแฝง ตามแนวทางเวชปฏิบัติวัณโรคระยะแฝง ของกองวัณโรค กรมควบคุมโรค กระทรวงสาธารณสุข ฉบับปัจจุบัน',
     ''
  ),
  (
     'Tuberculin Purified Protein Derivative',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Isoniazid + Rifampicin + Pyrazinamide + Ethambutol hydrochloride',
     '',
     'tab (เฉพาะ 75 + 150 + 400 + 275 mg)',
     '',
     ''
  ),
  (
     'Isoniazid + Rifapentine',
     'ยากำพร้า',
     'oral form',
     'ใช้สำหรับการรักษาวัณโรคระยะแฝง และผู้ที่มีความเสี่ยงสูงต่อวัณโรคระยะแฝง ตามแนวทางเวชปฏิบัติวัณโรคระยะแฝง ของกองวัณโรค กรมควบคุมโรค กระทรวงสาธารณสุข ฉบับปัจจุบัน',
     ''
  ),
  (
     'Isoniazid + Rifampicin',
     '',
     'cap/tab (เฉพาะ 100+150 mg และ 150+300 mg)',
     '',
     ''
  ),
  (
     'Isoniazid + Rifampicin',
     'ยากำพร้า',
     'oral form (for pediatric use)',
     '',
     ''
  ),
  (
     'Isoniazid + Rifampicin + Pyrazinamide',
     '',
     'tab (เฉพาะ 75 + 150 + 400 mg)',
     'ใช้เป็นยารวมในการรักษาวัณโรคในระยะ initial และ maintenance',
     ''
  ),
  (
     'Amikacin sulfate',
     '',
     'sterile sol',
     '1.ใช้รักษา drug-resistant tuberculosis2.ใช้ในกรณีไม่สามารถทนต่อยาวัณโรคหลักได้',
     ''
  ),
  (
     'Cycloserine',
     '',
     'cap',
     '1.ใช้รักษา drug-resistant tuberculosis2.ใช้ในกรณีไม่สามารถทนต่อยาวัณโรคหลักได้',
     ''
  ),
  (
     'Ethionamide',
     '',
     'tab',
     '1.ใช้รักษา drug-resistant tuberculosis2.ใช้ในกรณีไม่สามารถทนต่อยาวัณโรคหลักได้',
     ''
  ),
  (
     'Para-aminosalicylic acid',
     '',
     'EC tab',
     '1.ใช้รักษา drug-resistant tuberculosis2.ใช้ในกรณีไม่สามารถทนต่อยาวัณโรคหลักได้',
     ''
  ),
  (
     'Streptomycin sulfate',
     '',
     'sterile pwdr',
     '1.ใช้รักษา drug-resistant tuberculosis2.ใช้ในกรณีไม่สามารถทนต่อยาวัณโรคหลักได้',
     ''
  ),
  (
     'Bedaquiline fumarate',
     '',
     'tab',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB), extensively drug-resistant tuberculosis (XDR-TB)',
     ''
  ),
  (
     'Clofazimine',
     '',
     'cap',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB), extensively drug-resistant tuberculosis (XDR-TB)',
     ''
  ),
  (
     'Delamanid',
     '',
     'tab',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB), extensively drug-resistant tuberculosis (XDR-TB)',
     ''
  ),
  (
     'Levofloxacin hemihydrate',
     '',
     'tab (เฉพาะ 500 และ 750 mg), sterile sol',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), isoniazid mono-resistance หรือใช้รักษาวัณโรคในผู้ป่วยที่เกิดอาการไม่พึงประสงค์หรือไม่สามารถใช้ยากลุ่ม first-line ได้',
     ''
  ),
  (
     'Linezolid',
     '',
     'tab',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB), extensively drug-resistant tuberculosis (XDR-TB)',
     ''
  ),
  (
     'Moxifloxacin hydrochloride',
     '',
     'tab',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB), extensively drug-resistant tuberculosis (XDR-TB)',
     ''
  ),
  (
     'Pretomanid',
     '',
     'tab (เฉพาะ 200 mg)',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB) โดยให้ใช้เป็นองค์ประกอบของสูตรยาที่มี bedaquiline + linezolid ซึ่งอาจมีหรือไม่มีการใช้ยา moxifloxacin ร่วมด้วย',
     ''
  ),
  (
     'Protionamide',
     'ยากำพร้า',
     'tab',
     'ใช้รักษา multidrug-resistant tuberculosis (MDR-TB), pre-extensively drug-resistant tuberculosis (pre-XDR-TB), extensively drug-resistant tuberculosis (XDR-TB)',
     ''
  ),
  (
     'Clofazimine',
     '',
     'cap',
     '',
     ''
  ),
  (
     'Dapsone',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Fluconazole',
     '',
     'cap',
     '1. ใช้สำหรับ invasive fungal infection บางชนิด2. ใช้สำหรับ dermatomycoses',
     ''
  ),
  (
     'Griseofulvin',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Nystatin',
     '',
     'oral susp',
     '',
     ''
  ),
  (
     'Saturated solution of potassium iodide',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Itraconazole',
     '',
     'cap',
     'ใช้สำหรับโรคติดเชื้อ talaromycosis, histoplasmosis, cryptococcosis, vaginal candidiasis และ dermatomycoses',
     ''
  ),
  (
     'Amphotericin B',
     '',
     'sterile pwdr (เฉพาะ conventional formulations)',
     'ใช้สำหรับการรักษา invasive fungal infections',
     ''
  ),
  (
     'Fluconazole',
     '',
     'sterile sol',
     'ใช้เป็นยาแทน (alternative drug) ของ amphotericin B ในการรักษา cryptococcosis หรือ candidiasis เมื่อผู้ป่วยไม่สามารถใช้ amphotericin B ได้',
     ''
  ),
  (
     'Flucytosine (5-fluorocytosine)',
     'ยากำพร้า',
     'oral form',
     'ใช้เสริมฤทธิ์ยาต้านเชื้อราอื่น ๆ ในผู้ป่วย Cryptococcal meningitis',
     ''
  ),
  (
     'Itraconazole',
     '',
     'oral sol',
     '1. ใช้กับผู้ป่วยที่รับประทานยาแคปซูลไม่ได้  2. เป็นยาแทน (alternative drug) สำหรับโรคติดเชื้อ talaromycosis, histoplasmosis, cryptococcosis, vaginal candidiasis และ dermatomycoses3. ใช้สำหรับป้องกัน invasive fungal infection ในผู้ป่วยเด็กที่มี profound, protracted neutropenia เช่น ผู้ป่วย Allogeneic Hematopoietic Stem Cell Transplantation ช่วงpre-engraftment หรือมี graft versus host disease หรือ ผู้ป่วย acute myeloid leukemia  เป็นต้น',
     ''
  ),
  (
     'Liposomal amphotericin B',
     '',
     'sterile pwdr',
     'ใช้รักษา invasive fungal infections (ยกเว้น aspergillosis) ในผู้ป่วยที่ไม่สามารถทนต่อยา conventional amphotericin B ',
     ''
  ),
  (
     'Micafungin sodium',
     '',
     'sterile pwdr (เฉพาะ 50 mg)',
     'ใช้รักษา Invasive candidiasis ที่ดื้อต่อยา fluconazole หรือไม่สามารถใช้ conventional amphotericin B ได้ ',
     ''
  ),
  (
     'Posaconazole',
     '',
     'tab (เฉพาะ 100 mg)',
     'ใช้รักษา invasive mucormycosis ในผู้ป่วยที่ไม่ตอบสนองหรือไม่สามารถทนต่อยา amphotericin B ได้ ',
     ''
  ),
  (
     'Voriconazole',
     '',
     'tab, sterile pwdr',
     '1. ใช้รักษา invasive aspergillosis 2. ใช้รักษา invasive fungal infection จากเชื้อ Fusarium spp., Scedosporium spp. และ Trichosporon spp. ',
     ''
  ),
  (
     'Aciclovir',
     '',
     'tab, oral susp, oral susp (hosp)',
     '',
     ''
  ),
  (
     'Aciclovir sodium',
     '',
     'sterile pwdr, sterile sol',
     '1. ใช้สำหรับการติดเชื้อไวรัส varicella - zoster และ  herpes simplex  ในผู้ป่วยที่มีภูมิคุ้มกันบกพร่องและในทารกแรกเกิด2. ใช้สำหรับการติดเชื้อไวรัส varicella-zoster และ herpes simplex ที่มีการแพร่กระจาย หรือเป็นการติดเชื้อของอวัยวะภายใน หรือในผู้ป่วยที่ใช้ยารับประทานไม่ได้  3. ใช้กับทารกแรกเกิดที่มารดาป่วยเป็นโรคไข้อีสุกอีใสในช่วง 5 วันก่อนคลอดและในช่วง 2 วันหลังคลอด เพื่อป้องกันโรคอีสุกอีใสในทารกแรกเกิด (neonatal varicella)4. ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ',
     ''
  ),
  (
     'Oseltamivir phosphate',
     '',
     'cap, dry syr',
     '',
     ''
  ),
  (
     'Cidofovir',
     'ยากำพร้า',
     'sterile sol',
     '1. ใช้กับผู้ป่วยที่มีภาวะติดเชื้อ adenovirus ในเลือดหรืออวัยวะอื่นที่มีอาการรุนแรงที่ไม่เป็นผู้ป่วยระยะสุดท้าย (terminally ill) โดยมีอาการทางคลินิกที่เข้าได้ ร่วมกับการตรวจวินิจฉัยข้อใดข้อหนึ่ง ดังต่อไปนี้1.1 การตรวจพบ adenovirus ในเลือดด้วยวิธีทางอนูพันธุศาสตร์ (molecular detection)1.2 การตรวจพบ adenovirus จากสิ่งส่งตรวจของอวัยวะที่มีอาการสงสัย ด้วยวิธีทางอนูพันธุศาสตร์ (molecular detection) เช่น ปัสสาวะ สารคัดหลั่งจากทางเดินหายใจส่วนล่าง น้ำล้างจากถุงลมปอด (bronchoalveolar lavage fluid)1.3 การตรวจพบลักษณะทางพยาธิวิทยาที่เข้าได้กับการติดเชื้อ adenovirus (cytopathological change) หรือการตรวจพบไวรัสจากการตรวจด้วยกล้อง electron microscope2. ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ',
     ''
  ),
  (
     'Ganciclovir sodium',
     '',
     'sterile pwdr',
     '1. ใช้สำหรับ cytomegalovirus disease 2. ใช้ในกรณีพิเศษตามคำแนะนำของแพทย์ผู้เชี่ยวชาญด้านโรคติดเชื้อ',
     ''
  ),
  (
     'Peramivir',
     'ยากำพร้า',
     'sterile sol',
     'ใช้กับผู้ป่วยโรคไข้หวัดใหญ่ที่มีอาการรุนแรงและไม่สามารถใช้ยาชนิดรับประทาน หรือชนิดสูดพ่นได้',
     ''
  ),
  (
     'Efavirenz',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Lamivudine',
     '',
     'tab, syr',
     '',
     ''
  ),
  (
     'Nevirapine',
     '',
     'susp',
     '',
     ''
  ),
  (
     'Tenofovir disoproxil fumarate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Tenofovir Disoproxil Fumarate + Emtricitabine',
     '',
     'tab (300 + 200 mg)',
     '',
     ''
  ),
  (
     'Tenofovir Disoproxil Fumarate + Emtricitabine + Efavirenz',
     '',
     'tab (300 + 200 + 600 mg)',
     '',
     ''
  ),
  (
     'Tenofovir disoproxil fumarate + Lamivudine + Dolutegravir sodium',
     '',
     'tab (300 + 300 + 50 mg)',
     '',
     ''
  ),
  (
     'Tenofovir alafenamide + Emtricitabine',
     '',
     'tab (25 + 200)',
     '',
     ''
  ),
  (
     'Tenofovir Alafenamide + Emtricitabine + Dolutegravir',
     '',
     'tab (25 + 200 + 50)',
     '',
     ''
  ),
  (
     'Zidovudine',
     '',
     'cap, oral sol',
     '',
     ''
  ),
  (
     'Zidovudine + Lamivudine',
     '',
     'tab (เฉพาะ 300+150 mg)',
     '',
     ''
  ),
  (
     'Rilpivirine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Dolutegravir',
     '',
     'tab (เฉพาะ 50 mg)',
     '',
     ''
  ),
  (
     'Dolutegravir',
     '',
     'orodispersible tab',
     'เป็นสูตรยาต้านเอชไอวีสำหรับรักษาในเด็กอายุตั้งแต่ 4 สัปดาห์ขึ้นไปและมีน้ำหนักตัวมากกว่าหรือเท่ากับ 3 กิโลกรัม',
     ''
  ),
  (
     'Lopinavir + Ritonavir',
     '',
     'tab, oral sol',
     '',
     ''
  ),
  (
     'Ritonavir',
     '',
     'tab, oral sol',
     '',
     ''
  ),
  (
     'Abacavir',
     '',
     'tab, oral sol',
     '1. ใช้กับผู้ป่วยที่ไม่สามารถใช้ยา tenofovir หรือเกิดผลข้างเคียงที่ไม่สามารถใช้ยา tenofovir ได้ (ยา tenofovir ผลข้างเคียงที่สำคัญคือ ผลต่อไต และผลต่อ bone density)2.  ใช้เป็น nucleoside reverse transcriptase inhibitor (NRTI) ในสูตรยาต้านไวรัสดื้อยา ในกรณีที่การรักษาล้มเหลวจากเชื้อดื้อยาต้านไวรัสสูตรก่อน โดยต้องมีผลการตรวจ genotypic resistance ที่ไวกับยา abacavir และเชื้อไวต่อยาอื่นในสูตรอย่างน้อย 2 ชนิด3.  ใช้กับเด็กที่ติดเชื้อเอชไอวีอายุ 3 เดือนขึ้นไป',
     ''
  ),
  (
     'Abacavir + Lamivudine',
     '',
     'tab (600 + 300 mg)',
     '1. ใช้กับผู้ป่วยที่ไม่สามารถใช้ยา tenofovir หรือเกิดผลข้างเคียงที่ไม่สามารถใช้ยา tenofovir ได้ (ยา tenofovir ผลข้างเคียงที่สำคัญคือ ผลต่อไต และผลต่อ bone density)2. ใช้เป็น nucleoside reverse transcriptase inhibitor (NRTI) ในสูตรยาต้านไวรัสดื้อยา ในกรณีที่การรักษาล้มเหลวจากเชื้อดื้อยาต้านไวรัสสูตรก่อน โดยต้องมีผลการตรวจ genotypic resistance ที่ไวกับยา abacavir และเชื้อไวต่อยาอื่นในสูตรอย่างน้อย 2 ชนิด3. ใช้กับเด็กที่ติดเชื้อเอชไอวีอายุ 3 เดือนขึ้นไป',
     ''
  ),
  (
     'Darunavir',
     '',
     'tab (เฉพาะ 300, 600 และ 800 as base)',
     'ใช้รักษาโรคติดเชื้อเอชไอวีที่ดื้อต่อยาสูตรพื้นฐาน และสูตรที่สอง โดยเป็นไปตามแนวทางการตรวจวินิจฉัย รักษา และป้องกันการติดเชื้อเอชไอวี ประเทศไทย ฉบับปัจจุบัน',
     ''
  ),
  (
     'Tenofovir alafenamide',
     '',
     'tab (เฉพาะ 25 mg)',
     '1.ใช้ในผู้ป่วยอายุ 18 ปีขึ้นไป เป็นยาลำดับแรก (first line therapy) ในการรักษาโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรังรายใหม่ ซึ่งไม่เคยรักษามาก่อน โดยมีเกณฑ์ดังนี้  1.1ในกรณีผู้ป่วยที่เป็นโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรังชนิด HBeAg positive หรือ HBeAg negative มี alanine aminotransferase (ALT) สูงกว่าหรือเท่ากับ 1.5 เท่าของค่าปกติ และมี HBV DNA มากกว่า 10,000 copies/ml (หรือ 2,000 IU/ml) 1.2ในกรณีผู้ป่วยมีระดับ ALT น้อยกว่า 1.5 เท่าของค่าปกติ ต้องมีผล liver histology ที่แสดงว่ามีภาวะตับอักเสบตามเกณฑ์ The Knodell histology activity index (HAI) scoring system โดยมี necroinflammatory score มากกว่าหรือเท่ากับ 4 หรือตามเกณฑ์ METAVIR scoring system มีระดับ moderate หรือ severe necroinflammation (A มากกว่าหรือเท่ากับ 2) หรือ มีพังผืดในตับอย่างชัดเจนตามเกณฑ์ METAVIR scoring system โดยมี fibrosis stage มากกกว่าหรือเท่ากับ 2 หรือผลการตรวจ non-invasive fibrosis markers เช่น liver elastography, The aspartate aminotransferase to platelet ratio index (APRI) หรือ Fibrosis-4 score (FIB-4) เป็นต้น บ่งชี้ว่ามี fibrosis stage มากกว่าหรือเท่ากับ 2   2.ใช้เป็น switch therapy ในผู้ป่วยโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรังรายเดิมที่เคยได้รับการรักษาด้วยยา lamivudine หรือ entecavir หรือ tenofovir disoproxil fumarate (TDF) มาก่อน 3.ใช้สำหรับ compensated หรือ decompensated cirrhosis ที่ตรวจพบ HBV DNA  4.ใช้เป็น prophylactic therapy ในผู้ป่วยที่จะได้รับยาเคมีบำบัดโดยใช้ยาในระยะสั้นหรือยากดภูมิคุ้มกัน ในกรณีข้อใดข้อหนึ่ง ดังนี้ 4.1ตรวจพบ HBsAg positive หรือ4.2ตรวจพบ anti-HBc positive และ HBsAg-negative ที่ได้รับการรักษาด้วยยา monoclonal antibody to CD20 ได้แก่ Rituximab หรือ ได้รับปลูกถ่ายอวัยวะจากผู้บริจาคที่ตรวจพบ HBsAg-positive หรือตรวจพบ anti-HBc positive ร่วมกับ HBsAg-negative5.ใช้เป็น rescue therapy สำหรับเด็กอายุ 12-18 ปี ที่ดื้อยา entecavir หรือ lamivudine',
     ''
  ),
  (
     'Tenofovir disoproxil fumarate',
     '',
     'tab',
     '1.ใช้รักษาหรือควบคุมการติดเชื้อไวรัสตับอักเสบบีเรื้อรัง (chronic hepatitis B virus infection) ในหญิงตั้งครรภ์2.ใช้สำหรับ decompensated cirrhosis (ChildPugh score B or C) ที่ตรวจพบ HBV DNA3.ใช้เป็น rescue therapy ในผู้ป่วยอายุ 2-18 ปี ที่เป็นโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรัง กรณีที่ดื้อต่อการรักษาด้วยยากลุ่ม nucleoside analogs เช่น lamivudine, telbivudine, หรือ entecavir เป็นต้น และไม่สามารถใช้ tenofovir alafenamide (TAF) ได้',
     ''
  ),
  (
     'Lamivudine',
     '',
     'syr',
     'ใช้เป็น prophylactic therapy ในผู้ป่วยเด็กอายุน้อยกว่า 2 ปี ที่จะได้รับยาเคมีบำบัดหรือยากดภูมิคุ้มกันโดยใช้ยาในระยะสั้น หรือใช้ในเด็กที่ได้รับการปลูกถ่ายอวัยวะจากผู้บริจาคที่ตรวจพบ HBsAg-positive หรือตรวจพบ anti-HBc positive ร่วมกับ HBsAg-negative',
     ''
  ),
  (
     'Entecavir',
     '',
     'tab (เฉพาะ 0.5 mg)',
     '1.ใช้เป็น alternative first line therapy ในผู้ป่วยผู้ใหญ่ที่เป็นโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรัง (chronic hepatitis B) ในกรณีที่ไม่สามารถใช้ยา tenofovir alafenamide (TAF) หรือ tenofovir disoproxil fumarate (TDF) ได้ โดย1.1ผู้ป่วยที่มีการทำงานของไตผิดปกติตามเกณฑ์ข้อใดข้อหนึ่งดังต่อไปนี้1.1.1มี serum creatinine มากกว่าหรือเท่ากับ 1.5 มิลลิกรัมต่อเดซิลิตร (ในผู้ใหญ่) หรือ มากกว่า 2 เท่าของค่าปกติ (ในเด็ก) หรือ1.1.2มี creatinine clearance (CrCl) น้อยกว่าหรือเท่ากับ 50 มิลลิลิตรต่อนาที (ในผู้ใหญ่) หรือ 60 มิลลิลิตรต่อนาทีต่อ 1.73 ตารางเมตร (ในเด็ก) หรือ1.1.3ผู้ป่วยมีภาวะ proximal tubular dysfunction ร่วมกับมีความผิดปกติดังนี้ ได้แก่ hypokalemia หรือ hypophosphatemia หรือ glucosuria (ที่ไม่ได้เกิดจากภาวะ hyperglycemia) หรือ proteinuria มากกว่าหรือเท่ากับ 1 กรัมต่อวัน1.2ผู้ป่วยที่มีปัญหาโรคกระดูกบางหรือกระดูกพรุน2.ใช้ในผู้ป่วยเด็กอายุมากกว่า 6 ปีที่เป็นโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรัง (chronic hepatitis B) กรณีที่กลืนยาเม็ดได้ ตามเกณฑ์ข้อใดข้อหนึ่งดังต่อไปนี้2.1ใช้เป็นยาลำดับแรก (first line therapy) ในผู้ป่วยซึ่งไม่เคยรักษามาก่อน 2.2ใช้เป็น switch therapy เพื่อควบคุมโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรังที่รักษาได้ดีด้วยยา lamivudine มาก่อน2.3ใช้เป็น rescue therapy ที่ดื้อต่อการรักษาด้วยยา lamivudine แต่มีข้อห้ามในการใช้ยา tenofovir disoproxil fumarate (TDF)2.4ใช้เป็น prophylactic therapy กับผู้ป่วยที่จะได้รับยาเคมีบำบัดหรือยากดภูมิคุ้มกัน ในกรณีข้อใดข้อหนึ่ง ดังนี้2.4.1ตรวจพบ HBsAg positive หรือ 2.4.2ตรวจพบ anti-HBc positive และ HBsAg-negative ที่ได้รับการรักษาด้วยยา monoclonal antibody to CD20 ได้แก่ rituximab หรือ 2.4.3ได้รับการปลูกถ่ายอวัยวะจากผู้บริจาคที่ตรวจพบ HBsAg-positive หรือตรวจพบ anti-HBc positive ร่วมกับ HBsAg-negative',
     ''
  ),
  (
     'Entecavir',
     '',
     'oral sol',
     'ใช้ในผู้ป่วยเด็กอายุ 2-6 ปี ที่เป็นโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรัง (chronic hepatitis B) ซึ่งยังไม่สามารถกลืนยาเม็ดได้ ตามเกณฑ์ข้อใดข้อหนึ่งดังต่อไปนี้1.ใช้เป็นยาลำดับแรก (first line therapy) ในผู้ป่วยซึ่งไม่เคยรักษามาก่อน 2.ใช้เป็น switch therapy เพื่อควบคุมโรคติดเชื้อไวรัสตับอักเสบบีเรื้อรังที่รักษาได้ดีด้วยยา lamivudine มาก่อน3.ใช้เป็น rescue therapy ที่ดื้อต่อการรักษาด้วยยา lamivudine แต่มีข้อห้ามในการใช้ยา tenofovir disoproxil fumarate (TDF)4.ใช้เป็น prophylactic therapy กับผู้ป่วยที่จะได้รับยาเคมีบำบัดหรือยากดภูมิคุ้มกัน ในกรณีข้อใดข้อหนึ่ง ดังนี้4.1ตรวจพบ HBsAg positive หรือ 4.2ตรวจพบ anti-HBc positive และ HBsAg-negative ที่ได้รับการรักษาด้วยยา monoclonal antibody to CD20 ได้แก่ Rituximab หรือ 4.3ได้รับการปลูกถ่ายอวัยวะจากผู้บริจาคที่ตรวจพบ HBsAg-positive หรือตรวจพบ anti-HBc positive ร่วมกับ HBsAg-negative',
     ''
  ),
  (
     'Sofosbuvir + Velpatasvir',
     '',
     'tab (เฉพาะ 400 mg + 100 mg)',
     '1.ใช้รักษาโรคไวรัสตับอักเสบซีเรื้อรังทุกสายพันธุ์ ในผู้ป่วยน้ำหนัก 30 กิโลกรัมขึ้นไป และใช้ระยะเวลารักษา 12 สัปดาห์2.ใช้รักษาโรคไวรัสตับอักเสบซีเรื้อรังทุกสายพันธุ์ ทั้งกรณีมีตับแข็งและไม่มีตับแข็งในผู้ป่วยที่ไม่ตอบสนองต่อการรักษาในครั้งแรก (12 สัปดาห์) โดยให้ยาเพิ่มอีกเป็นเวลา 24 สัปดาห์',
     ''
  ),
  (
     'Ribavirin',
     '',
     'cap/tab  (เฉพาะ 200 mg)',
     '1.ใช้ ribavirin ร่วมกับ sofosbuvir + velpatasvir ในการรักษาโรคไวรัสตับอักเสบซีเรื้อรังทุกสายพันธุ์ กรณีมีตับแข็ง ในผู้ป่วยน้ำหนัก 30 กิโลกรัมขึ้นไป และใช้ระยะเวลารักษา  12 สัปดาห์2.ใช้ ribavirin ร่วมกับ sofosbuvir + velpatasvir ในการรักษาโรคไวรัสตับอักเสบซีเรื้อรังทุกสายพันธุ์ ทั้งกรณีมีตับแข็งและไม่มีตับแข็งในผู้ป่วยที่ไม่ตอบสนองต่อการรักษาในครั้งแรก (12 สัปดาห์) โดยให้ยาเพิ่มอีกเป็นเวลา 24 สัปดาห์',
     ''
  ),
  (
     'Chloroquine phosphate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Primaquine phosphate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Quinine',
     '',
     'compressed/film coated tab (as sulfate), sterile sol (as dihydrochloride)',
     '',
     ''
  ),
  (
     'Artenimol (Dihydroartemisinin) + Piperaquine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Artesunate + Pyronaridine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Artesunate',
     '',
     'tab (ไม่รวม lactab และ rectocap), sterile pwdr',
     '',
     ''
  ),
  (
     'Mefloquine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Metronidazole',
     '',
     'cap/tab (as base), susp (as benzoate), sterile sol (as base)',
     '',
     ''
  ),
  (
     'Pyrimethamine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Sulfadiazine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Pentamidine isetionate',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้สำหรับป้องกันหรือรักษาปอดอักเสบที่เกิดจาก Pneumocystis jirovecii หลังจากการรักษาด้วยยา Sulfamethoxazole + Trimethoprim (Co-trimoxazole) และ Clindamycin + Primaquine แล้วไม่ได้ผลหรือไม่สามารถทนต่อยาได้',
     ''
  ),
  (
     'Albendazole',
     '',
     'tab, susp',
     '',
     ''
  ),
  (
     'Diethylcarbamazine citrate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Mebendazole',
     '',
     'tab, susp, susp (hosp)',
     '',
     ''
  ),
  (
     'Niclosamide',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Praziquantel',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Ivermectin',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Ivermectin',
     'ยากำพร้า',
     'sterile sol',
     'ใช้รักษาการติดเชื้อพยาธิสตรองจิลอยด์ (strongyloidiasis) ในผู้ที่รับประทานยารูปแบบเม็ดไม่ได้',
     ''
  ),
  (
     'Chlorhexidine gluconate',
     '',
     'sol (aqueous), sol (เฉพาะ 2% ,  4% และ 5%) , sol/sol (hosp)(เฉพาะ 2% , 4% in 70% alcohol)',
     '',
     ''
  ),
  (
     'Ethyl alcohol',
     '',
     'sol, sol (hosp), gel (hosp)',
     '',
     ''
  ),
  (
     'Gentian violet',
     '',
     'sol (paint)',
     '',
     ''
  ),
  (
     'Hydrogen peroxide',
     '',
     'sol',
     '',
     ''
  ),
  (
     'Potassium permanganate',
     '',
     'pwdr (hosp)',
     '',
     ''
  ),
  (
     'Povidone-iodine',
     '',
     'sol, sol (hosp)',
     '',
     ''
  ),
  (
     'Biphasic isophane insulin',
     '',
     'sterile susp',
     '',
     ''
  ),
  (
     'Isophane insulin',
     '',
     'sterile susp',
     '',
     ''
  ),
  (
     'Soluble insulin',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Insulin aspart',
     '',
     'sterile sol',
     '1. ใช้เฉพาะผู้ป่วยที่เกิด hypoglycemia  บ่อยเมื่อใช้ conventional insulin 2. ใช้สำหรับควบคุมภาวะ postprandial hyperglycemia',
     ''
  ),
  (
     'Insulin aspart + insulin aspart protamine',
     '',
     'sterile susp (เฉพาะ 30% + 70%)',
     'เช่นเดียวกับ Insulin aspart',
     ''
  ),
  (
     'Insulin lispro',
     '',
     'sterile sol',
     '1. ใช้เฉพาะผู้ป่วยที่เกิด hypoglycemia บ่อยเมื่อใช้ conventional insulin 2. ใช้สำหรับควบคุมภาวะ postprandial hyperglycemia',
     ''
  ),
  (
     'Insulin lispro + insulin lispro protamine',
     '',
     'sterile susp (เฉพาะ 25% + 75%)',
     'เช่นเดียวกับ Insulin lispro',
     ''
  ),
  (
     'Insulin glargine',
     '',
     'sterile sol (cartridge เฉพาะ 100 IU/ml) (3 mL), (pre-filled pen เฉพาะ 100 IU/ml) (3 mL)',
     '1. ใช้สำหรับผู้ป่วยโรคเบาหวานชนิดที่ 1 โดยใช้ร่วมกับ prandial insulin อย่างน้อย 2 ครั้งขึ้นไป2. สำหรับผู้ป่วยโรคเบาหวานชนิดที่ 2 ให้ใช้เฉพาะผู้ป่วยที่มีภาวะน้ำตาลในเลือดต่ำอย่างรุนแรง (severe hypoglycemia) จากการใช้ conventional insulin',
     ''
  ),
  (
     'Glibenclamide',
     '',
     'tab (เฉพาะ 2.5 และ 5 mg)',
     '',
     'พึงระมัดระวังในผู้ป่วยสูงอายุหรือผู้ป่วยที่มีการทำงานของไตบกพร่อง'
  ),
  (
     'Glipizide',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Metformin hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Pioglitazone hydrochloride',
     '',
     'tab (เฉพาะ 15 และ 30 mg)',
     'ใช้เป็นยาทางเลือก ภายหลังการใช้ยา Metformin หรือยากลุ่ม Sulfonylureas',
     '1. ห้ามใช้ยานี้ในผู้ที่มีหัวใจล้มเหลวในระดับที่รุนแรง (NYHA ในระดับ 3 และ 4) ยานี้อาจทำให้เกิดภาวะหัวใจล้มเหลว2. ไม่ควรใช้ยานี้ในผู้ป่วยที่กำลังเป็นมะเร็งกระเพาะปัสสาวะ'
  ),
  (
     'Repaglinide',
     '',
     'tab (เฉพาะ 0.5, 1, 2 mg)',
     '1. ใช้สำหรับลด postprandial hyperglycemia2. ใช้ในผู้ป่วยที่มีความเสี่ยงต่อ hypoglycemia สูง',
     ''
  ),
  (
     'Diazoxide',
     'ยากำพร้า',
     'tab',
     '1. ใช้สำหรับ persistent hyperinsulinemic hypoglycemia of infancy (PHHI หรือ nesidioblastosis)2. ใช้สำหรับ insulinoma ที่ผ่าตัดไม่ได้',
     ''
  ),
  (
     'Glucagon, human',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้ในผู้ป่วยเบาหวานชนิดที่ 1 ที่มีภาวะ hypoglycemia บ่อยครั้ง (มากกว่า 2 ครั้ง/สัปดาห์) หรือ เกิดภาวะ severe hypoglycemia หมายถึง hypoglycemia รุนแรงมากจนต้องมาห้องฉุกเฉิน หรือรับไว้ในโรงพยาบาลปีละ 1 ครั้ง',
     ''
  ),
  (
     'Levothyroxine sodium',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Liothyronine sodium',
     'ยากำพร้า',
     'tab',
     'ใช้แทน levothyroxine sodium ชั่วคราวระหว่างรอทำ total body scan ในผู้ป่วยมะเร็งต่อมไทรอยด์',
     ''
  ),
  (
     'Lugol ''s solution',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Propylthiouracil',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Saturated solution of potassium iodide',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Thiamazole',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Octreotide acetate',
     '',
     'sterile pwdr (ชนิดออกฤทธิ์นาน เฉพาะ 20 และ 30 mg/vial)',
     'สำหรับผู้ป่วย thyrotropin secreting pituitary adenoma โดยมีเงื่อนไขดังนี้1. การใช้ยาก่อนการผ่าตัดเพื่อให้ฮอร์โมนไทรอยด์เข้าสู่ภาวะปกติก่อนการผ่าตัด หรือกรณีมีแนวโน้มที่ก้อนจะไม่สามารถผ่าออกได้หมด เช่น มีการลามเข้า cavernous sinus โดยมีระยะการให้ยา 1-3 เดือน2. การให้ยาระหว่างรอการตอบสนองต่อการรักษาด้วยการฉายแสงหลังผ่าตัดในกรณีที่ก้อนไม่สามารถผ่าตัดออกได้หมด',
     ''
  ),
  (
     'Dexamethasone',
     '',
     'cap/tab (as base), sterile sol (as sodium phosphate or acetate)',
     '',
     ''
  ),
  (
     'Hydrocortisone',
     'ชนิดเม็ดเป็นยากำพร้า',
     'tab (as base) , sterile pwdr (as sodium succinate), sterile susp (as acetate)',
     '',
     ''
  ),
  (
     'Prednisolone',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Fludrocortisone acetate',
     'ยากำพร้า',
     'tab',
     'ใช้สำหรับ replacement therapy ใน adrenocortical insufficiency',
     ''
  ),
  (
     'Methylprednisolone',
     '',
     'sterile pwdr/sterile susp (as hemisuccinate or sodium succinate or acetate)',
     '',
     ''
  ),
  (
     'Triamcinolone acetonide',
     '',
     'sterile susp',
     '',
     '1. ควรระวังการฉีดในตำแหน่งหรือรอยโรคที่มีการติดเชื้อหรือสงสัยว่าจะมีการติดเชื้อ2. กรณีฉีดเข้าข้อ โดย 2.1 ไม่ควรฉีดเข้าข้อใหญ่ในคราวเดียวกันเกิน 2 ข้อ ยกเว้นผู้ป่วยเด็กที่เป็นโรคข้ออักเสบเรื้อรัง2.2 การฉีดยาซ้ำเข้าข้อเดียวกันควรเว้นระยะห่างอย่างน้อย 3 เดือน 3. กรณีฉีดเข้ารอยโรค (intralesional injection) สำหรับโรคผิวหนัง ควรฉีดเข้าในชั้นหนังแท้ หลีกเลี่ยงการฉีดเข้าในชั้นหนังกำพร้าหรือไขมันใต้ผิวหนัง เพราะทำให้เกิดผลข้างเคียง เช่น ผิวหนังบาง เป็นต้น'
  ),
  (
     'Conjugated estrogens',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Medroxyprogesterone acetate',
     '',
     'tab (เฉพาะ 2.5 , 5 และ 10 mg)',
     '',
     ''
  ),
  (
     'Norethisterone',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Estradiol  (17b-estradiol)',
     '',
     'gel (เฉพาะ 0.06%)',
     '',
     ''
  ),
  (
     'Estradiol valerate',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Hydroxyprogesterone caproate',
     '',
     'sterile oily sol for inj',
     '',
     ''
  ),
  (
     'Conjugated estrogens',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Dydrogesterone',
     '',
     'film-coated tab (เฉพาะ 10 mg)',
     'ใช้ในหญิงตั้งครรภ์รายที่มีอาการแท้งซ้ำซาก (recurrent abortion)',
     ''
  ),
  (
     'micronized progesterone',
     '',
     'cap (เฉพาะ 100 mg และ 200 mg)',
     '1. ใช้ป้องกัน preterm birth ในหญิงตั้งครรภ์เดี่ยวที่มีประวัติการคลอดก่อนกำหนด (หลัง 16 สัปดาห์เป็นต้นไป)2. ใช้ป้องกัน preterm birth ในหญิงตั้งครรภ์เดี่ยวที่มี short cervical length (transvaginal) น้อยกว่า 25 mm เพื่อลดโอกาสการเกิดการคลอดก่อนกำหนด',
     ''
  ),
  (
     'Testosterone enantate',
     '',
     'sterile oily sol for inj',
     '',
     ''
  ),
  (
     'Cyproterone acetate',
     '',
     'tab',
     'ใช้ในผู้ป่วย moderate to severe hirsutism ที่มีข้อห้ามใช้หรือมีผลข้างเคียงจากการใช้ยา combined oral contraceptive หรือ spironolactone',
     'อาการที่เกี่ยวข้องกับความเป็นพิษของตับ (ดีซ่าน, ตับอักเสบ, ตับวาย) มักเกิดขึ้นหลังการใช้ยานี้ติดต่อกันเป็นเวลานานหลายเดือน ควรติดตามการทำงานของตับและพิจารณาหยุดยา หากพบหลักฐานการเกิดพิษต่อตับ'
  ),
  (
     'Chorionic gonadotrophin',
     '',
     'sterile pwdr',
     'ใช้สำหรับกระตุ้นการเคลื่อนตัวของอัณฑะ ในผู้ป่วยเด็กที่มี undescended testis และใช้ทดสอบการทำงานของอัณฑะ (HCG test)',
     ''
  ),
  (
     'Tetracosactide',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้สำหรับวินิจฉัยโรคทางต่อมไร้ท่อ',
     ''
  ),
  (
     'Octreotide acetate',
     '',
     'sterile pwdr (ชนิดออกฤทธิ์นาน เฉพาะ 20 และ 30 mg/vial)',
     'ใช้ในผู้ป่วย Acromegaly ที่ได้รับการรักษาโดยการผ่าตัดเนื้องอกหรือการฉายแสงแล้ว ระดับ Growth Hormone (GH) และ Insulin-like Growth Factor (IGF) ยังสูงอยู่ ',
     ''
  ),
  (
     'Somatropin',
     '',
     'sterile sol, sterile pwdr',
     'ใช้สำหรับผู้ป่วย growth hormone deficiency ในทารกแรกเกิดหรือเด็กเล็ก อายุน้อยกว่า 2 ปี ร่วมกับมีภาวะน้ำตาลในเลือดต่ำ ',
     ''
  ),
  (
     'Thyrotropin alfa',
     '',
     'sterile pwdr',
     'ใช้สำหรับ differentiated thyroid cancer (papillary and/or follicular thyroid carcinoma) ',
     ''
  ),
  (
     'Desmopressin acetate',
     '',
     'tab, nasal sol (nasal drop/spray), sterile sol',
     '1.ใช้สำหรับ diabetes insipidus2.ชนิดเม็ดใช้กับผู้ป่วยที่ไม่สามารถใช้ยาทางจมูกได้เท่านั้น',
     ''
  ),
  (
     'Alendronate sodium',
     '',
     'tab (เฉพาะ 70 mg)',
     'ใช้กับผู้ป่วยโรคกระดูกพรุนเป็นระยะเวลาไม่เกิน 5 ปี เมื่อมีเงื่อนไขข้อใดข้อหนึ่ง ดังนี้1.ชายและหญิงอายุ 50 ปีขึ้นไป 1.1.มีประวัติกระดูกสะโพกหรือกระดูกสันหลังหัก หรือ1.2.มีประวัติกระดูกหักที่บริเวณปลายแขน (distal forearm), ต้นแขน (humerus) หรือ เชิงกราน (pelvis) โดยมีค่า BMD T-score ที่กระดูกสันหลัง หรือ กระดูกสะโพก น้อยกว่าหรือเท่ากับ -2.52.ชายและหญิงอายุ 65 ปีขึ้นไป ที่ไม่เคยมีประวัติกระดูกสะโพกหรือกระดูกสันหลังหัก แต่ได้รับการตรวจพบข้อใดข้อหนึ่ง ดังต่อไปนี้2.1.มีค่า BMD T-score ที่กระดูกสันหลัง หรือ กระดูกสะโพก น้อยกว่าหรือเท่ากับ -2.5 2.2.มีค่า BMD T-score ที่กระดูกสันหลัง หรือ กระดูกสะโพก อยู่ระหว่าง -1.0 และ -2.5 และมีความเสี่ยงต่อการเกิดกระดูกสะโพกหักในช่วงเวลา 10 ปี มากกว่าหรือเท่ากับร้อยละ 3 (FRAX สำหรับประเทศไทย)',
     ''
  ),
  (
     'Calcitonin-salmon',
     '',
     'sterile sol',
     'ใช้กับผู้ป่วย severe hypercalcemia',
     'ใช้ยานี้ในระยะเวลาสั้นที่สุด ในขนาดต่ำสุดที่มีประสิทธิผลการรักษา'
  ),
  (
     'Disodium pamidronate',
     '',
     'sterile pwdr, sterile sol',
     'ใช้สำหรับ severe osteogenesis imperfecta ที่มีความเสี่ยงสูงต่อการเกิดกระดูกหัก',
     ''
  ),
  (
     'Zoledronic acid',
     '',
     'sterile sol (เฉพาะ 4 mg/5 ml)',
     '1. ใช้สำหรับภาวะ hypercalcemia ที่เกิดจากโรคมะเร็ง2. ใช้สำหรับป้องกันโรคแทรกซ้อนทางกระดูกซึ่งมี osteolytic lesion จากภาพรังสี (plain X-ray หรือ CT scan) และเกิดจากโรคมะเร็งดังต่อไปนี้2.1 โรคมะเร็ง multiple myeloma โดยให้ zoledronic acid เป็นเวลาไม่เกิน 2 ปี2.2 โรคมะเร็งเต้านม หรือมะเร็งต่อมลูกหมากชนิดที่ดื้อต่อฮอร์โมน (castration resistant prostate cancer) โดยให้ zoledronic acid เป็นเวลาไม่เกิน 2 ปี3. ใช้สำหรับ severe osteogenesis imperfecta ที่มีความเสี่ยงสูงต่อการเกิดกระดูกหัก',
     ''
  ),
  (
     'Bromocriptine mesilate',
     '',
     'tab',
     'ใช้สำหรับ prolactinoma , acromegaly, amenorrhea ทั้งที่มีและไม่มี galactorrhea',
     ''
  ),
  (
     'Leuprorelin acetate',
     '',
     'sterile pwdr (เฉพาะ 11.25 mg)',
     'ใช้สำหรับภาวะ central (gonadotrophin dependent) precocious puberty โดยมีแนวทางกำกับการใช้ยา เป็นไปตามรายละเอียดในภาคผนวก 3',
     ''
  ),
  (
     'Triptorelin pamoate',
     '',
     'sterile pwdr (เฉพาะ 11.25 mg)',
     'ใช้สำหรับภาวะ central (gonadotrophin dependent) precocious puberty ',
     ''
  ),
  (
     'Ketoconazole',
     '',
     'tab',
     '1. ใช้สำหรับ Cushings syndrome ที่รอการผ่าตัด หรือไม่ตอบสนองต่อการผ่าตัด และ/หรือ การฉายแสง2. ใช้สำหรับรักษาภาวะ androgen overproduction ในกรณี testotoxicosis',
     ''
  ),
  (
     'Methylergometrine maleate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Misoprostol',
     '',
     'tab (เฉพาะ 200 mcg)',
     '1.ใช้สำหรับเตรียมปากมดลูกในการยุติการตั้งครรภ์ด้วยวิธีทางศัลยกรรม2.ใช้สำหรับยุติการตั้งครรภ์กรณีที่มีอายุครรภ์มากกว่า 12 สัปดาห์ร่วมกับยา misoprostol (200 ไมโครกรัม) + mifepristone (200 มิลลิกรัม) tablet ชนิด combination pack ตามพระราชบัญญัติแก้ไขเพิ่มเติมประมวลกฎหมายอาญา (ฉบับที่ 28) พ.ศ. 2564 มาตรา 301 และ 305หมายเหตุใช้ยา misoprostol รูปแบบ tablet ขนาด 200 ไมโครกรัม เป็น repeated dose ภายหลังจากการใช้ยา misoprostol + mifepristone รูปแบบ tablet (200 ไมโครกรัม+ 200 มิลลิกรัมชนิด combination pack3.ใช้สำหรับป้องกันภาวะตกเลือดหลังคลอด ในสถานพยาบาลที่ไม่มียา oxytocin หรือไม่สามารถให้ยา oxytocin ได้ 4.ใช้สำหรับรักษาภาวะตกเลือดหลังคลอดที่เกิดจากมดลูกไม่หดรัดตัว ภายหลังใช้ยา oxytocin แล้วผู้ป่วยไม่ตอบสนอง',
     ''
  ),
  (
     'Misoprostol +  Mifepristone',
     '',
     'tab (200 mcg + 200 mg ชนิดcombination pack)',
     'ใช้สำหรับการยุติการตั้งครรภ์ตามพระราชบัญญัติแก้ไขเพิ่มเติมประมวลกฎหมายอาญา (ฉบับที่ 28) พ.ศ. 2564 มาตรา 301 และ 305',
     ''
  ),
  (
     'Oxytocin',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Alprostadil',
     '',
     'sterile sol (เฉพาะ 0.5 mg/ml)',
     'ใช้กับผู้ป่วยโรคหัวใจแต่กำเนิดที่ต้องพึ่ง ductus arteriosus',
     ''
  ),
  (
     'Indomethacin sodium',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้กับผู้ป่วยเด็กเพื่อปิด patent ductus arteriosus',
     ''
  ),
  (
     'Sulprostone',
     '',
     'sterile pwdr',
     'ใช้ช่วยชีวิตผู้ป่วย severe post-partum hemorrhage',
     ''
  ),
  (
     'Terbutaline sulfate',
     '',
     'tab, sterile sol',
     '',
     ''
  ),
  (
     'Nifedipine',
     '',
     'immediate release tab',
     'ใช้ใน uncomplicated premature labor ที่มีอายุครรภ์ 24-33 สัปดาห์',
     ''
  ),
  (
     'Clotrimazole',
     '',
     'vaginal tab',
     '',
     ''
  ),
  (
     'Nystatin',
     '',
     'vaginal tab',
     '',
     ''
  ),
  (
     'Conjugated estrogens',
     '',
     'vaginal cream',
     '',
     ''
  ),
  (
     'Etonogestrel',
     '',
     'implant 1 rod (68 mg/rod)',
     '',
     ''
  ),
  (
     'Ethinylestradiol + Levonorgestrel',
     '',
     'tab (เฉพาะ 30 + 150 mcg)',
     '',
     ''
  ),
  (
     'Levonorgestrel',
     '',
     'tab (เฉพาะ 750 mcg), implant  2 rods (75 mg/rod)',
     'Levonorgestrel รูปแบบยาเม็ดใช้สำหรับคุมกำเนิดกรณีฉุกเฉินเท่านั้น',
     ''
  ),
  (
     'Medroxyprogesterone acetate',
     '',
     'sterile susp',
     '',
     ''
  ),
  (
     'Ethinylestradiol + Desogestrel',
     '',
     'tab (เฉพาะ 20 + 150 mcg)',
     '',
     ''
  ),
  (
     'Lynestrenol',
     '',
     'tab (เฉพาะ 0.5 mg)',
     '',
     ''
  ),
  (
     'Doxazosin mesilate',
     '',
     'immediate release tab (เฉพาะ 2 และ 4 mg)',
     '',
     ''
  ),
  (
     'Alfuzosin hydrochloride',
     '',
     'SR tab (เฉพาะ 10 mg)',
     'ใช้กับผู้ป่วยโรคต่อมลูกหมากโตที่ไม่ตอบสนองต่อการรักษา หรือ ไม่สามารถทนต่ออาการไม่พึงประสงค์จากการรักษาด้วยยากลุ่ม non-uroselective alpha-1 adrenergic blockers',
     ''
  ),
  (
     'Finasteride',
     '',
     'tab(เฉพาะ 5 mg)',
     'ใช้กับผู้ป่วยโรคต่อมลูกหมากโตที่มีอาการผิดปกติในการปัสสาวะระดับปานกลางถึงรุนแรง และมีขนาดของต่อมลูกหมากมากกว่า 40 ml หรือมีระดับ prostate specific antigen (PSA) concentrations มากกว่า 1.4 ng/ml',
     ''
  ),
  (
     'Oxybutynin hydrochloride',
     '',
     'immediate release tab',
     '1. ใช้สำหรับ neurogenic bladder ในผู้ป่วยเด็กตั้งแต่แรกเกิด (newborn)2. ใช้ใน overactive bladder (OAB) ในผู้ป่วยเด็กตั้งแต่ 5 ปีขึ้นไป3. ไม่ใช้สำหรับ nocturnal enuresis (ปัสสาวะรดที่นอนในเด็ก)',
     ''
  ),
  (
     'Trospium chloride',
     '',
     'immediate release tab (เฉพาะ 20 mg)',
     'ใช้ใน overactive bladder (OAB) และ urinary incontinence ในผู้ใหญ่ ยกเว้น stress incontinence',
     ''
  ),
  (
     'Potassium citrate',
     '',
     'oral sol (hosp), dry pwdr for oral sol (hosp)',
     '',
     ''
  ),
  (
     'Sodium citrate + Citric acid',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Sodium citrate + Potassium citrate',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Busulfan',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Chlorambucil',
     '',
     'tab',
     'สำหรับโรคไตให้ใช้กรณี idiopathic membranous glomerulonephritis',
     ''
  ),
  (
     'Cyclophosphamide',
     '',
     'tab, sterile pwdr',
     '',
     ''
  ),
  (
     'Melphalan',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Carmustine',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้เป็น conditioning regimen ในการรักษา Hodgkins และ non-Hodgkins lymphoma ด้วยวิธี hematopoietic stem cell transplantation',
     ''
  ),
  (
     'Ifosfamide',
     '',
     'sterile pwdr',
     '1. ใช้เป็น second-line treatment สำหรับ lymphoma ชนิด relapse หรือ refractory   2. ใช้กับผู้ป่วยที่เป็น  sarcoma 3. ใช้สำหรับ Wilms tumor และ neuroblastoma4. ใช้ สำหรับ germ cell tumor',
     ''
  ),
  (
     'Procarbazine hydrochloride',
     'ยากำพร้า',
     'cap, tab',
     '1. ใช้เป็น adjuvant หรือ neo-adjuvant therapy สำหรับ anaplastic oligodendroglioma2. ใช้สำหรับ recurrent anaplastic oligodendroglioma3. ใช้สาหรับ Hodgkins lymphoma',
     ''
  ),
  (
     'Bleomycin',
     '',
     'sterile pwdr (as sulfate or as hydrochloride)',
     '',
     ''
  ),
  (
     'Dactinomycin',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Doxorubicin hydrochloride',
     '',
     'sterile pwdr,sterile susp ,sterile sol',
     'ไม่ใช้กับผู้ป่วยโรคหัวใจขาดเลือดเฉียบพลัน และผู้ป่วยที่มี cardiomyopathy ที่มี left ventricular ejection fraction น้อยกว่า 50%',
     ''
  ),
  (
     'Idarubicin hydrochloride',
     '',
     'sterile pwdr, sterile sol',
     'ใช้กับผู้ป่วย acute myeloid leukemia',
     ''
  ),
  (
     'Mitomycin',
     '',
     'sterile pwdr , sterile sol',
     '1. ใช้เป็น alternative drug ของ BCG สำหรับมะเร็งกระเพาะปัสสาวะชนิด superficial bladder cancer 2. ใช้รักษามะเร็งตับโดยการฉีดเข้าหลอดเลือดแดงเฉพาะที่ในการทำ transarterial chemo embolization (TACE)3. ใช้รักษามะเร็งทวารหนัก (anal canal) โดยใช้ร่วมกับรังสีรักษา',
     ''
  ),
  (
     'Mitoxantrone hydrochloride',
     '',
     'sterile pwdr, sterile sol',
     '1. ใช้สำหรับ acute myeloid leukemia  และมะเร็งต่อมน้ำเหลือง2. ใช้กับผู้ป่วยเด็กที่เป็น relapsed/refractory acute lymphoblastic leukemia (ALL)',
     ''
  ),
  (
     'Cytarabine',
     '',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Fluorouracil',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Mercaptopurine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Methotrexate',
     '',
     'tab (as base or sodium), sterile pwdr / sterile sol (as sodium)',
     '',
     ''
  ),
  (
     'Capecitabine',
     '',
     'tab',
     '1. ใช้สำหรับ advanced breast cancer โดยใช้เป็น second หรือ third-line drug หลังการใช้ anthracyclineและ/หรือ taxane มาแล้ว2. ใช้ร่วมกับรังสีรักษาในการรักษาเสริม ก่อน หรือ หลัง การผ่าตัดในมะเร็งลำไส้ใหญ่ส่วนปลาย3. ใช้เป็นการรักษาเสริมหลังการผ่าตัดมะเร็งลำไส้ใหญ่ stage II-III3.1 ใช้เป็นยาเดี่ยวใน colorectal cancer stage II-III หรือ3.2 ใช้ร่วมกับ oxaliplatin ใน stage III colorectal cancer ในผู้ป่วยที่มี Eastern Co-operative Oncology Group (ECOG) performance status ตั้งแต่ 0-14. ใช้ร่วมกับ oxaliplatin ในผู้ป่วย advanced colorectal cancer (CRC)5. ใช้เป็นการรักษาเสริมหลังผ่าตัดแบบ D2 lymphadenectomy ในผู้ป่วยมะเร็งกระเพาะอาหาร pathological stage II-III โดยใช้ร่วมกับยา oxaliplatin6. ใช้เป็นการรักษาเสริมหลังการผ่าตัดมะเร็งเต้านมระยะแรกชนิด triple negative ในผู้ป่วยที่มีรอยโรคทางพยาธิวิทยาหลงเหลือ (residual tumor) ภายหลังได้รับ neoadjuvant chemotherapy ที่มียา anthracycline และ taxane7. ใช้เป็นการรักษาเสริมหลังผ่าตัด (adjuvant therapy) ในผู้ป่วยโรคมะเร็งท่อน้ำดี (Cholangiocarcinoma) และ มะเร็งถุงน้ำดี (Gallbladder Cancer) โดยให้ยาไม่เกิน 8 cycles (1 คอร์ส ของการรักษา)',
     ''
  ),
  (
     'Fludarabine phosphate',
     '',
     'sterile pwdr (เฉพาะ 50 mg)',
     'ใช้เป็น first line หรือ second line treatment ใน B-cell chronic lymphocytic leukemia',
     ''
  ),
  (
     'Gemcitabine hydrochloride',
     '',
     'sterile pwdr',
     '1.ใช้สำหรับ advanced pancreatic cancer2.ใช้สำหรับ advanced non-small cell lung cancer3.ใช้สำหรับ advanced bladder cancer4.ใช้เป็น second-line หรือ subsequent line ใน advanced ovarian cancer ที่ดื้อต่อยาในกลุ่ม taxane5.ใช้ร่วมกับ cisplatin สำหรับ locally advanced and metastatic cholangiocarcinoma6.ใช้สำหรับรักษามะเร็งหลังโพรงจมูกระยะลุกลามเฉพาะที่ (locally advanced stage: stage III, IVa และ IVb ที่มีการกระจายไปที่ต่อมน้ำเหลือง) โดยใช้ร่วมกับ cisplatin เป็นยาเสริมก่อน (induction chemotherapy) การให้รังสีรักษาร่วมกับยาเคมีบำบัด (concurrent chemoradiation)7.ใช้สำหรับรักษามะเร็งหลังโพรงจมูกระยะแพร่กระจาย หรือกลับเป็นซ้ำ โดยใช้เป็นยาขนานแรกร่วมกับ cisplatin8.ใช้เป็นยาขนานที่สองในการรักษามะเร็งเนื้อเยื่ออ่อน (soft tissue sarcoma) ระยะแพร่กระจาย หรือผ่าตัดไม่ได้ที่เคยได้ยากลุ่ม anthracycline และ ifosfamide มาแล้ว โดยให้ร่วมกับยา docetaxel',
     ''
  ),
  (
     'Oxaliplatin',
     '',
     'sterile pwdr ,sterile sol',
     '1.ใช้ในการรักษา colorectal cancer stage III-IV โดยใช้ร่วมกับ 5-FU + leucovorin based- regimen หรือ capecitabine ในคนไข้ที่มี Eastern Co-operative Oncology Group (ECOG) performance status ตั้งแต่ 0  12.ใช้รักษาเสริมหลังผ่าตัดแบบ D2 lymphadenectomy ในผู้ป่วยมะเร็งกระเพาะอาหาร ที่มี pathological stage II-III โดยใช้ร่วมกับยา capecitabine 3.ใช้รักษาผู้ป่วยมะเร็งกระเพาะอาหารระยะแพร่กระจายหรือโรคกลับเป็นซ้ำที่ผ่าตัดไม่ได้ (ระยะที่ IV) และสภาพร่างกายแข็งแรง (ECOG PS 0-2) โดยให้เป็นยาขนานแรก และใช้ร่วมกับยากลุ่ม fluoropyrimidine4.ใช้รักษาเสริมหลังผ่าตัดในผู้ป่วยมะเร็งตับอ่อนระยะแรกที่ผ่าตัดออกจนไม่มีร่องรอยของโรคเหลืออยู่แบบเห็นได้ (post R0 or R1 resection) โดยใช้ร่วมกับ Irinotecan และ 5-FU',
     ''
  ),
  (
     'Pemetrexed',
     '',
     'sterile pwdr',
     'ใช้ร่วมกับยา cisplatin ในการรักษาผู้ป่วยมะเร็งเยื่อหุ้มปอดชนิดที่ไม่สามารถผ่าตัดออกไปได้โดยผู้ป่วยไม่เคยได้รับยาเคมีบำบัดมาก่อน',
     ''
  ),
  (
     'Thioguanine (6-TG)',
     '',
     'tab',
     'ใช้สำหรับ chronic myeloid leukemia, acute lymphoblastic leukemia และ acute myeloid leukemia',
     ''
  ),
  (
     'Etoposide',
     '',
     'cap (as base), sterile sol (as base)',
     '',
     ''
  ),
  (
     'Vinblastine sulfate',
     '',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Vincristine sulfate',
     '',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Vinorelbine  tartrate',
     '',
     'sterile sol (เฉพาะ 10 mg/ml)',
     'ใช้เป็น adjuvant therapy ใน non small cell lung cancer stage II-IIIA',
     ''
  ),
  (
     'Asparaginase',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Calcium folinate',
     '',
     'cap, tab, sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Cisplatin',
     '',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Carboplatin',
     '',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Hydroxycarbamide',
     '',
     'cap',
     '',
     ''
  ),
  (
     'Arsenic trioxide',
     'ยากำพร้า',
     'sterile sol, sterile sol (hosp)',
     'ใช้สำหรับ relapsed หรือ resistant acute promyelocytic leukemia (APL)',
     ''
  ),
  (
     'Dacarbazine',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้สำหรับ Hodgkins lymphoma ในสูตรยาเคมีบำบัด ABVD',
     ''
  ),
  (
     'Docetaxel',
     '',
     'sterile sol',
     '1.ใช้ร่วมกับ cyclophosphamide ในการรักษาเสริมสำหรับผู้ป่วยโรคมะเร็งเต้านมระยะเริ่มต้นที่มีปัญหาโรคหัวใจ หรือ เคยได้รับยา doxorubicin แล้ว 2.ใช้กับผู้ป่วยโรคมะเร็งเต้านมระยะลุกลามหลังจากได้รับ doxorubicin และ paclitaxel แล้ว หรือมีปัญหาโรคหัวใจ 3.ใช้เป็น second-line drug สำหรับโรคมะเร็งปอด ชนิด non-small cell ระยะลุกลาม 4.ใช้สำหรับมะเร็งต่อมลูกหมากระยะแพร่กระจาย5.ใช้เป็นยาขนานที่สองในการรักษามะเร็งเนื้อเยื่ออ่อน (soft tissue sarcoma) ระยะแพร่กระจาย หรือผ่าตัดไม่ได้ที่เคยได้ยากลุ่ม anthracycline และ ifosfamide มาแล้วโดยให้ร่วมกับ gemcitabine',
     ''
  ),
  (
     'Irinotecan hydrochloride',
     '',
     'sterile sol (เฉพาะ 20 mg/ml) (2 ml, 5 ml)',
     '1.ใช้สำหรับรักษา metastatic colorectal cancer โดยใช้ร่วมกับ 5-FU + leucovorin2.ใช้รักษาเสริมหลังผ่าตัดในผู้ป่วยมะเร็งตับอ่อนระยะแรกที่ผ่าตัดออกจนไม่มีร่องรอยของโรคเหลืออยู่แบบเห็นได้ (post R0 or R1 resection) โดยใช้ร่วมกับ oxaliplatin และ 5-FU',
     ''
  ),
  (
     'Mitotane',
     'ยากำพร้า',
     'tab (เฉพาะ 500 mg)',
     '1. ใช้สำหรับ adrenocortical carcinoma ที่ไม่สามารถผ่าตัดได้2. ใช้สำหรับ adrenocortical carcinoma ระยะแพร่กระจาย',
     ''
  ),
  (
     'Tretinoin',
     '',
     'cap',
     'ใช้รักษาโรค acute myeloid leukemia ชนิด M3 (acute promyelocytic leukemia) ที่ได้รับการตรวจ chromosome หรือ PML/RARA โดยจะต้องหยุดใช้ยาเมื่อผลการตรวจ chromosome ไม่ยืนยันว่าพบ t(15;17) หรือ PML/RARA เป็นลบ',
     ''
  ),
  (
     'Paclitaxel',
     '',
     'sterile sol',
     '1. ใช้สำหรับ advanced breast cancer ที่ได้รับ anthracycline มาแล้ว หรือไม่สามารถให้ anthracycline ได้2. ใช้เป็น adjuvant treatment สำหรับ high risk, node positive breast cancer3. ใช้สำหรับมะเร็งรังไข่4. ใช้สำหรับ advanced non-small cell lung cancer5. ใช้สำหรับ AIDS-related Kaposis sarcoma6. ใช้เป็น second line treatment ใน nasopharyngeal cancer ระยะแพร่กระจายหรือกลับเป็นซ้ำ7. ใช้สำหรับ esophageal cancer8. ใช้เป็น first line treatment ในการรักษา advanced cervical cancer 9. ใช้สำหรับ malignant melanoma10.ใช้สำหรับโรคมะเร็งเยื่อบุท่อนำไข่ หรือมะเร็งเยื่อบุช่องท้องชนิดปฐมภูมิ ในระยะลุกลาม (ระยะที่ IV) หรือ ระยะที่ IIIB-IIIC ที่ได้รับการผ่าตัด (debulked) แล้วมีขนาดก้อนเหลือมากกว่า 1 เซนติเมตร',
     ''
  ),
  (
     'Topotecan',
     '',
     'sterile pwdr',
     '1. ใช้กับผู้ป่วย neuroblastoma ที่มีความเสี่ยงสูง2. ใช้โดยแพทย์ผู้เชี่ยวชาญด้านโลหิตวิทยาและมะเร็งในเด็ก',
     ''
  ),
  (
     'Bevacizumab',
     '',
     'sterile sol',
     'ใช้สำหรับโรคมะเร็งรังไข่ชนิดเยื่อบุผิว มะเร็งเยื่อบุท่อนำไข่ หรือมะเร็งเยื่อบุช่องท้องชนิดปฐมภูมิ ในระยะลุกลาม (ระยะที่ IV) หรือ ระยะที่ IIIB-IIIC ที่ได้รับการผ่าตัด (debulked) แล้วมีขนาดก้อนเหลือมากกว่า 1 เซนติเมตร ',
     ''
  ),
  (
     'Bortezomib',
     '',
     'sterile pwdr (เฉพาะ 3.5 mg)',
     'ใช้สำหรับ multiple myeloma ในผู้ป่วย transplant candidate โดยใช้เป็น first-line treatment ',
     ''
  ),
  (
     'Erlotinib',
     '',
     'tab (เฉพาะ 150 mg)',
     'ใช้เป็น first-line drug สำหรับโรคมะเร็งปอด ชนิด non-small cell lung carcinoma (NSCLC) ระยะลุกลามถึงแพร่กระจายที่มีผลตรวจการกลายพันธุ์ของยีน Epidermal growth factor receptor (EGFR) เป็นบวก ',
     ''
  ),
  (
     'Imatinib  mesilate',
     '',
     'tab  (เฉพาะ 100 และ 400 mg)',
     '1. ใช้สำหรับ chronic myeloid leukemia (CML) 2. ใช้สำหรับ gastrointestinal stromal tumors (GISTs) ระยะลุกลามหรือมีการกระจายของโรค 3.ใช้เป็น first-line treatment สำหรับ Philadelphia chromosome positive acute lymphoblastic leukemia(Ph + ALL) โดยใช้ร่วมกับยาเคมีบำบัด ',
     ''
  ),
  (
     'Nilotinib hydrochloride',
     '',
     'cap (เฉพาะ 200 mg)',
     'ใช้เป็น second-line treatment สำหรับ chronic myeloid leukemia (CML) ที่ไม่สามารถใช้ imatinib ได้',
     ''
  ),
  (
     'Dasatinib',
     '',
     'tab (เฉพาะ 50 mg และ 70 mg)',
     '1.ใช้สำหรับ chronic myeloid leukemia (CML) ที่ไม่สามารถใช้ imatinib หรือ nilotinib ได้ 2.ใช้เป็น second-line treatment สำหรับ Philadelphia chromosome positive acute lymphoblasticleukemia (Ph + ALL) ที่ไม่สามารถใช้ยา imatinib ได้ โดยใช้ร่วมกับยาเคมีบำบัด ',
     ''
  ),
  (
     'Rituximab',
     '',
     'sterile sol',
     '1. ใช้สำหรับ non-Hodgkin lymphoma ชนิด Diffused Large B-Cell Lymphoma (DLBCL) ในเด็กและผู้ใหญ่ 2.ใช้ในการรักษา non-Hodgkin  lymphoma ชนิด advanced follicular lymphoma โดยใช้ร่วมกับยาเคมีบําบัดสูตร R-CHOP และ R-CVP 3.ใช้สำหรับ non-Hodgkin  lymphoma ชนิด burkitt lymphoma (BL) ในผู้ป่วยเด็ก ',
     ''
  ),
  (
     'Trastuzumab',
     '',
     'sterile pwdr (เฉพาะ 150 mg และ 440 mg)',
     'ใช้กับผู้ป่วยโรคมะเร็งเต้านมระยะเริ่มต้น (early stage breast cancer) ',
     ''
  ),
  (
     'Dexamethasone',
     '',
     'cap (as base) , tab (as base), sterile sol (as sodium phosphate or acetate)',
     '',
     ''
  ),
  (
     'Prednisolone',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Azathioprine',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Ciclosporin',
     '',
     'cap, oral sol, oral susp, sterile sol',
     '',
     ''
  ),
  (
     'Methylprednisolone',
     '',
     'sterile pwdr/sterile susp (as hemisuccinate or sodium succinate or acetate)',
     '',
     ''
  ),
  (
     'Antithymocyte immunoglobulin, rabbit',
     '',
     'sterile pwdr , sterile sol',
     '1. ใช้ในระยะ induction สำหรับผู้ป่วยที่ได้รับการปลูกถ่ายไตที่มีระดับความเสี่ยงปานกลางขึ้นไป ต่อการเกิด acute allograft rejection2. ใช้รักษาระยะ induction ในผู้ป่วยที่มีความเสี่ยงสูงต่อการเกิด acute allograft rejection ใน solid organ transplantation ที่ไม่ใช่การปลูกถ่ายไต3. ใช้รักษาภาวะ acute allograft rejection เฉพาะ solid organ transplantation ที่ไม่ตอบสนองต่อ pulse methylprednisolone หรือที่มีพยาธิสภาพรุนแรง4. ใช้รักษาระยะ induction ในผู้ป่วยปลูกถ่ายหัวใจที่ไม่สามารถใช้ basiliximab ได้ หรือ ผู้ป่วยปลูกถ่ายไต-หัวใจ (heart-kidney transplantation)',
     ''
  ),
  (
     'Basiliximab',
     '',
     'sterile pwdr',
     '1.ใช้รักษาระยะ induction ในผู้ป่วยปลูกถ่ายไตที่มีความเสี่ยงต่ำ (Low Risk: LR) ขึ้นไป2.ใช้รักษาระยะ induction ในผู้ป่วยปลูกถ่ายตับที่มีปัญหาไตร่วมด้วย หรือมีความเสี่ยงของการเกิดปัญหาไต ข้อใดข้อหนึ่งดังต่อไปนี้2.1 ผู้ป่วยที่มีภาวะ hepatorenal syndrome2.2 ผู้ป่วยที่มีภาวะไตวายเฉียบพลันก่อนผ่าตัด2.3 ผู้ป่วย CKD stage III ขึ้นไป หรือ CKD stage II with acute kidney injury2.4 ภาวะอื่นๆ ได้แก่ massive blood loss (มากกว่า 1 blood volume), prolonged hypotension (หรือ shock มากกว่า 3 ชั่วโมง), fulminant /subfulminant hepatic failure , impending primary graft non-function ( AST/ALT> 2,000 IU/L ภายใน 24 ชั่วโมงแรกของการผ่าตัด)3. ใช้รักษาระยะ induction ในผู้ป่วยปลูกถ่ายหัวใจ ยกเว้นในผู้ป่วยปลูกถ่ายไตหัวใจ (Heart-Kidney Transplantation)',
     ''
  ),
  (
     'Mycophenolate mofetil',
     '',
     'cap, tab',
     '1. ใช้กับผู้ป่วยปลูกถ่ายตับในระยะ maintenance therapy2. กรณีผู้ป่วยไตมีเงื่อนไข คือ   2.1 ใช้เป็น alternative drug ในกรณีผู้ป่วยปลูกถ่ายไตในระยะ maintenance therapy   2.2 ใช้เป็น alternative drug ในกรณีผู้ป่วย severe lupus nephritis (class III-IV) ในกรณี  ดังนี้        2.2.1 ระยะ induction therapy* ในกรณีดังนี้                2.2.1.1 กรณีที่ใช้ Intravenous cyclophosphamide (IVCY) อย่างน้อย 6 เดือนแล้วไม่ได้ผล และไม่สามารถทำให้เกิด remission** ได้ หรือ                2.2.1.2 กรณีที่เคยได้รับ Intravenous cyclophosphamide (IVCY) ครบ 1 course แล้ว และมี active lupus nephritis ซ้ำอีก หรือ                2.2.1.3 กรณีผู้ป่วยไม่สามารถรับ Intravenous cyclophosphamide (IVCY) ได้        2.2.2 ในระยะ maintenance therapy ที่ใช้ Azathioprine ไม่ได้หรือใช้แล้วไม่ได้ผล3. ใช้กับผู้ป่วยปลูกถ่ายหัวใจในระยะ maintenance therapy4. ใช้สำหรับผู้ป่วย Neuromyelitis optica spectrum disorder (NMOSD) ในกรณีดังนี้4.1 ใช้ยา prednisolone ร่วมกับยา azathioprine แล้วยังไม่สามารถป้องกันการกลับเป็นซ้ำของโรคได้หลังจากได้ยาในปริมาณที่เหมาะสม Prednisolone (10-20 mg/day) ร่วมกับ Azathioprine (2-3 mg/kg/day) เป็นเวลา 6 เดือน4.2 ผู้ป่วยมีข้อห้ามใช้ยา Prednisolone หรือ Azathioprine เพียงข้อใดข้อหนึ่ง ดังนี้4.2.1 มีภาวะตับอักเสบที่มีค่าเอนไซม์ของตับ (AST และ ALT) เพิ่มมากกว่าค่าปกติ 5 เท่า4.2.2 มีภาวะเม็ดเลือดขาวต่ำกว่า 3,000 cells/l หรือ มีปริมาณนิวโทรฟิลน้อยกว่า 1,000 cells/l4.2.3 มีอาการแพ้ยา เช่น มีผื่นแพ้ยาจากยา Azathioprine หรือมีภาวะอื่นๆ ที่ไม่สามารถใช้ยา Prednisolone ได้ เช่น มีภาวะน้ำตาลสูงที่ไม่สามารถควบคุมได้, กระดูกพรุนอย่างรุนแรง, ภาวะ avascular necrosis, ภาวะต้อหินจากยา หรือมีความผิดปกติทางเมตาบอลิซึมอื่นๆ ที่ส่งผลต่อภาวะทุพพลภาพของผู้ป่วยได้5. ใช้สำหรับรักษาภาวะ systemic sclerosis-associated interstitial lung disease (SSc-ILD) ที่ไม่ตอบสนองหลังได้รับยา Cyclophosphamide ภายในระยะเวลา 6 เดือน หรือมีข้อห้ามหรือไม่สามารถทนต่ออาการข้างเคียงจากการใช้ยา Cyclophosphamide โดยมีการติดตามประเมินผลนาน 1 ปีหลังได้รับยา6.ใช้สำหรับรักษาโรคปอดอินเตอร์สติเชียลจากโรคกล้ามเนื้ออักเสบไม่ทราบสาเหตุ (idiopathic inflammatory myositis-associated interstitial lung disease, IIM-ILD) ในกรณีดังนี้6.1 ไม่ตอบสนองต่อการรักษาด้วยยา corticosteroids และ ยากดภูมิพื้นฐานอีก 2 ชนิด ได้แก่ cyclophosphamide, azathioprine หรือ calcineurin inhibitors หรือ6.2 มีผลข้างเคียงหรือมีข้อห้ามของการรักษาด้วยยา corticosteroids และ ยากดภูมิพื้นฐาน',
     ''
  ),
  (
     'Tacrolimus',
     '',
     'cap, sterile sol (concentrate for infusion)',
     '1. ใช้กับผู้ป่วยปลูกถ่ายไตในระยะ maintenance therapy ที่อยู่ในกลุ่มที่มีความเสี่ยงปานกลาง (MR) ขึ้นไป2. ใช้กับผู้ป่วยปลูกถ่ายไต หลังเกิดภาวะ acute rejection โดยเลือกใช้เป็นตัวแรกเฉพาะผู้ป่วยที่มีความเสี่ยงปานกลาง (MR) ขึ้นไป 3. ใช้กับผู้ป่วยปลูกถ่ายตับในระยะ maintenance therapy',
     ''
  ),
  (
     'Sirolimus',
     '',
     'oral sol (เฉพาะ 1 mg/ml), tab (เฉพาะ 1 mg)',
     '1. ใช้กับผู้ป่วยปลูกถ่ายไตในระยะ maintenance therapy ที่มีเงื่อนไขข้อใดข้อหนึ่ง ดังต่อไปนี้1.1. ต้องการหลีกเลี่ยงพิษต่อไต หรือผลข้างเคียงอื่น ๆ จากยา cyclosporin หรือ tacrolimus1.2. ติดเชื้อ เช่น CMV (Cytomegalovirus) หรือ BKV (BK virus) ภายหลังจากการปลูกถ่ายไต1.3. ตรวจพบ หรือมีความเสี่ยงสูง ในการเกิดมะเร็งภายหลังจากการปลูกถ่ายไต2. ใช้กับผู้ป่วยปลูกถ่ายหัวใจที่มีภาวะไตวายที่มีค่า eGFR (CKD-EPI formula) ในช่วง 30-50 ml/min/1.73 m23. ใช้กับผู้ป่วยปลูกถ่ายตับที่เคยได้รับยา sirolimus มาก่อนและไม่มีปัญหาการตอบสนองต่อยา',
     ''
  ),
  (
     'Everolimus',
     '',
     'tab (เฉพาะ 0.25 mg และ 0.5 mg)',
     '1. ใช้กับผู้ป่วยปลูกถ่ายตับระยะ maintenance therapy ร่วมกับยา tacrolimus เพื่อหลีกเลี่ยงภาวะแทรกซ้อนจากการใช้ยา  tacrolimus ในขนาดสูงและเกิดผลข้างเคียงจากการใช้ยา mycophenolate mofetil ได้แก่ ปวดท้อง ท้องเสียเรื้อรัง (มากกว่า 2 สัปดาห์) ภาวะกดไขกระดูก2. ใช้กับผู้ป่วยปลูกถ่ายหัวใจ ที่มีภาวะดังต่อไปนี้2.1 ภาวะ cardiac allograft vasculopathy ที่ยืนยันโดย coronary angiogram หรือ intravascular ultrasound (IVUS) และ/หรือ2.2 ภาวะไตวายที่มีค่า eGFR (CKD-EPI formula) น้อยกว่า 30 ml/min/1.73 m2',
     ''
  ),
  (
     'BCG',
     '',
     'freeze-dried pwdr for bladder instillation',
     'ใช้สำหรับมะเร็งกระเพาะปัสสาวะชนิด superficial bladder cancer',
     ''
  ),
  (
     'Human normal immunoglobulin, intravenous',
     '',
     'sterile pwdr, sterile sol',
     '1. ใช้สำหรับโรคคาวาซากิระยะเฉียบพลัน (acute phase of Kawasaki disease)  2. ใช้สำหรับโรคภูมิคุ้มกันบกพร่องปฐมภูมิ (primary immunodeficiency diseases)  3. ใช้สำหรับโรค immune thrombocytopenia ชนิดรุนแรง  4. ใช้สำหรับ autoimmune hemolytic anemia (AIHA) ที่ไม่ตอบสนองต่อการรักษาตามขั้นตอนของมาตรฐานการรักษาและมีอาการรุนแรงที่อาจเป็นอันตรายถึงแก่ชีวิต  5. ใช้สำหรับโรค GuillainBarr syndrome ที่มีอาการรุนแรง โดยมีแนวทางกำกับการใช้ยาเป็นไปตาม รายละเอียดในภาคผนวก 3 6. ใช้สำหรับโรคกล้ามเนื้ออ่อนแรงชนิดร้ายระยะวิกฤต (myasthenia gravis, acute exacerbation หรือ myasthenic crisis)  7. ใช้สำหรับโรค pemphigus vulgaris ที่มีอาการรุนแรง และไม่ตอบสนองต่อการรักษาด้วยยามาตรฐาน  8. ใช้สำหรับ hemophagocytic lymphohistiocytosis (HLH) โดยมีแนวทางกำกับการใช้ยาเป็นไปตาม รายละเอียดในภาคผนวก 3 9. ใช้สำหรับโรค pemphigus vulgaris ที่มีอาการรุนแรง และไม่ตอบสนองต่อการรักษาด้วยยามาตรฐาน  10. ใช้สำหรับ hemophagocytic lymphohistiocytosis (HLH) โดยมีแนวทางกำกับการใช้ยาเป็นไปตาม รายละเอียดในภาคผนวก 3 11. ใช้เป็น second-line treatment สำหรับ dermatomyositis โดยมีแนวทางกำกับการใช้ยาเป็นไปตาม  รายละเอียดในภาคผนวก 312. ใช้สำหรับโรค Chronic Inflammatory Demyelinating Polyradiculoneuropathy (CIDP) 13. ใช้สำหรับโรค multifocal motor neuropathy with conduction block  14. ใช้สำหรับโรคสมองอักเสบจากภูมิคุ้มกันผิดปกติ (autoimmune encephalitis) ',
     ''
  ),
  (
     'Rituximab',
     '',
     'sterile sol',
     '1. ใช้สำหรับกลุ่มโรคนิวโรมัยอิลัยติสออพติกา (neuromyelitis optica spectrum disorder; NMOSD) ที่ไม่ตอบสนองต่อการรักษาด้วยยา Prednisolone + Azathioprine หรือมีข้อห้ามในการใช้ยา Prednisolone หรือ Azathioprine  2. ใช้สำหรับโรคมัลติเพิลสเคลอโรสิชชนิดที่มีการกลับเป็นซ้ำ (relapsing remitting multiple sclerosis; RRMS)  3. ใช้สำหรับโรคเส้นประสาทอักเสบเรื้อรังที่ไม่ตอบสนองต่อยาสเตียรอยด์ (refractory chronic inflammatory demyelinating polyneuropathy) 4. ใช้สำหรับโรคมัยแอสติเนียเกรวิสที่รุนแรงและไม่ตอบสนองต่อยาสเตียรอยด์ (severe myasthenia gravis)  5. ใช้สำหรับโรคสมองอักเสบจากภูมิคุ้มกันผิดปกติ (autoimmune encephalitis)  6. ใช้สำหรับโรค autoimmune myositis ชนิด necrotizing autoimmune myopathy (NAM) ',
     ''
  ),
  (
     'Tamoxifen citrate',
     '',
     'tab',
     'ใช้สำหรับมะเร็งเต้านม',
     ''
  ),
  (
     'Anastrozole',
     '',
     'tab (เฉพาะ 1 mg)',
     'ใช้สำหรับมะเร็งเต้านมที่มี hormone receptor เป็นบวก',
     ''
  ),
  (
     'Letrozole',
     '',
     'tab (เฉพาะ 2.5 mg)',
     'ใช้สำหรับมะเร็งเต้านมที่มี hormone receptor เป็นบวก',
     ''
  ),
  (
     'Megestrol acetate',
     '',
     'tab',
     '1. ใช้สำหรับ advanced breast cancer ที่มีผลการตรวจ hormone receptor เป็นบวก2. ใช้สำหรับ advanced endometrial cancer (endometrioid) โดยให้ยาจนกระทั่งมีการกำเริบของโรค3. ใช้สำหรับ early stage endometrial cancer ในผู้ป่วยอายุน้อยกว่า 40 ปี ที่เป็น  well-differentiated endometrioid ซึ่งผลการตรวจ MRI ไม่พบ myometrial invasion และให้ยาไม่เกิน 1 ปี4. ใช้สำหรับ low grade endometrial stromal sarcoma (ESS) และให้ยาไม่เกิน 1 ปี',
     ''
  ),
  (
     'Bicalutamide',
     '',
     'tab (เฉพาะ 50 mg)',
     '1. ใช้สำหรับรักษามะเร็งต่อมลูกหมากระยะแพร่กระจาย โดยใช้เป็นยาทางเลือกลำดับที่สองต่อจากการผ่าตัดอัณฑะออกทั้งสองข้าง (bilateral orchiectomy) 2. ใช้ร่วมกับ GnRH analogue ในผู้ป่วยโรคมะเร็งต่อมลูกหมากระยะลุกลามที่ไม่เคยได้รับการวินิจฉัยหรือรักษามาก่อนที่จำเป็นต้องได้รับการรักษาเร่งด่วน เช่น มีความเสี่ยงสูงมากต่อ pathological fracture,  มี malignant spinal cord compression, หรือมีความผิดปกติทางโลหิตวิทยาที่สงสัยมะเร็งต่อมลูกหมากระยะแพร่กระจาย (Disseminated intravascular clotting, DIC) โดยพิจารณาให้ยา bicalutamide เป็นเวลา 30 วัน ในระหว่างการรอตรวจชิ้นเนื้อเพื่อยืนยัน',
     ''
  ),
  (
     'Ketoconazole',
     '',
     'tab',
     'ใช้สำหรับมะเร็งต่อมลูกหมากชนิด castration resistance',
     ''
  ),
  (
     'Leuprorelin acetate',
     '',
     'sterile pwdr (เฉพาะ 11.25 และ 22.5 mg)',
     '1. ใช้เป็น adjuvant therapy ร่วมกับรังสีรักษาในมะเร็งต่อมลูกหมากที่มีความเสี่ยงปานกลาง เป็นระยะเวลาไม่เกิน 6 เดือน (2 cycles)2. ใช้เป็น adjuvant therapy ร่วมกับรังสีรักษาในมะเร็งต่อมลูกหมากที่มีความเสี่ยงสูงหรือสูงมาก เป็นระยะเวลาไม่เกิน 2 ปี (8 cycles)3. ใช้สำหรับผู้ป่วยโรคมะเร็งต่อมลูกหมากระยะลุกลามที่ไม่เคยได้รับการวินิจฉัยหรือรักษามาก่อนที่จำเป็นต้องได้รับการรักษาเร่งด่วนโดยใช้ร่วมกับยาในกลุ่ม antiandrogens (bicalutamide) เช่น มีความเสี่ยงสูงมากต่อ pathological fracture, มี malignant spinal cord compression, หรือมีความผิดปกติทางโลหิตวิทยาที่สงสัยมะเร็งต่อมลูกหมากระยะแพร่กระจาย (DIC) โดยพิจารณาให้ยา GnRH analogue เพียง 1 ครั้ง ในระหว่างการรอตรวจชิ้นเนื้อเพื่อยืนยัน',
     ''
  ),
  (
     'Triptorelin pamoate',
     '',
     'sterile pwdr (เฉพาะ 11.25 mg)',
     '1. ใช้เป็น adjuvant therapy ร่วมกับรังสีรักษาในมะเร็งต่อมลูกหมากที่มีความเสี่ยงปานกลาง เป็นระยะเวลาไม่เกิน 6 เดือน (2 cycles)2. ใช้เป็น adjuvant therapy ร่วมกับรังสีรักษาในมะเร็งต่อมลูกหมากที่มีความเสี่ยงสูงหรือสูงมาก เป็นระยะเวลาไม่เกิน 2 ปี (8 cycles)3. ใช้สำหรับผู้ป่วยโรคมะเร็งต่อมลูกหมากระยะลุกลามที่ไม่เคยได้รับการวินิจฉัยหรือรักษามาก่อนที่จำเป็นต้องได้รับการรักษาเร่งด่วนโดยใช้ร่วมกับยาในกลุ่ม antiandrogens (bicalutamide) เช่น มีความเสี่ยงสูงมากต่อ pathological fracture, มี malignant spinal cord compression, หรือมีความผิดปกติทางโลหิตวิทยาที่สงสัยมะเร็งต่อมลูกหมากระยะแพร่กระจาย (DIC) โดยพิจารณาให้ยา GnRH analogue เพียง 1 ครั้ง ในระหว่างการรอตรวจชิ้นเนื้อเพื่อยืนยัน',
     ''
  ),
  (
     'Fresh dried plasma',
     '',
     '',
     '',
     ''
  ),
  (
     'Fresh frozen plasma',
     '',
     '',
     '',
     ''
  ),
  (
     'Frozen cryoprecipitate',
     '',
     '',
     '',
     ''
  ),
  (
     'Leukocyte depleted platelets concentrate',
     '',
     '',
     '',
     ''
  ),
  (
     'Leukocyte depleted pooled platelets concentrate, random donor',
     '',
     '',
     '',
     ''
  ),
  (
     'Lyophilized cryoprecipitate',
     '',
     '',
     '',
     ''
  ),
  (
     'Packed red cell',
     '',
     '',
     '',
     ''
  ),
  (
     'Packed red cell, leukocyte depleted',
     '',
     '',
     '',
     ''
  ),
  (
     'Packed red cell, leukocyte poor',
     '',
     '',
     '',
     ''
  ),
  (
     'Platelets concentrate, random donor',
     '',
     '',
     '',
     ''
  ),
  (
     'Platelets concentrate, single donor',
     '',
     '',
     '',
     ''
  ),
  (
     'Whole blood',
     '',
     '',
     '',
     ''
  ),
  (
     'Leukocyte depleted platelets concentrate, single donor',
     '',
     '',
     'ใช้เฉพาะผู้ป่วยที่มีกลุ่มเลือดหายาก Rh- หรือมีความจำเป็นต้องใช้เลือดเร่งด่วนแต่ขาดเลือดเท่านั้น',
     ''
  ),
  (
     'Packed red cell, leukocyte depleted single donor 2 units',
     '',
     '',
     'ใช้เฉพาะผู้ป่วยที่มีกลุ่มเลือดหายาก Rh- หรือมีความจำเป็นต้องใช้เลือดเร่งด่วนแต่ขาดเลือดเท่านั้น',
     ''
  ),
  (
     'Packed red cell, irradiated',
     '',
     '',
     'ใช้กับผู้ป่วยปลูกถ่ายเซลล์ต้นกำเนิดเม็ดเลือด',
     ''
  ),
  (
     'Packed red cell, leukocyte poor, irradiated',
     '',
     '',
     'ใช้กับผู้ป่วยปลูกถ่ายเซลล์ต้นกำเนิดเม็ดเลือด',
     ''
  ),
  (
     'Platelets concentrate, irradiated',
     '',
     '',
     'ใช้กับผู้ป่วยปลูกถ่ายเซลล์ต้นกำเนิดเม็ดเลือด',
     ''
  ),
  (
     'Packed red cell, leukocyte depleted irradiated',
     '',
     '',
     'ใช้กับผู้ป่วยปลูกถ่ายเซลล์ต้นกำเนิดเม็ดเลือดที่เคยแพ้ต่อ Packed red cell, leukocyte poor, irradiated',
     ''
  ),
  (
     'Folic acid',
     '',
     'tab (เฉพาะไม่น้อยกว่า 5 mg)',
     '',
     ''
  ),
  (
     'Oxymetholone',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Deferiprone',
     '',
     'tab (เฉพาะ 500 mg)',
     '',
     ''
  ),
  (
     'Deferoxamine mesilate',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Iron sucrose',
     '',
     'sterile sol',
     'ใช้สำหรับรักษา iron deficiency anemia ในผู้ป่วย chronic kidney disease ที่ไม่ตอบสนองต่อ iron supplement ชนิดรับประทาน',
     ''
  ),
  (
     'Antithymocyte immunoglobulin, rabbit',
     '',
     'sterile pwdr, sterile sol',
     'ใช้สำหรับ severe aplastic anemia ',
     ''
  ),
  (
     'Deferasirox',
     '',
     'tab (เฉพาะ 250 mg)',
     '1. Transfusion Dependent Thalassemia ใช้เป็นยารักษาลําดับแรกในผู้ป่วยอายุ 2-6 ปี 2. ใช้เป็นยารักษาลําดับที่ 2 ในผู้ป่วยอายุตั้งแต่ 6 ปี ขึ้นไปที่ไม่ตอบสนองต่อการรักษาหรือมีผลข้างเคียงที่รุนแรงจากการรักษาด้วยยา deferiprone ',
     ''
  ),
  (
     'Epoetin alfa',
     '',
     'sterile pwdr/ sterile sol (เฉพาะ 1000, 2000, 3000, 4000, 5000 IU)',
     'ใช้สำหรับภาวะเลือดจางจากโรคไตเรื้อรังที่ไม่พบสาเหตุอื่นที่รักษาได้ ',
     ''
  ),
  (
     'Epoetin beta',
     '',
     'sterile sol (เฉพาะ 2000, 3000, 5000 IU)',
     'ใช้สำหรับภาวะเลือดจางจากโรคไตเรื้อรังที่ไม่พบสาเหตุอื่นที่รักษาได้ ',
     ''
  ),
  (
     'Filgrastim',
     '',
     'sterile sol',
     '1. ใช้สำหรับปลูกถ่ายไขกระดูกหรือเซลล์ต้นกำเนิดเม็ดเลือด เพื่อเคลื่อนย้าย progenitor cell จากไขกระดูกออกมาในเลือดของผู้ให้หรือผู้ป่วย เพื่อนำไปใช้ทั้งใน allogeneic และ autologous transplantation2. ใช้รักษา febrile neutropenia ที่เกิดจากยาเคมีบำบัด ให้พิจารณาในผู้ป่วยที่ต้องเข้ารับการรักษาในโรงพยาบาลร่วมกับการให้ยาต้านเชื้อจุลชีพในผู้ป่วยความเสี่ยงสูง กล่าวคือมีข้อใดข้อหนึ่งดังต่อไปนี้2.1  Profound neutropenia ซึ่งมี absolute neutrophil count น้อยกว่า 100 /mm32.2  มีปอดอักเสบชนิด bacterial pneumonia หรือ lobar pneumonia หรือ มีภาวะ septicemia 3. ใช้ป้องกัน febrile neutropenia แบบปฐมภูมิ (primary prophylaxis) ในกรณีดังต่อไปนี้3.1 ผู้ป่วยที่จะได้รับยาเคมีบำบัดด้วยสูตรที่มีความเสี่ยงสูงต่อการเกิด febrile neutropenia มากกว่าร้อยละ 203.2 ผู้ป่วยที่มีความเสี่ยงต่อการเกิด febrile neutropenia ร้อยละ 10 - 20 ร่วมกับการประเมินปัจจัยเสี่ยงของผู้ป่วย กล่าวคือ มีข้อใดข้อหนึ่งดังต่อไปนี้ อายุมากกว่า 65 ปี  มี performance status ที่ไม่ดี (Eastern Co-operative Oncology Group (ECOG) performance status  มากกว่าหรือเท่ากับ 2) มีภาวะ neutropenia (absolute neutrophil count < 1,500/mm3) หรือมีโรคแทรกซ้อนในไขกระดูกที่เกิดจากโรคมะเร็งดังกล่าว4. ใช้ป้องกัน febrile neutropenia แบบทุติยภูมิ (Secondary prophylaxis) ในผู้ป่วยที่เคยเกิด febrile neutropenia จากการรับยาเคมีบำบัดในครั้งก่อน และเป็นผู้ป่วยที่มีเป้าหมายการรักษาเพื่อหายขาด (curative aim)',
     ''
  ),
  (
     'Lenograstim',
     '',
     'sterile pwdr',
     'เช่นเดียวกับ filgrastim',
     ''
  ),
  (
     'Calcium chloride + Potassium chloride + Sodium chloride + Sodium acetate (Ringers acetate)',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Glucose with/without sodium chloride',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Intermittent peritoneal dialysis',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Potassium acetate',
     '',
     'sterile sol (hosp)',
     '',
     ''
  ),
  (
     'Potassium chloride',
     '',
     'syr, syr (hosp), elixir, elixir (hosp), compressed tab, EC tab, sterile sol',
     '',
     '1. ควรรับประทานยา potassium chloride หลังอาหารทันที ในกรณียาเม็ดควรดื่มน้ำอย่างน้อย 180 มิลลิลิตรและห้ามเอนตัวนอนลงอย่างน้อย 30 นาทีหลังรับประทานยาเม็ด2. ห้ามใช้ยา potassium chloride ชนิด elixir กับผู้ป่วยเด็กอายุต่ำกว่า 2 ขวบ เนื่องจากมีแอลกอฮอล์เป็นส่วนประกอบ'
  ),
  (
     'Potassium citrate',
     '',
     'oral sol (hosp), dry pwdr for oral sol (hosp)',
     '',
     ''
  ),
  (
     'Sodium acetate',
     '',
     'sterile sol (hosp)',
     '',
     ''
  ),
  (
     'Sodium bicarbonate',
     '',
     'tab, sterile sol',
     '',
     ''
  ),
  (
     'Sodium chloride',
     '',
     'tab (เฉพาะ 300 mg), sterile sol',
     '',
     ''
  ),
  (
     'Water for injection',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Calcium polystyrene sulfonate',
     '',
     'oral pwdr',
     '',
     ''
  ),
  (
     'Continuous ambulatory peritoneal dialysis',
     '',
     'basic bag sol, double bag sol',
     '',
     ''
  ),
  (
     'Human albumin',
     '',
     'sterile sol (เฉพาะ 20% albumin solution) (50 mL)',
     'ใช้กับผู้ป่วยโรคตับแข็งที่ได้รับการวินิจฉัยภาวะ Spontaneous Bacterial Peritonitis (SBP) โดยใช้ในวันที่ 1 และ 3 ของการวินิจฉัยโรค',
     ''
  ),
  (
     'Hydroxyethyl starch (HES) with electrolytes',
     '',
     'balanced salt sterile sol (เฉพาะ Hydroxyethyl starch (HES) 6%)',
     '1. ใช้สำหรับผู้ป่วยที่ขาดสารน้ำหรือมีการสูญเสียเลือดปริมาณมาก โดยที่ไม่มีการติดเชื้อในกระแสเลือดและไม่มีประวัติเป็นโรคไตวายมาก่อน เช่น ผู้ป่วยที่ได้รับอุบัติเหตุหรือการผ่าตัด 2. ขนาดที่ใช้ 30 ml/kg/วัน และทั้งนี้ขนาดสูงสุดไม่เกิน 1,000 ml/วัน',
     '1. ห้ามใช้ในผู้ป่วยกรณีต่าง ๆ ดังนี้1.1. ผู้ป่วยมีภาวะ bleeding disorder1.2. ผู้ป่วยมีการติดเชื้อในกระแสเลือด1.3. ผู้ป่วยมีประวัติเป็นโรคไตวายมาก่อน2. ห้ามใช้รูปแบบที่มีมันฝรั่งเป็นวัตถุดิบ ในผู้ป่วย severe hepatic impairment3. ห้ามใช้รูปแบบ unbalanced salt เนื่องจากอาจทำให้เกิด hyperchloremic acidosis ได้'
  ),
  (
     'Folic acid',
     '',
     'cap/tab (เฉพาะ 400-1,000 mcg และ 5 mg)',
     '',
     ''
  ),
  (
     'Multivitamins',
     '',
     'drop',
     '',
     ''
  ),
  (
     'Multivitamins',
     '',
     'syr',
     '',
     ''
  ),
  (
     'Multivitamins',
     '',
     'dry syr',
     '',
     ''
  ),
  (
     'Multivitamins',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Vitamin A',
     '',
     'cap/tab (เฉพาะ 25,000-50,000 IU ต่อ 1 cap/tab)',
     '',
     ''
  ),
  (
     'Vitamin B1',
     '',
     'tab (เฉพาะ 10-100 mg), sterile sol (เฉพาะ 100 mg/ml)',
     '',
     ''
  ),
  (
     'Vitamin B2',
     '',
     'tab (เฉพาะไม่ต่ำกว่า 10 mg)',
     '',
     ''
  ),
  (
     'Vitamin B6',
     '',
     'tab (เฉพาะ 10-100 mg), sterile sol (เฉพาะ 100 mg/ml)',
     '',
     'การรับประทานวิตามิน B6 ขนาดตั้งแต่ 200 มิลลิกรัมต่อวัน ขึ้นไปเป็นเวลานาน มีความสัมพันธ์กับการเกิด neuropathy ได้'
  ),
  (
     'Vitamin B12',
     '',
     'tab (เฉพาะไม่ต่ำกว่า 100 mcg), sterile sol (เฉพาะ 1000 mcg/ml)',
     '',
     ''
  ),
  (
     'Vitamin C',
     '',
     'tab (เฉพาะ 50 และ 100 mg)',
     '',
     ''
  ),
  (
     'Vitamin D2',
     '',
     'cap',
     'เป็น first -line drug ในผู้ป่วยที่มีภาวะขาดวิตามิน D',
     ''
  ),
  (
     'Vitamin K1',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Vitamin B complex',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Vitamin C',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Vitamin B complex',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Calcitriol (1,25-Dihydroxyvitamin D3)',
     '',
     'cap',
     '1.ใช้กับผู้ป่วยที่มีภาวะขาดฮอร์โมนพาราไทรอยด์ (primary hypoparathyroidism)2.ใช้กับผู้ป่วยที่มีภาวะแคลเซียมในเลือดต่ำ (ชนิดเฉียบพลันรุนแรง)3.ใช้กับผู้ป่วยโรคไตเรื้อรังระยะที่ 5 (chronic kidney disease stage 5 หรือ end-stage renal disease) ที่มีภาวะ secondary hyperparathyroidism',
     'ไม่ควรใช้กับผู้ป่วยโรคไตเรื้อรังระยะที่ 5 ที่มีระดับ serum calcium เกิน 10.5 mg/dL หรือ serum phosphate เกิน 5.5 mg/dL'
  ),
  (
     'Vitamin E',
     '',
     'emulsion (hosp), syr',
     '1. ใช้กับทารกแรกเกิดที่มีน้ำหนักตัวน้อยหรือเกิดก่อนกำหนดเท่านั้น2. ใช้ป้องกันและรักษาภาวะขาดวิตามินอีในทารก และเด็กที่มีปัญหาการย่อยไขมันและ/หรือการดูดซึมไขมันบกพร่อง',
     ''
  ),
  (
     'Calcitriol (1,25-Dihydroxyvitamin D3)',
     '',
     'cap',
     '1. ใช้ในผู้ป่วย hypophosphatemia rickets/osteomalacia2. ใช้ในผู้ป่วย pseudohypoparathyroidism 3. ใช้ในผู้ป่วย vitamin D-dependent rickets (VDDR) type I หรือ type II',
     ''
  ),
  (
     'Vitamin E',
     '',
     'cap',
     '1. ใช้กับทารกและเด็กที่มีโรคตับชนิดน้ำดีคั่ง (chronic cholestasis)2. ใช้ป้องกันและรักษาภาวะขาดวิตามินอีในเด็ก และเด็กที่มีปัญหาการย่อยไขมัน และ/หรือการดูดซึมไขมันบกพร่อง3. สั่งจ่ายยาโดยกุมารแพทย์ผู้เชี่ยวชาญทางโภชนาการ หรือกุมารแพทย์ผู้เชี่ยวชาญทางด้านโรคระบบทางเดินอาหารและตับเท่านั้น',
     ''
  ),
  (
     'Amino acid solution for infants',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Amino acid solution ชนิด high branched chain amino acid',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Amino acid solution ชนิด high essential amino acid',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Amino acids with/without minerals',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Complete water-soluble and fat soluble vitamins preparation',
     '',
     'preparation for intravenous use (sterile pwdr,sterile sol,sterile emulsion)',
     'ใช้กับผู้ป่วยที่ได้รับอาหารทางหลอดเลือดดำ (parenteral nutrition) และต้องการทั้ง water-soluble และ fat-soluble vitamins',
     ''
  ),
  (
     'Complete water-soluble vitamin preparation',
     '',
     'preparation for intravenous use (sterile pwdr)',
     'ใช้กับผู้ป่วยที่ได้รับอาหารทางหลอดเลือดดำ (parenteral nutrition) และต้องการเฉพาะ water soluble vitamins หรือมีข้อห้ามใช้สำหรับ fat-soluble vitamins',
     ''
  ),
  (
     'Complete fat-soluble vitamin preparation',
     '',
     'preparation for intravenous use (sterile pwdr, sterile sol, sterile emulsion)',
     'ใช้กับผู้ป่วยที่ได้รับอาหารทางหลอดเลือดดำ (parenteral nutrition) และต้องการเฉพาะ fat-soluble vitamins หรือมีข้อห้ามใช้สำหรับ water-soluble vitamins',
     ''
  ),
  (
     'Multivitamin injection without vitamin K',
     '',
     'preparation for intravenous use (sterile sol, sterile pwdr)',
     'ใช้กับผู้ป่วยที่ได้รับอาหารทางหลอดเลือดดำ (parenteral nutrition)',
     ''
  ),
  (
     'Dextrose solution with minerals with electrolytes',
     '',
     'sterile sol',
     'ยานี้มีความเข้มข้นของน้ำตาลสูงจึงห้ามให้ทาง peripheral vein ต้องให้ทาง central vein เท่านั้น',
     ''
  ),
  (
     'Fat emulsion',
     '',
     'sterile emulsion (เฉพาะ 20%)',
     '',
     ''
  ),
  (
     'Multiple trace mineral solution',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Two-in-one parenteral nutrition',
     '',
     'sterile sol',
     'ใช้กับผู้ป่วยที่จำเป็นต้องได้รับ parenteral nutrition ที่ไม่เหมาะสมที่จะได้รับ intravenous lipid emulsion',
     '1. ควรระวังในผู้ป่วยโรคไตหรือโรคหัวใจล้มเหลว หรือมีภาวะอื่นซึ่งเสี่ยงต่อภาวะ fluid overload และ/หรือ มีปัญหาความสมดุลของ minerals และ/หรือ electrolytes  และ/หรือผู้ป่วยโรคไต ที่ยังไม่ได้รับการบำบัดทดแทนไต (renal replacement therapy) เนื่องจาก สมดุลของ non protein energy ต่อ gram of nitrogen ไม่เหมาะกับสภาพผู้ป่วย2. ผลิตภัณฑ์ two-in-one parenteral nutrition อาจมี vitamins, trace minerals และ electrolytes บางชนิดไม่ครบถ้วนหรือไม่เพียงพอต่อความต้องการ ดังนั้น ควรเติมสารอาหารเหล่านี้ให้เพียงพอ และเฝ้าระวังติดตามอย่างใกล้ชิด3. กรณีที่ให้เป็น peripheral  parenteral nutrition (PPN) ที่จำเป็นจะต้องให้เกินกว่า 14 วัน ควรพิจารณาให้ทางcentral line 4. การให้อาหารทางหลอดเลือดดำมีความเสี่ยงต่อการติดเชื้อ และการเกิดหลอดเลือดดำอักเสบ (thrombophlebitis)'
  ),
  (
     'Three-in-one parenteral nutrition',
     '',
     'sterile sol',
     'ใช้กับผู้ป่วยอายุตั้งแต่ 11 ปีขึ้นไปที่มีภาวะทุพโภชนาการระดับปานกลางถึงรุนแรง และไม่สามารถรับอาหารทาง enteral ได้เพียงพอ (น้อยกว่า 60% ของพลังงานที่ต้องการต่อวัน)',
     '1. ควรระวังในผู้ป่วยโรคไตหรือโรคหัวใจล้มเหลว หรือมีภาวะอื่นซึ่งเสี่ยงต่อภาวะ fluid overload และ/หรือ มีปัญหาความสมดุลของ minerals และ/หรือ electrolytes 2. ผลิตภัณฑ์ three-in-one parenteral nutrition ไม่มี multivitamins และ trace minerals และอาจมี electrolytes และ minerals เช่น โซเดียม โพแทสเซียม แคลเซียม ไม่เพียงพอ ดังนั้นควรเติมสารอาหารเหล่านี้ให้เพียงพอ ตามคําแนะนําการใช้ของแต่ละผลิตภัณฑ์อย่างเคร่งครัด และเฝ้าระวังติดตามอย่างใกล้ชิด 3. กรณีที่ให้เป็น peripheral parenteral nutrition (PPN) ที่จำเป็นจะต้องให้เกินกว่า 14 วัน ควรพิจารณาให้ทาง central line4. การให้อาหารทางหลอดเลือดดำมีความเสี่ยงต่อการติดเชื้อ และการเกิดหลอดเลือดดำอักเสบ (thrombophlebitis)'
  ),
  (
     'Calcium carbonate',
     '',
     'cap, tab',
     '',
     ''
  ),
  (
     'Calcium gluconate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Ferrous sulfate',
     '',
     'cap, tab, oral sol, drop',
     '',
     ''
  ),
  (
     'Magnesium hydroxide',
     '',
     'tab, susp, susp (hosp)',
     '',
     ''
  ),
  (
     'Magnesium sulfate',
     '',
     'sterile sol, oral sol, oral sol(hosp)',
     '',
     ''
  ),
  (
     'Sodium fluoride',
     '',
     'tab, oral sol, oral sol(hosp)',
     '',
     'ระวังการใช้ในพื้นที่ที่มีฟลูออไรด์สูง เพราะอาจทำให้เกิด fluorosis'
  ),
  (
     'Trace element solution',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Zinc sulfate',
     '',
     'cap, tab, oral sol (hosp), sterile sol (hosp)',
     '',
     ''
  ),
  (
     'Aluminium hydroxide',
     '',
     'tab, susp, susp (hosp)',
     '',
     'กรณีที่ใช้รักษา hyperphosphatemia ในผู้ป่วยที่มีไตบกพร่อง ไม่ควรใช้ติดต่อกันเป็นระยะเวลานาน เนื่องจากอาจเกิดพิษจาก Aluminium'
  ),
  (
     'Ferrous fumarate',
     '',
     'cap, tab, oral sol, susp',
     '',
     ''
  ),
  (
     'Iron (III) hydroxide polymaltose complex',
     '',
     'syr',
     'ใช้ในกรณีที่ใช้ ferrous sulfate oral solution หรือ drop แล้วเกิดอาการไม่พึงประสงค์',
     ''
  ),
  (
     'Copper sulfate solution',
     '',
     'sterile sol (hosp), oral sol (hosp)',
     '',
     ''
  ),
  (
     'Dipotassium hydrogen phosphate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Oral acidic phosphate solution',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Oral neutral phosphate solution',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Sodium glycerophosphate',
     '',
     'sterile sol',
     'ใช้ในกรณีเด็กแรกเกิดที่ต้องการให้สารอาหารทางหลอดเลือดดำ (total parenteral nutrition)',
     ''
  ),
  (
     'Ferrous fumarate',
     '',
     'tab (เฉพาะ 65 mg as iron)',
     '',
     '1. ห้ามใช้ในผู้ป่วยโรคธาลัสซีเมียที่มีภาวะเหล็กเกิน 2. ระมัดระวังการใช้ในผู้ป่วยที่มีอาการแสดงของโรคธาลัสซีเมีย'
  ),
  (
     'Ferrous sulfate',
     '',
     'tab (เฉพาะ 60-65 mg as iron)',
     '',
     '1. ห้ามใช้ในผู้ป่วยโรคธาลัสซีเมียที่มีภาวะเหล็กเกิน 2. ระมัดระวังการใช้ในผู้ป่วยที่มีอาการแสดงของโรคธาลัสซีเมีย'
  ),
  (
     'Folic acid',
     '',
     'cap/tab (เฉพาะ 400-1,000 mcg และ 5 mg)',
     '1. ใช้สำหรับเสริมโฟเลทตลอดการตั้งครรภ์2. ใช้สำหรับเสริมโฟเลทในช่วง 6 เดือนแรกของการให้นมบุตร3. กรณีหญิงตั้งครรภ์ที่เคยมีประวัติตั้งครรภ์หรือคลอดบุตรที่มีภาวะ neural tube defect หรือปากแหว่ง เพดานโหว่ ควรใช้ความแรง 5 mg',
     ''
  ),
  (
     'Ferrous salt +  Folic acid',
     '',
     'tab (เฉพาะ 60-65 mg as iron + 400 mcg)',
     '1. ใช้สำหรับเสริมธาตุเหล็กและโฟเลทตลอดการตั้งครรภ์2. ใช้สำหรับเสริมธาตุเหล็กและโฟเลทในช่วง 6 เดือนแรกของการให้นมบุตร',
     'ระมัดระวังการใช้ในผู้ป่วยโรคธาลัสซีเมีย'
  ),
  (
     'Ferrous salt + Folic acid  + Potassium Iodide',
     '',
     'tab (เฉพาะ 60-65 mg as iron +  400 mcg +  150 mcg as iodine)',
     '1. ใช้เสริมธาตุเหล็ก โฟเลท และไอโอดีนตลอดการตั้งครรภ์2. ใช้สำหรับเสริมธาตุเหล็ก โฟเลท และไอโอดีนในช่วง 6 เดือนแรกของการให้นมบุตร3. ห้ามใช้ในผู้ที่มีภาวะไทรอยด์เป็นพิษ',
     '1. ควรติดตามเฝ้าระวังภาวะไทรอยด์เป็นพิษ2. ระมัดระวังการใช้ในผู้ป่วยโรคธาลัสซีเมีย'
  ),
  (
     'Potassium  Iodide',
     '',
     'tab (เฉพาะ 150 mcg as iodine)',
     '1. ใช้สำหรับเสริมไอโอดีนตลอดการตั้งครรภ์ 2. ใช้เสริมไอโอดีนในช่วง 6 เดือนแรกของการให้นมบุตร 3. ห้ามใช้ในผู้ที่มีภาวะไทรอยด์เป็นพิษ',
     'ควรติดตามเฝ้าระวังภาวะไทรอยด์เป็นพิษ'
  ),
  (
     'Penicillamine',
     'ยากำพร้า',
     'cap , tab',
     'ใช้รักษา Wilsons disease',
     'ระวังการใช้กับหญิงตั้งครรภ์เพราะเป็นสารก่อวิรูป (teratogen)'
  ),
  (
     'Carglumic acid',
     'ยากำพร้า',
     'oral form',
     '1. ใช้สำหรับผู้ป่วย N-acetylglutamate synthase (NAGS) deficiency ที่มีภาวะ hyperammonemia ทั้งใน acute hyperammonemia และ maintenance for chronic hyperammonemia2. ใช้สำหรับผู้ป่วยที่มีภาวะ acute hyperammonemia crisis ที่สงสัยว่าเป็น organic acidemia ชนิด propionic acidemia (PA) และ methylmalonic acidemia (MMA)',
     ''
  ),
  (
     'Imiglucerase',
     '',
     'sterile pwdr',
     'ใช้สำหรับ Gauchers disease type 1 ',
     ''
  ),
  (
     'Mercaptamine',
     'ยากำพร้า',
     'Immediate- release cap',
     'ใช้สำหรับ nephropathic cystinosis ',
     ''
  ),
  (
     'Nitisinone',
     'ยากำพร้า',
     'oral form',
     'ใช้สำหรับรักษาโรคไทโรซีนีเมียชนิดที่ 1 (hereditary tyrosinemia type 1) ',
     ''
  ),
  (
     'Sapropterin (BH4)',
     'ยากำพร้า',
     'oral form',
     '1. ใช้เพื่อทำการทดสอบ BH4 loading test สำหรับวินิจฉัยแยกผู้ป่วยโรค BH4 deficiencies จากโรค Phenylketonuria (PKU) และประเมินการตอบสนองต่อการรักษาด้วยยาsapropterin (BH4)2. ใช้สำหรับโรค tetrahydrobiopterin (BH4) deficiencies3. ใช้สำหรับโรค Phenylketonuria (PKU) ที่ได้รับการรักษาด้วยการควบคุมอาหารแล้วยังมีระดับ phenylalanine ในเลือดเกินกว่า 360 mol/L4. สั่งจ่ายโดยแพทย์อนุสาขาเวชพันธุศาสตร์เท่านั้น',
     ''
  ),
  (
     'Aspirin',
     '',
     'tab, EC tab',
     '',
     ''
  ),
  (
     'Diclofenac sodium',
     '',
     'EC tab, sterile sol',
     '',
     ''
  ),
  (
     'Ibuprofen',
     '',
     'film coated tab, susp',
     '',
     '1. ไม่ควรใช้ ibuprofen ระยะยาวในผู้ป่วยที่ใช้ low dose aspirin เนื่องจากอาจมีผลต่อต้านประสิทธิภาพในการป้องกันโรคหัวใจของยาแอสไพริน2. ใช้ในเด็กที่มีอายุ 3 เดือนขึ้นไปเท่านั้น3. ระมัดระวังการใช้ในผู้ป่วยที่มีเกล็ดเลือดต่ำ เช่น ไข้เลือดออก'
  ),
  (
     'Indomethacin',
     '',
     'cap',
     '',
     ''
  ),
  (
     'Naproxen',
     '',
     'tab (as base เฉพาะ 250 mg, sodium เฉพาะ 275 mg), cap (as base เฉพาะ 250 mg, sodium เฉพาะ 275 mg)',
     '',
     ''
  ),
  (
     'Piroxicam',
     '',
     'cap (as base), compressed  tab (as base), film coated tab (as base)',
     '',
     ''
  ),
  (
     'Chloroquine phosphate',
     '',
     'compressed tab, film coated tab',
     '',
     'การใช้ยาอาจเป็นพิษต่อจอประสาทตา ควรตรวจจอประสาทตาเป็นระยะๆ หลังการให้ยา'
  ),
  (
     'Hydroxychloroquine sulfate',
     '',
     'tab',
     '',
     'การใช้ยาอาจเป็นพิษต่อจอประสาทตา ควรตรวจจอประสาทตาเป็นระยะๆ หลังการให้ยา'
  ),
  (
     'Azathioprine',
     '',
     'tab',
     '',
     'ควรระมัดระวังหากต้องใช้ร่วมกับ allopurinol เนื่องจากเพิ่มความเสี่ยงต่อภาวะเม็ดเลือดขาวต่ำ'
  ),
  (
     'Methotrexate',
     '',
     'tab (as base or sodium), sterile pwdr/sterile sol (as sodium)',
     '',
     'การใช้ยาอาจเกิดการกดไขกระดูกและเป็นพิษต่อตับ ควรตรวจค่า complete blood count(CBC) และ SGPT ทุก 3-6 เดือน ระหว่างการใช้ยา'
  ),
  (
     'Sulfasalazine',
     '',
     'EC tab',
     '',
     ''
  ),
  (
     'Ciclosporin',
     '',
     'cap, oral sol, sterile sol',
     '1. ใช้เป็นยาเสริม (add on) สำหรับรักษาโรคข้ออักเสบรูมาตอยด์ที่มีโรคกำเริบ (Disease activity score 28 เท่ากับหรือมากกว่า 2.6 ขึ้นไป) หลังได้รับการรักษาด้วย methotrexate ร่วมกับ sulfasalazine หรือ ยาต้านมาลาเรีย (chloroquine/hydroxychloroquine) ในขนาดเต็มที่ อย่างน้อย 3 เดือนติดต่อกัน แล้วไม่ตอบสนอง2. ใช้โดยอายุรแพทย์โรคข้อเท่านั้น',
     ''
  ),
  (
     'Leflunomide',
     '',
     'tab (เฉพาะ 20 mg)',
     '1. ใช้เป็นยาเสริม (add on) สำหรับรักษาโรคข้ออักเสบรูมาตอยด์ที่มีโรคกำเริบ (Disease activity score 28 เท่ากับหรือมากกว่า 2.6 ขึ้นไป) หลังได้รับการรักษาด้วย methotrexate ร่วมกับ sulfasalazine หรือ ยาต้านมาเลเรีย (chloroquine/hydroxychloroquine) ในขนาดเต็มที่ อย่างน้อย 3 เดือนติดต่อกัน แล้วไม่ตอบสนอง 2. ใช้โดยอายุรแพทย์โรคข้อเท่านั้น',
     ''
  ),
  (
     'Adalimumab',
     '',
     'sterile sol (เฉพาะ 40 mg/0.8 ml และ20 mg/0.4 ml)',
     '1.ใช้สำหรับรักษาโรคข้ออักเสบสะเก็ดเงิน (psoriatic arthritis)  (เฉพาะ 40 มิลลิกรัมต่อ 0.8 มิลลิลิตร)2.ใช้สำหรับรักษาโรคข้ออักเสบรูมาตอยด์ (rheumatoid arthritis)  (เฉพาะ 40 มิลลิกรัมต่อ 0.8 มิลลิลิตร)3.ใช้สำหรับรักษาโรคข้ออักเสบไม่ทราบสาเหตุในเด็ก ชนิดไม่มีอาการทาง systemic (non-systemic juvenile idiopathic arthritis; non-sJIA) โดยให้ใช้ไม่เกิน 2 คอร์สการรักษาตลอดชีวิต และมีแนวทางกำกับการใช้ยาเป็นไปตามรายละเอียดในภาคผนวก 3 (เฉพาะ 40 มิลลิกรัมต่อ 0.8 มิลลิลิตร และ 20 มิลลิกรัมต่อ 0.4 มิลลิลิตร)',
     ''
  ),
  (
     'Infliximab',
     '',
     'sterile pwdr (เฉพาะ 100 mg)',
     'ใช้สำหรับรักษาโรคข้อกระดูกสันหลังอักเสบชนิดยึดติด (ankylosing spondylitis) ',
     ''
  ),
  (
     'Tocilizumab',
     '',
     'sterile sol (เฉพาะ 80 mg/4ml)',
     'สำหรับผู้ป่วยโรคข้ออักเสบไม่ทราบสาเหตุในเด็กอายุตั้งแต่ 2 ปีขึ้นไป ชนิดที่มีอาการชนิดซิสเต็มมิก (Systemic Juvenile Idiopathic Arthritis : SJIA) ',
     ''
  ),
  (
     'Colchicine',
     '',
     'tab',
     '',
     'ยานี้มีผลข้างเคียงทำให้อุจจาระร่วงและอาจทำให้กล้ามเนื้อลายสลาย (rhabdomyolysis) จึงควรระมัดระวังการใช้ร่วมกับยาที่ทำให้กล้ามเนื้อลายสลายเช่น ยาในกลุ่ม statins เป็นต้น'
  ),
  (
     'Allopurinol',
     '',
     'tab',
     '',
     'การลดความเสี่ยงหรือความรุนแรงต่อการเกิด severe cutaneous adverse reactions (SCAR) จากการใช้ allopurinol ทำได้โดย 1. เฝ้าระวังอาการอย่างใกล้ชิดในผู้ป่วยทุกรายในช่วง 2-4 สัปดาห์แรกของการให้ยา 2. ควรเริ่มใช้ยาในขนาดต่ำและค่อยๆ ปรับขนาดยาเพิ่มขึ้นช้าๆ ในผู้สูงอายุและผู้ป่วยที่มีการทำงานของไตบกพร่อง'
  ),
  (
     'Probenecid',
     '',
     'film coated tab',
     '',
     'ควรหลีกเลี่ยงการใช้ยาในผู้ป่วยที่มีประวัตินิ่วในไต หรือภาวะไตเสื่อม'
  ),
  (
     'Benzbromarone',
     '',
     'tab',
     '',
     'ใช้ด้วยความระมัดระวัง เนื่องจากมีรายงานการเกิด cytolytic liver damage  ทำให้ผู้ป่วยถึงแก่ชีวิต หรือต้องเปลี่ยนตับ'
  ),
  (
     'Febuxostat',
     '',
     'tab (เฉพาะ 80 mg)',
     'ใช้สำหรับภาวะกรดยูริกในเลือดสูงที่มีเงื่อนไขข้อใดข้อหนึ่งดังนี้1. ผู้ป่วยโรคเกาต์ที่แพ้ยา allopurinol ชนิดรุนแรง และมีข้อห้ามในการใช้ยากลุ่ม uricosuric 2. ผู้ป่วยโรคเกาต์ที่มียีน HLA-B*58:01 และมีข้อห้ามในการใช้ยากลุ่ม uricosuric3. ผู้ป่วยโรคเกาต์ที่มีระดับกรดยูริกมากกว่า 6 mg/dL ภายหลังจากการใช้ยากลุ่ม uricosuric ร่วมกับ allopurinol ในขนาดที่เหมาะสม4. ผู้ป่วยโรคเกาต์ที่มีระดับกรดยูริกมากกว่า 6 mg/dL ภายหลังจากการใช้ยากลุ่ม uricosuric ในกรณีผู้ป่วยที่แพ้ยา allopurinol ชนิดรุนแรง หรือมียีน HLA-B*58:015. เป็นยาทางเลือกในกรณีที่ใช้ allopurinol แล้วมีเอนไซม์ตับสูงเกิน 3 เท่าของค่าปกติ หรือ เพิ่มขึ้นเกิน 2 เท่าของระดับก่อนให้ยา และมีข้อห้ามใช้ยากลุ่ม uricosuric',
     'ควรระมัดระวังการใช้ febuxostat ในผู้ป่วยที่มีโรคหัวใจและหลอดเลือด หรือความเสี่ยงต่อโรคหัวใจและหลอดเลือดสูง'
  ),
  (
     'Pyridostigmine bromide',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Neostigmine methylsulfate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Diazepam',
     '',
     'cap, tab, sterile sol',
     '',
     ''
  ),
  (
     'Baclofen',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Tizanidine hydrochloride',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Methyl salicylate cream compound',
     '',
     'cream, cream (hosp)',
     '',
     ''
  ),
  (
     'Methyl salicylate ointment compound',
     '',
     'oint, oint (hosp)',
     '',
     ''
  ),
  (
     'Boric acid',
     '',
     'eye wash sol',
     '',
     ''
  ),
  (
     'Chloramphenicol',
     '',
     'eye drop, eye oint',
     '',
     ''
  ),
  (
     'Tetracycline hydrochloride',
     'ยากำพร้า',
     'eye oint',
     '',
     ''
  ),
  (
     'Gentamicin sulfate',
     '',
     'eye drop, eye oint',
     '',
     ''
  ),
  (
     'Polymyxin B sulfate + Neomycin sulfate + Gramicidin',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Cyclosporine',
     '',
     'eye drop (hosp)',
     'ใช้กับผู้ป่วย Keratoconjuctivitis sicca ที่มีอาการตาแห้งร่วมกับการอักเสบของพื้นผิวกระจกตา',
     ''
  ),
  (
     'Fusidic acid',
     '',
     'eye drop (in gel base)',
     'ใช้สำหรับหนังตาอักเสบ (blepharitis) ที่ใช้ chloramphenicol หรือ gentamicin แล้วแพ้หรือไม่ได้ผล',
     ''
  ),
  (
     'Levofloxacin',
     '',
     'eye drop (เฉพาะ 0.5%) (5 ml)',
     '1. ใช้สำหรับรักษาเยื่อบุตาอักเสบ (Bacterial conjunctivitis) 2. ใช้สำหรับการติดเชื้อแบคทีเรียบริเวณลูกตาส่วนนอกอื่น ๆ (other external ocular bacterial infections)',
     ''
  ),
  (
     'Levofloxacin',
     '',
     'eye drop (เฉพาะ 1.5%) (5 ml)',
     '1. ใช้สำหรับรักษากระจกตาอักเสบ (Bacterial Keratitis)2. ใช้สำหรับรักษาแผลที่กระจกตา (Corneal ulcer)',
     ''
  ),
  (
     'Dexamethasone sodium phosphate +  Neomycin sulfate',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Dexamethasone sodium phosphate + Chloramphenicol + Tetrahydrozoline hydrochloride',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Dexamethasone + Neomycin sulfate + Polymyxin B sulfate',
     '',
     'eye oint',
     '',
     ''
  ),
  (
     'Natamycin',
     '',
     'eye susp',
     'ใช้สำหรับการติดเชื้อราที่แผลกระจกตา',
     ''
  ),
  (
     'Aciclovir',
     '',
     'eye oint',
     '',
     ''
  ),
  (
     'Antazoline hydrochloride + Tetrahydrozoline hydrochloride',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Fluorometholone',
     '',
     'eye susp (as base)',
     'ใช้รักษาเยื่อบุตาอักเสบที่ไม่ได้เกิดจากการติดเชื้อ เช่น ภูมิแพ้ การระคายเคือง เป็นต้น',
     ''
  ),
  (
     'Prednisolone acetate',
     '',
     'eye susp',
     '1. ใช้รักษาม่านตาอักเสบและ/หรือหลังผ่าตัดตา2. ใช้รักษากระจกตาอักเสบหลังจากการติดเชื้อไวรัสที่ชั้น stroma หรือชั้นเยื่อบุโพรงตา (endothelium)',
     ''
  ),
  (
     'Sodium cromoglicate',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Olopatadine hydrochloride',
     '',
     'eye drop (เฉพาะ 0.1%)',
     'ใช้สำหรับผู้ป่วยเยื่อบุตาอักเสบเรื้อรังที่มีอาการอักเสบเฉียบพลัน ได้แก่ Vernal Keratoconjunctivitis, Atopic Keratoconjunctivitis, Giant Papillary Conjunctivitis โดยหลังจากโรคสงบแล้ว ให้พิจารณาใช้ Sodium cromoglicate เพื่อป้องกันการกลับเป็นซ้ำ',
     ''
  ),
  (
     'Atropine sulfate',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Cyclopentolate hydrochloride',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Phenylephrine hydrochloride',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Tropicamide',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Phenylephrine hydrochloride + Tropicamide',
     '',
     'eye drop (เฉพาะ 5% + 0.8%) (5 ml)',
     '',
     ''
  ),
  (
     'Glycerol',
     '',
     'oral sol (hosp)',
     '',
     ''
  ),
  (
     'Acetazolamide',
     '',
     'tab',
     '',
     ''
  ),
  (
     'Pilocarpine',
     '',
     'eye drop (as hydrochloride or nitrate)',
     '',
     ''
  ),
  (
     'Timolol maleate',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Brimonidine tartrate',
     '',
     'eye drop (เฉพาะ 0.2% w/v)',
     '1. ใช้รักษาต้อหินในกรณีที่มีข้อห้ามใช้ topical beta-blockers หรือ2. ใช้เฉพาะกรณีที่ใช้ยาชนิดอื่นรักษาต้อหินแล้วความดันในลูกตายังไม่ลดลงอยู่ในขั้นที่ปลอดภัย',
     ''
  ),
  (
     'Latanoprost',
     '',
     'eye drop (เฉพาะ 0.005% w/v)',
     '1. ใช้รักษาต้อหินในกรณีที่มีข้อห้ามใช้ topical beta-blockers หรือ2. ใช้เฉพาะกรณีที่ใช้ยารักษาต้อหินชนิดอื่นแล้วความดันในลูกตายังไม่ลดลงอยู่ในขั้นที่ปลอดภัย',
     ''
  ),
  (
     'Brinzolamide',
     '',
     'eye susp (เฉพาะ 1%) (5 ml)',
     '1. ใช้รักษาต้อหินในกรณีที่มีข้อห้ามใช้ topical beta-blockers หรือ2. ใช้เฉพาะกรณีที่ใช้ยาชนิดอื่นรักษาต้อหินแล้วความดันในลูกตายังไม่ลดลงอยู่ในขั้นที่ปลอดภัย',
     ''
  ),
  (
     'Brinzolamide + Timolol maleate',
     '',
     'eye susp (เฉพาะ 1%  + 0.5% ) (5 ml)',
     'ใช้เฉพาะกรณีที่ใช้ยารักษาต้อหินชนิดอื่นแล้วความดันในลูกตายังไม่ลดลงอยู่ในขั้นที่ปลอดภัย',
     ''
  ),
  (
     'Tetracaine hydrochloride',
     '',
     'eye drop',
     'ห้ามให้ผู้ป่วยนำกลับบ้าน',
     ''
  ),
  (
     'Hypromellose  (with preservative)',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Carbomer  (with preservative, with/without sorbitol)',
     '',
     'eye gel',
     '',
     ''
  ),
  (
     'White petrolatum + Mineral oil + Liquid lanolin anhydrous (preservative free)',
     '',
     'eye oint',
     'ใช้กับผู้ป่วยตาแห้งปานกลางถึงตาแห้งมาก ที่ใช้น้ำตาเทียมที่มี preservative ไม่ได้',
     ''
  ),
  (
     'Hypromellose + Dextran 70 (preservative free)',
     '',
     'eye drop (เฉพาะ 0.3% + 0.1%) (0.8 ml)',
     'ใช้เฉพาะกับผู้ป่วยตาแห้งมาก ที่ใช้น้ำตาเทียมที่มี preservative ไม่ได้',
     ''
  ),
  (
     'Dried protein-free dialysate of calf blood',
     '',
     'eye gel',
     'ใช้เพิ่มการสมานของแผลที่กระจกตา',
     ''
  ),
  (
     'Balance salt',
     '',
     'sol for ocular irrigation , sol for intraocular irrigation',
     '',
     ''
  ),
  (
     'Carbachol',
     '',
     'sterile sol for intraocular  use',
     'ใช้หดม่านตาระหว่างการผ่าตัด',
     ''
  ),
  (
     'Diclofenac sodium with preservative',
     '',
     'eye drop',
     '',
     ''
  ),
  (
     'Fluorescein sodium',
     '',
     'sterile sol for inj',
     '',
     ''
  ),
  (
     'Indocyanine green',
     'ยากำพร้า',
     'sterile pwdr for inj',
     '',
     ''
  ),
  (
     'Trypan blue',
     'ยากำพร้า',
     'sterile sol for intraocular use',
     'ใช้สำหรับย้อมสีถุงหุ้มเลนส์ระหว่างผ่าตัดต้อกระจกชนิดสุก',
     ''
  ),
  (
     'Bevacizumab',
     '',
     'sterile sol',
     '1. ใช้สำหรับ age-related macular degeneration (AMD)  2. ใช้สำหรับ diabetic macular edema (DME) 3. ใช้สำหรับ Retinal Vein Occlusion (RVO)   4. ใช้สำหรับการรักษาโรคจอตาผิดปกติในเด็กเกิดก่อนกำหนด (Retinopathy of Prematurity; ROP) ',
     ''
  ),
  (
     'Chloramphenicol',
     '',
     'ear drop',
     '',
     ''
  ),
  (
     'Dexamethasone + Framycetin sulfate + Gramicidin',
     '',
     'ear drop/ear oint (เฉพาะ 0.5 mg+5 mg+0.05 mg in 1 ml or 1 g)',
     '',
     ''
  ),
  (
     'Hydrocortisone + Neomycin sulfate + Polymyxin B sulfate',
     '',
     'ear drop (เฉพาะ 10 mg + 3400 U + 10000 U in 1 ml)',
     '',
     ''
  ),
  (
     'Acetic acid',
     '',
     'ear drop (hosp) (เฉพาะ 2% in aqueous และ 2% in 70% isopropyl alcohol)',
     '',
     'ห้ามใช้ในผู้ป่วยที่แก้วหูทะลุ'
  ),
  (
     'Boric acid',
     '',
     'ear drop (hosp) (เฉพาะ 3% in isopropyl alcohol)',
     '',
     'ห้ามใช้ในผู้ป่วยที่แก้วหูทะลุ'
  ),
  (
     'Gentian violet',
     '',
     'sol (hosp)',
     '',
     'ห้ามใช้ในผู้ป่วยที่แก้วหูทะลุ'
  ),
  (
     'Clotrimazole',
     '',
     'ear drop',
     '',
     ''
  ),
  (
     'Sodium bicarbonate',
     '',
     'ear drop (hosp)',
     '',
     ''
  ),
  (
     'Ofloxacin',
     '',
     'ear drop',
     'ใช้สำหรับหูน้ำหนวกเรื้อรังที่แก้วหูทะลุ ที่ใช้ Chloramphenicol ไม่ได้ผล',
     ''
  ),
  (
     'Budesonide',
     '',
     'nasal spray',
     'ใช้กับผู้ป่วยอายุ 6 ปีขึ้นไป',
     ''
  ),
  (
     'Fluticasone furoate',
     '',
     'nasal spray',
     'ใช้กับผู้ป่วยอายุ 2 ปีขึ้นไปในข้อบ่งใช้ 1.  โพรงจมูกอักเสบจากภูมิแพ้ที่เกิดตามฤดูกาลและตลอดปี 2.  เยื่อบุตาอักเสบจากภูมิแพ้',
     ''
  ),
  (
     'Ephedrine hydrochloride',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'nasal drop (hosp) (เฉพาะ 0.5-3%)',
     '',
     ''
  ),
  (
     'Sodium chloride',
     '',
     'sterile sol (for irrigation) (เฉพาะ 0.9%)',
     '',
     ''
  ),
  (
     'Oxymetazoline hydrochloride',
     '',
     'nasal drop, nasal spray',
     '',
     ''
  ),
  (
     'Borax (in glycerin)',
     '',
     'sol, sol (hosp)',
     '',
     ''
  ),
  (
     'Chlorhexidine gluconate',
     '',
     'mouthwash sol (เฉพาะ 0.12-0.2% w/v)',
     '',
     ''
  ),
  (
     'Iodine Paint, compound',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Talbot''s solution',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Triamcinolone acetonide',
     '',
     'oral paste',
     '',
     ''
  ),
  (
     'Fluocinolone acetonide',
     '',
     'oral paste, oral gel , sol',
     'ใช้ในกรณีที่ใช้ยา triamcinolone acetonide ไม่ได้ผลหรือรอยโรคมีความรุนแรง',
     ''
  ),
  (
     'Iodoform (in ether)',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Clotrimazole',
     '',
     'lozenge',
     '',
     ''
  ),
  (
     'Miconazole nitrate',
     '',
     'oral gel',
     '',
     ''
  ),
  (
     'Nystatin',
     '',
     'oral susp',
     '',
     ''
  ),
  (
     'Camphorated parachlorophenol',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Camphorated phenol',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Chlorhexidine gluconate',
     '',
     'sol (hosp) (เฉพาะ 2% )',
     '',
     ''
  ),
  (
     'Clove oil',
     '',
     'oil',
     '',
     ''
  ),
  (
     'EDTA',
     '',
     'sol (hosp) (เฉพาะ 14% หรือ 17% )',
     '',
     ''
  ),
  (
     'Formocresol',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Sodium hypochlorite',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Chlorhexidine  gluconate',
     '',
     'mouthwash sol / mouthwash sol (hosp) (เฉพาะ 0.1-0.2%w/v)',
     '',
     ''
  ),
  (
     'Sodium fluoride',
     '',
     'tab, oral sol',
     '',
     ''
  ),
  (
     'Epinephrine',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Artificial saliva',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Hydrogen peroxide',
     '',
     'mouthwash sol (1.5% w/v )',
     '',
     ''
  ),
  (
     'Sodium chloride',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Special mouthwash',
     '',
     'mouthwash sol (hosp)',
     '',
     ''
  ),
  (
     'Zinc oxide',
     '',
     'pwdr (hosp)',
     '',
     ''
  ),
  (
     'Zinc oxide with zinc acetate',
     '',
     'pwdr (hosp)',
     '',
     ''
  ),
  (
     'Carnoy''s solution',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'White head varnish',
     '',
     'varnish (hosp)',
     '',
     ''
  ),
  (
     'Sulfadiazine silver',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Fusidic acid',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Sodium fusidate',
     '',
     'oint',
     '',
     ''
  ),
  (
     'Mupirocin',
     '',
     'oint',
     'จำกัดการใช้เฉพาะ Methicillin-resistant S.aureus (MRSA)',
     ''
  ),
  (
     'Benzoic acid + Salicylic acid',
     '',
     'oint, oint (hosp)',
     '',
     ''
  ),
  (
     'Sodium thiosulfate',
     '',
     'sol, sol (hosp)',
     '',
     ''
  ),
  (
     'Clotrimazole',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Ketoconazole',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Benzyl benzoate',
     '',
     'emulsion/lotion (เฉพาะ 25%)',
     '',
     ''
  ),
  (
     'Permethrin',
     'ยากำพร้า',
     'cream/lotion (เฉพาะ1%)',
     'ใช้สำหรับรักษาเหา',
     ''
  ),
  (
     'Permethrin',
     'ยากำพร้า',
     'cream/lotion (เฉพาะ 5%)',
     'ใช้สำหรับรักษาหิด และโลน',
     ''
  ),
  (
     'Sulfur',
     '',
     'oint, oint (hosp) (เฉพาะ 5-10%)',
     '',
     ''
  ),
  (
     'Ivermectin',
     'ยากำพร้า',
     'tab',
     'ใช้สำหรับรักษาหิด ที่ใช้ยาทาไม่ได้หรือไม่ได้ผล',
     ''
  ),
  (
     'Aluminium acetate',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Mineral oil',
     '',
     'oil (hosp)',
     '',
     ''
  ),
  (
     'Olive oil',
     '',
     'oil (hosp)',
     '',
     ''
  ),
  (
     'Urea',
     '',
     'cream ,cream (hosp), oint (hosp)',
     '',
     ''
  ),
  (
     'White petrolatum',
     '',
     'oint (hosp)',
     '',
     ''
  ),
  (
     'Zinc oxide',
     '',
     'cream, cream (hosp), oint (hosp), paste (hosp)',
     '',
     ''
  ),
  (
     'Zinc sulfate',
     '',
     'lotion (hosp)',
     '',
     ''
  ),
  (
     'Calamine',
     '',
     'lotion, lotion (hosp)',
     '',
     ''
  ),
  (
     'Menthol + Phenol + Camphor',
     '',
     'ทุก topical dosage form (hosp)',
     '',
     ''
  ),
  (
     'Hydrocortisone acetate',
     '',
     'cream, cream (hosp)',
     '',
     ''
  ),
  (
     'Prednisolone',
     '',
     'cream, cream (hosp)',
     '',
     ''
  ),
  (
     'Betamethasone dipropionate',
     '',
     'cream, cream (hosp), oint',
     '',
     ''
  ),
  (
     'Betamethasone valerate',
     '',
     'cream, cream (hosp)',
     '',
     ''
  ),
  (
     'Triamcinolone acetonide',
     '',
     'cream, cream (hosp), lotion, lotion (hosp)',
     '',
     ''
  ),
  (
     'Clobetasol propionate',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Betamethasone valerate',
     '',
     'lotion, sol',
     '',
     ''
  ),
  (
     'Desoximetasone',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Betamethasone dipropionate + Salicylic acid',
     '',
     'oint (เฉพาะ 0.05% + 3%)',
     '1. ใช้สำหรับ chronic eczema 2. ใช้สำหรับโรคสะเก็ดเงิน (psoriasis)',
     ''
  ),
  (
     'Clobetasol propionate',
     '',
     'oint',
     'ใช้สำหรับโรคผิวหนังเรื้อรังที่ไม่ตอบสนองต่อยาอื่น เช่น โรคสะเก็ดเงินที่เล็บซึ่งเป็นบริเวณที่หนาและต้องใช้ยาที่เพิ่มการดูดซึมเพื่อให้เกิดประสิทธิผลในการรักษา',
     ''
  ),
  (
     'Clobetasol propionate',
     '',
     'lotion',
     'ใช้สำหรับโรคผิวหนังเรื้อรังที่ไม่ตอบสนองต่อยาอื่น',
     ''
  ),
  (
     'Mometasone furoate',
     '',
     'cream',
     'ใช้กรณีต้องใช้ยาเป็นเวลานาน',
     ''
  ),
  (
     'Betamethasone dipropionate + Calcipotriol',
     '',
     'gel, oint',
     '1. ใช้รักษา chronic plaque psoriasis ในผู้ใหญ่ที่ใช้ topical steroid รักษาแล้วไม่ได้ผล 2. ใช้ gel กับรอยโรคที่หนังศีรษะไม่เกิน 4 สัปดาห์ และ ointment กับรอยโรคที่ลำตัวไม่เกิน 8 สัปดาห์3. ใช้โดยแพทย์ผู้เชี่ยวชาญด้านตจวิทยา',
     ''
  ),
  (
     'Coal tar',
     '',
     'ทุก topical dosage form (hosp)',
     '',
     ''
  ),
  (
     'Coal tar + Triamcinolone acetonide',
     '',
     'cream (hosp) (เฉพาะ 3% + 0.02% หรือ 5% + 0.02%)',
     '',
     ''
  ),
  (
     'Salicylic acid',
     '',
     'lotion (hosp) , oint (hosp) , paste (hosp)',
     '',
     ''
  ),
  (
     'Dithranol',
     '',
     'paste (hosp)',
     '',
     ''
  ),
  (
     'Methotrexate',
     '',
     'tab (as base or sodium)',
     'ใช้สำหรับสะเก็ดเงินชนิดปานกลางถึงรุนแรงที่ดื้อต่อยาอื่น',
     ''
  ),
  (
     'Methoxsalen',
     'ยากำพร้า',
     'tab, cream (hosp) (เฉพาะไม่เกิน 0.1% w/w), topical sol (paint), topical sol (paint) (hosp) (เฉพาะไม่เกิน 0.1% w/w)',
     '',
     ''
  ),
  (
     'Calcipotriol',
     '',
     'oint',
     'ใช้ในกรณีที่ไม่ตอบสนองหรือเกิดผลข้างเคียงต่อ coal tar หรือ topical steroid',
     ''
  ),
  (
     'Acitretin',
     '',
     'cap',
     '1. ใช้สำหรับสะเก็ดเงินชนิดปานกลางถึงรุนแรง ที่ไม่ตอบสนองต่อยาอื่นหรือมีข้อห้ามในการใช้ methotrexate2. ใช้โดยแพทย์ผู้เชี่ยวชาญด้านตจวิทยา สำหรับรักษาโรคผิวหนังเรื้อรังอื่นๆ ที่ไม่ตอบสนองต่อการรักษาทั่วไป',
     'ห้ามใช้ในหญิงตั้งครรภ์ และหลังจากหยุดยานี้แล้วให้คุมกำเนิดเป็นระยะเวลาอย่างน้อย 3 ปี'
  ),
  (
     'Ciclosporin',
     '',
     'cap, oral sol',
     '1. ใช้สำหรับสะเก็ดเงินชนิดปานกลางถึงรุนแรง ที่ไม่ตอบสนองต่อยาอื่นหรือมีข้อห้ามในการใช้ methotrexate2. ใช้สำหรับ atopic dermatitis ชนิดรุนแรง3. ใช้โดยแพทย์ผู้เชี่ยวชาญด้านตจวิทยา สำหรับรักษาโรคผิวหนังเรื้อรังอื่นๆ ที่ไม่ตอบสนองต่อการรักษาทั่วไป',
     ''
  ),
  (
     'Lactic acid',
     '',
     'cream (hosp) (เฉพาะไม่เกิน 10% w/w)',
     '',
     ''
  ),
  (
     'Podophyllin',
     '',
     'paint, paint (hosp)',
     '',
     ''
  ),
  (
     'Salicylic acid',
     '',
     'oint (hosp), paste (hosp)',
     '',
     ''
  ),
  (
     'Silver nitrate',
     '',
     'sol (hosp),crystal (hosp),stick (hosp)',
     '',
     ''
  ),
  (
     'Trichloroacetic acid',
     '',
     'sol (hosp)',
     '',
     ''
  ),
  (
     'Salicylic acid + Lactic acid',
     '',
     'colloidal sol',
     '',
     ''
  ),
  (
     'Aluminium Chloride',
     '',
     'sol (hosp) (เฉพาะ 10-30%)',
     '',
     ''
  ),
  (
     'Anti-D immunoglobulin, human',
     'ยากำพร้า',
     'inj',
     '',
     ''
  ),
  (
     'BCG vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Diphtheria antitoxin',
     'ยากำพร้า',
     'inj',
     '',
     ''
  ),
  (
     'Diphtheria-Tetanus vaccine ทั้งชนิด DT(children type)และ dT (adult type)',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Diphtheria-Tetanus-Pertussis vaccine (whole cell)',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Diphtheria-Tetanus-Pertussis-Hepatitis B vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Diphtheria-Tetanus-Pertussis-Hepatitis B-Haemophilus influenzae type b vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Recombinant acellular Pertussis vaccine',
     '',
     'inj (เฉพาะ 0.5 ml)',
     'ใช้สำหรับการให้บริการแก่หญิงตั้งครรภ์ 1 ครั้ง ทุกการตั้งครรภ์ โดยอายุครรภ์ที่ควรได้รับวัคซีน aP ให้เป็นไปตามคำแนะนำของคณะอนุกรรมการสร้างเสริมภูมิคุ้มกันโรค ภายใต้คณะกรรมการวัคซีนแห่งชาติ และกำหนดการให้วัคซีนให้เป็นไปตามแผนงานสร้างเสริมภูมิคุ้มกันโรค ของกระทรวงสาธารณสุข',
     ''
  ),
  (
     'Hepatitis B vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Influenza vaccine ชนิดวัคซีนรวม 3 สายพันธุ์ (trivalent) ตามที่องค์การอนามัยโลกกำหนดในแต่ละปี',
     '',
     '',
     '1. บุคลากรทางการแพทย์ และเจ้าหน้าที่ที่เกี่ยวข้องกับผู้ป่วย2. ผู้ที่มีโรคเรื้อรัง คือ ปอดอุดกั้นเรื้อรัง หอบหืด หัวใจ หลอดเลือดสมอง ไตวาย ผู้ป่วยมะเร็งที่ได้รับยาเคมีบาบัดและเบาหวาน3. บุคคลที่มีอายุ 65 ปีขึ้นไป4. หญิงมีครรภ์ อายุครรภ์ 4 เดือนขึ้นไป5. เด็กอายุ 6 เดือนถึง 2 ปี6. ผู้พิการทางสมองช่วยเหลือตัวเองไม่ได้7. โรคธาลัสซีเมีย ภูมิคุ้มกันบกพร่อง (รวมถึงผู้ติดเชื้อเอชไอวีที่มีอาการ)8. ผู้ที่มีน้าหนักตั้งแต่ 100 กิโลกรัม หรือ ดัชนีมวลกาย ตั้งแต่ 35 กิโลกรัมต่อตารางเมตร',
     ''
  ),
  (
     'Influenza vaccine ชนิด pandemic Influenza สายพันธุ์ตามที่องค์การอนามัยโลกกำหนดในแต่ละปี',
     '',
     '',
     '',
     ''
  ),
  (
     'Measles-Mumps-Rubella vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Poliomyelitis vaccine, live attenuated (OPV)ชนิด bivalent และ trivalent',
     '',
     'oral sol, oral susp',
     '',
     ''
  ),
  (
     'Inactivated polio vaccine (IPV)(เฉพาะชนิดที่เป็นวัคซีนเดี่ยว)',
     '',
     'inj',
     'ใช้ตามโครงการกวาดล้างโปลิโอของประเทศไทย ตามนโยบายฉากสุดท้ายของการกวาดล้างโปลิโอในระดับโลก',
     ''
  ),
  (
     'Rabies immunoglobulin, horse',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Rabies vaccines ยกเว้นชนิด human diploid cell vaccine',
     '',
     'inj',
     '1. ใช้สำหรับ post-exposure protection2. ใช้สำหรับ pre-exposure protection ในประชากรกลุ่มที่มีความเสี่ยงสูง',
     ''
  ),
  (
     'Rubella vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Tetanus antitoxin, horse',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Tetanus vaccine',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Japanese encephalitis vaccine, inactivated',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Japanese encephalitis vaccine, live attenuated',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Rabies immunoglobulin, human',
     '',
     'inj',
     'ใช้สำหรับผู้ที่แพ้ rabies immunoglobulin, horse (ERIG)',
     ''
  ),
  (
     'Tetanus antitoxin, human',
     '',
     'inj',
     'ใช้สำหรับผู้ที่แพ้ tetanus antitoxin, horse',
     ''
  ),
  (
     'Hepatitis B immunoglobulin, human',
     '',
     'inj',
     'ใช้ร่วมกับการฉีด hepatitis B vaccine เฉพาะในกรณีดังต่อไปนี้1. ทารกแรกเกิดที่มารดามี HBsAg เป็นบวก2. เมื่อผิวหนังหรือเยื่อเมือกสัมผัสกับเลือดหรือสารคัดหลั่งที่มี HBsAg เป็นบวก เช่น บุคลากรทางการแพทย์ที่เกิดอุบัติเหตุสัมผัสโรคจากการทำงานตามแนวปฏิบัติของสถานพยาบาลนั้นๆ หรือผู้ที่ถูกข่มขืน3. ป้องกันผู้ป่วยจากการกลับเป็นโรคตับอักเสบบีซ้ำหลังจากได้รับการเปลี่ยนตับแล้ว',
     ''
  ),
  (
     'Human papillomavirus vaccine ชนิด 4 สายพันธุ์',
     '',
     'inj',
     '1. ใช้สำหรับการให้บริการวัคซีนเอชพีวีในแผนงานสร้างเสริมภูมิคุ้มกันโรคของกรมควบคุมโรคและสำนักงานหลักประกันสุขภาพแห่งชาติ2. เลือก 1 รายการ ระหว่างรายการที่ 24 หรือ 25 ที่จัดซื้อได้ถูกกว่า',
     ''
  ),
  (
     'Human papillomavirus vaccine ชนิดที่มีสายพันธุ์ก่อโรคอย่างน้อยสายพันธุ์ที่ 16 และ 18',
     '',
     'inj',
     '1. ใช้สำหรับการให้บริการวัคซีนเอชพีวีในแผนงานสร้างเสริมภูมิคุ้มกันโรคของกรมควบคุมโรคและสำนักงานหลักประกันสุขภาพแห่งชาติ2. เลือก 1 รายการ ระหว่างรายการที่ 24 หรือ 25 ที่จัดซื้อได้ถูกกว่า',
     ''
  ),
  (
     'Rotavirus vaccine',
     '',
     'oral form (for pediatric use)',
     '',
     ''
  ),
  (
     'Etomidate',
     '',
     'sterile emulsion',
     'ใช้สำหรับนำสลบ (Induction of general anesthesia) ในผู้สูงอายุหรือผู้ป่วยที่มีปัญหาด้านหัวใจและหลอดเลือด',
     ''
  ),
  (
     'Propofol',
     '',
     'sterile emulsion',
     '',
     ''
  ),
  (
     'Thiopental sodium',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Ketamine hydrochloride',
     'วัตถุออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'sterile sol',
     '1. ใช้ฉีดเข้ากล้ามเนื้อกับผู้ป่วยที่หาเส้นเลือดสำหรับให้น้ำเกลือไม่ได้2. ใช้ในกรณีที่ผู้ป่วยมีความดันเลือดต่ำ3. ใช้ในการระงับความรู้สึกสำหรับการทำหัตถการที่ใช้ระยะเวลาสั้นๆ4. ใช้เป็นยาเสริม (adjunct therapy) เพื่อระงับอาการปวดรุนแรง (intractable pain)',
     ''
  ),
  (
     'Isoflurane',
     '',
     'Inhalation vapour liquid',
     '',
     ''
  ),
  (
     'Sevoflurane',
     '',
     'Inhalation vapour liquid',
     '',
     ''
  ),
  (
     'Desflurane',
     '',
     'Inhalation vapour liquid',
     'ใช้เป็นทางเลือกในการให้ยาระงับความรู้สึกในกรณีต่อไปนี้1. โรคอ้วน (morbidly obese) ที่มีภาวะ obstructive sleep apnea (OSA) ร่วมด้วย2. โรคอ้วน (morbidly obese) ที่มี Body Mass Index (BMI) ตั้งแต่ 35 kg/m2 ขึ้นไป3. การผ่าตัดซึ่งต้องการให้ผู้ป่วยตื่นเร็ว ได้แก่ ผู้ป่วยในภาวะฉุกเฉิน การผ่าตัดที่ไม่ต้องรับผู้ป่วยไว้ค้างคืน4. การผ่าตัดสมอง',
     ''
  ),
  (
     'Atracurium besilate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Cisatracurium besilate',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Pancuronium bromide',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Rocuronium bromide',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Suxamethonium chloride',
     '',
     'sterile pwdr, sterile sol',
     '',
     ''
  ),
  (
     'Vecuronium bromide',
     '',
     'sterile pwdr',
     '',
     ''
  ),
  (
     'Diazepam',
     'วัตถุออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'cap, tab, sterile sol',
     '',
     ''
  ),
  (
     'Fentanyl citrate',
     'ยาเสพติดให้โทษประเภท 2',
     'sterile sol',
     '',
     ''
  ),
  (
     'Morphine sulfate',
     'ยาเสพติดให้โทษประเภท 2',
     'sterile sol',
     '',
     ''
  ),
  (
     'Pethidine hydrochloride',
     'ยาเสพติดให้โทษประเภท 2',
     'sterile sol',
     '',
     ''
  ),
  (
     'Dexmedetomidine',
     '',
     'sterile sol (เฉพาะ 100 mcg/ml) (2 ml)',
     '1. สำหรับการสงบประสาทและระงับปวดในหออภิบาลผู้ป่วยวิกฤต  (for sedation and analgesia in Intensive Care Unit patients) เฉพาะกรณีผู้ป่วยอายุมากกว่า 65 ปี หรือมีความเสี่ยงสูงต่อ delirium โดยโรคประจำตัว หรือมีข้อห้ามใช้ยาอื่นในบัญชียาหลักแห่งชาติ 2. สำหรับการสงบประสาทและระงับปวดสำหรับหัตถการทางการแพทย์ (for procedural sedation and analgesia)3. ใช้ร่วมกับการระงับความรู้สึก ในระหว่างผ่าตัด (for perioperative adjuvant anesthetic management)',
     ''
  ),
  (
     'Midazolam hydrochloride',
     'วัตถุออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'sterile sol',
     '1. ใช้เสริมยาระงับความรู้สึก2. ใช้เพื่อให้ผู้ป่วยสงบ คลายความวิตกกังวลทั้งในระยะ ก่อนระหว่างและหลังทำหัตถการ3. ใช้ระงับชัก',
     ''
  ),
  (
     'Midazolam maleate',
     'วัตถุออกฤทธิ์ต่อจิตและประสาทประเภท 2',
     'tab',
     'ใช้เตรียมผู้ป่วยก่อนให้ยาระงับความรู้สึก (premedication) เท่านั้น',
     ''
  ),
  (
     'Atropine sulfate',
     '',
     'sterile sol',
     'ใช้แก้ฤทธิ์ยาหย่อนกล้ามเนื้อ',
     ''
  ),
  (
     'Neostigmine methylsulfate',
     '',
     'sterile sol',
     'ใช้แก้ฤทธิ์ยาหย่อนกล้ามเนื้อ',
     ''
  ),
  (
     'Edrophonium  chloride',
     'ยากำพร้า',
     'sterile sol (เฉพาะ 10 mg/ml)',
     'ใช้วินิจฉัยโรค myasthenia gravis',
     ''
  ),
  (
     'Glycopyrronium bromide',
     '',
     'sterile sol',
     '1. ใช้เป็นยาทางเลือกแทนยา atropine โดยใช้ร่วมกับยา neostigmine ในการแก้ฤทธิ์ยาหย่อนกล้ามเนื้อ ในผู้ป่วยสูงอายุ หรือผู้ป่วยที่มีปัญหาหัวใจเต้นเร็ว2. ใช้ลดเสมหะหรือน้ำลาย ในการดมยาสลบกรณีที่จะทำหัตถการเกี่ยวกับทางเดินหายใจ3. ใช้ลดเสมหะในผู้ป่วยระยะสุดท้าย (end-of-life)',
     ''
  ),
  (
     'Sugammadex',
     '',
     'sterile sol (เฉพาะ 100 mg/ml) (2 ml)',
     'ใช้แก้ฤทธิ์ยาหย่อนกล้ามเนื้อในผู้ป่วยที่มีความเสี่ยงสูงที่ได้รับยา vecuronium หรือยา rocuronium เป็นยาหย่อนกล้ามเนื้อ ได้แก่1. ผู้มีโรคประจำตัว ได้แก่1.1. โรคทางระบบประสาทและกล้ามเนื้อ (เช่น myasthenia gravis, muscular dystrophy ฯลฯ)1.2. โรคระบบทางเดินหายใจ (เช่น chronic obstructive pulmonary disease, chronic bronchitis, asthma ฯลฯ)1.3. ผู้ป่วยที่มีภาวะไตวาย หรือผู้ป่วยที่มีภาวะตับวาย1.4. โรคหัวใจและหลอดเลือด (เช่น ischemic heart disease, heart failure, tachyarrhythmia, valvular heart disease ฯลฯ)2. การผ่าตัดที่มีระยะเวลายาวนานกว่า 3 ชั่วโมง หรือการผ่าตัดที่คาดการณ์เวลาที่ทำการผ่าตัดเสร็จได้ยาก โดยที่ผู้ป่วยได้รับยา rocuronium เป็นยาหย่อนกล้ามเนื้อ3. ผู้ป่วยเกิดภาวะ cannot intubate and cannot ventilate (CICV)4. ใช้แก้ฤทธิ์ยาหย่อนกล้ามเนื้อ สำหรับผู้ป่วย COVID-19 ที่ใส่ท่อช่วยหายใจในการนำสลบแบบรวดเร็ว (rapid sequence induction intubation) ในกรณีที่ต้องการให้ผู้ป่วยสามารถกลับมาหายใจได้โดยเร็ว',
     ''
  ),
  (
     'Dantrolene sodium',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้สำหรับ malignant hyperthermia',
     ''
  ),
  (
     'Benzocaine',
     '',
     'gel, oint',
     '',
     ''
  ),
  (
     'Lidocaine hydrochloride',
     '',
     'gel, oint, spray, viscous sol, sterile sol, sterile sol (dental cartridge)',
     '',
     ''
  ),
  (
     'Lidocaine + Prilocaine',
     '',
     'cream',
     '',
     ''
  ),
  (
     'Lidocaine hydrochloride + Epinephrine',
     '',
     'sterile sol, sterile sol (dental cartridge)',
     '',
     ''
  ),
  (
     'Mepivaciane hydrochloride',
     '',
     'sterile sol (dental cartridge)',
     '',
     ''
  ),
  (
     'Mepivaciane hydrochloride + Epinephrine',
     '',
     'sterile sol (dental cartridge)',
     '',
     ''
  ),
  (
     'Bupivacaine hydrochloride',
     '',
     'sterile sol',
     '',
     'อาจทำให้เกิดพิษต่อหัวใจ'
  ),
  (
     'Bupivacaine hydrochloride with/without glucose',
     '',
     'sterile sol',
     '',
     'อาจทำให้เกิดพิษต่อหัวใจ'
  ),
  (
     'Lidocaine hydrochloride + Epinephrine',
     '',
     'sterile sol',
     '',
     ''
  ),
  (
     'Antivenom sera',
     '',
     'inj',
     '',
     ''
  ),
  (
     'Polyvalent antivenom for hematotoxin',
     '',
     'inj',
     'ใช้แก้พิษต่อระบบเลือดในรายที่ถูกงูไม่ทราบชนิดกัด',
     ''
  ),
  (
     'Polyvalent antivenom for neurotoxin',
     '',
     'inj',
     'ใช้แก้พิษต่อระบบประสาทในรายที่ถูกงูไม่ทราบชนิดกัด',
     ''
  ),
  (
     'Acetylcysteine',
     '',
     'sterile sol',
     'ใช้รักษาภาวะพิษต่อตับจากเห็ดพิษกลุ่มที่มีอะมาทอกซิน (amatoxin containing mushrooms)',
     ''
  ),
  (
     'Vitamin B6',
     '',
     'sterile sol (เฉพาะ 50 mg)',
     'ใช้บำบัดพิษจากเห็ดสมองวัว (Gyromitra spp.)',
     ''
  ),
  (
     'Botulinum antitoxin',
     'ยากำพร้า',
     'inj',
     'ใช้บำบัดโรค Botulism',
     ''
  ),
  (
     'Atropine sulfate',
     '',
     'sterile sol',
     'ใช้ต้านพิษ cholinesterase inhibitors (เช่น organophosphates, carbamates) และภาวะ cholinergic crisis',
     ''
  ),
  (
     'Pralidoxime chloride',
     '',
     'sterile pwdr',
     'ใช้บำบัดพิษเฉียบพลันจาก organophosphates',
     ''
  ),
  (
     'Cyclophosphamide',
     '',
     'sterile pwdr',
     'ใช้บำบัดพิษจากสาร paraquat ภายใต้การกำกับดูแลของศูนย์พิษวิทยา',
     ''
  ),
  (
     'Calcium gluconatee',
     '',
     'sterile sol',
     'ใช้บำบัดพิษจาก hydrofluoric acid',
     ''
  ),
  (
     'Ethanol',
     'ยากำพร้าเฉพาะรูปแบบ sterile sol',
     'sterile sol, sterile sol (hosp)',
     'ใช้บำบัดพิษเฉียบพลันจาก methanol และ ethylene glycol',
     ''
  ),
  (
     'Calcium folinate',
     '',
     'cap, tab, sterile pwdr, sterile sol',
     'ใช้ร่วมกับ ethanol ในการบำบัดพิษจาก methanol',
     ''
  ),
  (
     'Deferoxamine mesilate',
     '',
     'sterile pwdr',
     'ใช้กำจัดพิษจากภาวะธาตุเหล็กสูงผิดปกติเฉียบพลัน',
     ''
  ),
  (
     'Dimercaprol',
     'ยากำพร้า',
     'sterile oil solution for IM use',
     'ใช้บำบัดพิษเฉียบพลันจากปรอท ทอง และสารหนู และใช้ร่วมกับ sodium calcium edetate ในกรณีบำบัด พิษเฉียบพลันจากตะกั่ว',
     'ห้ามใช้ในผู้ป่วยที่มีประวัติแพ้ถั่วลิสง (peanut) และอาจมีการแพ้ข้ามกลุ่มไปยังถั่วเหลือง (soya) ได้'
  ),
  (
     'Penicillamine',
     'ยากำพร้า',
     'cap, tab',
     'ใช้บำบัดอาการพิษจากสารทองแดง ตะกั่ว ปรอท และสารหนู',
     'ระวังการใช้กับหญิงตั้งครรภ์เพราะเป็นสารก่อวิรูป (teratogen)'
  ),
  (
     'Sodium calcium edetate',
     'ยากำพร้า',
     'sterile sol',
     'ใช้บำบัดพิษจากตะกั่ว สังกะสี และแมงกานีส',
     ''
  ),
  (
     'Succimer',
     'ยากำพร้า',
     'cap',
     'ใช้บำบัดพิษจากตะกั่ว',
     ''
  ),
  (
     'Sodium nitrite',
     'ยากำพร้า',
     'sterile sol, sterile sol (hosp)',
     'ใช้บำบัดพิษเฉียบพลันจากไซยาไนด์  และไฮโดรเจนซัลไฟด์',
     'การใช้ยาปริมาณมากเกินไปอาจทำให้เกิดภาวะ cardiovascular collapse, methaemoglobinaemia และ อาจเสียชีวิตได้'
  ),
  (
     'Sodium thiosulfate',
     'ยากำพร้า',
     'sterile sol, sterile sol (hosp)',
     'ใช้บำบัดพิษเฉียบพลันจากไซยาไนด์',
     ''
  ),
  (
     'Methylene blue',
     'ยากำพร้า',
     'sterile sol, sterile sol (hosp)',
     'ใช้บำบัด methaemoglobinaemia',
     'ควรใช้อย่างระมัดระวังในผู้ป่วยภาวะการทำงานของไตบกพร่องขั้นรุนแรง และในผู้ป่วยที่ขาดเอนไซม์ G6PD'
  ),
  (
     'Acetylcysteine',
     '',
     'sterile sol',
     'ใช้แก้พิษจากการได้รับ paracetamol เกินขนาด',
     ''
  ),
  (
     'Benzatropine mesilate',
     '',
     'sterile sol',
     'ใช้บำบัดภาวะ dystonia เนื่องจากยา',
     ''
  ),
  (
     'Calcium gluconate',
     '',
     'sterile sol',
     'ใช้บำบัดพิษจาก calcium channel blockers และ beta blockers',
     ''
  ),
  (
     'Diphenhydramine hydrochloride',
     'ยากำพร้า',
     'cap, sterile sol',
     'ใช้บำบัดภาวะ dystonia จากยา',
     ''
  ),
  (
     'Naloxone hydrochloride',
     '',
     'sterile sol',
     'ใช้บำบัดอาการพิษเฉียบพลันจากสารกลุ่ม opioids หรือยา clonidine',
     ''
  ),
  (
     'Sodium bicarbonate',
     '',
     'sterile sol (เฉพาะ 44.6 mEq)',
     'ใช้บำบัดภาวะ hyperkalemia หรือพิษเฉียบพลันจากสาร tricyclic antidepressants หรือ antiarrhythmics type I',
     ''
  ),
  (
     'Sodium nitroprusside',
     'ยากำพร้า',
     'sterile pwdr',
     'ใช้เพื่อขยายหลอดเลือดแดงในผู้ป่วยที่เกิด peripheral arterial spasm จากยากลุ่ม ergot',
     ''
  ),
  (
     'Vitamin K1',
     '',
     'sterile sol',
     'ใช้บำบัดภาวะยา anticoagulants (coumarin derivatives) เกินขนาด',
     ''
  ),
  (
     'Cyproheptadine hydrochloride',
     '',
     'tab',
     'ใช้บำบัดภาวะ acute serotonin syndrome',
     ''
  ),
  (
     'Bromocriptine mesilate',
     '',
     'tab',
     'ใช้กับผู้ป่วย neuroleptic malignant syndrome',
     ''
  ),
  (
     'Protamine sulfate',
     '',
     'sterile sol',
     'ใช้ในกรณีที่มีเลือดออกมากผิดปกติจากการได้รับ heparin เกินขนาด',
     ''
  ),
  (
     'Vitamin B6',
     '',
     'sterile sol (เฉพาะ 50 mg)',
     'ใช้บำบัดอาการทางสมองและชักที่เกิดจากยา isoniazid',
     ''
  ),
  (
     'Calcium folinate',
     '',
     'cap, tab, sterile pwdr, sterile sol',
     '1. ใช้บำบัดพิษจากสาร folic acid antagonists, methotrexate, trimethoprim และ pyrimethamine  2. ใช้ป้องกันพิษจาก methotrexate เฉพาะกรณีใช้ยานี้ในขนาดสูง',
     ''
  ),
  (
     'Flumazenil',
     '',
     'sterile sol',
     'ใช้แก้ฤทธิ์จากการใช้ยาในกลุ่ม benzodiazepines กรณีการทำหัตถการทางวิสัญญี',
     ''
  ),
  (
     'Mesna',
     '',
     'sterile sol',
     'ป้องกันภาวะเลือดออกในทางเดินปัสสาวะ ในผู้ป่วยที่ได้รับยา ifosfamide หรือ cyclophosphamide ขนาดสูง (มากกว่า 1.5 g/m2)',
     ''
  ),
  (
     'Phenobarbital sodium',
     'วัตถุที่ออกฤทธิ์ต่อจิตและประสาทประเภท 4',
     'sterile pwdr, sterile sol',
     'ใช้บำบัดอาการชักจากยา',
     ''
  ),
  (
     'Charcoal, activated',
     '',
     'pwdr',
     'ใช้ดูดซับสารพิษทั่วไปที่ได้รับในทางเดินอาหาร',
     ''
  ),
  (
     'Macrogols with electrolytes',
     '',
     'oral pwdr, oral pwdr (hosp)',
     'ใช้ทำหัตถการล้างกระเพาะและลำไส้ (whole bowel irrigation) กรณีได้รับสารพิษ หรือล้างผิวหนัง กรณีสัมผัส phenol',
     ''
  ),
  (
     'Sodium bicarbonate',
     '',
     'sterile sol (เฉพาะ 44.6 mEq)',
     'ใช้ปรับปัสสาวะให้เป็นด่าง เพื่อเร่งการกำจัดสารพิษ เช่น salicylates เป็นต้น',
     ''
  ),
  (
     'Iopamidol',
     '',
     'sterile sol (เฉพาะ 300 mgI/mL) (50 mL, 100 mL)',
     'ใช้ฉีดเข้าหลอดเลือด เช่น intravenous pyelography หรือ excretory urography การตรวจทางด้านเอกซเรย์คอมพิวเตอร์ (CT) การตรวจ angiography การตรวจและรักษาทาง interventional radiology เป็นต้น',
     ''
  ),
  (
     'Iopromide',
     '',
     'sterile sol (เฉพาะ 300 mgI/mL) (50 mL, 100 mL)',
     'ใช้ฉีดเข้าหลอดเลือด เช่น intravenous pyelography หรือ excretory urography การตรวจทางด้านเอกซเรย์คอมพิวเตอร์ (CT) การตรวจ angiography การตรวจและรักษาทาง interventional radiology เป็นต้น',
     ''
  ),
  (
     'Iopamidol',
     '',
     'sterile sol (เฉพาะ 370 mgI/mL) (50 mL, 100 mL)',
     'ใช้ฉีดเข้าหลอดเลือด สำหรับการตรวจ cardiovascular system และกรณีสงสัย hypervascular tumor',
     ''
  ),
  (
     'Iopromide',
     '',
     'sterile sol (เฉพาะ 370 mgI/mL) (50 mL, 100 mL)',
     'ใช้ฉีดเข้าหลอดเลือด สำหรับการตรวจ cardiovascular system และกรณีสงสัย hypervascular tumor',
     ''
  ),
  (
     'Iopamidol',
     '',
     'sterile sol (เฉพาะ 300 mgI/mL) (50 mL, 100 mL)',
     'ใช้สำหรับ intracavitary เช่น hysterosalpingography (HSG), urethrography, voiding cysto-urethrography เป็นต้น',
     ''
  ),
  (
     'Iopromide',
     '',
     'sterile sol (เฉพาะ 300 mgI/mL) (50 mL, 100 mL)',
     'ใช้สำหรับ intracavitary เช่น hysterosalpingography (HSG), urethrography, voiding cysto-urethrography เป็นต้น',
     ''
  ),
  (
     'Iopamidol',
     '',
     'sterile sol (เฉพาะ 300 mgI/mL) (50 mL, 100 mL)',
     'ใช้สำหรับ myelography',
     ''
  ),
  (
     'Barium sulfate',
     '',
     'pwdr for oral susp',
     '',
     ''
  ),
  (
     'Meglumine gadoterate',
     '',
     'sterile sol (เฉ พ า ะ 377 mg/mL(0.5 mmol/mL)) (10 mL, 15 mL)for intravascular or intraarticular',
     'ใช้สำหรับ Magnetic resonance imaging (MRI)',
     'ควรระมัดระวังการใช้ยานี้ ในผู้ป่วยที่มี Estimated glomerular filtration rate (eGFR) ต่ำกว่า 15 mL/min/1.73 m2 และผู้ป่วยที่ได้รับการรักษาโดยวิธีการบําบัดทดแทนไต ด้วยวิธีการฟอกเลือดด้วยเครื่องไตเทียม  (hemodialysis) หรือวิธีการล้างไตทางช่องท้อง (Peritoneal dialysis)'
  ),
  (
     'Ethiodized oil',
     '',
     'sterile sol (เฉพาะ 4.8 g iodine) (Iodine 38% w/w)',
     '1. ใช้ผสมกับยาเคมีบำบัด สำหรับการทำ transarterial chemoembolization (TACE) เพื่อรักษาผู้ป่วยมะเร็งตับ (hepatocellular carcinoma) และใช้โดยรังสีแพทย์2. ใช้ผสมกับ cyanoacrylate glue สำหรับการทำหัตถการ endovascular treatment เพื่อการอุดหลอดเลือดโรคหลอดเลือดผิดปกติและโรคภยันตรายของหลอดเลือดของระบบต่าง ๆ ของร่างกาย และใช้โดยแพทย์ผู้เชี่ยวชาญเฉพาะทางในสาขาที่เกี่ยวข้อง',
     ''
  ),
  (
     'Tc-99m dextran',
     '',
     'sterile sol for inj (hosp)',
     'ใช้เพื่อการตรวจวินิจฉัยโรคการอุดกั้นของระบบทางเดินน้ำเหลือง (lymphatic obstruction)',
     ''
  ),
  (
     'Tc-99m diethylene triamine penta acetic acid (DTPA)',
     '',
     'sterile sol for inj (hosp), aerosol for inhalation (hosp)',
     '1. ใช้เพื่อการคำนวณหาค่า glomerular filtration rate (GFR) 2. ใช้เพื่อการตรวจวินิจฉัยโรคทางเดินหายใจ (ventilation lung scan)',
     ''
  ),
  (
     'Tc-99m dimercaptosuccinic acid (DMSA)',
     '',
     'sterile sol for inj (hosp)',
     '1. ใช้เพื่อการตรวจวินิจฉัยโรคการอักเสบและแผลเป็นของเนื้อไต2. ใช้ประเมินการทำงานของไต',
     ''
  ),
  (
     'Tc-99m dimercaptosuccinic acid V (DMSA [V])',
     '',
     'sterile sol for inj (hosp)',
     'ใช้เพื่อการตรวจวินิจฉัยโรค medullary thyroid cancer',
     ''
  ),
  (
     'Tc-99m iminodiacetic acid (IDA)',
     '',
     'sterile sol for inj (hosp)',
     'ใช้เพื่อการตรวจวินิจฉัยโรคทางเดินน้ำดี',
     ''
  ),
  (
     'Tc-99m methylene diphosphonate (MDP)',
     '',
     'sterile sol for inj (hosp)',
     'ใช้เพื่อการตรวจวินิจฉัยโรคกระดูกและข้อ',
     ''
  ),
  (
     'Tc-99m phytate',
     '',
     'sterile sol for inj (hosp)',
     '1. ใช้เพื่อการตรวจวินิจฉัยโรคตับและม้าม 2. ใช้เพื่อตรวจวินิจฉัยการเคลื่อนไหวของระบบทางเดินอาหาร3. ใช้เพื่อการวินิจฉัย     3.1 ภาวะหลอดเลือดดำที่ขาอุดตัน     3.2 ภาวะเลือดออกในทางเดินอาหาร (gastrointestinal bleeding)',
     ''
  ),
  (
     'Tc-99m sulfur colloid',
     '',
     'sterile sol for inj (hosp)',
     '1. ใช้เพื่อการตรวจวินิจฉัยโรค reticuloendothelial 2. ใช้เพื่อตรวจวินิจฉัยการเคลื่อนไหวของระบบทางเดินอาหาร3. ใช้เพื่อการวินิจฉัยภาวะเลือดออกในทางเดินอาหาร (gastrointestinal bleeding)',
     ''
  );
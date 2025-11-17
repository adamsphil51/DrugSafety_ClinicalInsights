-- Project: DrugSafety_ClinicalInsights
-- Purpose: Track clinical outcomes, adverse events, and patient safety

-- 1. Patients table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    PatientCode VARCHAR(50),
    Age INT,
    Gender VARCHAR(10),
    Hospital VARCHAR(50)
);

INSERT INTO Patients (PatientID, PatientCode, Age, Gender, Hospital) VALUES
(1, 'P001', 34, 'Male', 'Hospital A'),
(2, 'P002', 28, 'Female', 'Hospital B'),
(3, 'P003', 45, 'Male', 'Hospital C'),
(4, 'P004', 52, 'Female', 'Hospital A'),
(5, 'P005', 38, 'Male', 'Hospital B');

-- 2. Drugs table
CREATE TABLE Drugs (
    DrugID INT PRIMARY KEY,
    DrugName VARCHAR(100)
);

INSERT INTO Drugs (DrugID, DrugName) VALUES
(1, 'Paracetamol 500mg'),
(2, 'Amoxicillin 250mg'),
(3, 'Ibuprofen 400mg');

-- 3. Prescriptions table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY,
    PatientID INT,
    DrugID INT,
    Dosage VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

INSERT INTO Prescriptions (PrescriptionID, PatientID, DrugID, Dosage, StartDate, EndDate) VALUES
(1, 1, 1, '500mg 3x/day', '2024-03-01', '2024-03-05'),
(2, 2, 2, '250mg 2x/day', '2024-03-02', '2024-03-08'),
(3, 3, 3, '400mg 2x/day', '2024-03-05', '2024-03-10'),
(4, 4, 1, '500mg 3x/day', '2024-03-06', '2024-03-10'),
(5, 5, 2, '250mg 2x/day', '2024-03-07', '2024-03-12');

-- 4. AdverseEvents table
CREATE TABLE AdverseEvents (
    EventID INT PRIMARY KEY,
    PatientID INT,
    DrugID INT,
    EventDescription VARCHAR(255),
    Severity VARCHAR(50),
    EventDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);

INSERT INTO AdverseEvents (EventID, PatientID, DrugID, EventDescription, Severity, EventDate) VALUES
(1, 1, 1, 'Mild headache', 'Mild', '2024-03-02'),
(2, 2, 2, 'Nausea', 'Moderate', '2024-03-03'),
(3, 3, 3, 'Dizziness', 'Mild', '2024-03-06'),
(4, 4, 1, 'Rash', 'Severe', '2024-03-07');

-- =====================================================
-- Clinical & Drug Safety Queries
-- =====================================================

-- 1. Total adverse events per drug
SELECT 
    d.DrugName,
    COUNT(a.EventID) AS TotalAdverseEvents
FROM Drugs d
LEFT JOIN AdverseEvents a ON d.DrugID = a.DrugID
GROUP BY d.DrugName
ORDER BY TotalAdverseEvents DESC;

-- 2. Adverse events by severity
SELECT 
    Severity,
    COUNT(*) AS EventCount
FROM AdverseEvents
GROUP BY Severity
ORDER BY EventCount DESC;

-- 3. Patients with multiple adverse events
SELECT 
    p.PatientCode,
    COUNT(a.EventID) AS NumEvents
FROM Patients p
JOIN AdverseEvents a ON p.PatientID = a.PatientID
GROUP BY p.PatientCode
HAVING COUNT(a.EventID) > 1;

-- 4. Treatment duration per patient
SELECT 
    p.PatientCode,
    d.DrugName,
    DATEDIFF(day, pr.StartDate, pr.EndDate) AS TreatmentDays
FROM Prescriptions pr
JOIN Patients p ON pr.PatientID = p.PatientID
JOIN Drugs d ON pr.DrugID = d.DrugID
ORDER BY TreatmentDays DESC;

-- 5. Hospital-level adverse events summary
SELECT 
    p.Hospital,
    COUNT(a.EventID) AS TotalEvents,
    SUM(CASE WHEN a.Severity = 'Severe' THEN 1 ELSE 0 END) AS SevereEvents
FROM Patients p
LEFT JOIN AdverseEvents a ON p.PatientID = a.PatientID
GROUP BY p.Hospital
ORDER BY TotalEvents DESC;

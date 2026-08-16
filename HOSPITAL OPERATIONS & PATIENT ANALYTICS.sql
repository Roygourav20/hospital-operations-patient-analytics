-- ============================================================
-- HOSPITAL OPERATIONS & PATIENT ANALYTICS
-- Database: MySQL
-- Purpose: Analyze patients, doctors, appointments, treatments,
--          billing, patient behavior, and hospital operations.
-- ============================================================

-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS hospital_management;
USE hospital_management;

-- ============================================================
-- 2. DATA EXPLORATION & BASIC QUALITY CHECKS
-- ============================================================

-- Patient record count
SELECT COUNT(*) AS patient_count
FROM patients;

-- Doctor record count
SELECT COUNT(*) AS doctor_count
FROM doctors;

-- Appointment record count
SELECT COUNT(*) AS appointment_count
FROM appointments;

-- Treatment record count
SELECT COUNT(*) AS treatment_count
FROM treatments;

-- Billing record count
SELECT COUNT(*) AS billing_record_count
FROM billing;

-- Sample records
SELECT *
FROM patients
LIMIT 10;

SELECT *
FROM doctors
LIMIT 10;

SELECT *
FROM appointments
LIMIT 10;

SELECT *
FROM treatments
LIMIT 10;

SELECT *
FROM billing
LIMIT 10;

-- ============================================================
-- 3. PATIENT ANALYSIS
-- ============================================================

-- 3.1 Patient distribution by address
SELECT
    address,
    COUNT(*) AS patient_count
FROM patients
GROUP BY address
ORDER BY patient_count DESC;

-- 3.2 Patient age distribution
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18
            THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 35
            THEN '18-35'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 36 AND 55
            THEN '36-55'
        ELSE '56+'
    END AS age_group,
    COUNT(*) AS patient_count
FROM patients
GROUP BY age_group
ORDER BY patient_count DESC;

-- 3.3 Patient registration trend by year and month
SELECT
    YEAR(registration_date) AS registration_year,
    MONTH(registration_date) AS registration_month,
    COUNT(*) AS new_patient_registrations
FROM patients
GROUP BY
    YEAR(registration_date),
    MONTH(registration_date)
ORDER BY
    registration_year,
    registration_month;

-- 3.4 Most commonly used patient email domains
SELECT
    SUBSTRING_INDEX(email, '@', -1) AS email_domain,
    COUNT(*) AS patient_count
FROM patients
GROUP BY email_domain
ORDER BY patient_count DESC;

-- ============================================================
-- 4. DOCTOR & SPECIALIZATION ANALYSIS
-- ============================================================

-- 4.1 Doctor count by specialization
SELECT
    specialization,
    COUNT(*) AS doctor_count
FROM doctors
GROUP BY specialization
ORDER BY doctor_count DESC;

-- 4.2 Doctors ranked by years of experience
SELECT
    doctor_id,
    CONCAT(first_name, ' ', last_name) AS doctor_name,
    specialization,
    years_experience
FROM doctors
ORDER BY years_experience DESC;

-- 4.3 Doctors whose first name ends with 'is'
SELECT
    doctor_id,
    CONCAT(first_name, ' ', last_name) AS doctor_name,
    specialization
FROM doctors
WHERE first_name LIKE '%is';

-- 4.4 Doctor classification by experience
SELECT
    doctor_id,
    CONCAT(first_name, ' ', last_name) AS doctor_name,
    specialization,
    years_experience,
    CASE
        WHEN years_experience <= 15 THEN 'Junior Doctor'
        ELSE 'Senior Doctor'
    END AS doctor_grade
FROM doctors
ORDER BY years_experience DESC;

-- 4.5 Medical specialization demand based on appointment volume
SELECT
    d.specialization,
    COUNT(a.appointment_id) AS appointment_volume
FROM doctors AS d
JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY appointment_volume DESC;

-- 4.6 Appointment count by doctor, including doctors with no appointments
SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors AS d
LEFT JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization
ORDER BY total_appointments DESC;

-- 4.7 Doctors ranked by appointment volume
SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS appointment_number,
    RANK() OVER (
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS doctor_rank
FROM doctors AS d
LEFT JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization
ORDER BY doctor_rank;

-- ============================================================
-- 5. APPOINTMENT ANALYSIS
-- ============================================================

-- 5.1 Appointment status distribution
SELECT
    status,
    COUNT(*) AS appointment_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_appointments
FROM appointments
GROUP BY status
ORDER BY appointment_count DESC;

-- 5.2 Appointment statuses with more than 50 records
SELECT
    status,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY status
HAVING COUNT(*) > 50
ORDER BY appointment_count DESC;

-- 5.3 Appointments recorded in the most recent 7-day period
SELECT *
FROM appointments
WHERE appointment_date >= (
    SELECT MAX(appointment_date) - INTERVAL 7 DAY
    FROM appointments
)
ORDER BY appointment_date DESC;

-- 5.4 Patient appointment details with assigned doctor
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    a.appointment_id,
    a.appointment_date,
    a.status,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization
FROM patients AS p
JOIN appointments AS a
    ON p.patient_id = a.patient_id
JOIN doctors AS d
    ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date DESC;

-- 5.5 Monthly appointment trend
SELECT
    YEAR(appointment_date) AS appointment_year,
    MONTH(appointment_date) AS appointment_month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    YEAR(appointment_date),
    MONTH(appointment_date)
ORDER BY
    appointment_year,
    appointment_month;

-- 5.6 Appointment trend by day of week
SELECT
    DAYNAME(appointment_date) AS appointment_day,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    DAYOFWEEK(appointment_date),
    DAYNAME(appointment_date)
ORDER BY total_appointments DESC;

-- 5.7 Patients with repeated no-shows or cancellations
SELECT
    patient_id,
    COUNT(*) AS missed_appointments
FROM appointments
WHERE status IN ('No-show', 'Cancelled')
GROUP BY patient_id
ORDER BY missed_appointments DESC;

-- 5.8 Patients with more than 3 appointments and a missed-appointment
-- rate above 40%
SELECT
    patient_id,
    COUNT(*) AS total_appointments,
    SUM(
        CASE
            WHEN status IN ('No-show', 'Cancelled') THEN 1
            ELSE 0
        END
    ) AS missed_appointments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN status IN ('No-show', 'Cancelled') THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS missed_appointment_rate
FROM appointments
GROUP BY patient_id
HAVING
    COUNT(*) > 3
    AND
    100.0 * SUM(
        CASE
            WHEN status IN ('No-show', 'Cancelled') THEN 1
            ELSE 0
        END
    ) / COUNT(*) > 40
ORDER BY missed_appointment_rate DESC;

-- ============================================================
-- 6. TREATMENT ANALYSIS
-- ============================================================

-- 6.1 Most common treatment types
SELECT
    treatment_type,
    COUNT(*) AS treatment_count
FROM treatments
GROUP BY treatment_type
ORDER BY treatment_count DESC;

-- 6.2 Treatment cost summary
SELECT
    MIN(cost) AS minimum_treatment_cost,
    MAX(cost) AS maximum_treatment_cost,
    ROUND(AVG(cost), 2) AS average_treatment_cost
FROM treatments;

-- ============================================================
-- 7. BILLING & REVENUE ANALYSIS
-- ============================================================

-- 7.1 Total paid revenue
SELECT
    ROUND(SUM(amount), 2) AS total_paid_revenue
FROM billing
WHERE payment_status = 'Paid';

-- 7.2 Revenue by payment status
SELECT
    payment_status,
    COUNT(*) AS billing_records,
    ROUND(SUM(amount), 2) AS total_amount
FROM billing
GROUP BY payment_status
ORDER BY total_amount DESC;

-- 7.3 Top revenue-generating patients
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    ROUND(SUM(b.amount), 2) AS total_spend
FROM patients AS p
JOIN billing AS b
    ON p.patient_id = b.patient_id
WHERE b.payment_status = 'Paid'
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY total_spend DESC;

-- 7.4 Patients ranked by total paid spending
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    ROUND(SUM(b.amount), 2) AS amount_spent,
    RANK() OVER (
        ORDER BY SUM(b.amount) DESC
    ) AS spending_rank
FROM patients AS p
JOIN billing AS b
    ON p.patient_id = b.patient_id
WHERE b.payment_status = 'Paid'
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY spending_rank;

-- 7.5 Monthly paid revenue trend
SELECT
    YEAR(bill_date) AS billing_year,
    MONTH(bill_date) AS billing_month,
    ROUND(SUM(amount), 2) AS monthly_revenue
FROM billing
WHERE payment_status = 'Paid'
GROUP BY
    YEAR(bill_date),
    MONTH(bill_date)
ORDER BY
    billing_year,
    billing_month;

-- ============================================================
-- 8. ADVANCED PATIENT ANALYTICS
-- ============================================================

-- 8.1 Patient visit frequency and gap between consecutive visits
WITH visit_history AS (
    SELECT
        patient_id,
        appointment_id,
        appointment_date,
        LAG(appointment_date) OVER (
            PARTITION BY patient_id
            ORDER BY appointment_date
        ) AS previous_visit_date
    FROM appointments
)
SELECT
    patient_id,
    appointment_id,
    appointment_date,
    previous_visit_date,
    DATEDIFF(
        appointment_date,
        previous_visit_date
    ) AS days_between_visits
FROM visit_history
ORDER BY
    patient_id,
    appointment_date;

-- 8.2 RFM-based patient segmentation
--
-- Recency  : Days since the patient's latest appointment
-- Frequency: Number of distinct appointments
-- Monetary : Total paid billing amount
--
-- Appointment and billing data are aggregated separately to avoid
-- double-counting caused by joining multiple appointment and billing
-- records for the same patient.

WITH appointment_summary AS (
    SELECT
        patient_id,
        MAX(appointment_date) AS last_visit,
        COUNT(DISTINCT appointment_id) AS frequency
    FROM appointments
    GROUP BY patient_id
),
billing_summary AS (
    SELECT
        patient_id,
        COALESCE(
            SUM(
                CASE
                    WHEN payment_status = 'Paid' THEN amount
                    ELSE 0
                END
            ),
            0
        ) AS monetary
    FROM billing
    GROUP BY patient_id
),
rfm AS (
    SELECT
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        a.last_visit,
        COALESCE(a.frequency, 0) AS frequency,
        COALESCE(b.monetary, 0) AS monetary
    FROM patients AS p
    LEFT JOIN appointment_summary AS a
        ON p.patient_id = a.patient_id
    LEFT JOIN billing_summary AS b
        ON p.patient_id = b.patient_id
),
scored AS (
    SELECT
        *,
        CASE
            WHEN last_visit IS NULL THEN NULL
            ELSE DATEDIFF(CURDATE(), last_visit)
        END AS recency_days,

        NTILE(4) OVER (
            ORDER BY
                CASE
                    WHEN last_visit IS NULL THEN 999999
                    ELSE DATEDIFF(CURDATE(), last_visit)
                END ASC
        ) AS r_score,

        NTILE(4) OVER (
            ORDER BY frequency DESC
        ) AS f_score,

        NTILE(4) OVER (
            ORDER BY monetary DESC
        ) AS m_score
    FROM rfm
)
SELECT
    patient_id,
    patient_name,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_code,
    CASE
        WHEN r_score >= 3
             AND f_score >= 3
             AND m_score >= 3
            THEN 'Champions'

        WHEN f_score >= 3
             AND m_score >= 3
            THEN 'Loyal High Value'

        WHEN r_score <= 2
             AND f_score <= 2
            THEN 'At Risk / Inactive'

        WHEN f_score >= 3
            THEN 'Frequent Visitors'

        WHEN m_score >= 3
            THEN 'High Spenders'

        ELSE 'Regular'
    END AS patient_segment
FROM scored
ORDER BY
    monetary DESC,
    frequency DESC;

-- ============================================================
-- 9. KEY ANALYTICAL OUTPUTS / BUSINESS QUESTIONS
-- ============================================================

-- Q1. Which specialization has the highest appointment demand?
SELECT
    d.specialization,
    COUNT(a.appointment_id) AS appointment_volume
FROM doctors AS d
JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY appointment_volume DESC;

-- Q2. Which doctors handle the highest appointment volume?
SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS appointment_volume,
    RANK() OVER (
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS doctor_rank
FROM doctors AS d
LEFT JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization
ORDER BY doctor_rank;

-- Q3. Which patients may require intervention due to missed appointments?
SELECT
    patient_id,
    COUNT(*) AS total_appointments,
    SUM(
        CASE
            WHEN status IN ('No-show', 'Cancelled') THEN 1
            ELSE 0
        END
    ) AS missed_appointments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN status IN ('No-show', 'Cancelled') THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS missed_appointment_rate
FROM appointments
GROUP BY patient_id
HAVING
    COUNT(*) > 3
    AND
    100.0 * SUM(
        CASE
            WHEN status IN ('No-show', 'Cancelled') THEN 1
            ELSE 0
        END
    ) / COUNT(*) > 40
ORDER BY missed_appointment_rate DESC;

-- Q4. Which patients generate the highest paid revenue?
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    ROUND(SUM(b.amount), 2) AS total_paid_revenue,
    RANK() OVER (
        ORDER BY SUM(b.amount) DESC
    ) AS revenue_rank
FROM patients AS p
JOIN billing AS b
    ON p.patient_id = b.patient_id
WHERE b.payment_status = 'Paid'
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY revenue_rank;

-- Q5. What is the monthly appointment trend?
SELECT
    YEAR(appointment_date) AS appointment_year,
    MONTH(appointment_date) AS appointment_month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    YEAR(appointment_date),
    MONTH(appointment_date)
ORDER BY
    appointment_year,
    appointment_month;

-- Q6. What is the monthly paid revenue trend?
SELECT
    YEAR(bill_date) AS billing_year,
    MONTH(bill_date) AS billing_month,
    ROUND(SUM(amount), 2) AS monthly_revenue
FROM billing
WHERE payment_status = 'Paid'
GROUP BY
    YEAR(bill_date),
    MONTH(bill_date)
ORDER BY
    billing_year,
    billing_month;

-- ============================================================
-- END OF PROJECT
-- ============================================================
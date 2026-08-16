# Hospital Operations & Patient Analytics

## 📌 Project Overview

This project analyzes hospital operational data using **MySQL** to understand patient behavior, appointment patterns, doctor workload, treatment trends, and revenue performance.

The analysis combines data from patients, doctors, appointments, treatments, and billing records to generate actionable business insights that can support hospital management and operational decision-making.

---

## 🎯 Business Objectives

The project focuses on answering key business questions such as:

* What is the demographic distribution of hospital patients?
* Which medical specializations have the highest appointment demand?
* Which doctors handle the highest number of appointments?
* What are the most common appointment statuses?
* Which patients have high no-show/cancellation rates?
* What are the monthly appointment and revenue trends?
* Which patients contribute the highest revenue?
* Which patients are frequent, high-value, or potentially at-risk?
* How frequently do patients return for appointments?

---

## 🗂️ Dataset

The project uses five relational datasets:

| Table          | Description                                                |
| -------------- | ---------------------------------------------------------- |
| `patients`     | Patient demographic, contact, and registration information |
| `doctors`      | Doctor information, specialization, and experience         |
| `appointments` | Patient appointments, dates, assigned doctors, and status  |
| `treatments`   | Treatment types and associated costs                       |
| `billing`      | Patient billing transactions and payment status            |

### Key Relationships

```text
Patients
   │
   ├── Appointments ─── Doctors
   │
   └── Billing

Treatments
```

---

## 🛠️ Tools & Technologies

* **MySQL**
* SQL
* Relational Database Analysis
* CTEs
* Window Functions
* Aggregations
* Joins
* CASE Statements
* Date & Time Functions

---

## 🔍 SQL Analysis Performed

### 1. Patient Analysis

Analyzed:

* Patient distribution by address
* Patient age groups
* Monthly patient registration trends
* Most commonly used email domains

### 2. Doctor & Specialization Analysis

Analyzed:

* Number of doctors by specialization
* Doctor experience
* Senior vs. junior doctor classification
* Appointment demand by specialization
* Doctor appointment workload
* Doctor ranking based on appointment volume

### 3. Appointment Analysis

Analyzed:

* Appointment status distribution
* Recent appointments
* Patient-doctor appointment details
* Monthly appointment trends
* Appointment volume by day of the week
* Repeated no-shows and cancellations
* Patients with more than 3 appointments and a missed-appointment rate above 40%

### 4. Treatment Analysis

Analyzed:

* Most frequently used treatment types
* Minimum treatment cost
* Maximum treatment cost
* Average treatment cost

### 5. Revenue & Billing Analysis

Analyzed:

* Total paid revenue
* Revenue by payment status
* Top revenue-generating patients
* Patient spending rankings
* Monthly revenue trends

### 6. Advanced Patient Analytics

Implemented advanced SQL analysis using:

* CTEs
* `RANK()`
* `NTILE()`
* `LAG()`
* `DATEDIFF()`
* `COALESCE()`
* Window functions

A major component of the project is **RFM-based patient segmentation**, classifying patients into groups such as:

* Champions
* Loyal High Value
* Frequent Visitors
* High Spenders
* At Risk / Inactive
* Regular

---

## 📊 Key Analytical Questions

Some of the main SQL analyses include:

### Doctor Performance

Ranking doctors based on appointment volume to understand workload distribution and identify doctors handling the highest number of appointments.

### Patient Intervention

Identifying patients with:

* More than 3 appointments
* More than 40% missed appointments

This can help identify patients who may benefit from appointment reminders or follow-up interventions.

### Patient Value

Using RFM analysis to evaluate patients based on:

* **Recency** — How recently the patient visited
* **Frequency** — How often the patient visited
* **Monetary** — Total paid revenue generated

### Operational Trends

Analyzing appointment and revenue trends by:

* Month
* Year
* Day of the week
* Appointment status
* Medical specialization

---

## 💡 Business Insights

The analysis is designed to help hospital management:

* Identify high-demand medical specializations
* Monitor doctor workload
* Identify patients with frequent missed appointments
* Understand patient registration trends
* Identify high-value patients
* Detect potentially inactive or at-risk patients
* Monitor appointment volume over time
* Track revenue performance
* Understand treatment demand and pricing

> **Note:** Specific numerical findings should be added here after running the final SQL queries against the dataset.

---

## 🧠 Key SQL Concepts Demonstrated

```text
✓ SELECT / WHERE / ORDER BY
✓ GROUP BY / HAVING
✓ INNER JOIN / LEFT JOIN
✓ CASE WHEN
✓ Aggregate Functions
✓ CTEs
✓ Subqueries
✓ Window Functions
✓ RANK()
✓ NTILE()
✓ LAG()
✓ DATEDIFF()
✓ TIMESTAMPDIFF()
✓ COALESCE()
✓ Date & Time Analysis
✓ RFM Segmentation
```

---

## 📁 Project Structure

```text
hospital-operations-patient-analytics/
│
├── README.md
│
├── hospital_operations_patient_analytics.sql
│
├── hospital_data.xlsx
│
└── Hospital_Analytics_Report.pdf
```

---

## 🚀 Future Improvements

The project can be extended by:

* Building an interactive **Power BI dashboard**
* Adding KPIs for appointment, patient, and revenue performance
* Creating doctor workload dashboards
* Adding patient retention analysis
* Building automated reporting
* Adding more advanced patient segmentation

---

## 👤 Author

**Gourav Roy**

Data Analyst | SQL | Excel | Power BI | Python

This project was developed as part of a portfolio focused on **Data Analytics and SQL-based business analysis**.

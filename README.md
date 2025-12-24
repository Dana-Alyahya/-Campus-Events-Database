# Campus Events Database System

This project implements a **Campus Events Database System** designed to manage the scheduling, organization, and approval of campus events. The system models real-world event management requirements using relational database design principles and advanced SQL features.

---

## 📌 Project Overview

The database supports different types of campus events (academic, social, sports, and religious), venues, departments, organizers, and approval workflows. Events may include multiple sub-events, require administrative approval, and trigger automated actions upon approval.

The project focuses on **conceptual modeling**, **normalization**, and **robust SQL implementation**.

---

## 🗂️ Key Features

- Management of campus events with start/end date and time constraints  
- Event classification with specialized attributes  
- Support for multiple venue types (sports areas, lecture halls, conference halls, public spaces)  
- Department-sponsored events with responsible personnel  
- Event organization by faculty, students, staff, or dependents  
- Sub-events with assigned coordinators and allocated time  
- Approval workflow with rejection justification  
- Automated trigger to notify maintenance, office services, and security upon approval  
- Enforcement of scheduling rules (maximum duration and allowed time window)

---

## 🛠️ Technologies Used

- **MySQL**
- **SQL**
- **EER Modeling (Crow’s Foot notation)**
- **Stored Procedures**
- **Triggers**
- **Views**
- **BCNF Normalization**

---

## 📐 Database Design

- Designed a complete **Enhanced Entity Relationship (EER) diagram**
- Converted the conceptual model into a **logical schema**
- Normalized all relations through **1NF, 2NF, and BCNF**
- Implemented database constraints to ensure data integrity

---

## ⚙️ Implementation Details

- SQL `CREATE` statements for all tables and constraints  
- Triggers to automate system behavior on event approval  
- Stored procedures to initialize and populate the database  
- Sample data added for testing and validation  
- Test queries used to verify correctness and consistency

---

## ▶️ How to Run

1. Open MySQL Workbench (or any MySQL client)
2. Execute the SQL schema creation scripts
3. Run the stored procedure to populate the database
4. Execute test queries to explore and validate the system

---

## 🎓 Course Context

This project was developed as part of **ICS 321 – Database Systems** and demonstrates practical application of database design, normalization, and advanced SQL concepts.

---

## 👤 Author

**Dana Alyahya**  
Computer Science Student  

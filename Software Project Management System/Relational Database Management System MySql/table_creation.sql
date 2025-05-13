Create database miniproject;
use miniproject;

-- 1. Role (No dependencies)
CREATE TABLE Role (
    Role_ID INT PRIMARY KEY, -- Unique identifier for the role
    Role_Name ENUM('Project Manager', 'Frontend_developer', 'Backend_developer', 'Tester', 'Designer', 'Business_analyst', 'Devops') NOT NULL, -- Predefined roles
    Description TEXT -- Description of the role's responsibilities
);

-- 2. Client (No dependencies)
CREATE TABLE Client (
    Client_ID INT PRIMARY KEY, -- Unique identifier for the client
    Client_Name VARCHAR(255) NOT NULL, -- Name of the client
    Contact_person VARCHAR(255), -- Contact person for the client
    Client_email VARCHAR(255), -- Email address of the client
    Address TEXT, -- Address of the client
    Phone VARCHAR(15) -- Phone number of the client
);

-- 3. Employee (Depends on Role)
CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY, -- Unique identifier for the employee
    FirstName VARCHAR(255) NOT NULL, -- First name of the employee
    LastName VARCHAR(255) NOT NULL, -- Last name of the employee
    Supervisor_ID INT DEFAULT NULL, -- Employee ID of the supervisor (self-relation, NULL for PM)
    Role_ID INT, -- Role assigned to the employee
    Email VARCHAR(255) NOT NULL, -- Email address of the employee
    Phone VARCHAR(15), -- Phone number of the employee
    Join_date DATE, -- Date when the employee joined the organization
    FOREIGN KEY (Supervisor_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE,
    FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID) ON DELETE CASCADE
);

-- 4. Project (Depends on Client and Employee)
CREATE TABLE Project (
    Project_ID INT PRIMARY KEY, -- Unique identifier for the project
    Project_Name VARCHAR(255) NOT NULL, -- Name of the project
    Client_ID INT NOT NULL, -- Client associated with the project
    PM_ID INT NOT NULL, -- Employee ID of the project manager
    Status ENUM('Planned', 'Ongoing', 'Completed', 'Delayed', 'Cancelled') NOT NULL DEFAULT 'Planned', -- Current status of the project (e.g., Active)
    FOREIGN KEY (Client_ID) REFERENCES Client(Client_ID) ON DELETE CASCADE,
    FOREIGN KEY (PM_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE
);

-- 5. Project Summary (Depends on Project)
CREATE TABLE Project_Summary (
    Project_Summary_ID INT PRIMARY KEY, -- Unique identifier for the project summary
    Project_ID INT NOT NULL, -- Project associated with the summary
    Description TEXT, -- Detailed description of the project
    Start_Date DATE, -- Start date of the project
    End_Date DATE, -- End date of the project
    Budget_in_Dollar DECIMAL(10, 2) , -- Budget allocated for the project
    FOREIGN KEY (Project_ID) REFERENCES Project(Project_ID) ON DELETE CASCADE
);

-- 6. Tasks (Depends on Project)
CREATE TABLE Tasks (
    Task_ID INT PRIMARY KEY, -- Unique identifier for the task
    Project_ID INT NOT NULL, -- Project associated with the task
    Task_Name VARCHAR(255) NOT NULL, -- Name of the task
    Severity ENUM('Low', 'Medium', 'High') NOT NULL, -- Severity level of the task
    Estimated_Time DECIMAL(10, 2), -- Estimated time to complete the task (hours)
    Status ENUM('Pending', 'In Progress', 'Completed') NOT NULL, -- Current status of the task
    FOREIGN KEY (Project_ID) REFERENCES Project(Project_ID) ON DELETE CASCADE
);

-- 7. Task Assignment (Depends on Tasks and Employee)
CREATE TABLE Task_Assignment (
    Assignment_ID INT PRIMARY KEY, -- Unique identifier for the task assignment
    Task_ID INT NOT NULL, -- Task assigned
    PM_ID INT NOT NULL, -- Project manager assigning the task
    Employee_ID INT NOT NULL, -- Employee assigned to the task
    Due_Date DATE, -- Due date for task completion
    Assignment_Date DATE, -- Date the task was assigned
    Approval_status ENUM('Pending', 'Approved', 'Rejected') NOT NULL, -- Approval status of the task
    Completion_percentage DECIMAL(5, 2), -- Percentage of task completion
    FOREIGN KEY (Task_ID) REFERENCES Tasks(Task_ID) ON DELETE CASCADE,
    FOREIGN KEY (PM_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE
);

-- 8. Time Log (Depends on Task Assignment)
CREATE TABLE Time_Log (
    Log_ID INT PRIMARY KEY, -- Unique identifier for the time log
    Assignment_ID INT NOT NULL, -- Assignment associated with the log
    Log_date DATE, -- Date of the time log
    Actual_Time DECIMAL(10, 2), -- Actual time spent on the assignment (hours)
    FOREIGN KEY (Assignment_ID) REFERENCES Task_Assignment(Assignment_ID) ON DELETE CASCADE
);

-- 9. Project Team (Depends on Project and Employee)
CREATE TABLE Project_Team (
    Project_Member_ID INT PRIMARY KEY, -- Unique identifier for the project team member
    Project_ID INT NOT NULL, -- Project associated with the team
    Employee_ID INT NOT NULL, -- Employee assigned to the team
    PM_ID INT NOT NULL, -- Project manager of the team
    Assigned_Date DATE, -- Date the employee joined the team
    End_date DATE, -- Date the employee left the team
    FOREIGN KEY (Project_ID) REFERENCES Project(Project_ID) ON DELETE CASCADE,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE,
    FOREIGN KEY (PM_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE
);

-- 10. Feedback (Depends on Task Assignment)
CREATE TABLE Feedback (
    Feedback_ID INT PRIMARY KEY,  -- Unique identifier for feedback
    Assignment_ID INT NOT NULL,  -- Links to a specific task assignment
    Feedback_Date DATE,  -- Date the feedback was given
    Feedback_Comments TEXT,  -- Feedback details
    FOREIGN KEY (Assignment_ID) REFERENCES Task_Assignment(Assignment_ID) ON DELETE CASCADE
);


-- 11. KPI (Depends on Project and Employee)
CREATE TABLE KPI (
    KPI_ID INT PRIMARY KEY, -- Unique identifier for the KPI entry
    Project_ID INT NOT NULL, -- Project associated with the KPI
    Employee_ID INT NOT NULL, -- Employee associated with the KPI
    Total_Actual_Time DECIMAL(10, 2), -- Total actual time spent on tasks
    Total_Estimated_Time DECIMAL(10, 2), -- Total estimated time for tasks
    Employee_Rating DECIMAL(5, 2), -- Rating of the employee's performance
    Total_tasks_Assigned INT, -- Total number of tasks assigned to the employee
    Total_Tasks_Completed INT, -- Number of tasks completed by the employee
    FOREIGN KEY (Project_ID) REFERENCES Project(Project_ID) ON DELETE CASCADE,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE
);


ALTER TABLE Project 
MODIFY COLUMN Status ENUM('Planned', 'Ongoing', 'Completed', 'Delayed', 'Cancelled') NOT NULL DEFAULT 'Planned';

Select * from Role;

ALTER TABLE Project_Summary 
CHANGE COLUMN Start_date Start_Date  DATE;

ALTER TABLE Project_Summary 
CHANGE COLUMN End_date End_Date  DATE;

ALTER TABLE Project_Team
CHANGE COLUMN  assigned_Date Assigned_Date DATE;

ALTER TABLE Project_Team
CHANGE COLUMN  End_date End_Date  DATE;

ALTER TABLE Project_Summary
CHANGE COLUMN  Budget_in_Dollar  Budget_in_Dollar DECIMAL(10, 2) NOT NULL ;


Select * from Tasks;

SET SQL_SAFE_UPDATES =0;

Delete from Time_Log;

ALTER TABLE Task_Assignment
DROP FOREIGN KEY Task_Assignment_ibfk_1;


ALTER TABLE Tasks
MODIFY COLUMN Task_ID INT AUTO_INCREMENT;

ALTER TABLE Task_Assignment
ADD CONSTRAINT Task_Assignment_ibfk_1
FOREIGN KEY (Task_ID) REFERENCES Tasks(Task_ID) ON DELETE CASCADE;

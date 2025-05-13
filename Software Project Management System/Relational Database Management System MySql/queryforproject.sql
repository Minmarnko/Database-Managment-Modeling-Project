-- st125166 Soe Htet Naing 
-- 3 Transactions
-- insert/ view / update status of a certain project ID
INSERT INTO Project (Project_ID, Project_Name, Client_ID, PM_ID, Status)
VALUES (151, 'Building DB project', 20, 3, 'Planned');

UPDATE Project
SET Status = 'Ongoing'
WHERE Project_ID = 151;

SELECT Project_ID, Project_Name, Status
FROM Project
WHERE Project_ID = 151;

-- insert/ View/Update status of a certain project’s task
INSERT INTO Tasks (Task_ID, Project_ID, Task_Name, Severity, Estimated_Time, Status)
VALUES (1001, 151, 'make connection', 'High', 8, 'Pending');

UPDATE Tasks
SET Status = 'In Progress'
WHERE Task_ID = 1001;

SELECT Task_ID, Task_Name, Status
FROM Tasks
WHERE Task_ID = 1001;

-- Insert/Update/View Team members information of project.
INSERT INTO Project_Team (Project_Member_ID, Project_ID, Employee_ID, PM_ID, Assigned_Date, End_Date)
VALUES (612, 151, 50, 3, '2025-02-01', '2025-04-01');

UPDATE Project_Team
SET End_Date = '2025-03-01'
WHERE Project_Member_ID = 612;

SELECT Employee_ID, FirstName, LastName, Role_ID, Supervisor_ID, Email, Phone, Join_date
FROM Employee
WHERE Employee_ID IN (
    SELECT Employee_ID
    FROM Project_Team
    WHERE Project_ID = 151
);

-- 6 reports
-- Query average time taken for each project to complete tasks
SELECT 
    t.Project_ID,
    p.Project_Name,
    AVG(tl.Actual_Time) AS Average_Time_Taken
FROM 
    Tasks t
JOIN 
    Task_Assignment ta ON t.Task_ID = ta.Task_ID
JOIN 
    Time_Log tl ON ta.Assignment_ID = tl.Assignment_ID
JOIN 
    Project p ON t.Project_ID = p.Project_ID
GROUP BY 
    t.Project_ID;

-- Query activity log for each project by certain project manager.
SELECT 
    p.Project_Name,
    t.Task_Name,
    tl.Log_date,
    tl.Actual_Time,
    p.PM_ID
FROM 
    Time_Log tl
JOIN 
    Task_Assignment ta ON tl.Assignment_ID = ta.Assignment_ID
JOIN 
    Tasks t ON ta.Task_ID = t.Task_ID
JOIN 
    Project p ON t.Project_ID = p.Project_ID
WHERE 
    p.Status = 'Ongoing'  
    AND p.PM_ID = 2 
ORDER BY 
    p.Project_Name, tl.Log_date DESC;


    

-- Query top high priority tasks with status pending of ongoing project with nearest due date
SELECT 
    t.Task_Name,
    ps.Description AS Task_Description,
    t.Severity,
    t.Status,
    p.Status AS Project_Status,
    ta.Due_Date
FROM 
    Tasks t
JOIN 
    Project p ON t.Project_ID = p.Project_ID
JOIN 
    Project_Summary ps ON t.Project_ID = ps.Project_ID
JOIN 
    Task_Assignment ta ON t.Task_ID = ta.Task_ID
WHERE 
    t.Severity = 'High'
    AND t.Status = 'Pending'
    AND p.Status = 'Ongoing'  -- Only include tasks from ongoing projects
    AND ta.Due_Date >= CURDATE()  -- Only tasks with due dates from today onwards
ORDER BY 
    ta.Due_Date ASC  -- Sort by nearest due date
LIMIT 10;


-- Query task that needs to be assigned by project manager 1.
SELECT 
    t.Task_ID,
    t.Task_Name,
    p.Project_Name,
    t.Status,
    pr.PM_ID
FROM 
    Tasks t
JOIN 
    Project p ON t.Project_ID = p.Project_ID
JOIN 
    Project pr ON p.Project_ID = pr.Project_ID
WHERE 
    t.Status = 'Pending'
    AND pr.PM_ID = 1;

-- Query projects with most budgets and least budgets
(
    SELECT 
        p.Project_Name, 
        ps.Budget_in_Dollar
    FROM 
        Project p
    JOIN 
        Project_Summary ps ON p.Project_ID = ps.Project_ID
    ORDER BY 
        ps.Budget_in_Dollar DESC
    LIMIT 1  -- Highest budget project
)
UNION
(
    SELECT 
        p.Project_Name, 
        ps.Budget_in_Dollar
    FROM 
        Project p
    JOIN 
        Project_Summary ps ON p.Project_ID = ps.Project_ID
    ORDER BY 
        ps.Budget_in_Dollar ASC
    LIMIT 1  -- Lowest budget project
);

-- Query detailed overview of task progress and time metrics for total tasks of  project
SELECT 
    p.Project_Name,
    COUNT(CASE WHEN t.Status = 'Completed' THEN 1 END) AS Completed_Tasks,
    COUNT(CASE WHEN t.Status != 'Completed' THEN 1 END) AS Remaining_Tasks,
    SUM(t.Estimated_Time) AS Total_Estimated_Time,
    SUM(tl.Actual_Time) AS Total_Actual_Time
FROM 
    Project p
JOIN 
    Tasks t ON p.Project_ID = t.Project_ID
LEFT JOIN 
    Task_Assignment ta ON t.Task_ID = ta.Task_ID
LEFT JOIN 
    Time_Log tl ON ta.Assignment_ID = tl.Assignment_ID
WHERE 
    p.Status = 'Ongoing'  -- Only include ongoing projects
GROUP BY 
    p.Project_Name
ORDER BY 
    Remaining_Tasks DESC;  -- Order by most remaining tasks first

    

-- Min Marn Ko-st125437 –
-- 17. Identifying Tasks Past Deadlines with Responsible Team Members
SELECT 
    T.Task_ID, 
    T.Task_Name, 
    T.Status, 
    TA.Due_Date, 
    E.Employee_ID, 
    CONCAT(E.FirstName, ' ', E.LastName) AS Employee_Name,
    P.Project_Name
FROM Tasks T
JOIN Task_Assignment TA ON T.Task_ID = TA.Task_ID
JOIN Employee E ON TA.Employee_ID = E.Employee_ID
JOIN Project P ON T.Project_ID = P.Project_ID
WHERE TA.Due_Date < CURDATE() AND T.Status <> 'Completed'
ORDER BY TA.Due_Date ASC;



-- 18. Proportion of Task Status (Completed, In-Progress, Pending) Across Projects
SELECT 
    P.Project_ID,
    P.Project_Name,
    COUNT(T.Task_ID) AS Total_Tasks,
    SUM(CASE WHEN T.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Tasks,
    SUM(CASE WHEN T.Status = 'In Progress' THEN 1 ELSE 0 END) AS In_Progress_Tasks,
    SUM(CASE WHEN T.Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Tasks,
    ROUND((SUM(CASE WHEN T.Status = 'Completed' THEN 1 ELSE 0 END) / COUNT(T.Task_ID)) * 100, 2) AS Completed_Percentage,
    ROUND((SUM(CASE WHEN T.Status = 'In Progress' THEN 1 ELSE 0 END) / COUNT(T.Task_ID)) * 100, 2) AS In_Progress_Percentage,
    ROUND((SUM(CASE WHEN T.Status = 'Pending' THEN 1 ELSE 0 END) / COUNT(T.Task_ID)) * 100, 2) AS Pending_Percentage
FROM Project P
LEFT JOIN Tasks T ON P.Project_ID = T.Project_ID
GROUP BY P.Project_ID, P.Project_Name
ORDER BY P.Project_ID;



-- 19. Delayed Projects Beyond Planned Deadlines
SELECT 
    P.Project_ID, 
    P.Project_Name, 
    P.Status, 
    PS.End_Date AS Planned_Deadline,
    DATEDIFF(CURDATE(), PS.End_Date) AS Days_Delayed
FROM Project P
JOIN Project_Summary PS ON P.Project_ID = PS.Project_ID
WHERE (P.Status = 'Delayed' OR P.Status = 'Ongoing') 
      AND PS.End_Date < CURDATE()
ORDER BY Days_Delayed DESC;


-- 20. Task Completion Rate by Priority Level
SELECT 
    T.Severity AS Task_Priority,
    COUNT(T.Task_ID) AS Total_Tasks,
    SUM(CASE WHEN T.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Tasks,
    ROUND((SUM(CASE WHEN T.Status = 'Completed' THEN 1 ELSE 0 END) / COUNT(T.Task_ID)) * 100, 2) AS Completion_Rate_Percentage
FROM Tasks T
GROUP BY T.Severity
ORDER BY Completion_Rate_Percentage DESC;

-- 21. Longest Time Taken to Complete Tasks
SELECT 
    T.Task_ID, 
    T.Task_Name, 
    P.Project_Name, 
    T.Severity AS Task_Priority, 
    TA.Assignment_Date, 
    TL.Log_date AS Completion_Date, 
    DATEDIFF(TL.Log_date, TA.Assignment_Date) AS Days_Taken
FROM Tasks T
JOIN Task_Assignment TA ON T.Task_ID = TA.Task_ID
JOIN Time_Log TL ON TA.Assignment_ID = TL.Assignment_ID
JOIN Project P ON T.Project_ID = P.Project_ID
WHERE T.Status = 'Completed'
ORDER BY Days_Taken DESC
LIMIT 10;



-- View/Update feedbacks of team members ( eg. Comments )
SELECT 
    F.Feedback_ID, 
    E.Employee_ID, 
    CONCAT(E.FirstName, ' ', E.LastName) AS Employee_Name, 
    P.Project_Name,
    T.Task_Name, 
    F.Feedback_Date, 
    F.Feedback_Comments
FROM Feedback F
JOIN Task_Assignment TA ON F.Assignment_ID = TA.Assignment_ID
JOIN Employee E ON TA.Employee_ID = E.Employee_ID
JOIN Tasks T ON TA.Task_ID = T.Task_ID
JOIN Project P ON T.Project_ID = P.Project_ID
ORDER BY F.Feedback_Date DESC;


-- View activity log of each task
SELECT 
    T.Task_ID, 
    T.Task_Name, 
    P.Project_Name, 
    TA.Employee_ID, 
    CONCAT(E.FirstName, ' ', E.LastName) AS Employee_Name, 
    TL.Log_ID, 
    TL.Log_date, 
    TL.Actual_Time
FROM Tasks T
JOIN Task_Assignment TA ON T.Task_ID = TA.Task_ID
JOIN Employee E ON TA.Employee_ID = E.Employee_ID
JOIN Time_Log TL ON TA.Assignment_ID = TL.Assignment_ID
JOIN Project P ON T.Project_ID = P.Project_ID
ORDER BY TL.Log_date DESC;


-- Create/update/remove/view clients information.
INSERT INTO Client (Client_ID, Client_Name, Contact_person, Client_email, Address, Phone)
VALUES (101, 'ABC Corporation', 'John Doe', 'johndoe@abc.com', '123 Main Street, NY', '+1-555-1234');
SELECT * FROM Client WHERE Client_ID = 101;
	


-- Sonakul kamnuanchai-st124738 –
-- Transaction:
INSERT INTO Project (Project_ID,Project_Name, Client_ID, PM_ID, Status)
VALUES (152,'New Project', 1, 1, 'Ongoing');

UPDATE Tasks
SET Task_Name = 'Updated Task Name'
WHERE Project_ID = 1
  AND Task_ID = 1; 

UPDATE Tasks
SET Status = 'In Progress'
WHERE Project_ID = 66
  AND Task_ID = 1;



-- 1.The project manager wants to see team members based on performance.
SELECT 
    p.Project_ID, 
    p.Project_Name, 
    e.FirstName || ' ' || e.LastName as FullName, 
    ta.Completion_percentage,
    r.Role_Name as Role
FROM Project p
JOIN Tasks t ON p.Project_ID = t.Project_ID
JOIN Task_Assignment ta ON t.Task_ID = ta.Task_ID
JOIN Employee e ON ta.Employee_ID = e.Employee_ID
JOIN Role r ON e.Role_ID = r.Role_ID
order by ta.Completion_percentage desc

-- 2.The project manager wants to see top clients.

SELECT c.Client_ID,
    c.Client_Name,
    COUNT(DISTINCT p.Project_ID) AS Project_Count
FROM Client c
JOIN Project p ON c.Client_ID = p.Client_ID
GROUP BY c.Client_ID, c.Client_Name
ORDER BY Project_Count DESC
LIMIT 10;

-- 3.The project manager wants to see who is assigned to multiple projects.
SELECT 
    ta.Employee_ID,
    e.FirstName || ' ' || e.LastName as FullName,
    COUNT(DISTINCT p.Project_ID) AS Project_Count
FROM Task_Assignment ta
JOIN Tasks t ON ta.Task_ID = t.Task_ID
JOIN Project p ON t.Project_ID = p.Project_ID
JOIN Employee e ON ta.Employee_ID = e.Employee_ID
GROUP BY ta.Employee_ID, e.FirstName
HAVING COUNT(DISTINCT p.Project_ID) > 1
ORDER BY Project_Count DESC;

-- 4.The project manager wants to analyze where the project was cancelled and evaluate which employees performed badly.
SELECT 
    p.Project_ID, 
    p.Project_Name, 
    e.FirstName || ' ' || e.LastName as FullName, 
    ta.Completion_percentage,
    r.Role_Name as Role
FROM Project p
JOIN Tasks t ON p.Project_ID = t.Project_ID
JOIN Task_Assignment ta ON t.Task_ID = ta.Task_ID
JOIN Employee e ON ta.Employee_ID = e.Employee_ID
JOIN Role r ON e.Role_ID = r.Role_ID
WHERE p.Status = 'Cancelled'
order by ta.Completion_percentage
Limit 5;

-- 5.The project manager wants to find employees with the role who are available with the highest rating.
SELECT 
    e.Employee_ID, 
    e.FirstName || ' ' || e.LastName as FullName,
    r.Role_Name,
    k.Employee_rating
FROM Employee e
JOIN Role r ON e.Role_ID = r.Role_ID
JOIN KPI k ON e.Employee_ID = k.Employee_ID
WHERE r.Role_Name = 'Business_analyst' or r.Role_Name = 'Backend_developer' or r.Role_Name = 'Frontend_developer'
ORDER BY k.Employee_rating DESC;


-- Phue Pwint Thwe-st124784 --
-- 1. View Team Members with a certain role
SELECT E.Employee_ID, E.FirstName, E.LastName, R.Role_Name
FROM Employee E
JOIN Role R ON E.Role_ID = R.Role_ID
WHERE R.Role_Name = 'Designer';

-- 2. View Task Progress and Assigned Team Members
SELECT T.Task_ID, T.Task_Name, TA.Completion_percentage, E.FirstName AS Assigned_Member
FROM Task_Assignment TA
JOIN Tasks T ON TA.Task_ID = T.Task_ID
JOIN Employee E ON TA.Employee_ID = E.Employee_ID
WHERE T.Project_ID = 1;

-- 3. View Feedbacks from Project Manager 
SELECT 
    F.Feedback_ID, 
    F.Feedback_date, 
    F.Feedback_Comments, 
    E.FirstName AS Project_Manager
FROM Feedback F JOIN Task_Assignment TA ON F.Assignment_ID = TA.Assignment_ID
JOIN Employee E ON TA.PM_ID = E.Employee_ID
ORDER BY F.Feedback_date DESC;

-- Report --
-- 1. Project Manager Checks Workload for Project Members
SELECT E.Employee_ID, E.FirstName, E.LastName, COUNT(TA.Task_ID) AS Total_Tasks
FROM Employee E
JOIN Task_Assignment TA ON E.Employee_ID = TA.Employee_ID
GROUP BY E.Employee_ID, E.FirstName, E.LastName
ORDER BY Total_Tasks DESC;

-- 2. Check Team Member Workload Based on Task Priority and Estimated Time
SELECT E.Employee_ID, E.FirstName, E.LastName, T.Severity AS Task_Priority, SUM(T.Estimated_Time) AS Total_Estimated_Time
FROM Employee E
JOIN Task_Assignment TA ON E.Employee_ID = TA.Employee_ID
JOIN Tasks T ON TA.Task_ID = T.Task_ID
GROUP BY E.Employee_ID, T.Severity
ORDER BY Total_Estimated_Time DESC;

-- 3. Identify Team Member Roles with Highest or Lowest Performance
SELECT 
    R.Role_Name,
    COUNT(K.KPI_ID) AS Total_Employees,
    AVG(K.Employee_Rating) AS Avg_Employee_Rating,
    SUM(K.Total_Tasks_Completed) AS Total_Tasks_Completed,
    SUM(K.Total_tasks_Assigned) AS Total_Tasks_Assigned
FROM KPI K JOIN Employee E ON K.Employee_ID = E.Employee_ID
JOIN Role R ON E.Role_ID = R.Role_ID
GROUP BY R.Role_Name
ORDER BY Avg_Employee_Rating DESC;

-- 4. Retrieve Ongoing Projects with the Highest Number of Tasks
SELECT P.Project_ID, P.Project_Name, COUNT(T.Task_ID) AS Total_Tasks
FROM Project P
JOIN Tasks T ON P.Project_ID = T.Project_ID
WHERE P.Status = 'Ongoing'
GROUP BY P.Project_ID, P.Project_Name
ORDER BY Total_Tasks DESC;

-- 5.Check Completed Projects Quarterly
SELECT YEAR(PS.End_date) AS Year, QUARTER(PS.End_date) AS Quarter, COUNT(PS.Project_ID) AS Planned_Projects
FROM Project_Summary PS
JOIN Project P ON PS.Project_ID = P.Project_ID
WHERE P.Status = 'Planned'
GROUP BY YEAR(PS.End_date), QUARTER(PS.End_date)
ORDER BY Year, Quarter;

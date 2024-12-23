# Problem 1 : Rank Scores (https://leetcode.com/problems/rank-scores/ )

# 1st Solution
SELECT score, DENSE_RANK() OVER(ORDER BY score DESC) AS 'rank' 
FROM Scores

# 2nd Solution
SELECT s1.score, 
    (
    SELECT COUNT(DISTINCT s2.score) 
    FROM scores s2 
    WHERE s2.score >= s1.score
    ) AS 'rank' 
FROM Scores s1
ORDER BY s1.score DESC

# 3rd Solution
SELECT s.score, COUNT(DISTINCT t.score) AS 'rank'
FROM Scores s
INNER JOIN Scores t
ON s.score <= t.score
GROUP BY s.score, s.id
ORDER BY s.score DESC

# Problem 2 : Exchange Seats (https://leetcode.com/problems/exchange-seats/ )

# 1st solution
SELECT 
    CASE 
        WHEN id % 2 = 1 AND id != cnt THEN id+1
        WHEN id % 2 = 1 AND id = cnt THEN id
        ELSE id-1
    END AS 'id', student 
FROM Seat, (SELECT COUNT(id) AS 'cnt' FROM Seat) AS seat_count
ORDER BY id;

# 2nd solution
SELECT 
    CASE 
        WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM seat) THEN id
        WHEN id % 2 = 1 THEN id+1
        ELSE id-1
    END AS 'id', student 
FROM Seat
ORDER BY id;

# 3rd solution
SELECT s1.id, COALESCE(s2.student, s1.student) AS student 
FROM Seat s1
LEFT JOIN Seat s2
ON (s1.id + 1) ^ 1 - 1 = s2.id;

# Problem 3 : Tree Node (https://leetcode.com/problems/tree-node/ )

# 1st Solution
SELECT id, 
    CASE
        WHEN p_id IS NULL THEN 'Root'
        WHEN id NOT IN (SELECT p_id FROM Tree WHERE p_id IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END as 'type'
FROM Tree    

# 2nd Solution
SELECT id, 
    CASE
        WHEN p_id IS NULL THEN 'Root'
        WHEN id IN (SELECT p_id FROM Tree) THEN 'Inner'
        ELSE 'Leaf'
    END as 'type'
FROM Tree    

# 3rd Solution
    SELECT id, 'Root' AS type
    FROM Tree
    WHERE p_id IS NULL
UNION 
    SELECT id, 'Leaf' AS type
    FROM Tree
    WHERE id NOT IN (
        SELECT p_id
        FROM Tree
        WHERE p_id IS NOT NULL
    ) AND p_id IS NOT NULL
UNION
    SELECT id, 'Inner' AS type
    FROm Tree
    WHERE id IN (
        SELECT p_id
        FROM Tree
        WHERe p_id IS NOT NULL
    ) AND p_id IS NOT NULL

# 4th Solution
SELECT id, 
    IF (p_id IS NULL, 'Root' , IF(id IN (SELECT p_id FROM Tree), 'Inner', 'Leaf')) AS type
FROM Tree

# Problem 4 : Deparment Top 3 Salaries (https://leetcode.com/problems/department-top-three-salaries/ )

# 1st Solution
WITH temp AS
(
    SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary, 
        DENSE_RANK() OVER(PARTITION BY d.id ORDER BY e.salary DESC) AS ranks
    FROM Employee e
    JOIN Department d
    ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM temp
WHERE ranks IN (1,2,3)

# 2nd Solution
SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary 
FROM Employee e
JOIN Department d
ON e.departmentId = d.id
WHERE 3 > (SELECT COUNT(DISTINCT e2.salary) 
            FROM Employee e2 
            WHERE e.salary < e2.salary AND e.departmentId = e2.departmentId)

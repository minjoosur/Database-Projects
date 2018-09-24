DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst ~ ' '
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, count(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, count(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, yearid
  from people, halloffame
  WHERE people.playerid = halloffame.playerid and inducted = 'Y'
  ORDER BY yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, schools.schoolid, halloffame.yearid
  FROM people, halloffame, schools, collegeplaying
  WHERE people.playerid = halloffame.playerid 
  and halloffame.playerid=collegeplaying.playerid 
  and collegeplaying.schoolid = schools.schoolid
  and inducted = 'Y'
  and schoolstate = 'CA'
  ORDER BY yearid DESC, schoolid, people.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, q2i.namefirst, q2i.namelast, schoolid
  FROM q2i LEFT OUTER JOIN collegeplaying on q2i.playerid = collegeplaying.playerid
  ORDER BY q2i.playerid DESC, schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT batting.playerid, namefirst, namelast, yearid, (h+ h2b + h3b*2 + hr*3)::float / ab as slg
  FROM people, batting
  WHERE people.playerid = batting.playerid
  AND ab > 50
  ORDER BY slg DESC, yearid, batting.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT batting.playerid, namefirst, namelast, (SUM(h) + SUM(h2b) + SUM(h3b)*2 + SUM(hr)*3)::float / SUM(ab::float) as lslg
  FROM people, batting
  WHERE people.playerid = batting.playerid
  GROUP BY batting.playerid, namefirst, namelast
  HAVING SUM(ab) > 50
  ORDER BY lslg DESC, playerid ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  FROM
  (  
    SELECT batting.playerid, namefirst, namelast, (SUM(h) + SUM(h2b) + SUM(h3b)*2 + SUM(hr)*3)::float / SUM(ab::float) as lslg
    FROM people, batting
    WHERE people.playerid = batting.playerid
    GROUP BY batting.playerid, namefirst, namelast
    HAVING SUM(ab) > 50
  ) AS records
  WHERE lslg > (
    SELECT (SUM(h) + SUM(h2b) + SUM(h3b)*2 + SUM(hr)*3)::float / SUM(ab::float)
    FROM batting
    WHERE playerid='mayswi01'
    GROUP BY playerid
    )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, min(salary), max(salary), avg(salary), stddev(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
SELECT buckets-1, min(min)+(buckets-1)*((max(max)-min(min))/10) as low, min(min)+(buckets)*((max(max)-min(min))/10) as high, count(*)
FROM(
  SELECT width_bucket(salary, min, max+1, 10) as buckets, min, max
  FROM salaries, 
    ( 
      SELECT min(salary), max(salary)
      FROM salaries
      WHERE yearid=2016
    ) as minmax
  WHERE yearid=2016
  ) as histogram
  GROUP BY buckets
  ORDER BY buckets
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT second.yearid, second.min-first.min as mindiff, second.max-first.max as maxdiff, second.avg-first.avg as avgdiff
  FROM (
    SELECT yearid, max(salary), min(salary), AVG(salary)
    FROM salaries
    GROUP BY yearid
    ORDER BY yearid
    ) as first INNER JOIN 
  (
    SELECT yearid, max(salary), min(salary), AVG(salary)
    FROM salaries
    GROUP BY yearid
    ORDER BY yearid
    ) as second
  ON second.yearid - 1 = first.yearid
  ORDER BY yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT salaries.playerid, namefirst, namelast, maxsalary.salary, maxsalary.yearid
  FROM (
    SELECT yearid, max(salary) as salary
    FROM salaries
    GROUP BY yearid
    HAVING yearid=2000 or yearid=2001
    ) as maxsalary, people, salaries
  WHERE salaries.salary = maxsalary.salary
  AND salaries.yearid = maxsalary.yearid
  AND salaries.playerid = people.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT allstarfull.teamid as team, max(salary)-min(salary) as diffAvg
  FROM allstarfull, salaries
  WHERE allstarfull.yearid=2016
  AND salaries.yearid=2016
  AND allstarfull.playerid=salaries.playerid
  GROUP BY allstarfull.teamid
  ORDER BY team
;


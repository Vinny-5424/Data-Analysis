SELECT TOP (1000) [EmployeeID]
      ,[JobTitle]
      ,[Salary]
  FROM [sqltutorial].[dbo].[EmployeeSalary]


Select *
from sqltutorial.dbo.EmployeeDemographics
where Gender = 'Male' and FirstName = 'Stephen'


select *
from EmployeeDemographics
where LastName like '%a%'

select *
from EmployeeDemographics
where FirstName is not null

select *
from EmployeeDemographics
where FirstName in ('Stephen', 'Scott', 'James')

--GROUP-BY AND ORDER-BY STATEMENTS 

Select Gender, count(Gender) as GenderCount
from EmployeeDemographics
group by Gender

Select Gender, Age, count(Gender) as GenderCount
from EmployeeDemographics
group by Gender, Age

Select Gender, count(Gender) as GenderCount
from EmployeeDemographics
where age > 31
group by Gender
order by GenderCount 

Select Gender, count(Gender) as GenderCount
from EmployeeDemographics
where age > 31
group by Gender
order by GenderCount desc

Select *
from EmployeeDemographics
order by gender, age

Select *
from EmployeeDemographics
order by gender, age desc
select* from EmployeeDemographics	
select* from EmployeeSalary


-- INTERMEDIATE		LEVEL
/*JOIN - is used to combine multiple tables to give an output*/


-- INNER JOIN: It picks the common keys

Select * 
from sqltutorial.dbo.EmployeeDemographics
inner Join sqltutorial.dbo.EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

--Left outer join : It joins based on the left table's keys

Select * 
from sqltutorial.dbo.EmployeeDemographics
left outer join sqltutorial.dbo.EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

--Right outer join : It joins based on the right table's keys

Select * 
from sqltutorial.dbo.EmployeeDemographics
right outer join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

Select  EmployeeSalary.EmployeeID, FirstName, LastName, JobTitle, Salary
from sqltutorial.dbo.EmployeeDemographics
right outer join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


/*To know the employee that earns the highest salary by showing the order and exemptimg the CEO*/

select EmployeeDemographics.EmployeeID, FirstName, LastName, Salary
from EmployeeDemographics
inner join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
where FirstName <> 'Akintade'
order by Salary desc


/* To know the average salaries of the all official positions*/
Select Jobtitle, avg(Salary) as AverageSalary
from EmployeeDemographics
inner join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
group by JobTitle



/*UNIONS - it selects all the data from all the tables and combine them as an output. It is basically used for data of same data entries. */
/*UNION ALL - It gives all outputs even if they are replicates.*/

Select EmployeeID, FirstName, Age
from EmployeeDemographics
union
select EmployeeID, JobTitle, Salary
from EmployeeSalary
order by EmployeeID
	
/*CASE STAREMENT - It allows to specify condition in return a particular output */

/* Detecting the age bracket of employees*/
select FirstName, LastName, Age,
case
	when Age > 30 then 'Old'
	else 'Young'
end as AgeBracket
from EmployeeDemographics
where Age is not null
order by Age

/* Simple Mathematical Case */

select FirstName, LastName, JobTitle, Salary,
case
	When JobTitle = 'Salesman' then Salary +(salary * .1)
	When JobTitle = 'Accountant' then Salary +(salary * .1)
	When JobTitle = 'HR' then Salary +(salary * .001)
	else salary + (Salary * .03)
	end as NewSalary
from EmployeeDemographics
join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID



/* HAVING STAEMENT - This is use to perform conditional operation on group after aggregation. This is done after grouping and oredering comes after it.*/

--Example 1
Select JobTitle, count(JobTitle)
from EmployeeDemographics
join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
group by JobTitle 
Having Count(JobTitle) > 1

--Example 2
select JobTitle, avg(Salary) as AvgSalary
from EmployeeDemographics
join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
group by JobTitle
Having avg(Salary) > 45000
order by AvgSalary 

select * 
from EmployeeDemographics

/* UPDATING - This edits the table at a particular section. */
update EmployeeDemographics
set Age = 31
where EmployeeID = 1013

/* DELETION : It removes an entire rows. */
delete from EmployeeDemographics
where EmployeeID = 1013

/* ALIASING: It is temporarily changing the column name of a script. */

-- Cahnging the column name in a table
select  FirstName as FName
from EmployeeDemographics

-- Combining the Fisrt name and the Last name as a full name.

select FirstName + ' ' + LastName as FullName
from EmployeeDemographics


-- Aliasing the table name
select Demo.FirstName + ' ' + Demo.LastName as FullName
from EmployeeDemographics as Demo  

/*PARTITION BY: it divides into partitions and indicates the total number of members in each category*/

Select Firstname, LastName, Gender, Salary,
count(Gender) over (partition by Gender) as TotalGender
from EmployeeDemographics
join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


/* CTE(Common table Expression): It is used to manipulate complex data. It is only created in memory; it is not in the database permanenetly. Also, it can be accessed by the one select statement after it only.*/

with CTE_Employee as(
	Select FirstName, LastName, Gender, Salary,
	count(Gender) over (partition by Gender) as TotalGender,
	avg(Salary) over (partition by Gender) as AvgSalary
	from EmployeeDemographics 
	join EmployeeSalary
		on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
	where Salary > 45000
)

select FirstName, AvgSalary
from CTE_Employee



/*TEMPORARY TABLES: It is just a table that is stored for a short period of time. It is identified by the "#" sign.*/

create table #temp_Employee(
EmployeeID int,
jobTitle varchar(50),
Salary int)

select * from #temp_Employee

Insert into #temp_Employee VAlues(
'1001', 'HR', 4000)

-- inputing a table as a data into another table
insert into #temp_Employee
Select * from EmployeeSalary

-- I have to delete one of the two 1001s because it is a primary key 
delete from #temp_Employee where EmployeeID = 1001 and jobTitle = 'Salesman'

--Manipulating a table as it is inserted into another table

drop table if exists #Temp_Employee2/*This is to erase the data in the temp table and input new ones.*/
--Creating the temp table
Create table #Temp_Employee2(
JobTitle varchar(50),
EmployeePerJob int,
Avgage int,
Avgsalary int)

--Inserting data into the table
Insert into #Temp_Employee2
select JobTitle, count(JobTitle), avg(Age), avg(Salary)
from EmployeeDemographics
join EmployeeSalary
	on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
group by JobTitle

select * from #Temp_Employee2

/*STRING FUNCTIONS - TRIM, LTRIM, RTRIM, REPLACE, SUBSTRING, UPPER, LOWER*/

--creating the table
Create table EmployeeError(
EmployeeID varchar(50),
FirstName varchar(50),
LastName varchar(50)
)

--Inserting values
insert  into EmployeeError values
('1001  ', 'Jimbo', 'Albert'),
('   1002', 'Tboy', 'Flenderson -Fired'),
('1003 ', 'Pamela', 'Peace')

--Viewing the table
select * from EmployeeError

--EDITING THE TABLE

-- 1. Using TRIMs(Left and Right)
select EmployeeID, trim(EmployeeID) as IDTRIM
from EmployeeError

select EmployeeID, rtrim(EmployeeID) as IDTRIM
from EmployeeError

select EmployeeID, ltrim(EmployeeID) as IDTRIM
from EmployeeError

-- 2. Using REPLACE
Select LastName, Replace(Lastname, ' -Fired', '') as LastNameFixed
from EmployeeError

-- 3. Using SUBSTRING
Select substring(FirstName,1,3)/*It return the First three characters, from index 1, of each element in the First*/
from EmployeeError
/*You can join two tables by matching substrings similar entities */

-- 4. Using UPPER and LOWER
Select FirstName, Upper(FirstName)
from EmployeeError

Select FirstName, lower(FirstName)
from EmployeeError

/*STORED PROCEDURE: This is a group of statements that has been created and stored in a database. It can be used by different over the network by different users using different inputs.*/
--EXAMPLE 1
--Creating the procedure
create procedure TEST
as
Select *
from EmployeeDemographics

--Using the stored procedure
Exec Test

--EXAMPLE 2
Create procedure Temp_Employee
as
Create table #temp_employee3(
JobTitle varchar(100),
EmployeePerJob int,
Avgage int,
Avgsalary int)

insert into #temp_employee3
select JobTitle, count(JobTitle), avg(Age), avg(Salary)
from sqltutorial..EmployeeDemographics
join sqltutorial..EmployeeSalary
	on sqltutorial..EmployeeDemographics.EmployeeID = sqltutorial..EmployeeSalary.EmployeeID
group by JobTitle

select *
from #temp_employee3

EXEC Temp_Employee

-- After modification of a Stored Procedure, this is how to execute it.
--Note: This particular one was modiified to accept a value for an entity.

EXEC Temp_Employee @JobTitle ='Salesman'


/*SUBQUERIES: They are used to return data to a particular part of a query.*/

-- Subquery in the select statement

Select EmployeeID, Salary,(Select  avg(Salary) from EmployeeSalary) as AvgSalary
from EmployeeSalary

--or
Select EmployeeID, Salary, avg(Salary) over() as AvgSalary
from EmployeeSalary

-- Subquery in From Statement
Select EmployeeID, AvgSalary
from (Select EmployeeID, Salary, Avg(Salary) over() as AvgSalary
	  from EmployeeSalary) EmployeeSalary

-- Subquery in Where Statement
Select b.EmployeeID, a.JobTitle, a.Salary, b.Age
from EmployeeSalary as a
join EmployeeDemographics as b
	on a.EmployeeID = b.EmployeeID
where a.EmployeeID in(
	Select EmployeeID
	from EmployeeDemographics
	where Age > 30)
	
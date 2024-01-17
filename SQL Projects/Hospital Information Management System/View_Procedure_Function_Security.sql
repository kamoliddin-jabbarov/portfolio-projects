-----------view
Create View View_Doctor
AS
Select DoctorID
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
	  ,Qualification
	  ,dp.Name AS Department
      ,g.Name As Gender
      ,[DateOfBirth]
      ,[ContactNo1]
      ,[ContactNo2]
      ,[Email]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[Pincode]
	  ,C.Name As City
	  from Doctor d
Inner Join Gender g
On d.GenderID=g.GenderID
Inner Join City C
On d.CityID=C.CityID
Inner Join Department dp
On d.DepartmentID=dp.DepartmentID

-----------procedure

create procedure SP_Retrieve_Doctor_Departmentwise
(
 @deptname varchar(50)
)
as 
begin

	select DoctorID,
		   FirstName,
		   MiddleName,
		   Qualification,
		   dp.Name as Department,
		   g.Name as Gender,
		   c.Name as City
		   from Doctor d
	left join Gender g
	on d.GenderID = g.GenderID
	left join City c
	on d.CityID = c.CityID
	left join Department dp
	on d.DepartmentID = dp.DepartmentID
	where dp.Name = @deptname

end

exec SP_Retrieve_Doctor_Departmentwise 'Medicine'

drop procedure SP_Retrieve_Doctor_Departmentwise

----function 
create function Fn_City(@City varchar(50))
returns table
as 
return
(Select PatientID,
		FirstName,
		MiddleName,
		LastName,
		g.Name as Gender,
		DateOfBirth,
		ContactNo1,
		ContactNo2,
		Email,
		AddressLine1,
		AddressLine2,
		Pincode,
		C.Name as City
		from Patient P
	inner join Gender g
	on P.GenderID=g.GenderID
	inner join City C
	on P.CityID = C.CityID
	where C.Name=@City
)

Select * from Fn_City('pune')

------------security 

Use Master 
go
create Login QlikSense with password = 'qliksense2024'

use HIMS
go
create user QlikSense from login QlikSense


grant select on dbo.Bill to QlikSense
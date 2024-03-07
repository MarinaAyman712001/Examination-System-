drop database ProjectDB
create database ProjectDB
on primary
(
 name = 'ProjectDB_Data',
 size = 30MB,
 filegrowth = 20%,
 Maxsize = 100MB ,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA/ProjectDB_Data.mdf'
)
LOG on
(
 name = 'ProjectDB_Log',
 size = 30MB,
 filegrowth = 20%,
 Maxsize = 100MB ,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA/ProjectDB_Log.ldf'
)
use ProjectDB
go
CREATE SEQUENCE QuestionSequence
  AS INT
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 10
  CYCLE;

go
CREATE TYPE idtype
FROM int NOT NULL;

go
CREATE TYPE nametype
FROM nvarchar(50) NOT NULL;

go

create table Intake
(
 IntakeId idtype,
 IntakeName nametype,
 constraint IntakePK primary key(IntakeId),
)
go
create table Department
(
 DeptId idtype,
 DeptName nametype,
 constraint DepartmentPK primary key(DeptId),
)
go
create table Branch
(
  BranchId idtype,
  BranchName nametype,
  constraint BranchPK primary key(BranchId),
)
go
create table Track
(
  TrackId idtype,
  TrackName nametype,
  constraint TrackPK primary key(TrackId),
)
go
create table Student
(
  StudId idtype,
  StudName nametype,
  UserName nametype,
  StudPassword nvarchar(50) not null,
  constraint StudentPK primary key(StudId),
)

go
create table Course
(
  CourseId idtype,
  InstCourseId idtype,
  CourseName nametype,
  CourseDescription nvarchar(200) null,
  CourseMaxDegree int not null,
  CourseMinDegree int not null,
  constraint CoursePK primary key(CourseId),
  constraint CourseFK foreign key(InstCourseId) references Instructor(InstId) ON UPDATE CASCADE ON DELETE CASCADE ,
  constraint CourseMaxDegreeCheck check (CourseMaxDegree>CourseMinDegree)
)

go
create table StudentRegInIntake
(
  CourseId idtype,
  IntakeId idtype,
  StudId idtype,
  TrackId idtype,
  DeptId idtype,
  BranchId idtype,
  constraint StudentRegInIntakeCourseFK foreign key(CourseId) references Course(CourseId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint StudentRegInIntakeFK foreign key(IntakeId) references Intake(IntakeId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint StudentRegInIntakeStudFK foreign key(StudId) references Student(StudId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint StudentRegInIntakeTrackFK foreign key(TrackId) references Track(TrackId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint StudentRegInIntakeDeptFK foreign key(DeptId) references Department(DeptId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint StudentRegInIntakeBranchFK foreign key(BranchId) references Branch(BranchId) ON UPDATE CASCADE ON DELETE CASCADE,
)

go
create table Class
(
  ClassId idtype,
  ClassName nametype,
  constraint ClassPK primary key(ClassId),
)

go
create table Instructor
(
  InstId idtype,
  InstName nametype,
  UserName nametype,
  InstPassword nvarchar(50) not null,
  InstManager int DEFAULT null,
  constraint InstructorPK primary key(InstId),
  constraint InstructorFK foreign key(InstManager) references Instructor(InstId) ,
)

go 
 create table InstructorTeachClass
(
  ClassId idtype,
  CourseId idtype,
  InstructorId idtype,
  InstructorTeachClassYear date not null,
  constraint InstructorTeachClassFK foreign key(ClassId) references Class(ClassId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint InstructorTeachCourseFK foreign key(CourseId) references Course(CourseId) ON UPDATE CASCADE ON DELETE CASCADE,
  constraint InstructorTeachFK foreign key(InstructorId) references Instructor(InstId)  ,
)

go
create table Exam
(
	ExamId idtype,
	CourseId idtype,
	StartTime time not null,
	EndTime time not null,
	FullDegree int not null,
	constraint ExamPK primary key(ExamId),
	constraint ExamCourseFK foreign key(CourseId) references Course(CourseId) ON UPDATE CASCADE ON DELETE CASCADE,
)
go
alter table [QuestionPool].[Exam]
add  total_time as datediff(minute,[StartTime],[EndTime])
select * from Exam
go
create table StudentPerformExam
(
	PerformExamId idtype,
	PerformStudId idtype,
	ExamResult int not null,
	primary key(PerformExamId,PerformStudId),
	constraint StudentPerformExamFKOne foreign key(PerformExamId) references [QuestionPool].[Exam](ExamId) ON UPDATE CASCADE ON DELETE CASCADE,
	constraint StudentPerformExamFKTwo foreign key(PerformStudId) references [Member].[Student](StudId) ON UPDATE CASCADE ON DELETE CASCADE
)
go

create table AllowanceOption
(
	ExamId idtype,
	ExamOption nvarchar(50) not null,
	Allowance bit not null,
	constraint ExamOptionIdFK foreign key(ExamId) references Exam(ExamId) ON UPDATE CASCADE ON DELETE CASCADE,
)
--select convert (varchar,GETDATE(),108)
go
CREATE RULE AllowChecker
as @c in (1,0);

go
sp_bindrule AllowChecker, 'AllowanceOption.Allowance'
go 
 create table Question
(
	QuestionId idtype ,
	ExamId idtype,
	QuestionType nvarchar(50) not null,
	Content nvarchar(200) not null,
	CorrectAns nvarchar(200) not null,
	constraint QuestionPK primary key(QuestionId),
	constraint QuestionFK foreign key(ExamId) references Exam(ExamId) ON UPDATE CASCADE ON DELETE CASCADE,
)
go
create table ChooseQuestion
(
	ChooseID idtype primary key identity(1,1),
	QuestionId idtype ,
	Choice nvarchar(200) not null, 
	constraint ChooseQuestionFK foreign key(QuestionId) references Question(QuestionId) ON UPDATE CASCADE ON DELETE CASCADE,

)
--Start Schema
go
create schema Member
go
alter schema Member transfer [dbo].[Instructor]
go 
alter schema Member transfer[dbo].[Student]
go
alter schema  Member transfer [dbo].[StudentPerformExam]
go
create schema Managment
go
alter schema Managment transfer [dbo].[Branch]
go 
alter schema Managment transfer [dbo].[Department]
go
alter schema Managment transfer [dbo].[Intake]
go 
alter schema Managment transfer [dbo].[Track]
go
alter schema Managment transfer [dbo].[Course]
go 
alter schema Managment transfer [dbo].[Class]
go
alter schema Managment transfer [dbo].[InstructorTeachClass]
go
alter schema Managment transfer  [dbo].[StudentRegInIntake] 
go
create schema QuestionPool
go
alter schema QuestionPool transfer [dbo].[AllowanceOption]
go 
alter schema QuestionPool transfer [dbo].[ChooseQuestion]
go
alter schema QuestionPool transfer[dbo].[Exam]
go
alter schema QuestionPool transfer [dbo].[Question]
go
alter schema Managment transfer [dbo].[StudentModify]
go
alter schema Managment transfer [dbo].[InstructorModify]
--End Schema
--#region Create Synonym
go
create synonym Branch for [Managment].[Branch]
go
create synonym Intake for [Managment].[Intake]
go
create synonym Track for [Managment].[Track]
go
create synonym Department for [Managment].[Department]
go
create synonym Class for [Managment].[Class]
go
create synonym InstructorTeachClass for [Managment].[InstructorTeachClass]
go
create synonym Course for [Managment].[Course]
go
create synonym StudentRegInIntake for [Managment].[StudentRegInIntake]
go
create synonym Instructor for [Member].[Instructor]
go
create synonym Student for [Member].[Student]
go
create synonym StudentPerformExam for [Member].[StudentPerformExam]
go
create synonym AllowanceOption for [QuestionPool].[AllowanceOption]
go
create synonym ChooseQuestion for [QuestionPool].[ChooseQuestion]
go
create synonym Exam for [QuestionPool].[Exam]
go
create synonym Question for [QuestionPool].[Question]
go
--#end region Create Synonym
--#region Insert Data In Tables
insert into Department(DeptId,DeptName) values(1,'IT'),(2,'IS'),(3,'CS'),(4,'MM')
go
insert into Intake(IntakeId,IntakeName)values(20,'Int30'),(21,'Int31') ,(22,'Int32') 
,(23,'Int33') ,(24,'Int34') ,(25,'Int35') ,(26,'Int36') ,(27,'Int37') 
,(28,'Int38') ,(29,'Int39') ,(30,'Int40') ,(31,'Int41') ,(32,'Int42') 
go
insert into Branch(BranchId,BranchName)values(1,'Smart'),(2,'NSity'),(3,'Alex')
,(4,'Ismallia'),(5,'Assiut'),(6,'Mnofea'),(7,'Mansora'),(8,'Minia')
,(9,'Sohag'),(10,'Qina')
go
insert into Track(TrackId,TrackName) values(111,'Full Stack Web Development By Using .Net'),
(222,'Full Stack Web Development By Using PHP'),(333,'Full Stack Web Development By Using MERN')
,(444,'Mobile Cross Platform'),(555,'Mobile Native')
go
insert into Instructor(InstId,InstName,UserName,InstPassword,InstManager)
values(123,'Shenouda','Sho@123','Sho@123',null),
(124,'Wessam','Wes@123','Wes@123',null),(125,'Mahmmod','Mah@123','Mah@123',null),
(126,'Ashrf','Ash@123','Ash@123',123),(127,'Ahmed','Ahm@123','Ahm@123',123),
(128,'Ali','Ali@123','Ali@123',124),(129,'Mohsen','Moh@123','Moh@123',124),
(130,'Khaled','Kha@123','Kha@123',125),(131,'Atef','Ate@123','Ate@123',125),
(132,'Fady','Fad@123','Fad@123',125),(133,'Noha','Noh@123','Noh@123',123)
go
insert into Class(ClassId,ClassName) values(5555,'ClassA'),(6666,'ClassB'),
(7777,'ClassC'),(8888,'ClassD'),(9999,'ClassE')
go
insert into Course(CourseId,InstCourseId,CourseName,CourseDescription,CourseMaxDegree,CourseMinDegree)
values(101,126,'JS','To Make WebSite Interactive With Users',100,50),
(201,130,'HTML','To Make Static WebSite',120,60),
(301,128,'CSS','To Make Design for WebSite ',130,50),
(401,127,'ES','New Feature Of JS',100,50),
(501,132,'HTML5','New Feature Of HTML',150,80),
(701,129,'CSS3','New Feature Of CSS',120,70),
(801,131,'C#','Learning C# Programming Language',160,70),
(901,133,'CCNA','Introduction Of Network',100,70)
go
insert into InstructorTeachClass(ClassId,CourseId,InstructorId,InstructorTeachClassYear)
values(5555,101,126,'2015-06-01'),(6666,201,127,'2016-06-01'),(7777,301,128,'2014-06-01'),
(8888,501,129,'2011-06-01')
go
insert into Student(StudId,StudName,UserName,StudPassword)values
(1001,'Mekhail','Mekh@456','Mekh@456'),(1002,'Hany','Hany@456','Hany@456'),
(1003,'Hend','Hend@456','Hend@456'),(1004,'Mousa','Mous@456','Mous@456'),
(1005,'Omar','Omar@456','Omar@456'),(1006,'Nehal','Neha@456','Neha@456'),
(1007,'Mohand','Moha@456','Moha@456'),(1008,'Romany','Roma@456','Roma@456'),
(1009,'Samir','Sami@456','Sami@456'),(1010,'Sameh','Smeh@456','Smeh@456'),
(1011,'Shaban','Shab@456','Shab@456'),(1012,'Ramadan','Rama@456','Rama@456'),
(1013,'Mostfa','Most@456','Most@456'),(1014,'Safa','Safa@456','Safa@456'),
(1015,'Sawsn','Saws@456','Saws@456'),(1016,'Hala','Hala@456','Hala@456')
go
insert into StudentRegInIntake(DeptId,BranchId,IntakeId,TrackId,CourseId,StudId)
values(1,1,20,111,101,1001),(1,1,20,111,101,1002),
(1,1,21,222,201,1001),(1,1,20,111,201,1002),(1,1,20,111,301,1001),(1,1,20,111,301,1002),
(1,1,20,111,401,1001),(1,1,20,111,401,1002),(1,1,20,111,501,1001),(1,1,20,111,501,1002)
insert into StudentRegInIntake(DeptId,BranchId,IntakeId,TrackId,CourseId,StudId)
values(1,1,20,111,101,1003),(1,1,20,111,101,1004),
(1,1,21,222,201,1003),(1,1,20,111,201,1004),(1,1,20,111,301,1003),(1,1,20,111,301,1004),
(1,1,20,111,401,1003),(1,1,20,111,401,1004),(1,1,20,111,501,1003),(1,1,20,111,501,1004)
go
insert into StudentRegInIntake(DeptId,BranchId,IntakeId,TrackId,CourseId,StudId)
values(1,1,20,111,101,1005),(1,1,20,111,101,1006),
(1,1,21,222,201,1005),(1,1,20,111,201,1006),(1,1,20,111,301,1005),(1,1,20,111,301,1006),
(1,1,20,111,401,1005),(1,1,20,111,401,1006),(1,1,20,111,501,1005),(1,1,20,111,501,1006)
go
insert into Exam(ExamId,CourseId,StartTime,EndTime,FullDegree) values
(410,101,'10:30','12:00',100),(411,201,'10:30','12:30',100),(412,301,'10:30','12:00',100),
(413,401,'10:30','12:00',100),(414,501,'11:30','16:00',100),(415,701,'13:30','15:00',100),
(416,801,'11:30','16:00',100),(417,901,'09:00','12:00',100)
go
insert into AllowanceOption(ExamId,ExamOption,Allowance)values
(410,'Open Book',1),(410,'Calculator',0),(411,'Open Source',1),(412,'Calculator',0),
(413,'Calculator',1),(413,'Open Book',1),(414,'Open Book',1),(415,'Open Source',0),
(416,'Open Book',0),(416,'Calculator',0),(416,'Open Source',1),(415,'Calculator',1),
(417,'Calculator',1),(417,'Open Source',1),(417,'Open Book',1),(415,'Open Book',0)
go 
--drop synonym Question
--drop table [QuestionPool].[Question]
insert into Question(QuestionId,ExamId,QuestionType,Content,CorrectAns) values
(1,410,'MCQ','Which type of JavaScript language is','Object-Based'),
(2,410,'MCQ','Which one of the following also known as Conditional Expression','Switch statement'),
(3,410,'MCQ',' In JavaScript, what is a block of statement?','block that combines a number of statements into a single compound statement'),
(4,410,'MCQ','When interpreter encounters an empty statements, what it will do:','Ignores the statements'),
(5,410,'True & False','Java Scriptis Lossly type','1'),
(6,410,'True & False','Java Script Is Object Base','1'),
(7,410,'True & False','Java Script Supported OPP','0'),
(8,410,'True & False','Java Script Is Case Sensetive','0'),
(9,410,'TextQ','Which one of the following is the correct way for calling the JavaScript code?','Preprocessor'),
(10,410,'TextQ','Which of the following type of a variable is volatile?','Immutable variable'),
(11,411,'MCQ','HTML stands for','Hyper Text MarkUp Language'),
(12,411,'MCQ','The correct sequence of HTML tags for starting a webpage is -','HTML, Head, Title, Body'),
(13,411,'MCQ',' Which of the following element is responsible for making the text bold in HTML?','<b>'),
(14,411,'MCQ',' Which of the following tag is used for inserting the largest heading in HTML?','<h1>'),
(15,411,'True & False','Html IS programming Language','0'),
(16,411,'True & False','Html Support OPP','0'),
(17,411,'True & False','Html Is Interprited Language','1'),
(18,411,'True & False','Html Case Sensetive','0'),
(19,411,'TextQ','How to create a hyperlink in HTML?','<a href = "www.javatpoint.com"> javaTpoint.com </a>'),
(20,411,'TextQ','How to create an ordered list (a list with the list items in numbers) in HTML?','<ol>')
go
insert into ChooseQuestion(QuestionId,Choice)values 
(1,'Object-Based'),
(1,'Programming Language'),
(1,'Hyper Text MarkUp Language'),
(2,'If-Else'),
(2,'Switch statement'),
(2,'For-Loop'),
(3,'block that combines a number of statements into a single compound statement'),
(3,'block that combines a number of statements into a Multiple compound statement'),
(3,'block that combines a number of statements into a single Line'),
(4,'Complete With Error'),
(4,'Compile All File'),
(4,'Ignores the statements'),
(11,'Hyper Text MarkUp Language'),
(11,'HyperText and links Markup Language'),
(11,'HighText Machine Language'),
(12,'HTML, Body, Title, Head'),
(12,'HTML, Head, Title, Body'),
(12,'Head, Title, HTML, body'),
(13,'<b>'),
(13,'<br>'),
(13,'<pre>'),
(14,'<h6>'),
(14,'<h1>'),
(14,'<h4>')
go
insert into StudentPerformExam(PerformStudId,PerformExamId,ExamResult)values
(1001,410,70),(1002,410,80),(1003,410,90),(1004,410,60),(1005,410,65),(1006,410,41),
(1007,410,58),(1008,410,63),(1009,410,35),(1010,410,26),(1011,410,92),
(1002,411,86),(1003,411,44),(1004,411,56),(1005,411,61),(1006,411,42),(1007,411,86),
(1008,411,44),(1009,411,56),(1010,411,61),(1011,411,42)
go

select * from ChooseQuestion
go
select * from Question
go
select * from AllowanceOption
go
select YEAR( '2021-09-01')
go
select IntakeId from Intake
go
select DeptId from Department
go
select BranchId from Branch
go
select TrackId from Track
go
select CourseId from Course
go
--select * from InstructorTeachClass
select StudId from Student
go
select * from Instructor
go
select * from Class
go 
select CourseId from Course
go
select * from Exam
go
select * from InstructorTeachClass
go
select * from StudentRegInIntake
go
select * from StudentPerformExam

--#End region
--#region Functions And Stored Procedures
-- Reset Student Password
go
Create procedure ResetStudentPassword(@userName varchar(50),@oldPassword varchar(50),@newPassword varchar(50))
as begin
		if exists(select Student.UserName from Student where Student.UserName=@userName)
			begin
				if exists(select Student.StudPassword from Student where Student.UserName=@userName
				and Student.StudPassword=@oldPassword)
					begin
						update Student set StudPassword=@newPassword where Student.UserName=@userName
					end
				else 
					select 'Please: Enter Valid Old Password' as 'Please:Try Again:'
			end
		else
			select 'UserName Is Not Valid' as ' Please:Try Again'
		
end
go
EXEC ResetStudentPassword @userName='Omar@456', @oldPassword='Omar@456', @newPassword='Omar@789'
-- Reset Instructor Password
go
Create procedure ResetInstructorPassword(@userName varchar(50),@oldPassword varchar(50),@newPassword varchar(50))
as begin
		if exists(select Instructor.UserName from Instructor where Instructor.UserName=@userName)
			begin
				if exists(select Instructor.InstPassword from Instructor where Instructor.UserName=@userName
				and Instructor.InstPassword=@oldPassword)
					begin
						update Instructor set InstPassword=@newPassword where Instructor.UserName=@userName
					end
				else 
					select 'Please: Enter Valid Old Password' as 'Please:Try Again:'
			end
		else
			select 'UserName Is Not Valid' as ' Please:Try Again'
		
end
go
alter schema Managment transfer [dbo].[InstructorModify]
go
EXEC ResetInstructorPassword @userName='Ash@123', @oldPassword='Ash@123', @newPassword='Ash@789'
select * from Instructor
/*Retrive All Student In specific Intake */
go
create procedure StudentsInIntake(@IntakeNumber int)
as begin
	
		select StudId,StudName,UserName from Student where Student.StudId 
		in(
		select StudId from StudentRegInIntake where IntakeId=@IntakeNumber
		  )
end
EXEC StudentsInIntake @IntakeNumber =20
--Retrive Courses Id And Using To Retrive All Courses In Specific Track
go
create function CoursesIDFunc(@TrackNumber int)
returns table
as return(
		select Course.CourseId from Course,StudentRegInIntake,Track
		where Course.CourseId=StudentRegInIntake.CourseId and
		Track.TrackId=StudentRegInIntake.TrackId and Track.TrackId=@TrackNumber
		
		)
		go
select * from CoursesIDFunc(111)
go
--Retrive All Questition Of Specific Exam
go
alter function QuestitionExam(@ExamNumber int)
returns table
as return(
		 select distinct(Question.Content),Question.QuestionId,ChooseQuestion.Choice,Question.QuestionType from  Question left Join ChooseQuestion  on Question.QuestionId=ChooseQuestion.QuestionId
		where Question.ExamId=@ExamNumber and Question.QuestionId
		in
			(
				select Question.QuestionId from Question left join ChooseQuestion
				on Question.QuestionId=ChooseQuestion.QuestionId where ExamId=@ExamNumber
				group by Question.QuestionId
			)
		)
go
select * from QuestitionExam(410)
--Retrive All Courses In Specific Track
go
create procedure CoursesInTrack(@TrackNumber int)
as begin

		select CourseName,CourseDescription,CourseMaxDegree,CourseMinDegree
		from Course where CourseId in
		(
		select * from CoursesIDFunc(@TrackNumber)
		)
		
end
go
EXEC CoursesInTrack @TrackNumber =111
go
--Retrive Students Id And Using To Retrive All Students In Specific Track
create function Students_IDS_In_Track(@TrackNumber int)
returns table
as return(
		select Student.StudId from Student,StudentRegInIntake,Track
		where Student.StudId=StudentRegInIntake.StudId and
		Track.TrackId=StudentRegInIntake.TrackId and Track.TrackId=@TrackNumber
		
		)
go
--Retrive All Students In Specific Track
create procedure StudentsInTrack(@TrackNumber int)
as begin
	
		select StudId,StudName
		from Student where StudId in
		(
		select * from Students_IDS_In_Track(@TrackNumber)
		)
end
select * from Students_IDS_In_Track(111)
EXEC StudentsInTrack @TrackNumber =111
go
--Procedure To Retrive Students In a Specific Course
create procedure Students_In_Specific_Course(@CourseNumber int)
as begin
	
		select StudId,StudName
		from Student where StudId in
		(
		select Student.StudId from Course,Student,StudentRegInIntake
		where Course.CourseId=StudentRegInIntake.CourseId and
		Student.StudId=StudentRegInIntake.StudId and Course.CourseId=@CourseNumber
		)
end
go
EXEC Students_In_Specific_Course @CourseNumber=101
go
select * from Course
go
--Procedure To Retrive Students Passes In a Specific Course
create procedure Students_Passes_In_Specific_Exam(@ExamNumber int)
as begin
	
		if exists(select Exam.ExamId from Exam where ExamId=@ExamNumber)
			begin
				select Student.StudName,StudentPerformExam.ExamResult
				from Exam,StudentPerformExam,Student 
				where Exam.ExamId=StudentPerformExam.PerformExamId and
				Student.StudId=StudentPerformExam.PerformStudId and
				ExamId=@ExamNumber and 
				ExamResult>(Exam.FullDegree*0.5)
			end
		else
		select 'Exam Is Not Found' as 'Please: Try Again'
		
end
go
EXEC Students_Passes_In_Specific_Exam @ExamNumber=410
go

--Procedure To Retrive Students In a Specific Course
Create procedure Students_Grades_In_Specific_Course(@CourseName varchar(50))
as begin
		if exists(select Course.CourseName from Course where Course.CourseName=@CourseName)
			begin
				select Student.StudName,StudentPerformExam.ExamResult
				from StudentPerformExam,Exam,Course,Student
				where StudentPerformExam.PerformExamId=Exam.ExamId and 
				Course.CourseId=Exam.CourseId and
				Student.StudId=StudentPerformExam.PerformStudId and
				Course.CourseName=@CourseName
			end
		else
			select 'Course Is Not Found' as 'Try Again'
		
end
go
EXEC Students_Grades_In_Specific_Course @CourseName='JS'
go
---Pick An Exam By Select Random Questition 
create procedure PickAnExam(@ExamNumber int,@NumberOfQuestiton int)
as begin
		if exists(select Exam.ExamId from Exam where Exam.ExamId=@ExamNumber)
			begin
				declare @t table(RandomQID int primary key)
				declare @start int
				set @start=0
				while @start!= @NumberOfQuestiton
				begin
					begin try
							insert into @t select Cast((((RAND()+1)*10)-9)as Integer)
							set @start=@start+1
					end try
							
					begin catch
							--rollback
					end catch
				end
				select * from QuestitionExam(@ExamNumber) where QuestionId
				in
				(
					select* from @t
				)			
			end
		else
			select 'Course Number Is Not Found' as ' Please:Try Again'
		
end
go
EXEC PickAnExam @ExamNumber=410, @NumberOfQuestiton=6

/**/
/*Function to Count Number Of Students In Each Track*/
go
create function Count_Of_Student_In_Each_Track()
returns table
as return(
		select  COUNT(distinct(Student.StudId)) as 'Number Of Students',Track.TrackName from Student,Track,StudentRegInIntake
		where Student.StudId=StudentRegInIntake.StudId and 
		Track.TrackId=StudentRegInIntake.TrackId group by  Track.TrackId,TrackName	
		)
go
select * from Count_Of_Student_In_Each_Track()
--#end region Function And Stored Procedure
--#region Views
--Student_Details View To Show Student Details
go
create view Student_Details as 
(
	select Student.StudName,Course.CourseName,Track.TrackName,Branch.BranchName 
	from Student,Course,Department,Intake,Track,Branch,StudentRegInIntake
	where Department.DeptId=StudentRegInIntake.DeptId and
	Branch.BranchId=StudentRegInIntake.BranchId and
	Intake.IntakeId=StudentRegInIntake.IntakeId and
	Track.TrackId=StudentRegInIntake.TrackId and
	Course.CourseId=StudentRegInIntake.CourseId and
	Student.StudId=StudentRegInIntake.StudId 
)
go
select * from Student_Details
go
-- Retrive All Instructors With Its Courses That He Give It*/
create view Instructor_Course as 
(
	select Instructor.InstName,Course.CourseName
	from Course,Instructor where 
	Course.InstCourseId=Instructor.InstId

)
go
select * from Instructor_Course
go
--Retrives Students Grades In Each Exam They Performed Its
create view Students_Grades_Each_Exam_Perofrmed as 
(
	select Student.StudName,StudentPerformExam.ExamResult,
	StudentPerformExam.PerformExamId from Student,StudentPerformExam 
	where Student.StudId=StudentPerformExam.PerformStudId
	and StudentPerformExam.PerformExamId in (
	select Exam.ExamId from Student,StudentPerformExam,Exam
	where Student.StudId=StudentPerformExam.PerformStudId and
	Exam.ExamId=StudentPerformExam.PerformExamId group by Exam.ExamId
											)

)
go
select * from Students_Grades_Each_Exam_Perofrmed
go
create view Managment.StudentTableModify as
(
	select * from Managment.StudentModify
)
go
select * from Managment.StudentTableModify
go
create view Managment.InstructorTableModify as
(
	select * from Managment.InstructorModify
)
go
select * from Managment.InstructorTableModify
--#end region View
--#region Triggers
--Table To Sava User Change Data On Student Table After Modify
create table StudentModify
(
	ServerUserName Nvarchar(150) not null,
	[Date] Date default getDate(),
	Note Nvarchar(250)
)
select * from StudentModify

go
--To Show Person Deatails That Inserted In Object That Called Student
create trigger InsertStudentTrigger
on [Member].[Student] After Insert
as
begin
	insert into [dbo].[StudentModify]
	values((suser_sname()),(GETDATE()),
	(CONCAT(suser_sname(),
	' Insert New Student With Id : ',(select [StudId] from inserted),
	' And Name : ',(select [StudName] from inserted),
	' in Table Student'))
	)
end
go
insert into [Member].[Student] values(1100,'Wess','Wess@111','Wess@111')
go
--To Show Person Deatails That Updated In Object That Called Student
create trigger UpdateStudentTrigger
on [Member].[Student] After Update
as
begin
	insert into [dbo].[StudentModify]
	values((suser_sname()),(GETDATE()),
	(CONCAT(suser_sname(),
	' Update Student With Id : ',(select [StudId] from inserted),
	' And Name : ',(select [StudName] from inserted),
	' in Table Student'))
	)
end

go
update [Member].[Student] set [StudId] = 1200 where [StudId] = 1100
go
--To Show Person Deleted That Inserted In Object That Called Student
create trigger DeleteStudentTrigger
on [Member].[Student] After Delete
as
begin
	insert into [dbo].[StudentModify]
	values((suser_sname()),(GETDATE()),
	(CONCAT(suser_sname(),
	' Delete Student With Id : ',(select [StudId] from deleted),
	' And Name : ',(select [StudName] from deleted),
	' in Table Student'))
	)
end
go
delete from [Member].[Student] where [StudId] = 1200


go
--Table To Sava User Change Data On Instructor Table After Modify
create table InstructorModify
(
	ServerUserName Nvarchar(150) not null,
	[Date] Date default getDate(),
	Note Nvarchar(250)
)
select * from InstructorModify

go
--To Show Person Deatails That Inserted In Object That Called Instructor
create trigger InsertInstructorTrigger
on [Member].[Instructor] After Insert
as
begin
	insert into [dbo].[InstructorModify]
	values((suser_sname()),(GETDATE()),
	(CONCAT(suser_sname(),
	' Insert New Instructor With Id : ',(select [InstId] from inserted),
	' And Name : ',(select [InstName] from inserted),
	' in Table Instructor'))
	)
end

go
insert into [Member].[Instructor] values(150,'Wess','Wess@111','Wess@111',Null)
go
--To Show Person Deatails That Updated In Object That Called Instructor
create trigger UpdateInstructorTrigger
on [Member].[Instructor] After update
as
begin
	insert into [dbo].[InstructorModify]
	values((suser_sname()),(GETDATE()),
	(CONCAT(suser_sname(),
		' Update Instructor With Id : ',(select [InstId] from inserted),
		' And Name : ',(select [InstName] from inserted),
		' in Table Instructor'))
	)
end

go
update [Member].[Instructor] set [InstId] = 200 where [InstId] = 150
go
--To Show Person Deatails That Deleted In Object That Called Instructor
create trigger DeleteInstructorTrigger
on [Member].[Instructor] After delete
as
begin
	insert into [dbo].[InstructorModify]
	values((suser_sname()),(GETDATE()),
	(CONCAT(suser_sname(),
		' Delete Instructor With Id : ',(select [InstId] from deleted),
		' And Name : ',(select [InstName] from deleted),
		' in Table Instructor'))
	)
end

go
delete from [Member].[Instructor] where [InstId] = 200
go
--Prevent Inserted Of Instructor To Another Course If Instructor Not Finished The Course That He Gave It Now 
create trigger PreventInsInsert
on [Managment].[InstructorTeachClass] instead of insert
as
begin
	if((select [InstructorId] from inserted) not in (select [InstructorId] from [Managment].[InstructorTeachClass]))
	begin
		insert into [Managment].[InstructorTeachClass] values(
		(select [ClassId] from inserted),
		(select [CourseId] from inserted),
		(select [InstructorId] from inserted),
		(select [InstructorTeachClassYear] from inserted))
	end
	else
	begin
		if((select DATEDIFF(year,
		(select [InstructorTeachClassYear] from [Managment].[InstructorTeachClass] where [InstructorId] = (select [InstructorId] from inserted)),
		(SELECT [InstructorTeachClassYear] from inserted))) <= 1)
		begin
			Select 'You can not insert Now' as [Error Message]
			rollback;
		end
		else
		begin
			insert into [Managment].[InstructorTeachClass] values(
			(select [ClassId] from inserted),
			(select [CourseId] from inserted),
			(select [InstructorId] from inserted),
			(select [InstructorTeachClassYear] from inserted))
		end
	end
end
insert into [Managment].[InstructorTeachClass] values(9999,901,123,'2022-06-01')
go
--Prevent Insert In Student Table If Exam Result More Than Exam Full Degree
create trigger PerformExamTrigger
on [Member].[StudentPerformExam] instead of Insert
as
begin
	if((select [ExamResult] from inserted) <= 
	(select [FullDegree] from [QuestionPool].[Exam] where [ExamId] = (select [PerformExamId] from inserted)))
	begin
		begin try
			insert into [Member].[StudentPerformExam]
			values((select [PerformExamId] from inserted),
			(select [PerformStudId] from inserted),
			(select [ExamResult] from inserted))
		end try
		begin catch
			select 'You can not Insert' as [Error Message]
			rollback
		end catch
	end
	else
	begin
		select 'Exam Result can not be larger than Full Degree' as [Error Message]
	end
end

--End region Trigger

--#region Indexes 
create clustered index InstructorTeachClassIndex
on [Managment].[InstructorTeachClass]([ClassId])
go
create clustered index StudentRegInIntakeIndex
on [Managment].[StudentRegInIntake]([CourseId])
go
create clustered index AllowanceOptionIndex
on [QuestionPool].[AllowanceOption]([ExamId])
go
--#end region Indexes
--#regin Users
go
create table DatabaseUsers
(
	Username Nvarchar(50) not null,
	[Password] NvarChar(30) not null
)
go
insert into DatabaseUsers
values('admin','admin@1'),('manager','manager@2'),('instructor','instructors@3'),('student','student@4')
go
select * from DatabaseUsers
go
create login [admin]
with password = 'admin@1'
go
create user [admin] for login [admin]
go
create login [manager]
with password = 'manager@2'
go
create user [manager] for login [manager]
go
create login [instructor]
with password = 'instructor@3'
go
create user [instructor] for login [instructor]
go
create login [student]
with password = 'student@4'
go
create user [student] for login [student]
go
--#end region Users
/*#region Users Permission*/
Grant control on database::[ProjectDB] TO [admin];
Grant select,insert,update,delete,execute on database::[ProjectDB] to [manager]
Grant select,insert,update,delete on object::[QuestionPool].[Exam] to [instructor]
Grant select,insert,update,delete on object::[Member].[StudentPerformExam] to [instructor]
Grant select,insert,update,delete on object::[QuestionPool].[AllowanceOption] to [instructor]
Grant select on object::[QuestionPool].[Question] to [instructor]
Grant select on object::[QuestionPool].[ChooseQuestion] to [instructor]
Grant select on object::[Member].[Instructor] to [instructor]
Grant execute on schema::[dbo] to [instructor]
Grant select on object::[dbo].[QuestitionExam]to [instructor]--
Grant execute on object::[dbo].[PickAnExam] to [instructor]
Grant execute on object::[dbo].[ResetInstructorPassword] to [instructor]
Grant select on object::[dbo].[Instructor_Course] to [instructor]--
Grant select on object::[dbo].[Students_Grades_Each_Exam_Perofrmed] to [instructor]--
Grant execute on schema::[dbo] to [student]
Grant execute on object::[dbo].[ResetStudentPassword] to [student]
/*end region */
/*#region Daily BackUp*/
DECLARE @path VARCHAR(500)
DECLARE @name VARCHAR(500)
DECLARE @pathwithname VARCHAR(500)
DECLARE @time DATETIME
DECLARE @year VARCHAR(4)
DECLARE @month VARCHAR(2)
DECLARE @day VARCHAR(2)
DECLARE @hour VARCHAR(2)
DECLARE @minute VARCHAR(2)
DECLARE @second VARCHAR(2)
SET @path = 'F:\'
SELECT @time   = GETDATE()
SELECT @year   = (SELECT CONVERT(VARCHAR(4), DATEPART(yy, @time)))
SELECT @month  = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(mm,@time),'00')))
SELECT @day    = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(dd,@time),'00')))
SELECT @hour   = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(hh,@time),'00')))
SELECT @minute = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(mi,@time),'00')))
SELECT @second = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(ss,@time),'00')))
SELECT @name ='ProjectDB' + '_' + @year + @month + @day + @hour + @minute + @second

SET @pathwithname = @path + @namE + '.bak'
BACKUP DATABASE [ProjectDB] 
TO DISK = @pathwithname WITH NOFORMAT, NOINIT, SKIP, REWIND, NOUNLOAD, STATS = 10
/*#end regin*/

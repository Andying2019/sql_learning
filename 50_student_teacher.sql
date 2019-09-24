use 50_student_teacher;
select * from course;
select * from sc;
select * from score_temporary;
select * from student;
select * from teacher;
1.查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
select * from
	(select * from SC where CId='01') as t1,
	(select * from SC where CId='02') as t2
where t1.SId=t2.SId and t1.score>t2.score

select * from student right join
	(
	select t1.SId, score01, score02 from
		(select SId, score as score01 from SC where CId = '01') as t1,
		(select SId, score as score02 from SC where CId = '02') as t2
	where t1.SId= t2.SId and score01>score02
	)r
on student.SId=r.SId
1.1查询同时存在" 01 "课程和" 02 "课程的情况
select 	* from
(select SId from SC where CId='01') as t1,
(select SId from SC where CId='02') as t2
where t1.SId=t2.SId;
1.2查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
select * from 
(select * from sc where sc.CId = '01') as t1
left join 
(select * from sc where sc.CId = '02') as t2
on t1.SId = t2.SId;
1.3查询不存在" 01 "课程但存在" 02 "课程的情况
select * from SC 
where SC.SId not in(
select SId from sc where sc.CId = '01'
)
and SC.CId='02'
2.查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select sc.sid, sname, avg(score) as avgscore from student, sc
where student.sid = sc.sid
group by sid,sname
having avgscore >=60
或
select student.SId, Sname, avgscore from student,(
select SId, avg(score) as avgscore from sc group by SId having avgscore>=60
)r
where student.SId=r.SId
3.查询在 SC 表存在成绩的学生信息

4.查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
select student.sid, sname, count(cid) as cno, sum(score) as sscore from student left join sc
on student.sid = sc.sid
group by student.sid,sname
或
select s.sid, s.sname,r.coursenumber,r.scoresum
from (
    (select student.sid,student.sname 
    from student
    )s 
    left join 
    (select 
        sc.sid, sum(sc.score) as scoresum, count(sc.cid) as coursenumber
        from sc 
        group by sc.sid
    )r 
   on s.sid = r.sid
);

select Sname, r.* from student,
	(select SId, count(CId), sum(score) from SC group by SId) r
where r.SId=student.SId
4.1查有成绩的学生信息
select distinct(sname),sage,ssex from student right join sc
on student.sid = sc.sid

select * from student 
where exists (select sc.sid from sc where student.sid = sc.sid);
5.查询「李」姓老师的数量
select count(*) from teacher where Tname like '李%'；
6.查询学过「张三」老师授课的同学的信息
select student.* from student,sc,course,teacher
where student.SId=sc.SId 
and sc.CId=course.CId
and course.TId=teacher.TId
and Tname='张三'
7.查询没有学全所有课程的同学的信息
select student.* from student
where student.sid not in
	(select sid from sc
    group by sid 
    having count(sc.cid)= (select count(course.cid) from course)
    )

select student.*, count(cid) as cno from student,sc     #sid只包含选了课的学生,不包含一门课都没选的学生
where student.sid = sc.sid
group by sid,sname,sage,ssex
having cno <( select count(distinct(cid)) as acno from course)

select * from student,                                    #sid只包含选了课的学生,不包含一门课都没选的学生
(select SId, count(CId) as scno from sc group by SId) as t1,
(select count(distinct(CId)) as courseno from sc) as t2
where student.SId=t1.SId and scno < courseno

8.查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
select * from student
where student.sid in(
select sid from sc where cid in 
(select cid from sc where sid='01')
)
9.查询和" 01 "号的同学学习的课程 完全相同的其他同学的信息

10.查询没学过"张三"老师讲授的任一门课程的学生姓名

select * from student where sid not in(
select sid from sc,course,teacher
where sc.cid=course.cid and course.tid=teacher.tid and tname='张三'
)

11.查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
select t2.sid, student.sname,t3.avgscore from student,(
select sid, count(cid) as lno from (  
select sid, cid, score as lscore from sc where score <60 ) t1
group by sid)t2,
(select sid, avg(score) as avgscore from sc group by sid)t3
where student.sid = t2.sid and t3.sid=t2.sid and lno>1

select sname, t1.sid, avg from (
select sid, avg(score) as avg, sum(score <60) as lno from sc
group by sid having lno >1 ) t1
join student on
student.sid=t1.sid
 
查询所有课程都及格的学生sid
select * from sc where sid not in(
select sid from sc where score <60)

12.检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select student.*, score from student, sc
 where student.sid = sc.sid 
 and cid='01' 
 and score <60 
 order by score desc
13.按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select student.*,avg from student ,
(select sid, avg(score) as avg from sc group by sid)t1
where student.sid=t1.sid order by avg desc;
 
14.查询各科成绩最高分、最低分和平均分：
以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

15.按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
15.1.按各科成绩进行排序，并显示排名， Score 重复时合并名次
16.查询学生的总成绩，并进行排名，总分重复时保留名次空缺
##排名为122446
使用dense_rank()
16.1.查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
##排名为123456
set @rownum=0;
select sid,sscore,@rownum:=@rownum +1 as sequence from(
select sid,sum(score) as sscore from sc group by sid order by sscore desc
)t1;

select sid,sscore,row_number() over( order by sscore desc) as sequence from(
select sid,sum(score) as sscore from sc group by sid order by sscore desc
)t1;
17.统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比

18.查询各科成绩前三名的记录

order by cid asc, sc.score desc;
19.查询每门课程被选修的学生数
select cid, count(cid) from sc group by cid
20.查询出只选修两门课程的学生学号和姓名
select t1.sid,sname from student,
(select sid, count(cid) as cno from sc group by sid)t1
where student.sid=t1.sid and cno = 2

select sid from sc group by sid having count(cid)=2
21.查询男生、女生人数
select ssex, count(ssex) from student group by ssex

22.查询名字中含有「风」字的学生信息
select * from student where sname like '%风%'
23.查询同名同性学生名单，并统计同名人数
select sname,count(sname) from student group by sname having count(sname)>1
24.查询 1990 年出生的学生名单
select * from student where year(sage)='1990'
25.查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
select cid, avg(score) as avgscore from  sc group by cid 
order by avgscore desc,cid asc
26.查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
select t1.sid, avgscore,sname from student,
(select sc.sid, avg(score) as avgscore from sc  group by sc.sid having avgscore >=85)t1
where t1.sid=student.sid 
##或:(only_full_group_by模式下，group by后的字段包含多个）
select sc.sid, student.sname, AVG(sc.score) as aver from student, sc
where student.sid = sc.sid
group by sc.sid,sname
having aver >= 85;

select @@sql_mode;
SHOW VARIABLES LIKE 'sql_mode';
set global sql_mode='';
set global sql_mode='STRICT_TRANS_TABLES';
27.查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
select sname, score from student,sc,course
where student.sid=sc.sid and sc.cid=course.cid
and cname='数学' and score<60
28.查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
select student.sid, cid,score from student left join sc
on student.sid=sc.sid
29.查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
select sname,sc.cid,score from student,sc,course
where student.sid=sc.sid and sc.cid=course.cid
and score >70
30.查询存在不及格的课程
select distinct(cid) from sc where score<60
select cid from sc where score<60 group by cid
31.查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名
select sc.sid,sname from student,sc
where student.sid=sc.sid
and cid='01'
and score>=80
and student.sid = sc.sid;
32.求每门课程的学生人数
select cid, count(sid) as sno from sc group by cid
33.成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
##最简洁写法
select student.*, score from student,sc,course,teacher
where student.sid=sc.sid and sc.cid=course.cid and course.tid=teacher.tid
and tname='张三'
order by score desc limit 1

34.成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

35.查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
36.查询每门功成绩最好的前两名


37.统计每门课程的学生选修人数（超过 5 人的课程才统计）
select cid, count(cid) as cno from sc group by cid having cno >5
38.检索至少选修两门课程的学生学号
select sid, count(cid) as cno from sc group by sid having cno>=2
39.查询选修了全部课程的学生信息
select student.* from student,
(select sid from sc group by sid having count(cid)=
(select count(distinct(cid)) from course)
)t1
where student.sid=t1.sid

select student.*
from sc ,student 
where sc.SId=student.SId
GROUP BY sc.SId
HAVING count(*) = (select DISTINCT count(*) from course )
40.查询各学生的年龄，只按年份来算
41.按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
select student.SId as 学生编号,student.Sname  as  学生姓名,
TIMESTAMPDIFF(YEAR,student.Sage,CURDATE()) as 学生年龄
from student

42.查询本周过生日的学生
select *
from student 
where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE());
43.查询下周过生日的学生
44.查询本月过生日的学生
select *
from student 
where MONTH(student.Sage)=MONTH(CURDATE());
45.查询下月过生日的学生
46.以学生编号分组，求总分
select sid,cid,score,
SUM(score) over(partition by sid) ranking  
from sc
46.1以学生编号分组，按成绩从高到低排序
select sid,cid,score,
ROW_NUMBER() over(partition by sid order by score desc) ranking  
from sc
46.2以课程分组，按成绩从高到低排序
select sid,cid,score,
ROW_NUMBER() over(partition by cid order by score desc) ranking
from sc
47.已课程分组，查询分数在90分以上的各科最高分
select * from 
(select sid,cid,score,
ROW_NUMBER() over(partition by cid order by score desc) ranking from sc
where score>90
) A 
WHERE A.ranking=1 
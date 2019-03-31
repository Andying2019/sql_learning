-- 查询有多少人选了3-105这门课
select count(*) from score where cno='3-105';
select cno,count(*) from score GROUP BY cno;
select cno,count(*) from score GROUP BY cno having count(*)>=5;
select cno,count(*) from score;


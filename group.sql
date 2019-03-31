select cno,count(*) from score GROUP BY cno;
select cno,count(*) from score GROUP BY cno having count(*)>=5;
select cno,count(*) from score;
select count(*) from score where cno='3-105';

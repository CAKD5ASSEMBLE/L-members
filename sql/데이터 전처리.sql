-- # 점포코드로 지역 유추
--create table 점포지역 as
SELECT 고객번호, 점포코드,지역, 구매금액, RankNo
FROM
    (SELECT 고객번호, 점포코드,지역,sum(구매금액) 구매금액,
    ROW_NUMBER() OVER (PARTITION BY 고객번호 ORDER BY sum(구매금액) DESC) AS RankNo
    FROM LCL2 where 지역 is null group by 고객번호, 점포코드,지역)
WHERE RankNO = 1
order by 고객번호, 점포코드;


-- # 감소고객 중에서 점포지역과 사는지역이 일치하지 않는 고객
select *
from
(SELECT  t.고객번호, t.점포코드, 점포지역.지역 점포지역
FROM
(SELECT 고객번호,점포코드,지역,
ROW_NUMBER() OVER (PARTITION BY 고객번호 ORDER BY count(점포코드) DESC) AS RankNo
FROM LCL2 group by 고객번호,점포코드,지역) T,
점포지역
WHERE T.RankNO=1 and T.점포코드=점포지역.점포코드 AND T.지역!=점포지역.지역 order by 고객번호) a
join custdemo b on a.고객번호 = b.고객번호
join 고정고객 c on a.고객번호 = c.고객번호
where 고객구분 = '감소';


-- # 고정고객의 채널, 경쟁사, 멤버십 내역
select a.*, nvl(채널이용횟수, 0) 채널이용횟수, nvl(경쟁사이용횟수, 0) 경쟁사이용횟수, nvl(멤버십가입개수, 0) 멤버십가입개수
from
고정고객 a
left outer join 
(SELECT 고객번호, SUM(이용횟수) 채널이용횟수 FROM CHANNEL
GROUP BY 고객번호) b on a.고객번호 = b.고객번호
left outer join 
(SELECT 고객번호, COUNT(고객번호) 경쟁사이용횟수 FROM COMPET
GROUP BY 고객번호) c on a.고객번호 = c.고객번호
left outer join
(select 고객번호, count(고객번호) 멤버십가입개수 FROM membership
group by 고객번호) d on a.고객번호 = d.고객번호
where 고객구분 = '감소' and 멤버십가입개수 > 2;


-- # LCL2 지역 null값 채우기
--- # 지역 null값 채워서 임시2 테이블 만들기
UPDATE 점포지역 SET 지역 = '경기' WHERE 점포코드 = 563;

create table 임시2 as
select 고객번호, b.지역
from
    (SELECT 고객번호, 점포코드,지역, 구매금액, RankNo
    FROM
    (SELECT 고객번호, 점포코드,지역,sum(구매금액) 구매금액,
    ROW_NUMBER() OVER (PARTITION BY 고객번호 ORDER BY sum(구매금액) DESC) AS RankNo
    FROM LCL2 where 지역 is null group by 고객번호, 점포코드,지역)
WHERE RankNO = 1
order by 고객번호, 점포코드) a
join 점포지역 b on a.점포코드 = b.점포코드;

--- # LCL2에 지역 반영
MERGE INTO lcl2 a
USING 임시2 b
ON (a.고객번호 = b.고객번호)
WHEN MATCHED THEN UPDATE SET a.지역 = b.지역;


-- # 고객의 구매금액을 시간별로 묶기
select a.고객번호, 기, 구매시간, sum(구매금액), b.고객구분,
ROW_NUMBER() OVER (PARTITION BY a.고객번호 ORDER BY sum(구매금액) DESC) RankNo
from lcl2 a
join 고정고객 b on a.고객번호 = b.고객번호
where (기='7기' or 기='1기') and b.고객구분 = '감소'
group by a.고객번호, 기, 구매시간, b.고객구분
order by a.고객번호, 기, RankNo;
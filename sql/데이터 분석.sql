--데이터 분석

-- # 제휴사 별 매출
select YEAR 년, SUBSTR(구매일자, 5, 2) 월, 제휴사, TO_CHAR(sum(구매금액), '999,999,999,999,999') "총매출액", TO_CHAR(round(AVG(구매금액)), '999,999') "평균금액"
from purprod
WHERE 제휴사 = 'C'
GROUP BY YEAR, SUBSTR(구매일자, 5, 2), 제휴사
ORDER BY YEAR, SUBSTR(구매일자, 5, 2), 제휴사;


-- 매장갯수 : 593
select count(distinct 점포코드) from purprod;

--  상위 50프로 구매횟수 년도 점포 리스트
SELECT YEAR, 점포코드,ROUND(SUM(구매금액)/1000) 구매금액 ,count(구매금액) 구매횟수 
FROM PURPROD P, CUSTDEMO C WHERE P.고객번호=C.고객번호
GROUP BY YEAR,점포코드
ORDER BY 구매횟수 desc
FETCH FIRST 50 PERCENT ROWS ONLY;

-- # 고객별 멤버십 가입 현황
SELECT 고객번호, 멤버십명 FROM MEMBERSHIP
WHERE 고객번호 = ANY(SELECT 고객번호 FROM MEMBERSHIP GROUP BY 고객번호 HAVING COUNT(고객번호) > 1);

-- 지역별 나이대에 따른 고객분포와 소비금액
select 거주지역, 성별, 연령대, count(c.고객번호), sum(구매금액) from custdemo c,purprod p where c.고객번호=p.고객번호
group by 거주지역, 성별, 연령대 order by 거주지역;

-- 가장 많이 이용하는 제휴사
select 제휴사,count(*) from channel group by 제휴사; 

-- 거주지역별 매장 방문횟수
select distinct c.거주지역, 점포코드,count(점포코드) from custdemo c,purprod p
where c.고객번호=p.고객번호 group by c.거주지역,점포코드 order by count(점포코드) desc,거주지역;

-- 제휴사별 유출 고객수
select 제휴사,count(경쟁사) from compet group by 제휴사;

-- 편의품
SELECT * FROM PRODCL WHERE 분류 = any('가공식품', '신선식품', '일상용품', '의약품/의료기기', '교육/문화용품', '외식', '기타');

-- # 2014, 2015, 2년 합산 매출, 증감률
--CREATE TABLE "연도별매출비교" AS
SELECT "2014 구매금액" "2014", "2015 구매금액" "2015", "2014 구매금액" + "2015 구매금액" "합계",
TO_CHAR(("2015 구매금액"-"2014 구매금액")/"2015 구매금액"*100, '99.99') "증감률"
FROM 
(SELECT SUM(구매금액) "2014 구매금액" FROM PURPROD WHERE 연도 = 2014) a,
(SELECT SUM(구매금액) "2015 구매금액" FROM PURPROD WHERE 연도 = 2015) b;



-- # 제휴사, 년도별 총매출액
--CREATE TABLE "제휴사별연도별총매출액" AS
SELECT 제휴사, 연도, 성별, SUM(구매금액) "합계" FROM PURPROD GROUP BY 제휴사,연도,성별 ORDER BY 제휴사,연도;


-- # 각 제휴사에 방문한 고객별 구매건수
--CREATE TABLE "번호제휴성별연도건수매출" AS
SELECT P.고객번호, 제휴사, C.성별, 연도, COUNT(P.고객번호) "구매건수", sum(구매금액) "합계"
FROM PURPROD P, CUSTDEMO C
WHERE P.고객번호 = C.고객번호
GROUP BY P.고객번호, 제휴사, C.성별, 연도
ORDER BY P.고객번호, C.성별;

-- # 경쟁사 분석
SELECT a.고객번호, a.제휴사, B.성별, 연령대, 거주지역, 경쟁사이용횟수, 매출
FROM
(SELECT 고객번호, 제휴사, COUNT(경쟁사) "경쟁사이용횟수", SUBSTR(이용년월, 0, 4) "연도" FROM COMPET
GROUP BY 고객번호, 제휴사, SUBSTR(이용년월, 0, 4)
ORDER BY 고객번호) a,
(SELECT * FROM 번호제휴성별연도건수매출
WHERE 연도 = 2015) b,
CUSTDEMO C
WHERE a.고객번호 = b.고객번호 AND a.제휴사 = b.제휴사 AND a.고객번호 = c.고객번호 AND B.성별 = C.성별
ORDER BY a.고객번호;

select * from compet
where 이용년월 like '%2014%';

-- # 채널 분석
SELECT a.고객번호, 온라인, 이용횟수, sum(매출) "매출"
FROM CHANNEL a, 번호제휴성별연도건수매출 b
WHERE a.고객번호 = b.고객번호 AND SUBSTR(온라인, 1, 1) = b.제휴사
GROUP BY a.고객번호, 온라인, 이용횟수
ORDER BY a.고객번호, 온라인, 이용횟수;


-- # 셩별 별로 온라인 이용횟수
select 성별, sum(이용횟수) 이용횟수
from custdemo a, channel b where a.고객번호=b.고객번호
group by 성별;

-- # RFM 분석을 위해 최종 방문 날짜 구하기
--SELECT *
--FROM
--(SELECT 고객번호, 구매일자, SUM(구매금액), ROW_NUMBER() over(partition by 고객번호 order by 구매일자 desc) "순위" 
--FROM LCL GROUP BY 고객번호, 구매일자)
--WHERE 순위 = '1';

--- # 계열사 전체
SELECT 고객번호, TO_DATE(20151231)-MAX(TO_DATE(구매일자)) "Recency", COUNT(구매금액) "Frequency", SUM(구매금액) "Monetary"
FROM LCL
GROUP BY 고객번호
ORDER BY 고객번호;

--- # 제휴사 별
SELECT 고객번호, 제휴사, TO_DATE(20151231)-MAX(TO_DATE(구매일자)) "Recency", COUNT(구매금액) "Frequency", SUM(구매금액) "Monetary"
FROM LCL
GROUP BY 고객번호, 제휴사
ORDER BY 고객번호;


-- # 연령대별 분석
--- # 제휴사, 연령
SELECT 제휴사, 연령대, COUNT(연령대) "고객수", ROUND(avg(구매금액)) "평균금액", SUM(구매금액) "합계" FROM LCL
GROUP BY 제휴사, 연령대
ORDER BY 제휴사, 연령대;

--- # 성별, 연령
SELECT 성별, 연령대, COUNT(연령대) "고객수", ROUND(avg(구매금액)) "평균금액", SUM(구매금액) "합계", 연도 FROM LCL
GROUP BY 성별, 연령대, 연도
ORDER BY 성별, 연령대, 연도;


-- # 거주지역 분석
SELECT 거주지역, sum(고객수) "고객수", round(avg(평균금액)) "평균금액", sum(합계) "매출"
FROM 
(SELECT 거주지역, 연령대, COUNT(연령대) "고객수", ROUND(avg(구매금액)) "평균금액", SUM(구매금액) "합계", PERCENT_RANK() OVER (ORDER BY SUM(구매금액) DESC) "퍼센트" 
FROM LCL
GROUP BY 거주지역, 연령대)
--WHERE 퍼센트 <= 0.1
GROUP BY 거주지역
order by 평균금액 desc;

-- # 구매감소 고객의 상품 별 총구매액
SELECT a.고객번호, a.성별, a.연령대, a.지역, a.세분류명, a.분류, b.고객구분, a.기, sum(a.구매금액) "총구매액"
FROM LCL2 a
JOIN 증감고객 b ON a.고객번호 = b.고객번호
WHERE 고객구분 = '감소'
GROUP BY a.고객번호, a.성별, a.연령대, a.지역, a.세분류명, a.분류, b.고객구분, a.기
ORDER BY a.고객번호, a.성별, a.연령대, a.지역, a.세분류명, a.분류, b.고객구분, a.기;


-- # 지역별 매출액 증감
SELECT 지역, 매출액1기, 매출액7기 
FROM
(SELECT b.지역, sum(a.이용금액14_1) 매출액1기, sum(a.이용금액15_3) 매출액7기
FROM 증감고객 a, LCL2 b 
WHERE a.고객번호 = b.고객번호 
GROUP BY b.지역);


-- # 경쟁사, 채널 고객별 이용횟수
--- # 채널
SELECT 고객번호, SUM(이용횟수) FROM CHANNEL
GROUP BY 고객번호
ORDER BY SUM(이용횟수) DESC;

SELECT COUNT(DISTINCT 고객번호) FROM CHANNEL;

SELECT 고객번호, COUNT(고객번호) FROM COMPET
GROUP BY 고객번호
ORDER BY COUNT(고객번호) DESC;

--- # 경쟁사
SELECT COUNT(COUNT(고객번호)) FROM COMPET
GROUP BY 고객번호
ORDER BY COUNT(고객번호) DESC;

-- # 분기별 제휴사 총매출액 증감률
select a.제휴사, a.연도, a.분기, a.총구매액, b.연도, b.분기, b.총구매액, round((b.총구매액-a.총구매액)/b.총구매액 * 100, 2) "증감률"
from
(SELECT 제휴사, 연도, 분기, SUM(구매금액) "총구매액" FROM LCL where 연도 = 2014 GROUP BY 제휴사,연도,분기 ORDER BY 제휴사, 연도) a,
(SELECT 제휴사, 연도, 분기, SUM(구매금액) "총구매액" FROM LCL where 연도 = 2015 GROUP BY 제휴사,연도,분기 ORDER BY 제휴사, 연도) b
where a.제휴사 = b.제휴사 and a.분기 = b.분기;


-- # 기존고객 분기별 제휴사 총매출액
SELECT 제휴사, 연도, 분기, SUM(구매금액) "총구매액" 
FROM LCL a
join
분기기준고객 b on a.고객번호 = b.고객번호
where 연도 = 2014
GROUP BY 제휴사, 연도, 분기 
ORDER BY 제휴사, 연도;


-- # 기존고객 분기별 성별, 카테고리, 총매출액
SELECT 제휴사, 연도, 분기, 성별, 세분류명, SUM(구매금액) "총구매액" 
FROM LCL a
join
분기기준고객 b on a.고객번호 = b.고객번호
where 연도 = 2015
GROUP BY 제휴사, 연도, 분기, 성별, 세분류명
ORDER BY 제휴사, 연도, 분기, 세분류명;
-- # 고객별 2014년 대비 2015년 매출 증감률
--CREATE TABLE 고객별매출증감률 AS
SELECT C.고객번호, C.성별, NVL(A."2014", 0) "연도2014", NVL(B."2015", 0) "연도2015", ROUND((NVL("2015", 0)-NVL("2014", 0))/"2014"*100, 4) "증감률"
FROM
(SELECT 고객번호, 성별 FROM CUSTDEMO) C
FULL OUTER JOIN
(SELECT 고객번호, 성별, SUM(구매금액) "2015" FROM LCL
WHERE 연도 = 2015
GROUP BY 고객번호, 성별
ORDER BY 고객번호) B
ON C.고객번호 = B.고객번호 AND C.성별 = B.성별
FULL OUTER JOIN
(SELECT 고객번호, 성별, SUM(구매금액) "2014" FROM LCL
WHERE 연도 = 2014
GROUP BY 고객번호, 성별
ORDER BY 고객번호) A
ON A.고객번호 = C.고객번호 AND A.성별 = C.성별;

--- # 2015년 이탈고객
SELECT * FROM 고객별매출증감률
WHERE 연도2015 = 0;




-- # 연령별 매출 증감률
--CREATE TABLE 연령별매출증감률 AS
SELECT A.성별, A.연령대, A."고객수" 고객수14, B."고객수" 고객수15, A.평균금액 "평균금액14", B.평균금액 "평균금액15", A."합계" "매출14", B.합계 "매출15", ROUND((B.고객수-A.고객수)/A.고객수*100, 2) "고객수증감률", ROUND((B.합계-A.합계)/A.합계*100, 2) "매출증감률"
FROM
(SELECT 성별, 연령대, COUNT(연령대) "고객수", ROUND(avg(구매금액)) "평균금액", SUM(구매금액) "합계" FROM LCL
WHERE 연도 = 2014
GROUP BY 성별, 연령대
ORDER BY 성별, 연령대) A,
(SELECT 성별, 연령대, COUNT(연령대) "고객수", ROUND(avg(구매금액)) "평균금액", SUM(구매금액) "합계" FROM LCL
WHERE 연도 = 2015
GROUP BY 성별, 연령대
ORDER BY 성별, 연령대) B
where A.성별 = B.성별 AND A.연령대 = B.연령대;

SELECT * FROM 연령별매출증감률;

--- # 연도합산, 연령별 매출 증감률
SELECT a.*, round((b.고객수15-b.고객수14)/b.고객수14*100, 2) "고객수증감률", round((b.매출15-b.매출14)/b.매출14*100, 2) "매출증감률"
FROM
(SELECT 연령대, SUM(고객수14) "고객수14", SUM(고객수15) "고객수15", AVG(평균금액14) "평균금액14", AVG(평균금액15) "평균금액15", SUM(매출14) "매출14", SUM(매출15) "매출15" FROM 연령별매출증감률
GROUP BY 연령대
ORDER BY 연령대) a,
(SELECT 연령대, SUM(고객수14) "고객수14", SUM(고객수15) "고객수15", AVG(평균금액14) "평균금액14", AVG(평균금액15) "평균금액15", SUM(매출14) "매출14", SUM(매출15) "매출15" FROM 연령별매출증감률
GROUP BY 연령대
ORDER BY 연령대) b
where a.연령대 = b.연령대;




-- # 구매감소 고객의 상품 별 총구매액
SELECT a.고객번호, 성별, 연도, 분기, 세분류명, 분류, 고객구분, sum(구매금액) "총구매액"
FROM LCL a
JOIN 증감고객 b ON a.고객번호 = b.고객번호
WHERE 고객구분 = '감소'
GROUP BY a.고객번호, 성별, 연도, 분기, 세분류명, 분류, 고객구분
ORDER BY a.고객번호, 연도, 분기, 세분류명, 분류;


SELECT 연도, 분기, sum(구매금액) "총구매액"
FROM LCL a
JOIN 증감고객 b ON a.고객번호 = b.고객번호
WHERE 고객구분 = '증가' and 분기 = any('1분기', '3분기', '4분기')
GROUP BY 연도, 분기
ORDER BY 연도, 분기;


-- # 고객별 2014년 대비 2015년 매출 증감률
--CREATE TABLE 고객별매출증감률 AS
SELECT C.고객번호, C.성별, NVL(A."2014", 0) "연도2014", NVL(B."2015", 0) "연도2015", ROUND((NVL("2015", 0)-NVL("2014", 0))/"2014"*100, 4) "증감률"
FROM
(SELECT 고객번호, 성별 FROM CUSTDEMO) C
FULL OUTER JOIN
(SELECT 고객번호, 성별, SUM(구매금액) "2015" FROM LCL
WHERE 연도 = 2015
GROUP BY 고객번호, 성별
ORDER BY 고객번호) B
ON C.고객번호 = B.고객번호 AND C.성별 = B.성별
FULL OUTER JOIN
(SELECT 고객번호, 성별, SUM(구매금액) "2014" FROM LCL
WHERE 연도 = 2014
GROUP BY 고객번호, 성별
ORDER BY 고객번호) A
ON A.고객번호 = C.고객번호 AND A.성별 = C.성별;

--- # 2015년 이탈고객
SELECT * FROM 고객별매출증감률
WHERE 연도2015 = 0;

-- 1년 동안 최다 방문회수 매장과 매출
SELECT YEAR, 점포코드,ROUND(SUM(구매금액)/1000) 구매금액 ,count(구매금액) 구매횟수 
FROM PURPROD P, CUSTDEMO C WHERE P.고객번호=C.고객번호
GROUP BY YEAR,점포코드
HAVING SUM(구매금액) > (SELECT AVG(구매금액) FROM PURPROD)
ORDER BY 구매횟수 desc;

-- # 고객별 멤버십 가입 현황
SELECT 고객번호, 멤버십명 FROM MEMBERSHIP
WHERE 고객번호 = ANY(SELECT 고객번호 FROM MEMBERSHIP GROUP BY 고객번호 HAVING COUNT(고객번호) > 1);

--- # 2015년 구매감소 고객 확인하기
SELECT DISTINCT B.고객번호, B.성별, B.제휴사, B.세분류명, COUNT(B.세분류명) "구매횟수", B.분류, B.연도
FROM 고객별매출증감률 A, LCL B
WHERE 
A.고객번호 = B.고객번호 AND A.성별 = B.성별
AND 증감률 < 5.41
GROUP BY B.고객번호, B.성별, B.제휴사, B.세분류명, B.분류, B.연도
ORDER BY 고객번호, 분류;

-- # 분기 기준 고객 나누기
--- # 8분기 모두 구매한 고객
select 고객번호
from
(SELECT 고객번호, 연도, 분기, count(고객번호) "분기별구매횟수" FROM lcl
where 분기 = any('1분기', '2분기', '3분기', '4분기')
group by 고객번호, 연도, 분기
order by 고객번호)
group by 고객번호
having count(고객번호) = 8
order by 고객번호;

--- # 8분기 동안 계속 구매한 고객 수
select count(count(고객번호))
from
(SELECT 고객번호, 연도, 분기, count(고객번호) "분기별구매횟수" FROM lcl
where 분기 = any('1분기', '2분기', '3분기', '4분기')
group by 고객번호, 연도, 분기
order by 고객번호)
group by 고객번호
having count(고객번호) = 8
order by 고객번호;


-- # 반기 기준 고객 나누기
--- # 반기 기준 계속 구매한 고객 수
select 고객번호
from
(select 고객번호, count(고객번호)
from
(SELECT 고객번호, 연도 FROM lcl
where 분기 = any('1분기', '2분기')
group by 고객번호, 연도
order by 고객번호)
group by 고객번호
having count(고객번호) = 2
intersect
select 고객번호, count(고객번호)
from
(SELECT 고객번호, 연도 FROM lcl
where 분기 = any('3분기', '4분기')
group by 고객번호, 연도
order by 고객번호)
group by 고객번호
having count(고객번호) = 2
order by 고객번호);

--- # 반기 기준 계속 구매한 고객 수
select count(*)
from
(select 고객번호, count(고객번호)
from
(SELECT 고객번호, 연도 FROM lcl
where 분기 = any('1분기', '2분기')
group by 고객번호, 연도
order by 고객번호)
group by 고객번호
having count(고객번호) = 2
intersect
select 고객번호, count(고객번호)
from
(SELECT 고객번호, 연도 FROM lcl
where 분기 = any('3분기', '4분기')
group by 고객번호, 연도
order by 고객번호)
group by 고객번호
having count(고객번호) = 2
order by 고객번호);

-- # 기존고객 2014, 2015 개별 총구매액 비교
select *
from
(select sum(sum(구매금액)) "2014"
from 분기기준고객 b
join LCL a on b.고객번호 = a.고객번호
where 연도 = 2014
group by b.고객번호),
(select sum(sum(구매금액)) "2015"
from 분기기준고객 b
join LCL a on b.고객번호 = a.고객번호
where 연도 = 2015
group by b.고객번호);


--- # 비기존고객 고객번호
select 고객번호 from lcl
minus
select 고객번호 from 분기기준고객;


-- # 기존고객, 비기존고객의 중요도 비교
--- # 비기존고객의 2014, 2015 합산 총구매액
select sum(sum(구매금액))
from lcl a
join
(select 고객번호 from lcl
minus
select 고객번호 from 분기기준고객) b on a.고객번호 = b.고객번호
group by a.고객번호;

--- # 기존고객의 2014, 2015 합산 총구매액
select sum(sum(구매금액))
from lcl a
join 분기기준고객 b on a.고객번호 = b.고객번호
group by a.고객번호;

--- # 비기존고객의 2014, 2015 평균액
select avg(avg(구매금액))
from lcl a
join
(select 고객번호 from lcl
minus
select 고객번호 from 분기기준고객) b on a.고객번호 = b.고객번호
group by a.고객번호;

--- # 기존고객의 2014, 2015 평균액
select avg(avg(구매금액))
from lcl a
join 분기기준고객 b on a.고객번호 = b.고객번호
group by a.고객번호;

select a.고객번호, 연도, 분기, sum(구매금액) "총구매금액"
from lcl a
join 분기기준고객 b on a.고객번호 = b.고객번호
group by a.고객번호, 연도, 분기
order by a.고객번호, 연도, 분기;

select a.고객번호, 연도, 분기, sum(구매금액) "총구매금액"
from lcl a
join
(select 고객번호 from lcl
minus
select 고객번호 from 분기기준고객) b on a.고객번호 = b.고객번호
group by a.고객번호, 연도, 분기
order by a.고객번호, 연도, 분기;

-- # 신규, 기존, 이탈 평균금액
--- # 연도기준 증가 0% 기준 매출증가한 기존고객 평균구매액
SELECT round(sum(연도2015)/count(*)) FROM 고객별매출증감률
where 증감률 > 0;

--- # 연도기준 증가 5.14% 기준 매출증가한 기존고객의 평균구매액
SELECT round(sum(연도2015)/count(*)) FROM 고객별매출증감률
where 증감률 > 5.14;

--- # 연도기준 신규고객의 평균구매액
SELECT round(SUM(연도2015)/count(*)) FROM 고객별매출증감률
WHERE 연도2014 = 0;

-- # 연도기준 이탈고객의 평균구매액
SELECT round(SUM(연도2014)/count(*)) FROM 고객별매출증감률
WHERE 연도2015 = 0;

-- # 분기를 기수로 바꿔서 테이블 생성
--create table 기기
--(
--연도 number,
--분기 varchar2(10),
--기 varchar2(10)
--);
--
--insert into 기기(연도,분기,기) values(2014,'1분기','1기');
--insert into 기기(연도,분기,기) values(2014,'2분기','2기');
--insert into 기기(연도,분기,기) values(2014,'3분기','3기');
--insert into 기기(연도,분기,기) values(2014,'4분기','4기');
--insert into 기기(연도,분기,기) values(2015,'1분기','5기');
--insert into 기기(연도,분기,기) values(2015,'2분기','6기');
--insert into 기기(연도,분기,기) values(2015,'3분기','7기');
--insert into 기기(연도,분기,기) values(2015,'4분기','8기');

select a.고객번호, a.연도, a.분기, b.기 from lcl a
join
기기 b on a.연도 = b.연도 and a.분기 =  b.분기
where b.분기='3분기';



-- # 구매감소 고객의 상품 별 총구매액
SELECT a.고객번호, a.성별, a.연령대, d.지역, a.세분류명, a.분류, b.고객구분, c.기, sum(a.구매금액) "총구매액"
FROM LCL a
JOIN 증감고객 b ON a.고객번호 = b.고객번호
JOIN 기기 c ON a.연도 = c.연도 AND a.분기 = c.분기
JOIN CUSTDEMO d ON a.고객번호 = d.고객번호 AND a.성별 = d.성별 AND a.연령대 = d.연령대 AND a.거주지역 = d.거주지역
WHERE 고객구분 = '감소'
GROUP BY a.고객번호, a.성별, a.연령대, d.지역, a.세분류명, a.분류, b.고객구분, c.기
ORDER BY a.고객번호, a.성별, a.연령대, d.지역, a.세분류명, a.분류, b.고객구분, c.기;
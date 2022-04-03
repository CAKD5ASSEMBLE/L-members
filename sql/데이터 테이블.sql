--분석에 필요한 테이블 생성

--'CUSTDEMO, PRODCL, PURPROD 테이블 합치기'
CREATE TABLE LCL2 AS
SELECT *
FROM
(SELECT 프로드.고객번호, 데모.성별, 데모.연령대, 프로드.제휴사, 프로드.세분류명, 프로드.분류, 프로드.소분류명, 프로드.구매일자, 프로드.월, 프로드.구매시간, 프로드.구매금액, 데모.지역,기.기
FROM LCL "프로드"
LEFT OUTER JOIN CUSTDEMO "데모"
ON 프로드.고객번호 = 데모.고객번호
LEFT OUTER JOIN 기기 "기"
ON 프로드.연도 = 기.연도 AND 프로드.분기=기.분기)
ORDER BY 고객번호, 제휴사,구매일자;

-- 고객별 2014년 대비 2015년 매출 증감률
CREATE TABLE 고객별매출증감률 AS
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

--- # 연령별 매출 증감률'
CREATE TABLE 연령별매출증감률 AS
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
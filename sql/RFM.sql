'RFM 분석을 위해 최종 방문 날짜 구하기'

-- # RFM 분석을 위해 최종 방문 날짜 구하기
--SELECT *
--FROM
--(SELECT 고객번호, 구매일자, SUM(구매금액), ROW_NUMBER() over(partition by 고객번호 order by 구매일자 desc) "순위" 
--FROM LCL GROUP BY 고객번호, 구매일자)
--WHERE 순위 = '1';

--- # 제휴사 별
SELECT 고객번호, 제휴사, TO_DATE(20151231)-MAX(TO_DATE(구매일자)) "Recency", COUNT(구매금액) "Frequency"
FROM LCL
GROUP BY 고객번호, 제휴사, 분기
ORDER BY 고객번호;

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

--- # 2014년 기준 RFM 계열사 전체
SELECT 고객번호, TO_DATE(20141231)-MAX(TO_DATE(구매일자)) "Recency", COUNT(구매금액) "Frequency", SUM(구매금액) "Monetary"
FROM LCL
WHERE 연도 = 2014
GROUP BY 고객번호
ORDER BY 고객번호;

--- # 2015년 기준 RFM 계열사 전체
SELECT 고객번호, TO_DATE(20151231)-MAX(TO_DATE(구매일자)) "Recency", COUNT(구매금액) "Frequency", SUM(구매금액) "Monetary"
FROM LCL
WHERE 연도 = 2015
GROUP BY 고객번호
ORDER BY 고객번호;
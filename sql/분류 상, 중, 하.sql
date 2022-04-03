-- # 카테고리 상, 중, 하로 다시 나누기
--- # 분류등급 컬럼 추가
alter table lcl2 add 분류등급 varchar2(50);
--평균값 모음
SELECT
(select avg(구매금액) from lcl2 where 분류='유아동'), 
(select avg(구매금액) from lcl2 where 분류='신선식품'), 
(select avg(구매금액) from lcl2 where 분류='가공식품'), 
(select avg(구매금액) from lcl2 where 분류='의약품/의료기기'),
(select avg(구매금액) from lcl2 where 분류='외식'),
(select avg(구매금액) from lcl2 where 분류='일상용품'), 
(select avg(구매금액) from lcl2 where 분류='의류'),
(select avg(구매금액) from lcl2 where 분류='가구/인테리어'),
(select avg(구매금액) from lcl2 where 분류='패션잡화'), 
(select avg(구매금액) from lcl2 where 분류='디지털/가전'), 
(select avg(구매금액) from lcl2 where 분류='명품'),  
(select avg(구매금액) from lcl2 where 분류='전문스포츠/레저'), 
(select avg(구매금액) from lcl2 where 분류='교육/문화용품') FROM DUAL; 

SELECT a.고객번호, a.분류등급, b.고객구분, a.기, sum(a.구매금액) "총구매액"
FROM LCL2 a 
JOIN 고정고객 b ON a.고객번호 = b.고객번호
where 분류 = '신선식품'
GROUP BY a.고객번호, a.분류등급, b.고객구분, a.기
ORDER BY a.고객번호, a.분류등급, b.고객구분, a.기

update lcl2 set 분류등급 = '의류_상' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '의류' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) >= 212802);

update lcl2 set 분류등급 = '의류_중' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '의류' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 212802  and (sum(구매금액)/count(구매금액)) >= 141868);

update lcl2 set 분류등급 = '의류_하' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '의류' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 141868);

update lcl2 set 분류등급 = '패션잡화_상' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '패션잡화' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) >= 131170);

update lcl2 set 분류등급 = '패션잡화_중' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '패션잡화' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 131170  and (sum(구매금액)/count(구매금액)) >= 87447);

update lcl2 set 분류등급 = '패션잡화_하' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '패션잡화' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 87447);

update lcl2 set 분류등급 = '신선식품_상' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '신선식품' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) >= 10186);

update lcl2 set 분류등급 = '신선식품_중' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '신선식품' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 10186  and (sum(구매금액)/count(구매금액)) >= 6791);

update lcl2 set 분류등급 = '신선식품_하' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '신선식품' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 6791);

update lcl2 set 분류등급 = '일상용품_상' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '일상용품' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) >= 27271);

update lcl2 set 분류등급 = '일상용품_중' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '일상용품' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 27271  and (sum(구매금액)/count(구매금액)) >= 18180);

update lcl2 set 분류등급 = '일상용품_하' 
where 소분류명 =
any(select 소분류명 from lcl2 
where 분류 = '일상용품' group by 분류등급, 소분류명 
having (sum(구매금액)/count(구매금액)) < 18180);

commit;
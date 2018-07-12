-- 1.
select table_name from user_tables where table_name='D_BASE2_2' ;

-- 2.
TRUNCATE TABLE D_BASE2_2 ;

-- 3.
create table D_BASE2_2 ( 
               항만 varchar2(20) primary key, 
               입항선박수 number(5), 
               입항선박톤수 number(10), 
               출항선박수 number(5), 
               출항선박톤수 number(10)) ;

-- 4.
select 항만 
                          , 입항선박수
                          , round(avg(입항선박수) over (partition by floor(입항선박수/500)), 0) 입항선박수_평활
                          , 출항선박수
                          , round(avg(출항선박수) over (partition by floor(출항선박수/500)), 0) 출항선박수_평활
                      from D_BASE2_2 ;

-- 5.
create or replace view 입항_median_view
           as 
           select 항만
                , 입항선박수
                , bin_id /* 구간 id */
                , rnum /* 구간 내의 위치 */
                , floor((cnt + 1) / 2) med1 /* 구간의 중앙 위치(왼쪽) */
                , ceil((cnt + 1) / 2) med2 /* 구간의 중앙 위치(오른쪽) */
           from ( select 항만
                       , 입항선박수
                       , floor(입항선박수 / 500) bin_id
                       , row_number() over (partition by floor(입항선박수 / 500) order by 입항선박수) rnum
                       , count(*) over (partition by floor(입항선박수 / 500)) cnt
                  from D_BASE2_2 ) ;

-- 6.
          select 항만
               , min(decode(gubun, 1, col1)) 입항선박수
               , min(decode(gubun, 1, col2)) 입항선박수_평활
               , min(decode(gubun, 2, col1)) 출항선박수
               , min(decode(gubun, 2, col2)) 출항선박수_평활
          from ( select 1 gubun /* 입항선박수 중앙값 구하기 */
                      , a.항만
                      , a.입항선박수 col1
                        /* b.입항선박수 : 구간 내 중앙(왼쪽)값, c.입항선박수 : 구간 내 중앙(오른쪽)값 */
                      , round((b.입항선박수+c.입항선박수) / 2, 0) col2
                 from 입항_median_view a, 입항_median_view b, 입항_median_view c
                 where a.bin_id = b.bin_id and a.med1 = b.rnum
                   and a.bin_id = c.bin_id and a.med2 = c.rnum
                 union all
                 select 2 gubun /* 출항선박수 중앙값 구하기 */
                      , a.항만
                      , a.출항선박수 col1
                        /* b.출항선박수 : 구간 내 중앙(왼쪽)값, c.출항선박수 : 구간 내 중앙(오른쪽)값 */
                      , round((b.출항선박수 + c.출항선박수) / 2, 0) col2
                 from 출항_median_view a, 출항_median_view b, 출항_median_view c
                 where a.bin_id = b.bin_id and a.med1 = b.rnum
                   and a.bin_id = c.bin_id and a.med2 = c.rnum )
          group by 항만 ;

-- 7.
select 항만
                          , 입항선박수
                          , case when (입항선박수 - 입항_경계_최소) < (입항_경계_최대 - 입항선박수) then 입항_경계_최소
                            else 입항_경계_최대 end 입항선박수_평활
                          , 출항선박수
                          , case when (출항선박수 - 출항_경계_최소) < (출항_경계_최대 - 출항선박수) then 출항_경계_최소
                            else 출항_경계_최대 end 출항선박수_평활
                      from (
                             select 항만
                                  , 입항선박수
                                  , floor(입항선박수/500)*500 입항_경계_최소
                                  , floor(입항선박수/500)*500 + 500 입항_경계_최대
                                  , 출항선박수
                                  , floor(출항선박수/500)*500 출항_경계_최소
                                  , floor(출항선박수/500)*500 + 500 출항_경계_최대
                             from D_BASE2_2 ) ;



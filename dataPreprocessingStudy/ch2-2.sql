-- 1.
select table_name from user_tables where table_name='D_BASE2_2' ;

-- 2.
TRUNCATE TABLE D_BASE2_2 ;

-- 3.
create table D_BASE2_2 ( 
               �׸� varchar2(20) primary key, 
               ���׼��ڼ� number(5), 
               ���׼������ number(10), 
               ���׼��ڼ� number(5), 
               ���׼������ number(10)) ;

-- 4.
select �׸� 
                          , ���׼��ڼ�
                          , round(avg(���׼��ڼ�) over (partition by floor(���׼��ڼ�/500)), 0) ���׼��ڼ�_��Ȱ
                          , ���׼��ڼ�
                          , round(avg(���׼��ڼ�) over (partition by floor(���׼��ڼ�/500)), 0) ���׼��ڼ�_��Ȱ
                      from D_BASE2_2 ;

-- 5.
create or replace view ����_median_view
           as 
           select �׸�
                , ���׼��ڼ�
                , bin_id /* ���� id */
                , rnum /* ���� ���� ��ġ */
                , floor((cnt + 1) / 2) med1 /* ������ �߾� ��ġ(����) */
                , ceil((cnt + 1) / 2) med2 /* ������ �߾� ��ġ(������) */
           from ( select �׸�
                       , ���׼��ڼ�
                       , floor(���׼��ڼ� / 500) bin_id
                       , row_number() over (partition by floor(���׼��ڼ� / 500) order by ���׼��ڼ�) rnum
                       , count(*) over (partition by floor(���׼��ڼ� / 500)) cnt
                  from D_BASE2_2 ) ;

-- 6.
          select �׸�
               , min(decode(gubun, 1, col1)) ���׼��ڼ�
               , min(decode(gubun, 1, col2)) ���׼��ڼ�_��Ȱ
               , min(decode(gubun, 2, col1)) ���׼��ڼ�
               , min(decode(gubun, 2, col2)) ���׼��ڼ�_��Ȱ
          from ( select 1 gubun /* ���׼��ڼ� �߾Ӱ� ���ϱ� */
                      , a.�׸�
                      , a.���׼��ڼ� col1
                        /* b.���׼��ڼ� : ���� �� �߾�(����)��, c.���׼��ڼ� : ���� �� �߾�(������)�� */
                      , round((b.���׼��ڼ�+c.���׼��ڼ�) / 2, 0) col2
                 from ����_median_view a, ����_median_view b, ����_median_view c
                 where a.bin_id = b.bin_id and a.med1 = b.rnum
                   and a.bin_id = c.bin_id and a.med2 = c.rnum
                 union all
                 select 2 gubun /* ���׼��ڼ� �߾Ӱ� ���ϱ� */
                      , a.�׸�
                      , a.���׼��ڼ� col1
                        /* b.���׼��ڼ� : ���� �� �߾�(����)��, c.���׼��ڼ� : ���� �� �߾�(������)�� */
                      , round((b.���׼��ڼ� + c.���׼��ڼ�) / 2, 0) col2
                 from ����_median_view a, ����_median_view b, ����_median_view c
                 where a.bin_id = b.bin_id and a.med1 = b.rnum
                   and a.bin_id = c.bin_id and a.med2 = c.rnum )
          group by �׸� ;

-- 7.
select �׸�
                          , ���׼��ڼ�
                          , case when (���׼��ڼ� - ����_���_�ּ�) < (����_���_�ִ� - ���׼��ڼ�) then ����_���_�ּ�
                            else ����_���_�ִ� end ���׼��ڼ�_��Ȱ
                          , ���׼��ڼ�
                          , case when (���׼��ڼ� - ����_���_�ּ�) < (����_���_�ִ� - ���׼��ڼ�) then ����_���_�ּ�
                            else ����_���_�ִ� end ���׼��ڼ�_��Ȱ
                      from (
                             select �׸�
                                  , ���׼��ڼ�
                                  , floor(���׼��ڼ�/500)*500 ����_���_�ּ�
                                  , floor(���׼��ڼ�/500)*500 + 500 ����_���_�ִ�
                                  , ���׼��ڼ�
                                  , floor(���׼��ڼ�/500)*500 ����_���_�ּ�
                                  , floor(���׼��ڼ�/500)*500 + 500 ����_���_�ִ�
                             from D_BASE2_2 ) ;



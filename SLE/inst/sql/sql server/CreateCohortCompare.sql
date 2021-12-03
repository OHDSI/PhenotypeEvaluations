/************************************************************************
@file CreateCohortCompare.sql
************************************************************************/

{DEFAULT @cdm_database_schema = 'CDM_SIM' }
{DEFAULT @cohort_database_schema = 'CDM_SIM' }
{DEFAULT @cohort_database_table = 'cohort'
{DEFAULT @original_cohort_id = 0 }
{DEFAULT @compare_cohort_id = 99999 }
{DEFAULT @compare_count = 10 }
{DEFAULT @look_back = 365 }

--Bring in cohort data for comparison
select subject_id, cohort_start_date, date_part(y, cohort_start_date) yr,  date_part(month, cohort_start_date) mon, p.year_of_birth, p.gender_concept_id 
into #temp_table_2
from @cohort_database_schema.@cohort_database_table co
join @cdm_database_schema.person p
  on co.subject_id = p.person_id
where co.cohort_definition_id = @original_cohort_id;

--group members of cohort by matching criteria (cohort start month and year, birth year and sex) and get counts of groups  
select date_part(y, cohort_start_date) yr,  date_part(month, cohort_start_date) mon, 
  year_of_birth, gender_concept_id, count(subject_id) cnt
into #temp_table_3
from #temp_table_2
group by date_part(y, cohort_start_date),  date_part(month, cohort_start_date), 
  year_of_birth, gender_concept_id;

--find up to 30 matches for cohort members by matching criteria
select *
into #temp_table_4
from 
  (select co.year_of_birth year_of_birth_dx, co.gender_concept_id gender_concept_id_dx, co.yr yr_dx, co.mon mon_dx,
    p2.person_id, min(vo.visit_start_date) over (partition by p2.person_id, co.year_of_birth, co.gender_concept_id,
                                                      co.yr, co.mon) visit_start_date, 
    date_part(y, min(visit_start_date) over (partition by p2.person_id, co.year_of_birth, co.gender_concept_id,
                                                  co.yr, co.mon)) yr2, 
    date_part(month, min(visit_start_date) over (partition by p2.person_id, co.year_of_birth, co.gender_concept_id,
                                                      co.yr, co.mon)) mon2, 
    p2.year_of_birth year_of_birth2, p2.gender_concept_id gender_concept_id2,
    row_number() over (partition by co.year_of_birth, co.gender_concept_id,
                          co.yr, co.mon order by random()) rn
  from #temp_table_3 co
  join @cdm_database_schema.person p2
    on co.year_of_birth = p2.year_of_birth
    and co.gender_concept_id = p2.gender_concept_id
    and p2.person_id not in (
      select subject_id
      from #temp_table_2)
  join @cdm_database_schema.visit_occurrence vo
    on vo.person_id = p2.person_id
    and date_part(month, vo.visit_start_date) = co.mon
    and date_part(y, vo.visit_start_date) = co.yr
  join @cdm_database_schema.observation_period ob
    on vo.person_id = ob.person_id
      and vo.visit_start_date >= ob.observation_period_start_date
      and vo.visit_start_date <= ob.observation_period_end_date
      and vo.visit_start_date >= dateadd(d, @look_back, ob.observation_period_start_date)) a
join #temp_table_3 co
  on a.yr_dx = co.yr
    and a.mon_dx = co.mon
    and a.year_of_birth2 = co.year_of_birth
    and a.gender_concept_id2 = co.gender_concept_id
    and a.rn <= 10*co.cnt*3
order by co.year_of_birth, co.gender_concept_id, co.yr, co.mon, rn;

--keep only one entry for any selected matched subject
select person_id, gender_concept_id, year_of_birth, min(visit_start_date) visit_start_date
into #temp_table_5
from #temp_table_4
group by person_id, gender_concept_id, year_of_birth;

--randomize the matched subjects in each matching criteria group
select person_id, gender_concept_id, year_of_birth, visit_start_date, date_part(y, visit_start_date) yr, date_part(mon, visit_start_date) mon,
  row_number() over (partition by gender_concept_id, year_of_birth, date_part(y, visit_start_date), date_part(mon, visit_start_date)
                          order by random()) rn
into #temp_table_6
from #temp_table_5
order by gender_concept_id, year_of_birth, visit_start_date, date_part(y, visit_start_date), date_part(mon, visit_start_date);

--create a proper cohort table from the matched subjects and insert into designated location
insert into @cohort_database_schema.@cohort_database_table
select @compare_cohort_id as cohort_definition_id, a.person_id subject_id, visit_start_date cohort_start_date, 
  cast(dateadd(d, 1, visit_start_date) as date) cohort_end_date
from #temp_table_6 a
join #temp_table_3 b
  on a.gender_concept_id = b.gender_concept_id
    and a.year_of_birth = b.year_of_birth
    and a.yr = b.yr
    and a.mon = b.mon
where a.rn <= @compare_count*b.cnt;


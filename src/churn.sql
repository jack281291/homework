CREATE table count_users as SELECT date, COUNT(distinct user_id) as n_users from transactions GROUP By date 

CREATE TABLE dates_range as SELECT * FROM (
WITH RECURSIVE dates(date) AS (
  VALUES('2019-07-01')
  UNION ALL
  SELECT date(date, '+1 day')
  FROM dates
  WHERE date < '2020-06-30'
)
SELECT date as date_now FROM dates)

/* Here I'm assuminig that we have all the transactions in one table and I'm taking all the user_id in order to evaluate their status for each day bettween 
2019-07-01 and 2020-06-30 */
CREATE table transactions_0 as 
SELECT t1.user_id, t2.date_now from 
((select distinct user_id, 1 as k from transactions) as t1 left JOIN (SELECT date_now, 1 as k from dates_range) as t2 on t1.k = t2.k)
order by date_now;

create table transactions_1 as select distinct t.*, t2.* from transactions_0 t left join transactions t2
on t.user_id = t2.user_id where t.date_now >= t2.date;

select count(user_id) as n_user, date_now, status from (select t.*,
       (case when date_now = min(date) over (partition by user_id)
             then 'New'
             when date_now < date(lag(date) over (partition by user_id order by date), "+28 Days")
             then 'Active'
             when date_now < date(lead(date) over (partition by user_id order by date),  "-28 Days")
             then 'Churned'
             else 'Reactivated'
        end) as status
from transactions_1 t) group by date_now, status

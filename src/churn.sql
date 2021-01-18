create table transactions_0 as select distinct user_id, DATE("2020-01-01") as date_now from transactions;

create table transactions_1 as select distinct t.*, t2.* from transactions_0 t left join transactions t2
on t.user_id = t2.user_id where t.date_now >= t2.date_;

select count(user_id) as n_user, date_now, status from (select t.*,
       (case when date_now = min(date_) over (partition by user_id)
             then 'New'
             when date_now < date(lag(date_) over (partition by user_id order by date_), "+28 Days")
             then 'Active'
             when date_now < date(lead(date_) over (partition by user_id order by date_),  "-28 Days")
             then 'Churned'
             else 'Reactivated'
        end) as status
from transactions_1 t) group by date_now, status

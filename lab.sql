/* example of a lateral join */

select *
from credit_cards as c
cross join lateral (
    select
        cc_num,
        amount,
        purchase_time
    from transactions as t
    where c.cc_num = t.cc_num
    order by purchase_time desc
    limit 3
) as q

/*
- cc_num
- cc_holder_name
- cc_num
- amount
- purchase_time
*/
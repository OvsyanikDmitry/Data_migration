--shipping_datamart
CREATE or REPLACE VIEW public.shipping_datamart AS
with sh as (
select distinct ss.shippingid,ss.state,
ss.shipping_start_fact_datetime,
ss.shipping_end_fact_datetime,
s.shipping_plan_datetime,
date_part('day', ss.shipping_end_fact_datetime - ss.shipping_start_fact_datetime) as full_day_at_shipping,
case when shipping_end_fact_datetime>shipping_plan_datetime then 1 else 0
end is_delay,--is_delay
case when ss.state = 'finished' then 1 else 0
end is_shipping_finish --is_shipping_finish
from public.shipping_status ss
join public.shipping s
on ss.shippingid =s.shippingid
) select distinct
  si.shippingid, si.vendorid, t.transfer_type,
  sh.full_day_at_shipping,sh.is_delay,sh.is_shipping_finish,
  si.payment_amount,
  payment_amount*(t.shipping_transfer_rate + sc.shipping_country_base_rate + sa.agreement_rate)as vat,
  payment_amount*sa.agreement_commission as profit,
  case when is_delay = 1 then
  (date_part('day',sh.shipping_end_fact_datetime - sh.shipping_plan_datetime))
  else 0 end delay_day_at_shipping
      from public.shipping_info si
        join public.shipping_transfer t
        on si.transfer_type_id = t.transfer_type_id
          join public.shipping_country_rates sc
          on si.shipping_country_id  = sc.shipping_country_id
            join public.shipping_agreement sa
            on si.agreementid = sa.agreementid
              join sh
              on si.shippingid=sh.shippingid
              where sh.is_shipping_finish in (select max(sh.is_shipping_finish)from sh)
              ;

select * from public.shipping_datamart;

--public.shipping_country_rates
CREATE SEQUENCE shipping_country_seq START 1;
insert into public.shipping_country_rates
(shipping_country_id,shipping_country,shipping_country_base_rate)
select
  nextval('shipping_country_seq')::int AS id,
  shipping_country,
  shipping_country_base_rate
  from (select distinct shipping_country, shipping_country_base_rate
				from public.shipping) as a;
drop sequence shipping_country_seq;

--public.shipping_agreement
insert into public.shipping_agreement(agreementid,agreement_number,agreement_rate,agreement_commission)
select distinct
descriptions[1]::int as agreementid,
descriptions[2] as agreement_number,
descriptions[3]::numeric(14,3) as agreement_rate,
descriptions[4]::numeric(14,3) as agreement_commission
from (
select
regexp_split_to_array(vendor_agreement_description, E'\\:+') as descriptions
from public.shipping) as a
;

--public.shipping_transfer
CREATE SEQUENCE transfer_type_id_seq START 1;
insert into public.shipping_transfer (transfer_type_id,transfer_type,transfer_model,shipping_transfer_rate)
select distinct
nextval('transfer_type_id_seq')::int AS transfer_type_id,
transfer_type,
transfer_model,
shipping_transfer_rate
from
(
	select distinct
	shipping_transfer_rate,
	(regexp_split_to_array(shipping_transfer_description, E'\\:+'))[1] as transfer_type,
	(regexp_split_to_array(shipping_transfer_description, E'\\:+'))[2] as transfer_model
	from public.shipping
) as a;

drop sequence transfer_type_id_seq;

--shipping_info
insert into public.shipping_info
  select distinct shippingid, vendorid, payment_amount, shipping_plan_datetime,
  transfer_type_id, shipping_country_id, agreementid from (
  with transfer as (
  	select transfer_type_id,
  	transfer_type||':'||transfer_model as shipping_transfer_description
  	from public.shipping_transfer
  	),
  		agreement as (select agreementid,
  					  agreementid||':'||agreement_number||':'||agreement_rate::NUMERIC(14,2)
  					  ||':'||agreement_commission::NUMERIC(14,2) as vendor_agreement_description
  				      from public.shipping_agreement)
  select s.shippingid,s.vendorid,s.payment_amount,s.shipping_plan_datetime,
  st.transfer_type_id,
  sc.shipping_country_id,
  sa.agreementid
  from public.shipping s
  join transfer st
  on s.shipping_transfer_description = st.shipping_transfer_description
  join public.shipping_country_rates sc
  on s.shipping_country = sc.shipping_country
  join agreement sa
  on s.vendor_agreement_description = sa.vendor_agreement_description
  ) as a
;



--shipping_status

insert into public.shipping_status
select distinct shippingid,state,status,shipping_start_fact_datetime,shipping_end_fact_datetime
  from (
  with start_dt as (
      select distinct shippingid, state, status, state_datetime as shipping_start_fact_datetime
      from public.shipping
      where state ='booked'),
        finish_dt as (
        select distinct shippingid, state, status, state_datetime as shipping_end_fact_datetime
        from public.shipping
        where state ='recieved')
  select s.shippingid, s.state, s.status,
  st.shipping_start_fact_datetime,
  f.shipping_end_fact_datetime
  from public.shipping s
  join start_dt as st
  on s.shippingid = st.shippingid
  join finish_dt as f
  on s.shippingid = f.shippingid
  join
  ( select orderid, status, state
  from (
  select orderid ,status, state,
  row_number() over(partition by orderid order by state_datetime desc ) as rn
  from public.shipping
  ) as a
  where rn = 1
  ) as final_status
  on final_status.orderid = s.orderid
  and final_status.status = s.status
  and final_status.state = s.state
  ) as t
  ;

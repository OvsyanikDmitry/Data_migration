

--shipping_country_rates
DROP TABLE IF EXISTS public.shipping_country_rates;
CREATE TABLE public.shipping_country_rates(
  shipping_country_id SERIAL PRIMARY KEY,
  shipping_country TEXT,
  shipping_country_base_rate NUMERIC(14,3)
);
CREATE INDEX shipping_country_id
ON public.shipping_country_rates (shipping_country_id);


--shipping_agreement
DROP TABLE IF EXISTS public.shipping_agreement;
CREATE TABLE public.shipping_agreement (
  agreementid INT PRIMARY KEY,
  agreement_number TEXT,
  agreement_rate NUMERIC(14,3),
  agreement_commission NUMERIC(14,3)
)
;
CREATE INDEX agreementid
ON public.shipping_agreement (agreementid);


--shipping_transfer
DROP TABLE IF EXISTS public.shipping_transfer;
CREATE TABLE public.shipping_transfer (
    transfer_type_id SERIAL PRIMARY KEY,
    transfer_type TEXT,
    transfer_model TEXT,
    shipping_transfer_rate NUMERIC(14,3)
  )
;
CREATE INDEX transfer_type_id
ON public.shipping_transfer (transfer_type_id);

--shipping_info
DROP TABLE IF EXISTS public.shipping_info;
CREATE TABLE public.shipping_info (
  shippingid BIGINT PRIMARY KEY,
  vendorid BIGINT,
  payment_amount NUMERIC(14,2),
  shipping_plan_datetime TIMESTAMP,
  transfer_type_id BIGINT,
  shipping_country_id BIGINT,
  agreementid INT,
  FOREIGN KEY (transfer_type_id) REFERENCES shipping_transfer(transfer_type_id)
  ON UPDATE cascade,
  FOREIGN KEY (shipping_country_id) REFERENCES shipping_country_rates(shipping_country_id)
  ON UPDATE cascade,
  FOREIGN KEY (agreementid) REFERENCES shipping_agreement(agreementid)
  ON UPDATE cascade
);
CREATE INDEX shippingid_info on public.shipping_info(shippingid);


--shipping_status
DROP TABLE IF EXISTS public.shipping_status  ;
CREATE TABLE public.shipping_status(
  shippingid BIGINT PRIMARY KEY,
  status TEXT,
  state TEXT,
  shipping_start_fact_datetime TIMESTAMP,
  shipping_end_fact_datetime TIMESTAMP
);
CREATE INDEX shippingid_status on public.shipping_status (shippingid);

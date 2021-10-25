select
a.*,  trim(lg_product_l08_name),  trim(lg_product_l07_name)
from dwpviewa.FQ_Consol_Ledger a
left join dwpviewa.LG_Hier_Product as prod
on a.LG_Product_ID = prod.LG_Product_ID
and '29991231' between prod.from_date and prod.to_date
where a.reporting_mth in ('201807')
and date between a.from_date and a.to_date
and trim(lg_product_l08_key) in ('Fmwrs','CPWRS')
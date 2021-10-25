
--**** CLEAR CURRENT MONTH DATA ****
delete 
from    finiq.rafc_sme_fq_adjusted_instr
where    to_date = 1200731;
    
-- ***  UPLOAD CURRENT MONTH DATA ***
insert into finiq.RAFC_sme_fq_adjusted_instr
sel case when RAGL.Bal_Type_Code in ('BAL') then 'EOP'
    when RAGL.Bal_Type_Code in ('MAB', 'MAC', 'MAD') then 'MAB'
    else 'PNL'
    end (Named Metric_code)
     , '001' (Named LG_Entity_Id) 
    ,RAGL.Acctg_Cntr_Id (Named LG_Cost_Centre_Id)        
    ,RAGL.Acctg_Acct_Id (Named LG_Account_Id)
    ,RAGL.Acctg_Pdct_Id (Named LG_Product_Id)     
    ,trim(Rlshp_Centre_Id) (Named LG_Relationship_Centre_Id)    
    ,'' (Named Lg_Location_Id)
    ,trim(RAGL.Rpt_Centre_Id) (Named Reporting_Centre_Id)
    ,RAGL.From_Date                     
    ,RAGL.To_Date                       
    , cast((RAGL.to_date (format 'YYYYMM')) as char(6)) (Named Reporting_Mth)           
    ,sum(-Bal_Amt) (Named Metric_Amt) 
    ,NULL (Named SME_Account_Id)
    ,NULL (Named SME_Debit_Centre_Id)         
    ,NULL (Named SME_Credit_Centre_Id)        
    ,NULL (Named State_Centre)    
    ,'Base Data' (Named Description)    
 from EWP1VAFCA.RAFC_Armt_GL_Compnt_Mth RAGL
inner join dwpviewa.lg_hier_centre hc
    on RAGL.Acctg_Cntr_Id = hc.lg_centre_id
    and hc.lg_centre_l14_key = 'RB4892'
    and hc.lg_centre_l13_key <> '187405'
    and hc.lg_centre_l12_key <> '400150'
	and hc.lg_sgb_centre_Ind = 'Y'
    and 1200731 BETWEEN hc.From_Date and hc.TO_DATE 
inner join dwpviewa.lg_hier_centre hrc
    on RAGL.Rpt_Centre_Id = hrc.lg_centre_id
    and hrc.lg_centre_l14_key = 'RB4892'
    and 1200731 BETWEEN hrc.From_Date and hrc.TO_DATE 
inner join  dwpviewa.LG_Hier  la1
    on RAGL.Acctg_Acct_Id = la1.child_id
    and Segment_Type = 'Account'     
    and Parent1_Id = 'MARACT'
    and (Parent6_Id in ('ALOANS','LCUSDP','LACCEP') 
    or Parent8_Id = 'ICMARG')
    and Parent7_Id <>'ALPRO1'
    and 1200731  between la1.From_Date and la1.To_Date    
where RAGL.Acctg_Pdct_Id <> '00000'
and RAGL.Acctg_Cntr_Id <> '848383'
and 1200731  between RAGL.From_Date and RAGL.To_Date
-- ****  Acct_key to  Armt_Key mapping ****
and RAGL.Armt_Key in
(sel distinct aal.armt_key
from dwpviewa.CIS_Cust_Outline_SME CCOS
join dwpviewa.Acct_CIS_Cust_Link accl
    on accl.cis_key = ccos.cis_key
    and 1200731 between accl.from_date and accl.to_date
    and accl.cust_role_code = 'PRN'
join dwpviewa.Acct_Armt_Link aal
    on accl.acct_key = aal.acct_key
    and 1200731 between aal.from_date and aal.to_date
where 1200731 between ccos.from_date and ccos.to_date) 

group by 1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17;


/* State Centre */    
update finiq.rafc_sme_fq_adjusted_instr
    from (
        sel distinct  LGHC.Child_id, SMJ.SME_Credit_Centre_Id (Named State_centre_id)
            from finiq.sme_journal_mapping SMJ
                   INNER  JOIN dwpviewa.LG_Hier  LGHC
                                ON  LGHC.Segment_Type = 'Centre'     
                                AND LGHC.Parent1_Id = 'CNTINT'
                                AND LGHC.Parent3_Id = 'RB4892'
                                AND 1200731 BETWEEN LGHC.From_Date and LGHC.TO_DATE
                                AND (LGHC.Child_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent1_id = SMJ.SME_Debit_Centre_Id    
                                OR   LGHC.Parent2_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent3_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent4_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent5_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent6_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent7_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent8_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent9_id = SMJ.SME_Debit_Centre_Id)
                                
            WHERE Mapping_Type = 'State_Centre'
            AND 1200731 BETWEEN SMJ.From_Date and SMJ.TO_DATE) Ct_Map
            
    set State_Centre = State_centre_id
    
    WHERE Ct_Map.Child_id = reporting_centre_id
    and To_Date = 1200731;

/*  Non Interest Income  */
insert into finiq.rafc_sme_fq_adjusted_instr
sel 
    Metric_code
    ,'999' (Named Lg_Entity_id)
    ,'848702' (Named Lg_Cost_centre_Id)
    ,'601320' (Named Lg_account_Id)  /* Default NOINTE account */
    ,fal.Lg_Product_Id
    ,'848702' (Named Lg_Relationship_Centre_id)
    ,'00' (Named LG_Location_Id)
    ,'848702' (Named Reporting_Centre_Id)
    , fal.From_Date
    , fal.To_Date
    , cast((fal.to_date (format 'YYYYMM')) as char(6)) (Named Reporting_Mth)
    ,sum(metric_amt * Parm_Value_Key) (Named Metric_Amt)
    ,NULL (Named SME_Account_Id)
    ,NULL (Named SME_Debit_Centre_Id)         
    ,NULL (Named SME_Credit_Centre_Id)    
    ,State_Centre (Named State_Centre)    
    ,'FEES' (Named Description)    
    from finiq.rafc_sme_fq_adjusted_instr fal
    join (
sel    child_id,pct.Parm_Value_Key
            from    finiq.sme_reference pct
            INNER  JOIN dwpviewa.LG_Hier  LGHP
            ON  LGHP.Segment_Type = 'Product'     
            AND LGHP.Parent1_Id = 'TPROD'
            AND 1200731 BETWEEN LGHP.From_Date 
    AND LGHP.TO_DATE
            AND (LGHP.Child_id = pct.Parm_Name     
            OR   LGHP.Parent1_id = pct.Parm_Name    
            OR   LGHP.Parent2_id = pct.Parm_Name 
            OR   LGHP.Parent3_id = pct.Parm_Name     
            OR   LGHP.Parent4_id = pct.Parm_Name   
            OR   LGHP.Parent5_id = pct.Parm_Name
            OR   LGHP.Parent6_id = pct.Parm_Name)  
            where Parm_Desc = 'Fees_Pct'
            and  1200731  between pct.From_Date and pct.To_Date) pct
    on fal.Lg_Product_Id = pct.child_id
    INNER  JOIN   dwpviewa.LG_Hier  la1
    on FAL.LG_Account_ID = la1.child_id
    and Segment_Type = 'Account'     
    and Parent1_Id = 'MARACT'
    and Parent8_Id = 'ICMARG'
    and  1200731  between la1.From_Date and la1.To_Date
   where fal.To_Date =  1200731
   and  fal.state_centre is not null
    group by 1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17;

-- *** MAP Account Product ID ***
update finiq.rafc_sme_fq_adjusted_instr
    from (
        sel    distinct LGHA.Child_Id as Ac_Child_id, LGHP.Child_Id as Pd_Child_id,
        SME_Account_Id as Act
    from finiq.sme_journal_mapping SMJ
    INNER  JOIN dwpviewa.LG_Hier  LGHA
                        ON  LGHA.Segment_Type = 'Account'     
                        AND LGHA.Parent1_Id = 'MARACT'
                        AND 1200731 BETWEEN LGHA.From_Date AND LGHA.TO_DATE
                        AND (LGHA.Child_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent1_id = SMJ.LG_Account_Key    
                        OR   LGHA.Parent2_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent3_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent4_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent5_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent6_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent7_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent8_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent9_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent10_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent11_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent12_id = SMJ.LG_Account_Key)     
    INNER  JOIN dwpviewa.LG_Hier  LGHP
                        ON  LGHP.Segment_Type = 'Product'     
                        AND LGHP.Parent1_Id = 'TPROD'
                        AND 1200731 BETWEEN LGHP.From_Date 
    AND LGHP.TO_DATE
                        AND (LGHP.Child_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent1_id = SMJ.LG_Product_Key    
                        OR   LGHP.Parent2_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent3_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent4_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent5_id = SMJ.LG_Product_Key
                        OR   LGHP.Parent6_id = SMJ.LG_Product_Key)  
    WHERE Mapping_Type = 'SME_ACCTPDT'
    AND 1200731 BETWEEN SMJ.From_Date 
    AND SMJ.TO_DATE )   Ac_Map

    Set SME_Account_Id  = Act

    WHERE Lg_Account_id = Ac_Map.Ac_Child_Id
    AND Lg_Product_id = Ac_Map.Pd_Child_id
    and finiq.rafc_sme_fq_adjusted_instr.To_Date = 1200731;
    
    
-- *** MAP CENTRE ID ***
update finiq.rafc_sme_fq_adjusted_instr
    from (
        sel distinct LGHA.Child_Id as Ac_Child_id, LGHP.Child_Id as Pd_Child_id, SMJ.SME_Account_Id as SME_Acct,
         SME_Debit_Centre_Id as D_Ctre, SME_Credit_Centre_Id as C_Ctre
    from finiq.sme_journal_mapping SMJ
    INNER  JOIN dwpviewa.LG_Hier  LGHA
                        ON  LGHA.Segment_Type = 'Account'     
                        AND LGHA.Parent1_Id = 'MARACT'
                        AND 1200731 BETWEEN LGHA.From_Date AND LGHA.TO_DATE
                        AND (LGHA.Child_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent1_id = SMJ.LG_Account_Key    
                        OR   LGHA.Parent2_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent3_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent4_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent5_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent6_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent7_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent8_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent9_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent10_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent11_id = SMJ.LG_Account_Key     
                        OR   LGHA.Parent12_id = SMJ.LG_Account_Key)     
    INNER  JOIN dwpviewa.LG_Hier  LGHP
                        ON  LGHP.Segment_Type = 'Product'     
                        AND LGHP.Parent1_Id = 'TPROD'
                        AND 1200731 BETWEEN LGHP.From_Date and LGHP.TO_DATE
                        AND (LGHP.Child_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent1_id = SMJ.LG_Product_Key    
                        OR   LGHP.Parent2_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent3_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent4_id = SMJ.LG_Product_Key     
                        OR   LGHP.Parent5_id = SMJ.LG_Product_Key
                        OR   LGHP.Parent6_id = SMJ.LG_Product_Key)  
    WHERE Mapping_Type = 'SME_Centre'
    AND 1200731 BETWEEN SMJ.From_Date  AND SMJ.TO_DATE )   Ac_Map

    set SME_Debit_Centre_Id = D_Ctre,
        SME_Credit_Centre_Id = C_Ctre
        
    WHERE  finiq.rafc_sme_fq_adjusted_instr.Lg_Account_id = Ac_Map.Ac_Child_Id
    and finiq.rafc_sme_fq_adjusted_instr.Lg_Product_id = Ac_Map.Pd_Child_id
    and finiq.rafc_sme_fq_adjusted_instr.SME_Account_Id = Ac_Map.SME_Acct
    and finiq.rafc_sme_fq_adjusted_instr.To_Date = 1200731;

--*** LOAN OFFSET ***
insert into finiq.rafc_sme_fq_adjusted_instr
sel 
    a.Metric_code
    ,'999' (Named Lg_Entity_id)
    ,'848702' (Named Lg_Cost_centre_Id)
    ,'146207' (Named Lg_Account_id)
    ,'11246' (Named Lg_Product_Id)   /* Default Loan Offset account */
    ,'848702' (Named Lg_Relationship_Centre_id)
    ,'00' (Named LG_Location_Id)
    ,'848702' (Named Reporting_Centre_Id)
    ,a.From_Date       
     ,a.To_Date    
    ,cast((a.to_date (format 'YYYYMM')) as char(6)) (Named Reporting_Mth)
    ,SME (Named Metric_Amt)
     ,'146207' (Named SME_Account_Id)
    ,'848702' (Named SME_Debit_Centre_Id)         
    ,'848383' (Named SME_Credit_Centre_Id)  
    ,State_centre_id (Named State_Centre)    
    ,'Loan Offset' (Named Description)  
 from 
(sel a.metric_code, State_centre_id, From_date, To_Date, _201206_SME *(cast(_146207 as float)/cast (_201206 as float)) as SME
from
(sel
case when Rec_Type_Cd = 'P' and Version_Id = '00' then 'EOP' else 'MAB' end (Named Metric_code) 
,sum(LG.Period_Amt) (Named _146207)
from dwpviewa.LG_Ledger LG
where LG.Period_Seq_Num in (sel distinct max(Period_Seq_Num) 
							from dwpviewa.LG_Ledger 
							where date between from_date and to_date
							and Rec_Type_Cd in ('P')
							and Version_Id in ('00')
							and Period_Amt <> 0
							and LG_Account_Id = '146207'
							and LG_Cost_Centre_Id = '846827')
and Rec_Type_Cd in ('P','S')
and Version_Id in ('00','AM')							
and LG.Period_Amt <> 0
and LG.LG_Account_Id = '146207'
and LG.LG_Cost_Centre_Id = '846827'
and date between from_date and to_date
Group by 1) a

,(Sel case when RAGL.Bal_Type_Code in ('BAL') then 'EOP'
	    when RAGL.Bal_Type_Code in ('MAB', 'MAC', 'MAD') then 'MAB'
	    else 'PNL'  end	(Named Metric_code)
	, RAGL.from_date
    , RAGL.to_date
	,sum (case when RAGL.Acctg_Acct_Id = '201206' then Bal_Amt else 0 end) (Named _201206)
from EWP1VAFCA.RAFC_Armt_GL_Compnt_Mth RAGL
        
    inner join dwpviewa.lg_hier_centre hc
    on RAGL.Acctg_Cntr_Id = hc.lg_centre_id
    and hc.lg_centre_l14_key = 'RB4892'
	and hc.lg_sgb_centre_Ind = 'Y'
    and 1200731 BETWEEN hc.From_Date 	and hc.TO_DATE 
    
    inner join dwpviewa.lg_hier_centre hrc
    on RAGL.Rpt_Centre_Id = hrc.lg_centre_id
    and hrc.lg_centre_l14_key = 'RB4892'
    and 1200731 BETWEEN hrc.From_Date and hrc.TO_DATE
          
    where RAGL.Acctg_Acct_Id in  ('201206')
    and 1200731  between RAGL.From_Date and RAGL.To_Date 
	and  RAGL.Armt_Key  not in (
		sel	distinct aal.armt_key
		from dwpviewa.CIS_Cust_Outline_SME CCOS
		join dwpviewa.Acct_CIS_Cust_Link accl
		    on accl.cis_key = ccos.cis_key
		    and 1200731 between accl.from_date 
			and accl.to_date
		    and accl.cust_role_code = 'PRN'
		join dwpviewa.Acct_Armt_Link aal
		    on accl.acct_key = aal.acct_key
		    and 1200731 between aal.from_date and aal.to_date
		where 1200731 between ccos.from_date and ccos.to_date) 
group by 1,2,3) b

 ,(sel case when RAGL.Bal_Type_Code in ('BAL') then 'EOP'
    when RAGL.Bal_Type_Code in ('MAB', 'MAC', 'MAD') then 'MAB'
    else 'PNL' end (Named Metric_code)
    , State_centre_id
    , sum(Bal_Amt) (Named _201206_SME)  
    from EWP1VAFCA.RAFC_Armt_GL_Compnt_Mth RAGL
    
    inner join dwpviewa.lg_hier_centre hc
    on RAGL.Acctg_Cntr_Id = hc.lg_centre_id
    and hc.lg_centre_l14_key = 'RB4892'
    and hc.lg_centre_l13_key <> '187405'
    and hc.lg_centre_l12_key <> '400150'
    and hc.lg_centre_id <> '848383'
	and hc.lg_sgb_centre_Ind = 'Y'
    and 1200731 BETWEEN hc.From_Date and hc.TO_DATE 
    
    inner join dwpviewa.lg_hier_centre hrc
    on RAGL.Rpt_Centre_Id = hrc.lg_centre_id
    and hrc.lg_centre_l14_key = 'RB4892'
    and 1200731 BETWEEN hrc.From_Date and hrc.TO_DATE 
    
left join (sel distinct  LGHC.Child_id, SMJ.SME_Credit_Centre_Id (Named State_centre_id)
            from finiq.sme_journal_mapping SMJ
                   INNER  JOIN dwpviewa.LG_Hier  LGHC
                                ON  LGHC.Segment_Type = 'Centre'     
                                AND LGHC.Parent1_Id = 'CNTINT'
                                AND LGHC.Parent3_Id = 'RB4892'
                                AND 1200731 BETWEEN LGHC.From_Date and LGHC.TO_DATE
                                AND (LGHC.Child_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent1_id = SMJ.SME_Debit_Centre_Id    
                                OR   LGHC.Parent2_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent3_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent4_id = SMJ.SME_Debit_Centre_Id     
                                OR   LGHC.Parent5_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent6_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent7_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent8_id = SMJ.SME_Debit_Centre_Id
                                OR   LGHC.Parent9_id = SMJ.SME_Debit_Centre_Id)
                                
            WHERE Mapping_Type = 'State_Centre'
            AND 1200731 BETWEEN SMJ.From_Date and SMJ.TO_DATE) sc
            on sc.Child_id = RAGL.Rpt_Centre_Id
        
    where RAGL.Acctg_Acct_Id in  ('201206')
    and 1200731  between RAGL.From_Date and RAGL.To_Date 
	and RAGL.Armt_Key in
		(sel distinct aal.armt_key
		from dwpviewa.CIS_Cust_Outline_SME CCOS
		join dwpviewa.Acct_CIS_Cust_Link accl
		    on accl.cis_key = ccos.cis_key
		    and 1200731 between accl.from_date and accl.to_date
		    and accl.cust_role_code = 'PRN'
		join dwpviewa.Acct_Armt_Link aal
		    on accl.acct_key = aal.acct_key
		    and 1200731 between aal.from_date and aal.to_date
		where 1200731 between ccos.from_date and ccos.to_date) 

group by 1,2)  c

where a.metric_code = b.metric_code
and a.metric_code = c.metric_code) a;

-- *** CONTRA LOAN OFFSET ***
insert into finiq.rafc_sme_fq_adjusted_instr
sel 
    a.Metric_code
    ,'999' (Named Lg_Entity_id)
    ,'848702' (Named Lg_Cost_centre_Id)
    ,'146200' (Named Lg_Account_id)
    ,'11256' (Named Lg_Product_Id)   /* Default Loan Offset account */
    ,'848702' (Named Lg_Relationship_Centre_id)
    ,'00' (Named LG_Location_Id)
    ,'848702' (Named Reporting_Centre_Id)
    ,cast(reporting_mth||'01'  as date) (Named From_Date)       
    ,1200731 (Named To_Date)       
    , cast((a.to_date (format 'YYYYMM')) as char(6)) (Named Reporting_Mth)
    ,-a.metric_amt (Named metric_amt)
     ,'146200' (Named SME_Account_Id)
    , SME_Debit_Centre_Id 
    , SME_Credit_Centre_Id
    , '848702' (Named State_Centre)    
    ,'Contra Loan Offset' (Named Description)  
 from
    ( sel *
     from finiq.rafc_sme_fq_adjusted_instr
     where Description = 'Loan Offset'
     and To_Date = 1200731) a;
    

    -- *** State Centre to Credit/Debit ***    
    update finiq.RAFC_sme_fq_adjusted_instr
    Set SME_Debit_Centre_Id = State_Centre
    where To_Date = 1200731
    and SME_Debit_Centre_Id = '848702';

    update finiq.RAFC_sme_fq_adjusted_instr
    Set SME_Credit_Centre_Id = State_Centre
    where To_Date = 1200731
    and SME_Credit_Centre_Id = '848702';
    

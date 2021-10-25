sel distinct  LGHC.Child_id, SMJ.SME_Credit_Centre_Id (Named State_centre_id)
            from finiq.sme_journal_mapping SMJ
                   INNER  JOIN DWPVTBLA.LG_Hier  LGHC
                                ON  LGHC.Segment_Type = 'Centre'     
                                AND LGHC.Parent1_Id = 'CNTINT'
                                AND LGHC.Parent3_Id = 'RB4892'
                                AND 1200331 BETWEEN LGHC.From_Date and LGHC.TO_DATE
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
            AND 1200331 BETWEEN SMJ.From_Date and SMJ.TO_DATE
			and LGHC.Child_id = '846827'
			
			
			select * from 
			 finiq.sme_journal_mapping SMJ
			 
			 
			 
			 
			 insert into finiq.sme_journal_mapping values('State_Centre','','','','842105','843380',1161001,1991231)

			delete 
			 from finiq.sme_journal_mapping
			where mapping_type = 'State_Centre'
			and sme_debit_centre_id = '842105'
			
			
			
			select * from 
			DWPVTBLA.LG_Hier LGHC  
			where child_id = '842105'
                                AND LGHC.Segment_Type = 'Centre'     
                                AND LGHC.Parent1_Id = 'CNTINT'
                                AND LGHC.Parent3_Id = 'RB4892'
								And child_id = '846827'
								
								
								
								
								
								
								select * from dwpviewa.lg_hier_centre
								where lg_centre_id  in ('842009','842010','842205','842209','843380','848702')
								and date between from_date and to_date
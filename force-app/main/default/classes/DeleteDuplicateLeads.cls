/***************************************************************************************************
* @Author:        CRM Developer
* @className:     DeleteDuplicateLeads
* @Description:   This class deletes the duplicate leads 
                    based on the email and name within the same campaign.
***************************************************************************************************/
public with sharing class DeleteDuplicateLeads {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     getDuplicateLeads
* @Description:   This method gets the duplicate leads 
                    based on the email and name within the same campaign.
***************************************************************************************************/
    public void getDuplicateLeads(){
        List<CampaignMember> campaignMembers = [SELECT 
                                                    CampaignId, Lead.Id, Lead.Name, Lead.Email 
                                                FROM 
                                                    CampaignMember 
                                                WHERE 
                                                    LeadId != null];
        Map<Id, List<Lead>> campaignToLeads = new Map<Id, List<Lead>>();
        for(CampaignMember cm : campaignMembers){
            if(!campaignToLeads.containsKey(cm.CampaignId)){
                campaignToLeads.put(cm.CampaignId, new List<Lead>());
            }
            campaignToLeads.get(cm.CampaignId).add(cm.Lead);
        }
        List<Lead> duplicateLeads = new List<Lead>();
        for(List<Lead> leadsInCampaign : campaignToLeads.values()){
            Set<String> emailSet = new Set<String>();
            Set<String> nameSet = new Set<String>();
            for(Lead l : leadsInCampaign){
                if(emailSet.contains(l.Email) || nameSet.contains(l.Name)){
                    duplicateLeads.add(l);
                }else{
                    emailSet.add(l.Email);
                    nameSet.add(l.Name);
                }
            }
        }
        Database.DeleteResult[] results = Database.delete(duplicateLeads, false);
        for(Database.DeleteResult dr : results){
            if(!dr.isSuccess()){
                System.debug(dr.getErrors());
            }
        }
    }
}

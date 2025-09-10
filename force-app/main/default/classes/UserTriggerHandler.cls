public with sharing class UserTriggerHandler {

    public static List<User> salesUserSetup(List<User> newUsers) {
        //List to stores Group Members and Permission set assignment.
        Set<Id> userId = new Set<Id>();
        for(User user: newUsers){
                userId.add(user.Id);
        }
        List<GroupMember> myGroup=new List<GroupMember>();
        List<PermissionSetAssignment> permissionSetList=new List<PermissionSetAssignment>();
        //All the queries to fetch the required data.
        Id role = [SELECT Id
                    FROM UserRole 
                    WHERE DeveloperName = 'WesternSalesTeam'].Id;
        Id myPermissionSet = [SELECT Id
                                FROM PermissionSet 
                                WHERE Name = 'Sales_User'].Id;
        Id salesProfile = [SELECT Id 
                            FROM Profile 
                            WHERE Name = 'Sales Person'].Id;
        Id SalesGroup = [SELECT Id
                        FROM Group 
                        WHERE DeveloperName = 'Sales_Team'].Id;
        List<PermissionSetAssignment> psaList = [
                SELECT Id
                FROM PermissionSetAssignment 
                WHERE AssigneeId IN :userId 
                AND PermissionSetId = :myPermissionSet
            ];
        //Looping through the new users and updating the user role, Profile, Public Group and assigning permission set.
        for(User user: newUsers){
            String FirstName = user.FirstName;
            if(FirstName.Startswith('Sales')){
                try{    
                    user.UserRoleId = role;
                    user.ProfileId = salesProfile;
                    myGroup.add(new GroupMember(GroupId=SalesGroup, UserOrGroupId=user.Id));
                    if(psaList.isEmpty()){
                        permissionSetList.add(new PermissionSetAssignment(PermissionSetId=myPermissionSet, AssigneeId= user.Id));
                    }
                    system.debug('User Role updated for ' + user.Name + 
                    ' to ' + user.UserRole.DeveloperName 
                    + 'with Profile: ' + user.Profile.Name);                    
                }
                catch(Exception e){
                    System.debug('Error when fetcing the role: ' + e.getMessage());
                    }
                }
            }
            //DML Queries
            Insert permissionSetList;
            Insert myGroup;
            return newUsers;
    }
    //Method to restrict the user from deactivating.
    public static void doNotDeactivate(List<User> listOfUser,Map<ID,User> oldusers){
        for(User u:listOfUser){
            User oldUser=oldusers.get(u.Id);
            if(u.IsActive == false && oldUser.IsActive == true && u.Do_not_Deactivate__c == true){
                u.addError('You Can not Deactivate this User');
            }
        }
    }
}
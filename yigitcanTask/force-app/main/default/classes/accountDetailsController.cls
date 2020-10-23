public class accountDetailsController {

    public static final Integer ACCOUNT_NAME_MAX_LENGTH = 100;
    public static final String ACCOUNT_LENGTH_ERROR_MESSAGE = 'Length is less than '+ACCOUNT_NAME_MAX_LENGTH+' characters';
    
    public List <Contact> contacts {get;set;}
    public String searchKey {get;set;}
    public Account account {get;set;}

    public accountDetailsController(ApexPages.StandardController accountDetailsController ) {
        this.account = (Account)accountDetailsController.getRecord();
        this.contacts = this.getAllContacts();
    }

    public void setPrimaryContact() {
        try {
            String passedParam1 = Apexpages.currentPage().getParameters().get('setPrimaryContactParam');
            
            List<Contact> allAccountContacts = this.getAllContacts();
            for(Contact contactRecord : allAccountContacts) {
                contactRecord.Is_Primary_Contact__c = (contactRecord.id == passedParam1);
            }
            
            for(Contact contactRecord : this.contacts) {
                contactRecord.Is_Primary_Contact__c = (contactRecord.id == passedParam1);
            }
 
            Database.update(allAccountContacts);
                
        } catch (Exception ex) {
            system.debug('ex = '+ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''));
        }
    }

    private List<Contact> getAllContacts() {
        return [SELECT Name, Title, Phone, Is_Primary_Contact__c 
            FROM Contact 
            WHERE AccountId = :this.account.Id
            + ' WITH SECURITY_ENFORCED'
        ];   
    }
    public void search() {
        this.contacts = new List<Contact>();
        String searchQuery = 'SELECT Name, Title, Phone, Is_Primary_Contact__c'
        + ' FROM Contact'
        + ' WHERE Name LIKE \'%'+String.escapeSingleQuotes(searchKey)+'%\''
        + ' AND AccountId = \''+this.account.Id+'\''
        + ' WITH SECURITY_ENFORCED';
        
        try {
            this.contacts = Database.query(searchQuery);
        } catch (Exception ex) {
            system.debug('ex = '+ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Some error occured during search.'));
        }
        
    }

    public PageReference cancel() {
        PageReference acctPage = new ApexPages.StandardController(account).view();
        acctPage.setRedirect(true); 
        return acctPage;
    }
    public void save() {
        try {
            if(this.validateAccount()) {
                update this.account;
            }
        }
        catch (Exception ex) {
            system.debug('ex = '+ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Some error occured during search.'));
        }
    }

    private Boolean validateAccount() {
        Boolean isValid = true;
        if(String.isBlank(this.account.Name)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Account Name'));
            isValid = false;
        } else {
            if (this.account.name.length() > ACCOUNT_NAME_MAX_LENGTH) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, ACCOUNT_LENGTH_ERROR_MESSAGE));
                isValid = false;
            }
        }

        if(String.isBlank(this.account.AccountNumber)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Account Number!'));
            isValid = false;
        } 

        if(String.isBlank(this.account.Phone)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Account Phone!')); 
            isValid = false;
        }

        return isValid;
    }
}
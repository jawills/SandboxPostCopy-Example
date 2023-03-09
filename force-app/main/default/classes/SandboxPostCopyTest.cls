@isTest
private class SandboxPostCopyTest {

    @isTest
    static void test_post_copy() {

        Profile p = [ SELECT id FROM Profile WHERE name = 'Standard User' ];
        Profile p2 = [ SELECT id FROM Profile WHERE name = 'System Administrator' ];
        User user1;
        User user2;

        System.runAs( new User( id = UserInfo.getUserId() ) ) {

            user1 = newUser( p.id, 'Alpha', 'User 1', 'user_1=salesforce.com@example.com' );
            user2 = newUser( p2.id, 'Beta', 'User 2', 'user_2@salesforce.com.invalid' );

            insert new User[] { user1, user2 };

        }

        Test.startTest();

        Test.testSandboxPostCopyScript(
            new SandboxPostCopyScript(), // apex class to run
            UserInfo.getOrganizationId(), // org id
            '00D90000000KY45', // sandbox id
            'Sandbox' // sandbox name
        );

        Test.stopTest();

        user1 = [ SELECT id, email FROM User WHERE id = :user1.id ];
        System.assertEquals( 'user_1=salesforce.com@example.com', user1.email );
        
        user2 = [ SELECT id, email FROM User WHERE id = :user2.id ];
        System.assertEquals( 'user_2@salesforce.com', user2.email );

    }

    private static User newUser( ID profileId, String firstName, String lastName, String email ) {
        Integer rand = Math.round( Math.random() * 1000 );
        return new User(
            isActive = true,
            profileId = profileId,
            alias = firstName.substring(0,1) + lastName.substring(1,5),
            firstName = firstName,
            lastName = lastName,
            email = email,
            username = rand + email,
            replace_email__c = true,
            emailEncodingKey = 'UTF-8',
            languageLocaleKey = 'en_US',
            localeSidKey = 'en_US',
            timeZoneSidKey = 'America/Chicago'
        );
    }

}
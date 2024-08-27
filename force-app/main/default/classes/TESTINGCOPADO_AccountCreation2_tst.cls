@isTest
public class TESTINGCOPADO_AccountCreation2_tst {

    @isTest
    public static void testingClass(){
        TESTINGCOPADO_AccountCreation2 newClass = New TESTINGCOPADO_AccountCreation2();
        newClass.createAccount('test');
        Assert.isNotNull(newClass, 'The instance is null');

    }
}
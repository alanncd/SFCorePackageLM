@IsTest
public class TESTINGCOPADO_1_TST {
    @isTest
    public static void testingClass(){
        TESTINGCOPADO_1 newClass = New TESTINGCOPADO_1();
        newClass.createAccount('test');
        Assert.isNotNull(newClass, 'The instance is null');

    }
}
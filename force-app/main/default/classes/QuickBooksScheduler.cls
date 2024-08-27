public class QuickBooksScheduler {
  @InvocableMethod(label='Schedule QuickBooks Job')
  public static List<Boolean> scheduleQuickBooksJob() {
    QuickBooksController qbc = new QuickBooksController();
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    String sch = '20 30 8 * * ?';
    String jobID = System.schedule('get Quickbooks Job', sch, qbc);

    String schV = '20 30 10 * * ?';
    VendorRefreshBatch vend = new VendorRefreshBatch();
    String jobIDV = System.schedule('Refresh Vendor Batch', schV, vend);

    // Store the job ID in a custom object or return it in some way
    // For simplicity, you can log it or return it as a debug message
    System.debug('Scheduled Job ID: ' + jobID);
    // Check if both job IDs are not null
    Boolean aux = (jobID != null && jobIDV != null);

    // Return the result as a List<String>
    return new List<Boolean>{ aux };
  }
}
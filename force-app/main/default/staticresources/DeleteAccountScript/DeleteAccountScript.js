function deleteAccount(accountId) {
    alert('deleteAccount called with accountId: ' + accountId);
    Visualforce.remoting.Manager.invokeAction(
        'AccountsInformationController.deleteAccountRemote',
        accountId,
        function(result, event) {
            if(event.status) {
                alert('The account has been deleted');
                location.reload();
            } else {
                alert('Error: ' + result);
            }
        },
        {escape: true}
    );
}

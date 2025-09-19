function deleteAccount(accountId) {
    console.log('deleteAccount called with accountId: ' + accountId);
    alert('deleteAccount called with accountId: ' + accountId);
    Visualforce.remoting.Manager.invokeAction(
        '{!$RemoteAction.AccountsInformationController.deleteAccountRemote}',
        accountId,
        function(result, event) {
            console.log('result: ' + result + ', event.status: ' + event.status);
            if(event.status) {
                alert(result);
                location.reload();
            } else {
                alert('Error: ' + result);
            }
        },
        {escape: true}
    );
}

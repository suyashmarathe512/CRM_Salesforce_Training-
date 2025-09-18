<apex:page controller="AccountsInformationController" >
<script>
    function deleteAccount(accountId) {
        Visualforce.remoting.Manager.invokeAction(
            '{!$RemoteAction.DeleteAccountScriptController.deleteAccount}',
            accountId,
            function(result, event) {
                if (event.status) {
                    alert('The account has been deleted. Reload the page to update the list.');
                } else {
                    alert('Failed to delete account: ' + event.message);
                }
            },
            {escape: true}
        );
    }
</script>
</apex:page>
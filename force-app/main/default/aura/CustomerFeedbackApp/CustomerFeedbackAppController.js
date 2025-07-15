({
    handleStatusChange: function(component, event, helper) {
        var status = event.getParam('status');
        component.set('v.selectedStatus', status);
    }
})

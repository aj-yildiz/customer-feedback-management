({
    handleStatusChange: function(component, event, helper) {
        var selected = component.get("v.selectedStatus");
        var statusChangeEvent = component.getEvent("statusChange");
        statusChangeEvent.setParams({ status: selected });
        statusChangeEvent.fire();
    }
})

<aura:application extends="force:slds">
    <aura:attribute name="selectedStatus" type="String"/>
    <aura:handler event="c:statusChangeEvent" action="{!c.handleStatusChange}"/>
    <c:statusFilter/>
    <lightning:card title="Customer Feedback List">
        <c:feedbackList statusFilter="{!v.selectedStatus}"/>
    </lightning:card>
</aura:application>

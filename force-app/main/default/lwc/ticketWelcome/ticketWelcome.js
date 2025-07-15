import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class TicketWelcome extends LightningElement {
  @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
  user;

  get userName() {
    if (this.user && this.user.data) {
      return this.user.data.fields.Name.value;
    }
    return 'there';
  }

  get isUserLoaded() {
    return this.user && this.user.data;
  }
} 
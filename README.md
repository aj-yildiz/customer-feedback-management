# Customer Feedback Management Salesforce DX Project

This Salesforce DX project contains a ready-to-deploy Customer Feedback Management app with:

- Custom Object: `Customer_Feedback__c` and fields
- Apex Controller and Tests
- LWC: Feedback List
- Aura: Status Filter and App

## Deployment

1. Authenticate to your DevHub and scratch org:
   ```sh
   sf org login web --set-default-dev-hub
   sf org create scratch --set-default
   ```
2. Push source:
   ```sh
   sf project deploy start --target-org <your-scratch-org-alias>
   ```
3. Run tests:
   ```sh
   sf apex run test --target-org <your-scratch-org-alias> --code-coverage
   ```

## Project Structure
- `force-app/` — Main source
- `README.md` — This file
- `.forceignore` — Ignore patterns
- `sfdx-project.json` — SFDX config

## Requirements
- Salesforce CLI (`sf`)
- Scratch org enabled

---

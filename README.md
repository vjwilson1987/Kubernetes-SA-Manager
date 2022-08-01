# k8suser

## What is its purpose?.

The script k8user.sh will help you automate the process of creation, deletion and fetching the user config file of both kubernetes staging and production cluster.

## How to use the script?.

The user input reads from the file input.txt in the following format:

````
K8USER: ${username}
ACTION: CREATE | DELETE | GET | LIST | CHROLE
ROLE: ADMIN | READONLY
STAGING: YES | NO
PRODUCTION: YES | NO
SLACKID: Your_Slack_Member_ID
````

so everytime when you want to CREATE or DELETE or GET config file of a user, you use the above inputs in the input.txt file, then pushing it to gitlab triggers the script k8user.sh to run accordingly.

- **K8USER**: Input the username you want to CREATE or DELETE or GET the config file.

- **ACTION**: Action to be taken for the username, whether you want to create or delete or get or list or chroleits configuration file.


        - If CREATE, will proceed with CREATE action.
        - If DELETE, will proceed with DELETE action.
        - If GET, will proceed with getting existing service account configuration.
        - If LIST, will proceed with simply listing the existing users.
        - If CHROLE, will proceed with changing role to either Admin or Read-only of the mentioned user.

- **ROLE**: Whether you want to create the service account with Admin or Read-only role.

- **STAGING**:


        - If YES, will proceed with either CREATION or DELETION on staging depends on ACTION.
        - If NO, skip CREATEor DELETE on staging.

- **PRODUCTION**:


        - If YES, will proceed with either CREATION or DELETION on production depends on ACTION.
        - If NO, skip CREATE or DELETE on production.

- **SLACKID**: 


        - You enter the unique Member ID/Slack ID of the staff/user you want the script to send the config file on both staging and production after processing(CREATE or GET).
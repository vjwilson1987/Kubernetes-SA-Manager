#!/bin/sh

##Automate Kubernetes user creation and deletion.
##by Vipin John Wilson on 29 July 2021.

#set -xv

CPATH=$(pwd)
#echo "${CPATH}"
FILE="${CPATH}/input.txt"         ##The user input accepts through this file##
mkdir ~/.kube
NS="app"
APITOKEN=$(echo ${SLACK_STAFF_BOT_API_TOKEN} | base64 -d);           ##APITOKEN for the slack BOT staffonboard##


################################# User Input Validation #################################
validate_result()
{
  if ! echo "${RESULT}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]' | grep -Eqx '(yes|no)'; then
    echo "Check if your answer is either YES or NO for STAGING and PRODUCTION";
    exit 1;
  fi;
}

if [ ! -s "${CPATH}"/input.txt ]; then
  echo "File input.txt does not have any content in it";
  exit 1;
fi;

K8USER=$(awk -F: '!/#/ && /K8USER/{print $2}' "${FILE}")
echo "${K8USER}";
if [ -z "${K8USER// }" ]; then
    echo "Input a username on the input.txt file to create";
    exit 1;
fi;

if ! echo "${K8USER}" | sed -e 's/^[ \t]*//' | grep -i -q -x '^[a-z0-9]*$'; then
    echo "Symbols, Special characters, space not allowed in the \"K8USER\" field. Enter a valid username.";
    exit 1;
fi;

ACTION=$(awk -F: '!/#/ && /ACTION/{print $2}' "${FILE}");
echo "${ACTION}";
if [ -z "${ACTION// }" ]; then
    echo "For ACTION, Mention CREATE or DELETE or GET or LIST or CHROLE on the input.txt file.";
    exit 1;
fi;

if ! echo "${ACTION}" | sed -e 's/^[ \t]*//' | grep -i -q -x '^[a-zA-Z]*$'; then
    echo "For ACTION, Numbers, Symbols, Special characters, space not allowed. Enter CREATE or DELETE or GET or LIST or CHROLE in the \"ACTION\" field";
    exit 1;
fi;

if ! echo "${ACTION}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]' | grep -Eqx '(create|delete|get|list|chrole)'; then
    echo "Check if your answer is CREATE or DELETE or GET or LIST or CHROLE for ACTION";
    exit 1;
fi;

ROLE=$(awk -F: '!/#/ && /^ROLE/{print $2}' "${FILE}");
echo "${ROLE}";
if [ -z "${ROLE// }" ]; then
    echo "For ROLE, Mention ADMIN or READONLY on the input.txt file.";
    exit 1;
fi;

if ! echo "${ROLE}" | sed -e 's/^[ \t]*//' | grep -i -q -x '^[a-zA-Z]*$'; then
    echo "For ROLE, Numbers, Symbols, Special characters, space not allowed. Enter ADMIN or READONLY in the \"ROLE\" field";
    exit 1;
fi;

if ! echo "${ROLE}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]' | grep -Eqx '(admin|readonly)'; then
    echo "Check if your answer is ADMIN or READONLY for ROLE";
    exit 1;
fi;

STAGING=$(awk -F: '!/#/ && /STAGING/{print $2}' "${FILE}")
#echo "${STAGING}";
if [ -z "${STAGING// }" ]; then
    echo "Mention YES or NO on the input.txt file if you want to create the user account on STAGING";
    exit 1;
fi;

if ! echo "${STAGING}" | sed -e 's/^[ \t]*//' | grep -i -q -x '^[a-zA-Z]*$'; then
    echo "Numbers, Symbols, Special characters, space not allowed. Enter either Yes or No in the \"STAGING\" field";
    exit 1;
fi;

RESULT=$(echo "${STAGING}" | sed -e 's/^[ \t]*//');
validate_result;
unset RESULT;

PRODUCTION=$(awk -F: '!/#/ && /PRODUCTION/{print $2}' "${FILE}")
#echo "${PRODUCTION}";
if [ -z "${PRODUCTION// }" ]; then
    echo "Mention YES or NO on the input.txt file if you want to create the user account on PRODUCTION";
    exit 1;
fi;

if ! echo "${PRODUCTION}" | sed -e 's/^[ \t]*//' | grep -i -q -x '^[a-zA-Z]*$'; then
    echo "Numbers, Symbols, Special characters, space not allowed. Enter either Yes or No in the \"PRODUCTION\" field";
    exit 1;
fi;

RESULT=$(echo "${PRODUCTION}" | sed -e 's/^[ \t]*//');
validate_result;
unset RESULT;

SLACKID=$(awk -F: '!/#/ && /SLACKID/{print $2}' "${FILE}");
#echo "${SLACKID}";
if [ -z "${SLACKID// }" ]; then
    echo "Enter your correct SLACKID.";
    exit 1;
fi;

if ! echo "${SLACKID}" | sed -e 's/^[ \t]*//' | grep -i -q -x '^[a-zA-Z0-9]*$'; then
    echo "For SLACKID, Symbols, Special characters, space not allowed. Enter your correct SLACKID.";
    exit 1;
fi;
################################# User Input Validation Ends ###############################

send_staging()
{
  curl -F file=@"${suserconfig}" -F "initial_comment=From Admin" -F channels="${SLACK_ID}" -H "Authorization: Bearer ${APITOKEN}" https://slack.com/api/files.upload ;
  rm -rf "${suserconfig}";    ##clean up after sending
}

send_production()
{
  curl -F file=@"${puserconfig}" -F "initial_comment=From Admin" -F channels="${SLACK_ID}" -H "Authorization: Bearer ${APITOKEN}" https://slack.com/api/files.upload ;
  rm -rf "${puserconfig}";    ##clean up after sending
}

staging_config_file()
{
suserconfig="${KUSER}_staging_config";
touch "${suserconfig}";
echo ""
echo "###################### Kubernetes Staging Configuration File (~/.kube/config) ############################" > "${suserconfig}";
echo "" >> "${suserconfig}";
echo " apiVersion: v1" >> "${suserconfig}";
echo " clusters:" >> "${suserconfig}";
echo " - cluster:" >> "${suserconfig}";
echo "     $(echo "${CERT_AUTH_DATA_STAGING}" | base64 -d)" >> "${suserconfig}";
echo "     server: https://api.$CLUSTER" >> "${suserconfig}";
echo "   name: $CLUSTER" >> "${suserconfig}";
echo " contexts:" >> "${suserconfig}";
echo " - context:" >> "${suserconfig}";
echo "     cluster: $CLUSTER" >> "${suserconfig}";
echo "     user: $CLUSTER" >> "${suserconfig}";
echo "   name: $CLUSTER" >> "${suserconfig}";
echo " current-context: $CLUSTER" >> "${suserconfig}";
echo " kind: Config" >> "${suserconfig}";
echo " preferences: {}" >> "${suserconfig}";
echo " users:" >> "${suserconfig}";
echo " - name: $CLUSTER" >> "${suserconfig}";
echo "   user:" >> "${suserconfig}";
echo "     token: $STOKEN" >> "${suserconfig}";
echo "" >> "${suserconfig}";
echo "###################### Kubernetes Staging Configuration File (~/.kube/config) ############################" >> "${suserconfig}";
echo ""
send_staging;
}

production_config_file()
{
puserconfig="${KUSER}_production_config";
touch "${puserconfig}";
echo ""
echo "###################### Kubernetes Production Configuration File (~/.kube/config) #########################" > "${puserconfig}";
echo "" >> "${puserconfig}";
echo " apiVersion: v1" >> "${puserconfig}";
echo " clusters:" >> "${puserconfig}";
echo " - cluster:" >> "${puserconfig}";
echo "     $(echo "${CERT_AUTH_DATA_PRODUCTION}" | base64 -d)" >> "${puserconfig}";
echo "     server: https://api.$CLUSTER" >> "${puserconfig}";
echo "   name: $CLUSTER" >> "${puserconfig}";
echo " contexts:" >> "${puserconfig}";
echo " - context:" >> "${puserconfig}";
echo "     cluster: $CLUSTER" >> "${puserconfig}";
echo "     user: $CLUSTER" >> "${puserconfig}";
echo "   name: $CLUSTER" >> "${puserconfig}";
echo " current-context: $CLUSTER" >> "${puserconfig}";
echo " kind: Config" >> "${puserconfig}";
echo " preferences: {}" >> "${puserconfig}";
echo " users:" >> "${puserconfig}";
echo " - name: $CLUSTER" >> "${puserconfig}";
echo "   user:" >> "${puserconfig}";
echo "     token: $PTOKEN" >> "${puserconfig}";
echo "" >> "${puserconfig}";
echo "###################### Kubernetes Production Configuration File (~/.kube/config) #########################" >> "${puserconfig}";
echo ""
send_production;
}

find_usertoken_staging()
{
STAGING_SECRET_NAME=$(kubectl get secret -n "${NS}" | grep user-"${KUSER}" | cut -d' ' -f1);
STOKEN=$(kubectl -n "${NS}" get secret "${STAGING_SECRET_NAME}" -o jsonpath='{.data.token}' | base64 -d);
}

find_usertoken_production()
{
PRODUCTION_SECRET_NAME=$(kubectl get secret -n "${NS}" | grep user-"${KUSER}" | cut -d' ' -f1);
PTOKEN=$(kubectl -n "${NS}" get secret "${PRODUCTION_SECRET_NAME}" -o jsonpath='{.data.token}' | base64 -d);
}

check_role()
{
 if [ "${KROLE}" = "ADMIN" ]; then
   UROLE="app-admin";
   return;
 elif [ "${KROLE}" = "READONLY" ]; then
   UROLE="reader-role";
   return;
 fi;
}

KUSER=$(echo "${K8USER}" | sed -e 's/^[ \t]*//');
KROLE=$(echo "${ROLE}" | sed -e 's/^[ \t]*//' | tr '[:lower:]' '[:upper:]');
SLACK_ID=$(echo "${SLACKID}" | sed -e 's/^[ \t]*//');
CH=$(echo "${ACTION}" | sed -e 's/^[ \t]*//' | tr '[:lower:]' '[:upper:]');

if [ "${CH}" = "CREATE" ]; then

  echo "Account creation on STAGING";

  SVAL=$(echo "${STAGING}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${SVAL}" = "yes" ]; then
    echo "${KUBECTL_CONFIG_STAGING_SRVUSER}" | base64 -d > ~/.kube/config;
    CLUSTER=$(kubectl config  current-context);
    CONTEXT=$(kubectl config current-context | cut -d- -f3);
    find_usertoken_staging;
    if [ -n "${STOKEN}" ]; then
      echo "";
      echo "The user ${KUSER} already exists on Staging";
    else
      echo "";
      echo "Creating user service accounts and rolebindings";
      check_role;
      kubectl create sa user-"${KUSER}" -n "${NS}";
      kubectl create rolebinding user-"${KUSER}" --role="${UROLE}" --serviceaccount="${NS}":user-"${KUSER}" -n "${NS}";
      find_usertoken_staging;
      staging_config_file;
    fi;

  elif [ "${SVAL}" = "no" ]; then
    echo "Found STAGING: NO, skipping account creation on STAGING";
  fi;

  echo "Account creation on PRODUCTION";

  PVAL=$(echo "${PRODUCTION}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${PVAL}" = "yes" ]; then
    echo "${KUBECTL_CONFIG_PRODUCTION_SRVUSER}" | base64 -d > ~/.kube/config;
    CLUSTER=$(kubectl config  current-context);
    CONTEXT=$(kubectl config current-context | cut -d- -f3);
    find_usertoken_production;
    if [ -n "${PTOKEN}" ]; then
      echo "";
      echo "The user ${KUSER} already exists on Production";
    else
      echo "";
      echo "Creating user service accounts and rolebindings";
      check_role;
      kubectl create sa user-"${KUSER}" -n "${NS}";
      kubectl create rolebinding user-"${KUSER}" --role="${UROLE}" --serviceaccount="${NS}":user-"${KUSER}" -n "${NS}";
      find_usertoken_production;
      production_config_file;
    fi;

  elif [ "${PVAL}" = "no" ]; then
    echo "Found PRODUCTION: NO, skipping account creation on PRODUCTION";
  fi;

elif [ "${CH}" = "DELETE" ]; then

  echo "Account deletion on STAGING";

  SVAL=$(echo "${STAGING}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${SVAL}" = "yes" ]; then
    echo "${KUBECTL_CONFIG_STAGING_SRVUSER}" | base64 -d > ~/.kube/config;
    #CLUSTER=$(kubectl config  current-context);
    #CONTEXT=$(kubectl config current-context | cut -d- -f3);
    find_usertoken_staging;
    if [ -z "${STOKEN}" ]; then
      echo "";
      echo "The user ${KUSER} does not exist on Staging";
    else
      echo ""
      echo "Deleting user service accounts and rolebindings on Staging"
      kubectl delete sa user-"${KUSER}" -n "${NS}";
      kubectl delete rolebinding user-"${KUSER}" -n "${NS}";
    fi;

  elif [ "${SVAL}" = "no" ]; then
    echo "Found STAGING: NO, skipping account deletion on STAGING";
  fi;

  echo "Account deletion on PRODUCTION";

  PVAL=$(echo "${PRODUCTION}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${PVAL}" = "yes" ]; then
    echo "${KUBECTL_CONFIG_PRODUCTION_SRVUSER}" | base64 -d > ~/.kube/config;
    #CLUSTER=$(kubectl config  current-context);
    #CONTEXT=$(kubectl config current-context | cut -d- -f3);
    find_usertoken_production;
    if [ -z "${PTOKEN}" ]; then
      echo "";
      echo "The user ${KUSER} does not exist on Production";
    else
      echo ""
      echo "Deleting user service accounts and rolebindings on Production"
      kubectl delete sa user-"${KUSER}" -n "${NS}";
      kubectl delete rolebinding user-"${KUSER}" -n "${NS}";
    fi;

  elif [ "${PVAL}" = "no" ]; then
    echo "Found STAGING: NO, skipping account deletion on STAGING";
  fi;

elif [ "${CH}" = "GET" ]; then

  echo "";
  echo "Getting config file on staging for the user ${KUSER}";
  echo "${KUBECTL_CONFIG_STAGING_SRVUSER}" | base64 -d > ~/.kube/config;
  CLUSTER=$(kubectl config  current-context);
  CONTEXT=$(kubectl config current-context | cut -d- -f3);
  find_usertoken_staging;
  staging_config_file;

  echo "";
  echo "Getting config file on production for the user ${KUSER}";
  echo "${KUBECTL_CONFIG_PRODUCTION_SRVUSER}" | base64 -d > ~/.kube/config;
  CLUSTER=$(kubectl config  current-context);
  CONTEXT=$(kubectl config current-context | cut -d- -f3);
  find_usertoken_production;
  production_config_file;

elif [ "${CH}" = "LIST" ]; then

  SVAL=$(echo "${STAGING}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${SVAL}" = "yes" ]; then
    echo "";
    echo "Listing users in the namespace app on staging..."
    echo "Name          Secrets    Age"
    echo "${KUBECTL_CONFIG_STAGING_SRVUSER}" | base64 -d > ~/.kube/config;
    kubectl get sa -n "${NS}" | grep user | cut -d\- -f2;

  elif [ "${SVAL}" = "no" ]; then
    echo "Found STAGING: NO, not listing user accounts on staging";
  fi;

  PVAL=$(echo "${PRODUCTION}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${PVAL}" = "yes" ]; then
    echo "";
    echo "Listing users in the namespace app on production..."
    echo "Name          Secrets    Age"
    echo "${KUBECTL_CONFIG_PRODUCTION_SRVUSER}" | base64 -d > ~/.kube/config;
    kubectl get sa -n "${NS}" | grep user | cut -d\- -f2;

  elif [ "${PVAL}" = "no" ]; then
    echo "Found PRODUCTION: NO, not listing user accounts on production";
  fi;

elif [ "${CH}" = "CHROLE" ]; then

  SVAL=$(echo "${STAGING}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${SVAL}" = "yes" ]; then
    echo "${KUBECTL_CONFIG_STAGING_SRVUSER}" | base64 -d > ~/.kube/config;
    CLUSTER=$(kubectl config current-context);
    CONTEXT=$(kubectl config current-context | cut -d- -f3);
    find_usertoken_staging;
      if [ -z "${STOKEN}" ]; then
        echo "";
        echo "The user ${KUSER} does not exist on Staging";
      else
        echo "";
        echo "Changing the role to ${KROLE} on Staging";
        kubectl delete rolebinding user-"${KUSER}" -n "${NS}";
        check_role;
        kubectl create rolebinding user-"${KUSER}" --role="${UROLE}" --serviceaccount="${NS}":user-"${KUSER}" -n "${NS}";
        find_usertoken_staging;
        staging_config_file;
      fi;

  elif [ "${SVAL}" = "no" ]; then
    echo "Found STAGING: NO, not changing role on STAGING";
  fi;

  PVAL=$(echo "${PRODUCTION}" | sed -e 's/^[ \t]*//' | tr '[:upper:]' '[:lower:]');

  if [ "${PVAL}" = "yes" ]; then
    echo "${KUBECTL_CONFIG_PRODUCTION_SRVUSER}" | base64 -d > ~/.kube/config;
    CLUSTER=$(kubectl config current-context);
    CONTEXT=$(kubectl config current-context | cut -d- -f3);
    find_usertoken_production;
      if [ -z "${PTOKEN}" ]; then
        echo "";
        echo "The user ${KUSER} does not exist on Production";
      else
        echo "";
        echo "Changing the role to ${KROLE} on Production";
        kubectl delete rolebinding user-"${KUSER}" -n "${NS}";
        check_role;
        kubectl create rolebinding user-"${KUSER}" --role="${UROLE}" --serviceaccount="${NS}":user-"${KUSER}" -n "${NS}";
        find_usertoken_production;
        production_config_file;
      fi;

  elif [ "${PVAL}" = "no" ]; then
    echo "Found PRODUCTION: NO, not changing role on production";
  fi;

fi;
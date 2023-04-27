# New GCP project template

Creates all the basic terraform resources + GHA workflows needed for a new GCP terraform project + a Virtual Machine or Kubernetes Cluster. Clone this repo and follow allong to get quickly bootsrap your own GCP project.

## Modules in-use

- [modules-gcp-tf-base](https://github.com/cloudymax/modules-gcp-tf-base)
- [modules-gcp-tf-vm](https://github.com/cloudymax/modules-gcp-tf-vm)
- [modules-gcp-tf-gke](https://github.com/cloudymax/modules-gcp-tf-gke)

## Infracost

Infracost shows cloud cost estimates for Terraform. It lets engineers see a cost breakdown and understand costs before making changes, either in the terminal, VS Code or pull requests.
To get started using Infracost with Github Actions, take a look here: https://github.com/infracost/actions

## Setting-up via the gCloud CLI

[Installing the gCloud CLI](https://cloud.google.com/sdk/docs/install)

or use docker the docker container `gcr.io/google.com/cloudsdktool/google-cloud-cli`


1. Log in

   ```bash
   gcloud auth login --no-launch-browser
   ```

2. Find your billing account ID:

   ```bash
   gcloud alpha billing accounts list

   or

   gcloud alpha billing accounts list \
      --filter='NAME:<your user name>' \
      --format='value(ACCOUNT_ID)'
   ```

3. Find your Organization ID

   ```bash
   gcloud organizations list

   or

   gcloud organizations list \
      --filter='DISPLAY_NAME:<some org name>' \
      --format='value(ID)'
   ```

4. Populate required variables with unique values for your own project.

   ```bash
   export PROJECT_NAME="An Easy To Read Name"
   export PROJECT_ID="machine-readable-project-name"
   export ORGANIZATION=
   export ORGANIZATION_DOMAIN=
   export ORGANIZATION_ID=$(gcloud organizations list |grep $ORGANIZATION |awk '{print $2}')
   export BIG_ROBOT_NAME="myserviceaccount"
   export BIG_ROBOT_EMAIL=$(echo $BIG_ROBOT_NAME@$PROJECT_ID.iam.gserviceaccount.com)
   export BIG_ROBOT_GROUP="admin-bot-group@$ORGANIZATION_DOMAIN"
   export LOCATION="europe-west4"
   export MAIN_AVAILABILITY_ZONE="europe-west4-a"
   export KEYRING="mykeyring"
   export KEYRING_KEY="terraform-key"
   export BILLING_ACCOUNT=$(gcloud beta billing accounts list |grep $ORGANIZATION |awk '{print $1}')
   export GCLOUD_CLI_IMAGE_URL="gcr.io/google.com/cloudsdktool/google-cloud-cli"
   export GCLOUD_CLI_IMAGE_TAG="slim"
   export BACKEND_BUCKET_NAME="$PROJECT_ID-backend-state-storage"
   export BUCKET_PATH_PREFIX="terraform/state"
   ```

5. Create a new Project and set it as active, then enable billing

    ```bash
    gcloud projects create $PROJECT_ID --name="$PROJECT_NAME"
    gcloud config set project $PROJECT_ID
    gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT

    ```

6. Enable required Apis (may take a couple minutes)

   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   gcloud services enable cloudidentity.googleapis.com
   gcloud services enable cloudkms.googleapis.com
   gcloud services enable iamcredentials.googleapis.com
   gcloud services enable iam.googleapis.com
   gcloud services enable cloudbilling.googleapis.com
   gcloud services enable container.googleapis.com
   sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
   ```

7. Create a group:

    ```bash
    gcloud identity groups create "admin-bot-group@$ORGANIZATION" --organization=$ORGANIZATION_ID --display-name="top-level-bot-group"
    ```

8. Give the group some permissions:

    ```bash
    gcloud projects add-iam-policy-binding $PROJECT_ID \
      --member=group:"admin-bot-group@$ORGANIZATION" \
      --role=roles/iam.serviceAccountUser \
      --role=roles/compute.instanceAdmin.v1 \
      --role=roles/compute.osLogin \
      --role=roles/cloudkms.cryptoKeyEncrypterDecrypter

    gcloud projects add-iam-policy-binding $PROJECT_ID \
      --member=group:"admin-bot-group@$ORGANIZATION" \
      --role=roles/owner

    gcloud organizations add-iam-policy-binding "$ORGANIZATION_ID" \
      --member="group:admin-bot-group@$ORGANIZATION" \
      --role='roles/compute.xpnAdmin'
    ```

9. Create a Service Account and add the computer.serviceAgent role

   ```bash
   gcloud iam service-accounts create $BIG_ROBOT_NAME \
      --display-name="Authorative Service Account"

   gcloud projects add-iam-policy-binding $PROJECT_ID \
      --member=serviceAccount:"$BIG_ROBOT_EMAIL" \
      --role=roles/compute.serviceAgent \
   ```

10. Add the service account to the admin group:

    ```bash
    gcloud identity groups memberships add \
      --group-email="admin-bot-group@$ORGANIZATION" \
      --member-email=$BIG_ROBOT_EMAIL
    ```

11. Create a KeyRing and a key

    ```bash
    gcloud kms keyrings create $KEYRING --location=$LOCATION

    gcloud kms keys create $KEYRING_KEY \
        --keyring $KEYRING \
        --location $LOCATION \
        --purpose "encryption"
    ```

12. Then we create a service-account key, auth the key and assume the identity. Save the resulting json file as a repo secret called 'TERRAFORM_KEY'.

    ```bash
    gcloud iam service-accounts keys create $KEYRING_KEY \
        --iam-account=$BIG_ROBOT_EMAIL

    gcloud auth activate-service-account "$BIG_ROBOT_EMAIL" \
        --key-file=$(pwd)/$KEYRING_KEY  \
        --project=$PROJECT_ID
    ```

13. Create backend bucket for the state and enable versioning:

    ```bash
    gsutil mb gs://$BACKEND_BUCKET_NAME

    gsutil versioning set on gs://$BACKEND_BUCKET_NAME
    ```

14. Populate the templates. envsubst requires the apt packages `gettext`. Add repo secrets for `ORGANIZATION`, `ORGANIZATION_ID`, and `BILLING ACCOUNT` if using the included workflow.

    ```bash
    envsubst < "backend.tf.template" > "backend.tf"
    envsubst < "terraform.tfvars.template" > "terraform.tfvars"
    envsubst < "providers.tf.template" > "providers.tf"
    ```

15. Init and apply terraform via the command line.

    ```bash
    docker run --platform linux/amd64 -it \
    -v $(pwd):/terraform \
    -w /terraform \
    hashicorp/terraform:latest init

    docker run -it --platform linux/amd64 -it \
    -v $(pwd):/terraform \
    -w /terraform \
    hashicorp/terraform:latest apply
    ```

## GPU Quoata request

- [How to request GPU quota increase in Google Cloud](https://stackoverflow.com/questions/45227064/how-to-request-gpu-quota-increase-in-google-cloud)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp-tf-base"></a> [gcp-tf-base](#module\_gcp-tf-base) | github.com/cloudymax/modules-gcp-tf-base.git | n/a |
| <a name="module_gcp-tf-vm"></a> [gcp-tf-vm](#module\_gcp-tf-vm) | github.com/cloudymax/modules-gcp-tf-vm.git | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_bucket_name"></a> [backend\_bucket\_name](#input\_backend\_bucket\_name) | name of the bucket that will hold the terraform state | `string` | `"slim"` | no |
| <a name="input_big_robot_email"></a> [big\_robot\_email](#input\_big\_robot\_email) | email of the top-level service account | `string` | n/a | yes |
| <a name="input_big_robot_group"></a> [big\_robot\_group](#input\_big\_robot\_group) | group for top-level service accounts | `string` | n/a | yes |
| <a name="input_big_robot_name"></a> [big\_robot\_name](#input\_big\_robot\_name) | Name of the top-level service account | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | the billing account you want all this to go under | `string` | n/a | yes |
| <a name="input_bucket_path_prefix"></a> [bucket\_path\_prefix](#input\_bucket\_path\_prefix) | path to the terrafom state in the bucket | `string` | n/a | yes |
| <a name="input_keyring"></a> [keyring](#input\_keyring) | Name for your keyring decryption key | `string` | n/a | yes |
| <a name="input_keyring_key"></a> [keyring\_key](#input\_keyring\_key) | name for the key you will create in the keyring | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | geographic location/region | `string` | n/a | yes |
| <a name="input_main_availability_zone"></a> [main\_availability\_zone](#input\_main\_availability\_zone) | availability zone within your region/location | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | your GCP organization name | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | gcloud projects describe <project> --format='value(parent.id)' | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | machine readable project name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The human-readbale project name string | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

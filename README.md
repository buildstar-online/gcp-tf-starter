# GCP Starter-Project Template (WiP)

Creates all the basic terraform resources + GHA workflows needed for a new GCP terraform project + a Virtual Machine or Kubernetes Cluster. Clone this repo and follow allong to get quickly bootsrap your own GCP project.

Modules in use:
- [modules-gcp-tf-base](https://github.com/cloudymax/modules-gcp-tf-base)
- [modules-gcp-tf-vm](https://github.com/cloudymax/modules-gcp-tf-vm) (Currently disabled while testing GKE)
- [modules-gcp-tf-gke](https://github.com/cloudymax/modules-gcp-tf-gke)

Workflows included:
- [Run `terraform apply` on merge to main](https://github.com/cloudymax/gcp-tf-starter/blob/main/.github/workflows/apply-on-merge.yml)
- [Run `terraform plan` on pull request](https://github.com/cloudymax/gcp-tf-starter/blob/main/.github/workflows/plan-on-pr.yml)
- [Run `terraform apply` with custom parameters on workflow dispatch](https://github.com/cloudymax/gcp-tf-starter/blob/main/.github/workflows/run-terraform.yml)
- [Run `terraform destroy` on workflow dispatch](https://github.com/cloudymax/gcp-tf-starter/blob/main/.github/workflows/terraform-destroy.yml)
- [Craete an Infracost price estimate on workflow dispatch](https://github.com/cloudymax/gcp-tf-starter/blob/main/.github/workflows/infracost.yml)
- [Update terraform docs on workflow dispatch](https://github.com/cloudymax/gcp-tf-starter/blob/main/.github/workflows/main.yml)

## Prerequisites

1. A Google Cloud Platform Account

   This project uses non-free resources. You will need to sign up for a gcloud account, verify your identity as well as provide a payment method. One of the benefits of wutomating your cloud projects with terraform is the ease with which you may re-create and destroy cloud resources. Make use of this festure to `turn off` your project when it is not in use.

   - [Sign up for Google Cloud and recieved $300 in credits](https://cloud.google.com/free)

2. gCloud CLI
   
   You will need googles cli tool to authenticate your innitial account as well as create some base resources and permissions that will allow terraform to control your project.
   - [Installing the gCloud CLI](https://cloud.google.com/sdk/docs/install)
   - or use the docker container `gcr.io/google.com/cloudsdktool/google-cloud-cli`

3. Terraform

   You will need terraform to manage all of the terraform (obviously). Be aware that terraform doesn't have ARM64 support yet so M1/M2 mac users will need to use the docker version of the cli with the `--platform linux/amd64` flag.
   - [Installing Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   - [Dockerhub images](https://hub.docker.com/r/hashicorp/terraform/)

4. Resource Quotas (Optional)

   GCP as well as most other cloud providers amke use of `Quotas` to limit the amount of resources customers can create. This prevents abuse of their `free-tier` as well as stops customer from accidentially letting autoscaling generate massive bills. If you plan on deploying GPU/TPU accelerators or more than a couple VMs, you will need to request a quota increase for those resources. See below for more information.

   - [How to request GPU quota increase in Google Cloud](https://stackoverflow.com/questions/45227064/how-to-request-gpu-quota-increase-in-google-cloud)

5. Infracost (Optional)

   Infracost shows cloud cost estimates for Terraform. It lets engineers see a cost breakdown and understand costs before making changes, either in the terminal, VS Code or pull requests.
   
   > Infracost isnt working for the `g2-standard` instance family on GCP yet since it's a brand-new machine family that just went live. I have a ticket open [HERE](https://github.com/infracost/infracost/issues/2437) for the issue and have been told it will be addressed in the next release.
   
   - [Infracost Quickstart Guide](https://www.infracost.io/docs/#quick-start)
   - [Run Infracost automatically in your Github Actions Workflows](https://github.com/infracost/actions)
   - [Check out the project out on Github](https://github.com/infracost/infracost)

## Helpful Links

- [GPU models availble on Google Cloud](https://cloud.google.com/compute/docs/gpus#nvidia_gpus_for_compute_workloads)
- [GPU model availability by region](https://cloud.google.com/compute/docs/gpus/gpu-regions-zones)
- [GPU Prices](https://cloud.google.com/compute/gpus-pricing)
- [Virtual Machine types available](https://cloud.google.com/compute/docs/machine-resource)
- [Virtual Mchine Prices](https://cloud.google.com/compute/vm-instance-pricing)

## Get Started

1. Authenticate to Google Cloud

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
   export PROJECT_ID="gpu-cloud-init-project"
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
    -e "GOOGLE_APPLICATION_CREDENTIALS=$KEYRING_KEY" \
    -w /terraform \
    hashicorp/terraform:latest \
    -var="billing_account=$BILLING_ACCOUNT" init

    docker run -it --platform linux/amd64 -it \
    -v $(pwd):/terraform \
    -e "GOOGLE_APPLICATION_CREDENTIALS=$KEYRING_KEY" \
    -e "GOOGLE_PROJECT=$PROJECT_ID" \
    -w /terraform \
    hashicorp/terraform:latest \
    apply \
    -var="billing_account=$BILLING_ACCOUNT" \
    -var="organization=$ORGANIZATION" \
    -var="organization_id=$ORGANIZATION_ID"
    ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.47.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | 4.47.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp-tf-base"></a> [gcp-tf-base](#module\_gcp-tf-base) | github.com/cloudymax/modules-gcp-tf-base.git | n/a |
| <a name="module_modules-gcp-gke"></a> [modules-gcp-gke](#module\_modules-gcp-gke) | github.com/cloudymax/modules-gcp-gke.git | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | set autoscaling true or false | `bool` | `true` | no |
| <a name="input_autoscaling_max_nodes"></a> [autoscaling\_max\_nodes](#input\_autoscaling\_max\_nodes) | max number of nodes allowed | `number` | `1` | no |
| <a name="input_autoscaling_min_nodes"></a> [autoscaling\_min\_nodes](#input\_autoscaling\_min\_nodes) | min number of nodes allocation | `number` | `1` | no |
| <a name="input_autoscaling_strategy"></a> [autoscaling\_strategy](#input\_autoscaling\_strategy) | GKE autoscaling strategy. BALANCED or ANY | `string` | `"ANY"` | no |
| <a name="input_backend_bucket_name"></a> [backend\_bucket\_name](#input\_backend\_bucket\_name) | name of the bucket that will hold the terraform state | `string` | `"slim"` | no |
| <a name="input_big_robot_email"></a> [big\_robot\_email](#input\_big\_robot\_email) | email of the top-level service account | `string` | n/a | yes |
| <a name="input_big_robot_group"></a> [big\_robot\_group](#input\_big\_robot\_group) | group for top-level service accounts | `string` | n/a | yes |
| <a name="input_big_robot_name"></a> [big\_robot\_name](#input\_big\_robot\_name) | Name of the top-level service account | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | the billing account you want all this to go under | `string` | n/a | yes |
| <a name="input_bucket_path_prefix"></a> [bucket\_path\_prefix](#input\_bucket\_path\_prefix) | path to the terrafom state in the bucket | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster we will create | `string` | `"my-cluster"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | default size of the OS Disk for each VM or Node | `number` | `64` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | 'pd-standard', 'pd-balanced' or 'pd-ssd' | `string` | n/a | yes |
| <a name="input_guest_accelerator"></a> [guest\_accelerator](#input\_guest\_accelerator) | GPU or TPU to attach to the virtual-machine. | `string` | n/a | yes |
| <a name="input_guest_accelerator_count"></a> [guest\_accelerator\_count](#input\_guest\_accelerator\_count) | Number of accelerators to attach to each machine | `number` | n/a | yes |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | Number of nodes the GKE cluster starts with | `number` | `1` | no |
| <a name="input_keyring"></a> [keyring](#input\_keyring) | Name for your keyring decryption key | `string` | n/a | yes |
| <a name="input_keyring_key"></a> [keyring\_key](#input\_keyring\_key) | name for the key you will create in the keyring | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | geographic location/region | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The GCP machine type to use for the VM or Nodes | `string` | n/a | yes |
| <a name="input_main_availability_zone"></a> [main\_availability\_zone](#input\_main\_availability\_zone) | availability zone within your region/location | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | your GCP organization name | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | gcloud projects describe <project> --format='value(parent.id)' | `string` | n/a | yes |
| <a name="input_os_image"></a> [os\_image](#input\_os\_image) | Operating system to use on VM's and nodes | `string` | `"ubuntu-os-cloud/ubuntu-2204-lts"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | machine readable project name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The human-readbale project name string | `string` | n/a | yes |
| <a name="input_use_default_node_pool"></a> [use\_default\_node\_pool](#input\_use\_default\_node\_pool) | True=use the deafult GKE node pool, Fale=use seprately managed pool | `bool` | `false` | no |
| <a name="input_userdata"></a> [userdata](#input\_userdata) | Cloud-init user-data.yaml file to apply to each VM or Node | `string` | `"user-data.yaml"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

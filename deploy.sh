cd ./backend/apis/collector &&
  ./deploy.sh

cd ../../../devops/aws &&
  terraform init
  terraform apply
# run-sandbox

1. Run terraform from `terraform/`. The output will include the Artifact registry repo url to use in step 2.
2. Run `gcloud builds submit . --tag <AR REPO URL>` from `app/`
3. Update `service.yaml` with the AR repo URL on line for `image`
4. Run `gcloud run services replace service.yaml` from `/`
5. Run `gcloud run services set-iam-policy nginx-example policy.yaml` from `/`
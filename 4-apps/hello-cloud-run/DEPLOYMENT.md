# Cloud Run end-to-end deployment walkthrough

> This is an **unexecuted example**. Running it can incur Cloud Build, Artifact Registry, and Cloud Run charges. It requires an authenticated, billable GCP project with sufficient permissions. No live deployment is claimed.

## Local build and smoke test

```bash
cd 4-apps/hello-cloud-run
mvn -B clean verify
docker build -t hello-cloud-run:local .
docker run --rm -p 8080:8080 hello-cloud-run:local
# In another terminal
curl --fail http://localhost:8080/api/hello
curl --fail http://localhost:8080/actuator/health
```

## Optional GCP deployment

Set the environment variables to values for **your own** project. Review IAM and pricing first.

```bash
export PROJECT_ID=YOUR_PROJECT_ID
export REGION=us-central1
export REPOSITORY=lab-apps
export SERVICE=hello-cloud-run
export IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${SERVICE}:manual"

gcloud config set project "$PROJECT_ID"
gcloud services enable artifactregistry.googleapis.com cloudbuild.googleapis.com run.googleapis.com
gcloud artifacts repositories create "$REPOSITORY" --repository-format=docker --location="$REGION" --description="Lab images"

# Build and push the Dockerfile into Artifact Registry
gcloud builds submit --tag "$IMAGE" .

# Access remains authenticated by default. Explicitly configure an invoker identity.
gcloud run deploy "$SERVICE" \
    --image="$IMAGE" \
    --region="$REGION" \
    --no-allow-unauthenticated \
    --memory=512Mi --cpu=1 --max-instances=2 --port=8080

SERVICE_URL="$(gcloud run services describe "$SERVICE" --region="$REGION" --format='value(status.url)')"
curl --fail -H "Authorization: Bearer $(gcloud auth print-identity-token)" "$SERVICE_URL/api/hello"
```

Some IAM setups require granting `roles/run.invoker` or using a specific service-account identity. This example does not create those permissions automatically.

## Cleanup

```bash
gcloud run services delete "$SERVICE" --region="$REGION"
gcloud artifacts docker images list "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}"
gcloud artifacts repositories delete "$REPOSITORY" --location="$REGION"
```

Only delete the repository if it belongs entirely to this lab. Check Cloud Build history, Cloud Run services, Artifact Registry and the Billing console to verify there are no leftover billable resources.

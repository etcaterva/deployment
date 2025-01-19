GITHUB_API_BASE_URL=https://api.github.com
org=etcaterva
repo=eas-secret-santa-mail-consumer
version=$1

# https://docs.github.com/en/rest/reference/repos#get-a-release-asset
# GET /repos/{owner}/{repo}/releases/assets/{asset_id}

mkdir -p releases

response_file=releases/releases-${version}.json
response=$(curl -sH "Authorization: Bearer ${GITHUB_TOKEN}" ${GITHUB_API_BASE_URL}/repos/${org}/${repo}/releases/tags/${version} > ${response_file} )

for ext in zip sha256
do
    asset_id=$(cat ${response_file} | jq -r ".assets[] | select(.name == \"eas-email-consumer-${version}.${ext}\") .id")
    asset_name=$(cat ${response_file} | jq -r ".assets[] | select(.name == \"eas-email-consumer-${version}.${ext}\") .name")

    curl ${curl_custom_flags} \
         -L \
         -H "Accept: application/octet-stream" \
         -H "Authorization: Bearer ${GITHUB_TOKEN}" \
            "${GITHUB_API_BASE_URL}/repos/${org}/${repo}/releases/assets/${asset_id}" -o "releases/${asset_name}"
done

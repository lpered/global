#!/bin/sh
set -eu

: "${SNOWFLAKE_ACCOUNT:?SNOWFLAKE_ACCOUNT is required}"
: "${SNOWFLAKE_USER:?SNOWFLAKE_USER is required}"
: "${SNOWFLAKE_PASSWORD:?SNOWFLAKE_PASSWORD is required}"
: "${SNOWFLAKE_ROLE:?SNOWFLAKE_ROLE is required}"
: "${SNOWFLAKE_DATABASE:?SNOWFLAKE_DATABASE is required}"
: "${SNOWFLAKE_WAREHOUSE:?SNOWFLAKE_WAREHOUSE is required}"
: "${SNOWFLAKE_PROD_SCHEMA:?SNOWFLAKE_PROD_SCHEMA is required}"

# Evidence requires source-scoped names. Keep the public stack interface aligned
# with dbt and translate it only within this container.
export EVIDENCE_SOURCE__warehouse__account="${SNOWFLAKE_ACCOUNT}"
export EVIDENCE_SOURCE__warehouse__username="${SNOWFLAKE_USER}"
export EVIDENCE_SOURCE__warehouse__password="${SNOWFLAKE_PASSWORD}"
export EVIDENCE_SOURCE__warehouse__role="${SNOWFLAKE_ROLE}"
export EVIDENCE_SOURCE__warehouse__database="${SNOWFLAKE_DATABASE}"
export EVIDENCE_SOURCE__warehouse__warehouse="${SNOWFLAKE_WAREHOUSE}"
export EVIDENCE_SOURCE__warehouse__schema="${SNOWFLAKE_PROD_SCHEMA}"

npm run build:strict
exec ./node_modules/.bin/serve -s build -l 3000

FROM debian:bullseye-slim
WORKDIR /app
COPY --from=openpolicyagent/opa /opa .
COPY **/*.rego .
COPY **/*.json .
CMD [ "/app/opa" ]

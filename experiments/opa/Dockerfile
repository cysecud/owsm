FROM debian:bullseye-slim
WORKDIR /app
COPY --from=openpolicyagent/opa /opa .
COPY **/*.rego .
CMD [ "/app/opa" ]

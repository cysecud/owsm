FROM scratch
WORKDIR /app
COPY --from=openpolicyagent/opa /opa .
COPY **/*.rego .
COPY **/*.json .
CMD [ "/app/opa" ]

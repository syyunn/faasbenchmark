FROM golang:1.12.17 as builder

RUN mkdir /app 
ADD . /app/
WORKDIR /app 
RUN go build -o faasbenchmark main.go

FROM node:13.8.0-stretch

RUN apt-get update && apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg wget

# add azure cli repo
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
	AZ_REPO=$(lsb_release -cs) && \
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list

# add dotnot repo
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
	mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
	wget -q https://packages.microsoft.com/config/debian/9/prod.list && \
	mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
	chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
	chown root:root /etc/apt/sources.list.d/microsoft-prod.list

RUN npm install -g serverless
RUN apt-get update && apt-get install -y azure-cli dotnet-sdk-3.1 maven azure-functions-core-tools
RUN mkdir /app

COPY --from=builder /app/ /app

CMD /app/faasbenchmark





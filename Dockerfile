FROM swift:5.6

WORKDIR /root/zosconnect-for-swift
COPY . .
RUN swift build

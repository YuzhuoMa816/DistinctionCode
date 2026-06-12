FROM node:18.20-alpine3.19
WORKDIR /app

COPY package.json ./

RUN apk add --no-cache curl && npm install

COPY . .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

CMD ["npm", "start"]
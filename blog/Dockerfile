FROM node:25-alpine

WORKDIR /app

COPY ./blog/package*.json ./

RUN npm install

COPY ./blog/ ./

RUN npm run build

ENV NODE_ENV=production

ENV PORT=3000

EXPOSE 3000

ENTRYPOINT ["npm", "start"]


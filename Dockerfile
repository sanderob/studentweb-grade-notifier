# Image
FROM node:21.7.3-slim as base

FROM base as deps

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Set the working directory
WORKDIR /usr/src/discord-bot

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install the dependencies
RUN npm install

FROM base as prod

# Set the working directory
WORKDIR /usr/src/discord-bot

COPY --from=deps /usr/src/discord-bot/node_modules ./node_modules
COPY --from=deps /usr/local/lib/node_modules ./node_modules

COPY bot.js /usr/src/discord-bot/bot.js
COPY internal/ /usr/src/discord-bot/internal/
COPY commands/ /usr/src/discord-bot/commands/
COPY package*.json /usr/src/discord-bot/

# Start the app
CMD ["node", "."]

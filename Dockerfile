# Image
FROM node:20.10.0-alpine@sha256:e96618520c7db4c3e082648678ab72a49b73367b9a1e7884cf75ac30a198e454 as base

WORKDIR /usr/src/discord-bot

# Install dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    gnupg \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

FROM base as deps

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install the dependencies, including Puppeteer with Chromium
RUN npm ci --omit=dev

FROM base as prod

COPY --from=deps /usr/src/discord-bot/node_modules/ node_modules/
COPY --from=deps /usr/local/lib/node_modules/ node_modules/
COPY --from=deps package*.json ./

COPY bot.js bot.js
COPY commands/ commands/
COPY internal/ internal/
COPY .env .env

# Start the app
CMD ["node", "."]

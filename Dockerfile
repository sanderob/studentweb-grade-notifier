# Image
FROM node:21.7.3-bookworm as base

# Set the working directory
WORKDIR /usr/src/discord-bot

# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    chromium \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

FROM base as deps

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install the dependencies
RUN npm ci --only=production

# Copy the rest of the files
COPY . .

RUN npm run build

FROM base as prod

WORKDIR /usr/src/discord-bot

COPY --from=deps /usr/src/discord-bot/node_modules ./node_modules
COPY --from=deps /usr/local/lib/node_modules ./node_modules
COPY --from=deps /usr/src/discord-bot/dist ./dist

# Start the app
CMD ["node", "."]

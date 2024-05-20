# Image
FROM node:21.7.3-bookworm as base

# Set the working directory
WORKDIR /usr/src/discord-bot

# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

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

# Install the dependencies
RUN npm install --omit=dev 

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

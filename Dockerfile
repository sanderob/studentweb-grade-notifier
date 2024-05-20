# Image
FROM node:20.10.0-alpine@sha256:e96618520c7db4c3e082648678ab72a49b73367b9a1e7884cf75ac30a198e454

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

# Set the working directory
WORKDIR /usr/src/discord-bot

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install the dependencies, including Puppeteer with Chromium
RUN npm ci --omit=dev

# Copy the rest of the files
COPY bot.js bot.js
COPY commands/ commands/
COPY internal/ internal/
COPY deploy_commands.js deploy_commands.js

RUN node deploy_commands.js

# Start the app
CMD ["node", "."]
# Image
FROM node:20.10.0-alpine

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
RUN npm install \
    && npm install puppeteer --save

# Copy the rest of the files
COPY . .

# Start the app
CMD ["node", "."]

# Base image
FROM node:18

# Set working directory
WORKDIR /app

# Copy Strapi app from subfolder
COPY my-strapi-app/ .

# Install dependencies
RUN yarn install

# Build the Strapi app
RUN yarn build

# Expose port
EXPOSE 1337

# Start the app
CMD ["yarn", "start"]

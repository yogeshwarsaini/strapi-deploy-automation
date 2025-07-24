# Step 1: Use node base image
FROM node:20-alpine

# Step 2: Install dependencies
RUN apk add --no-cache python3 make g++ libc6-compat bash

# Step 3: Set working directory
WORKDIR /app

# Step 4: Copy only the Strapi app code
COPY ./my-strapi-app/package*.json ./
# COPY ./my-strapi-app/yarn.lock ./

# Step 5: Install dependencies
RUN yarn install

# Step 6: Copy rest of the app
COPY ./my-strapi-app ./

# Step 7: Build the Strapi app
RUN yarn build

# Step 8: Expose Strapi port
EXPOSE 1337

# Step 9: Start the app
CMD ["yarn", "start"]

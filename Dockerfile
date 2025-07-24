# Step 1: Base image
FROM node:18

# Step 2: Set working directory
WORKDIR /app

# Step 3: Copy only dependency files first
COPY ./my-strapi-app/package.json ./ 
COPY ./my-strapi-app/yarn.lock ./  

# Step 4: Install dependencies
RUN yarn install

# Step 5: Copy full project
COPY ./my-strapi-app/ .

# Step 6: Build the Strapi app
RUN yarn build

# Step 7: Expose port
EXPOSE 1337

# Step 8: Start command
CMD ["yarn", "start"]

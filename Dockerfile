# Stage 1: Build the app
FROM node:16.17.0-alpine as builder

WORKDIR /app

# Copy dependency files
COPY ./package.json ./
COPY ./yarn.lock ./

# Install all dependencies including devDependencies
RUN yarn install --frozen-lockfile --production=false

# Copy application files
COPY . ./

# Set up environment variables for the build process
ARG TMDB_V3_API_KEY=default_key
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the app
RUN yarn build

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

# Clean default Nginx files
RUN rm -rf ./*

# Copy build output from builder stage
COPY --from=builder /app/dist ./

EXPOSE 80

# Start Nginx server
ENTRYPOINT ["nginx", "-g", "daemon off;"]

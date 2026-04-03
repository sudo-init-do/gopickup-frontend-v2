# Stage 1: Build the Flutter Web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy the pubspec files first to leverage Docker caching
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the web app
RUN flutter build web --release --base-href /

# Stage 2: Serve the app with Nginx
FROM public.ecr.aws/nginx/nginx:alpine

# Copy the build output from the builder stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for the final restoration
EXPOSE 80

# Command to run nginx
CMD ["nginx", "-g", "daemon off;"]

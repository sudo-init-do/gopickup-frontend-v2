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

# Copy site-specific nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ensure permissions are correct
RUN chown -R nginx:nginx /usr/share/nginx/html

# Health check to ensure Nginx is responsive before traffic starts flow
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# Expose ports for both standard and alternative routing
EXPOSE 80 3000

# Command to run nginx
CMD ["nginx", "-g", "daemon off;"]

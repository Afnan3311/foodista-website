

FROM nginx:stable-alpine

LABEL maintainer="your-team@example.com"
LABEL description="Foodista static website served via Nginx"

# Remove the default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy Foodista source code
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

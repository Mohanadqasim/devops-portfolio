# Use lightweight Nginx Alpine base image
FROM nginx:alpine

# Copy portfolio static files to Nginx web root
COPY index.html /usr/share/nginx/html/index.html

# Expose HTTP port
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
FROM nginx:alpine

# Copy portfolio website
COPY index.html /usr/share/nginx/html/index.html

# Copy downloadable resume
COPY Mohanad-Qasim-CV.pdf /usr/share/nginx/html/Mohanad-Qasim-CV.pdf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
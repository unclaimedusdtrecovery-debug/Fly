# syntax=docker/dockerfile:1

# Stage 1: Build the application when a Node project is present.
FROM node:18 AS build

WORKDIR /usr/src/app

# Copy the application source into the build context first so dependency installation
# can happen whenever a package.json exists.
COPY . .

# Install dependencies only when a Node app is actually present.
RUN if [ -f package.json ]; then npm install; fi

# Stage 2: Create the final production image.
FROM node:18

WORKDIR /usr/src/app

# Copy the project source from the build stage.
COPY --from=build /usr/src/app ./

ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

# Run the application using the non-root user (recommended for security).
USER node

# Start the app when a package.json is present and can launch the service.
# Otherwise, fall back to a direct Node entrypoint if one exists.
CMD ["sh", "-c", "if [ -f package.json ] && npm run start --if-present >/dev/null 2>&1; then npm run start --if-present; elif [ -f index.js ]; then node index.js; else echo 'No application entrypoint found.' >&2; exit 1; fi"]
